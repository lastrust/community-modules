// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

// Uncomment this line to use console.log
import "hardhat/console.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {IERC721} from "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import {IERC721Receiver} from "@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol";
import {SafeERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import {Pausable} from "@openzeppelin/contracts/security/Pausable.sol";
import {ReentrancyGuard} from "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import {IBunzz} from "./interfaces/IBunzz.sol";
import {IStakingERC721} from "./interfaces/IStakingERC721.sol";

error NoTokenIds();
error WaitToFinish();
error NotTokenOwner();
error NotEnoughBalance();
error TooHighReward();
error FailedToWithdrawStaking();

/**
 * Stakes tokens for a certain duration and gets rewards according to their
 * staked shares
 */
contract StakingERC721 is
  IBunzz,
  IStakingERC721,
  IERC721Receiver,
  Ownable,
  Pausable,
  ReentrancyGuard
{
  using SafeERC20 for IERC20;

  // Address to staking ERC721 token
  IERC721 public stakingToken;
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
  uint256 public totalSupply;
  // Balances of staked token per user
  mapping(address => uint256) public balances;
  // Mapping of staker/depositor of the token
  mapping(uint256 => address) public stakedAssets;

  /* -------------------------------------------------------------------------- */
  /*                                   Events                                   */
  /* -------------------------------------------------------------------------- */

  /**
   * Emitted when user stakes staking token
   */
  event Staked(address indexed account, uint256 amount, uint256[] tokenIds);
  /**
   * Emited when user unstakes his/her staked token
   */
  event Unstaked(address indexed account, uint256 amount, uint256[] tokenIds);
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
    stakingToken = IERC721(stakingToken_);
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
   * @notice Stakes user's NFTs
   * @dev Callable only when unpaused
   * @param tokenIds The tokenIds of the NFTs which will be staked
   */
  function stake(
    uint256[] memory tokenIds
  ) public nonReentrant whenNotPaused updateReward(msg.sender) {
    if (tokenIds.length == 0) {
      revert NoTokenIds();
    }

    uint256 amount;
    uint256 length = tokenIds.length;
    for (uint256 i = 0; i < length; ++i) {
      // Transfer user's NFTs to the staking contract
      stakingToken.safeTransferFrom(msg.sender, address(this), tokenIds[i]);
      // Increment the amount which will be staked
      ++amount;
      // Save who is the staker/depositor of the token
      stakedAssets[tokenIds[i]] = msg.sender;
    }
    _stake(amount);
    emit Staked(msg.sender, amount, tokenIds);
  }

  /**
   * @notice Unstake staked user's NFTs
   * @dev Callable only when unpaused
   * @param tokenIds The tokenIds of the NFTs which will be withdrawn
   */
  function unstake(
    uint256[] memory tokenIds
  ) public nonReentrant whenNotPaused updateReward(msg.sender) {
    if (tokenIds.length == 0) {
      revert NoTokenIds();
    }

    uint256 amount;
    uint256 length = tokenIds.length;
    for (uint256 i = 0; i < length; ++i) {
      // Check if the user who withdraws is the owner
      if (stakedAssets[tokenIds[i]] != msg.sender) {
        revert NotTokenOwner();
      }
      // Transfer NFTs back to the owner
      stakingToken.safeTransferFrom(address(this), msg.sender, tokenIds[i]);
      // Increment the amount which will be withdrawn
      ++amount;
      // Cleanup stakedAssets for the current tokenId
      stakedAssets[tokenIds[i]] = address(0);
    }
    _unstake(amount);

    emit Unstaked(msg.sender, amount, tokenIds);
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
  function exit(uint256[] memory tokenIds) public whenNotPaused {
    unstake(tokenIds);
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

  function onERC721Received(
    address operator,
    address from,
    uint256 tokenId,
    bytes calldata data
  ) external returns (bytes4) {
    return this.onERC721Received.selector;
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

  function _stake(uint256 _amount) internal {
    totalSupply += _amount;
    balances[msg.sender] += _amount;
  }

  function _unstake(uint256 _amount) internal {
    totalSupply -= _amount;
    balances[msg.sender] -= _amount;
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
