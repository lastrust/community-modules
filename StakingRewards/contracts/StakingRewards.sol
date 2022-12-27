// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

// Uncomment this line to use console.log
// import "hardhat/console.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {SafeERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import {Pausable} from "@openzeppelin/contracts/security/Pausable.sol";
import {ReentrancyGuard} from "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import {IStakingRewards} from "./interfaces/IStakingRewards.sol";

error ZeroAmount();
error WaitToFinish();
error NotEnoughBalance();
error TooHighReward();
error FailedToWithdrawStaking();

/**
 * Stakes tokens for a certain duration and gets rewards according to their
 * staked shares
 */
contract StakingRewards is IStakingRewards, Ownable, Pausable, ReentrancyGuard {
  using SafeERC20 for IERC20;

  // Address to staking ERC20 token
  IERC20 public stakingToken;
  // Address to rewards ERC20 token
  IERC20 public rewardsToken;
  // Block timestamp of the end of reward session
  uint256 public periodFinish;
  // Reward rate
  uint256 public rewardRate;
  // Rewards duration in seconds
  uint256 public rewardsDuration = 7 days;
  // Last timestamp of funding in seconds
  uint256 public lastUpdateTime;
  // Accumulated rewards token
  uint256 public rewardPerTokenStored;

  // Mapping for accumulated rewards token as temporary store
  mapping(address => uint256) public userRewardPerTokenPaid;
  // Mapping for rewards amount, <user account, rewards amount>
  mapping(address => uint256) public rewards;

  // Total staked token amount
  uint256 private totalSupply;
  // Balances of staked token per user
  mapping(address => uint256) private balances;

  /* -------------------------------------------------------------------------- */
  /*                                   Events                                   */
  /* -------------------------------------------------------------------------- */

  /**
   * Emitted when user stakes staking token
   */
  event Staked(address indexed account, uint256 amount);
  /**
   * Emited when user unstakes his/her staked token
   */
  event Unstaked(address indexed account, uint256 amount);
  /**
   * Emitted when user claim his/her rewards token
   */
  event Claimed(address indexed account, uint256 amount);
  /**
   * Emitted when owner funds rewards token and restart rewarding session
   */
  event Funded(uint256 amount);
  /**
   * Emitted when rewards duration has been updated
   */
  event RewardsDurationUpdated(uint256 duration);
  /**
   * Emitted when owner recovered tokens from this contract
   */
  event Recovered(address token, uint256 amount);

  /* -------------------------------------------------------------------------- */
  /*                                  Modifier                                  */
  /* -------------------------------------------------------------------------- */

  modifier updateReward(address account) {
    rewardPerTokenStored = _rewardPerToken();
    lastUpdateTime = _lastTimeRewardApplicable();
    if (account != address(0)) {
      rewards[account] = _earned(account);
      userRewardPerTokenPaid[account] = rewardPerTokenStored;
    }
    _;
  }

  /* -------------------------------------------------------------------------- */
  /*                             External Functions                             */
  /* -------------------------------------------------------------------------- */

  /**
   * @dev Constructor
   * @param rewardsToken_ Address to rewards ERC20 token
   * @param stakingToken_ Address to staking ERC20 token
   * @param duration Reward duration in seconds
   */
  constructor(address rewardsToken_, address stakingToken_, uint256 duration) {
    rewardsToken = IERC20(rewardsToken_);
    stakingToken = IERC20(stakingToken_);
    rewardsDuration = duration;
  }

  function connectToOtherContracts(
    address[] memory otherContracts
  ) external override onlyOwner {}

  /**
   * @notice Pause or unpause contract
   * @dev Callable by owner
   * @param newPaused Flag to new paused state
   */
  function setPaused(bool newPaused) external onlyOwner {
    if (newPaused) {
      _pause();
    } else {
      _unpause();
    }
  }

  /**
   * @notice Set rewards duration, only available to set after finish
   * of previous rewards period.
   * @dev Callable by owner
   * @param duration New rewards duration
   */
  function setRewardsDuration(uint256 duration) external onlyOwner {
    if (block.timestamp < periodFinish) {
      revert WaitToFinish();
    }
    rewardsDuration = duration;
    emit RewardsDurationUpdated(duration);
  }

  /**
   * @notice Stake staking token, callable only when unpaused.
   * Every staked balance per user will be accumulated and it transfers tokens
   * from user to this contract.
   * @dev Callable only when unpaused
   * @param amount Staking amount
   */
  function stake(
    uint256 amount
  ) public nonReentrant whenNotPaused updateReward(msg.sender) {
    if (amount <= 0) {
      revert ZeroAmount();
    }
    totalSupply += amount;
    balances[msg.sender] += amount;
    stakingToken.safeTransferFrom(msg.sender, address(this), amount);
    emit Staked(msg.sender, amount);
  }

  /**
   * @notice Unstake staking token, callable only when unpaused.
   * Staked balance per user will be reduced and it transfers tokens back from
   * this contract to the user.
   * @dev Callable only when unpaused
   * @param amount Unstaking amount
   */
  function unstake(
    uint256 amount
  ) public nonReentrant whenNotPaused updateReward(msg.sender) {
    if (amount <= 0) {
      revert ZeroAmount();
    }
    if (balances[msg.sender] < amount) {
      revert NotEnoughBalance();
    }
    totalSupply -= amount;
    balances[msg.sender] -= amount;
    stakingToken.safeTransfer(msg.sender, amount);
    emit Unstaked(msg.sender, amount);
  }

  /**
   * @notice Claim rewards tokens, callable only when unpaused.
   * @dev Callable only when unpaused
   */
  function claim() public nonReentrant whenNotPaused updateReward(msg.sender) {
    uint256 reward = rewards[msg.sender];
    if (reward > 0) {
      rewards[msg.sender] = 0;
      rewardsToken.safeTransfer(msg.sender, reward);
      emit Claimed(msg.sender, reward);
    }
  }

  /**
   * @notice Claim rewards tokens and unstake staked amount.
   * @dev Callable only when unpaused.
   */
  function exit() public whenNotPaused {
    unstake(balances[msg.sender]);
    claim();
  }

  /**
   * @notice Fund rewards tokens and re-calculate rewards rate.
   * Rewards rate will be calculated again from remaining distributable tokens
   * and awarding rewards tokens.
   * @dev Callable only when unpaused and by owner
   * @param reward Funding rewards token amount
   */
  function fund(
    uint256 reward
  ) public onlyOwner whenNotPaused updateReward(address(0)) {
    if (block.timestamp >= periodFinish) {
      rewardRate = reward / rewardsDuration;
    } else {
      uint256 remaining = periodFinish - block.timestamp;
      uint256 leftover = remaining * rewardRate;
      rewardRate = (reward + leftover) / rewardsDuration;
    }

    // Ensure the provided reward amount is not more than the balance in the contract.
    // This keeps the reward rate in the right range, preventing overflows due to
    // very high values of rewardRate in the earned() and rewardsPerToken()
    // Reward + leftover must be less than 2^256 / 10^18 to avoid overflow.
    rewardsToken.safeTransferFrom(msg.sender, address(this), reward);
    uint256 balance = rewardsToken.balanceOf(address(this));
    if (rewardRate > balance / rewardsDuration) {
      revert TooHighReward();
    }

    lastUpdateTime = block.timestamp;
    periodFinish = block.timestamp + rewardsDuration;

    emit Funded(reward);
  }

  /**
   * @notice Transfer ERC20 tokens back from this contract to the owner
   * except staking token.
   * @dev Callable by owner
   * @param tokenAddress Recovering token address
   * @param tokenAmount Recovering token amount
   */
  function recoverERC20(
    address tokenAddress,
    uint256 tokenAmount
  ) external onlyOwner {
    if (tokenAddress == address(stakingToken)) {
      revert FailedToWithdrawStaking();
    }
    IERC20(tokenAddress).safeTransfer(owner(), tokenAmount);
    emit Recovered(tokenAddress, tokenAmount);
  }

  /* -------------------------------------------------------------------------- */
  /*                             Internal Functions                             */
  /* -------------------------------------------------------------------------- */

  function _lastTimeRewardApplicable() internal view returns (uint256) {
    return block.timestamp < periodFinish ? block.timestamp : periodFinish;
  }

  function _rewardPerToken() internal view returns (uint256) {
    if (totalSupply == 0) {
      return rewardPerTokenStored;
    }
    return
      rewardPerTokenStored +
      ((_lastTimeRewardApplicable() - lastUpdateTime) * rewardRate * 1e18) /
      totalSupply;
  }

  function _earned(address account) internal view returns (uint256) {
    return
      (balances[account] *
        (_rewardPerToken() - userRewardPerTokenPaid[account])) /
      1e18 +
      rewards[account];
  }

  /* -------------------------------------------------------------------------- */
  /*                               View Functions                               */
  /* -------------------------------------------------------------------------- */

  /**
   * @param account User address
   * @return Returns balance of staked amount per user.
   */
  function balanceOf(address account) external view returns (uint256) {
    return balances[account];
  }

  /**
   * @return Returns last time to calculate rewards.
   * If now is less than the last time, returns now.
   */
  function lastTimeRewardApplicable() external view returns (uint256) {
    return _lastTimeRewardApplicable();
  }

  /**
   * @return Returns total amount of calculated rewards.
   */
  function rewardPerToken() external view returns (uint256) {
    return _rewardPerToken();
  }

  /**
   * @param account User address
   * @return Returns earned rewards per user.
   */
  function earned(address account) external view returns (uint256) {
    return _earned(account);
  }

  /**
   * @return Returns total rewards amount for current duration.
   */
  function getRewardForDuration() external view returns (uint256) {
    return rewardRate * rewardsDuration;
  }
}
