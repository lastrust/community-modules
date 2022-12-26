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

contract StakingRewards is IStakingRewards, Ownable, Pausable, ReentrancyGuard {
  using SafeERC20 for IERC20;

  IERC20 public stakingToken;
  IERC20 public rewardsToken;
  uint256 public periodFinish;
  uint256 public rewardRate;
  uint256 public rewardsDuration = 7 days;
  uint256 public lastUpdateTime;
  uint256 public rewardPerTokenStored;

  mapping(address => uint256) public userRewardPerTokenPaid;
  mapping(address => uint256) public rewards;

  uint256 private totalSupply;
  mapping(address => uint256) private balances;

  /* -------------------------------------------------------------------------- */
  /*                                   Events                                   */
  /* -------------------------------------------------------------------------- */

  event Staked(address indexed account, uint256 amount);
  event Unstaked(address indexed account, uint256 amount);
  event Claimed(address indexed account, uint256 amount);
  event Funded(uint256 amount);
  event RewardsDurationUpdated(uint256 duration);
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

  constructor(address rewardsToken_, address stakingToken_, uint256 duration) {
    rewardsToken = IERC20(rewardsToken_);
    stakingToken = IERC20(stakingToken_);
    rewardsDuration = duration;
  }

  function setPaused(bool newPaused) external onlyOwner {
    if (newPaused) {
      _pause();
    } else {
      _unpause();
    }
  }

  function setRewardsDuration(uint256 duration) external onlyOwner {
    if (block.timestamp < periodFinish) {
      revert WaitToFinish();
    }
    rewardsDuration = duration;
    emit RewardsDurationUpdated(duration);
  }

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

  function claim() public nonReentrant whenNotPaused updateReward(msg.sender) {
    uint256 reward = rewards[msg.sender];
    if (reward > 0) {
      rewards[msg.sender] = 0;
      rewardsToken.safeTransfer(msg.sender, reward);
      emit Claimed(msg.sender, reward);
    }
  }

  function exit() public whenNotPaused {
    unstake(balances[msg.sender]);
    claim();
  }

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

  function balanceOf(address account) external view returns (uint256) {
    return balances[account];
  }

  function lastTimeRewardApplicable() external view returns (uint256) {
    return _lastTimeRewardApplicable();
  }

  function rewardPerToken() external view returns (uint256) {
    return _rewardPerToken();
  }

  function earned(address account) external view returns (uint256) {
    return _earned(account);
  }

  function getRewardForDuration() external view returns (uint256) {
    return rewardRate * rewardsDuration;
  }
}
