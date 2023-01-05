// SPDX-License-Identifier: UNLICENSED

/**
 *Submitted for verification at BscScan.com on 2022-02-17
*/

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import  "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import  "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

import  "./interface/IStaking.sol";


contract Staking is Ownable, IStaking {
  using SafeERC20 for IERC20;

  // Info of each user.
  struct UserInfo {
    uint256 amount;
    uint256 rewardDebt;
    uint256 pendingAmount;
  }
  
  IERC20 public immutable stkToken;
  address public feeWallet;


  uint256 public lastRewardBlock;
  uint256 public rewardPerBlock;
  uint256 private _accSTKPerShare;

  uint256 public totalStakedAmount;
  uint256 private _rewardBalance;

  uint128 public harvestFee;
  uint128 private _maxFeePercent;

  // Info of each user that stakes LP tokens.
  mapping (address => UserInfo) public userInfo;
  
  constructor(
    IERC20 _stkToken,
    uint256 _rewardPerBlock,
    address _feeWallet,
    uint128 __maxFeePercent,
    uint128 _harvestFee
  ) {
    require(__maxFeePercent < 1000);
    require(_harvestFee <= __maxFeePercent);
    stkToken = _stkToken;
    rewardPerBlock = _rewardPerBlock;
    feeWallet = _feeWallet;
    _maxFeePercent = __maxFeePercent;
    harvestFee = _harvestFee;
  }

  /**
   * @dev Used to set the fee wallet address
   * @param _feeWallet The address of fee wallet
   */
  function setFeeWallet(address _feeWallet) external onlyOwner {
    feeWallet = _feeWallet;
    emit SetFeeWallet(feeWallet);
  }

  /**
   * @dev Set the harvest fee. 100% is 1000
   * @param _feePercent The harvest fee percent
   */
  function setHarvestFee(uint128 _feePercent) external onlyOwner {
    require(_feePercent <= _maxFeePercent, "setHarvestFee: feePercent invalid");
    harvestFee = _feePercent;
    emit SetHarvestFee(_feePercent);
  }

  /**
   * @dev Deposit reward token by owner.
   * @param _amount The amount of token.
   */
  function depositReward(uint256 _amount) external override onlyOwner {
    stkToken.safeTransferFrom(msg.sender, address(this), _amount);
    _rewardBalance = _rewardBalance + _amount;
    emit DepositReward(msg.sender, _amount);
  }

  function _getMultiplier(uint256 _from, uint256 _to) private pure returns (uint256) {
    return _to - _from;
  }

  /**
   * @dev Get pending reward of user.
   * @param _user The address of target user
   * @return return pending reward amount of user.
   */
  function getPending(address _user) public view override returns (uint256) {
    uint256 pending = _getPending(_user);
    uint256 _harvestFee = pending * harvestFee / 1000;
    return pending - _harvestFee;
  }

  function _getPending(address _user) private view returns (uint256) {
    UserInfo storage user = userInfo[_user];
    uint256 acc = _accSTKPerShare;
    if (block.number > lastRewardBlock && totalStakedAmount != 0 && _rewardBalance > 0) {
      uint256 reward = _getReward();
      acc = acc + reward * 1e12 / totalStakedAmount;
    }
    return user.amount * acc / 1e12 - user.rewardDebt + user.pendingAmount;
  }

  function _getReward() private view returns (uint256) {
    if (_getMultiplier(lastRewardBlock, block.number) <= _rewardBalance / rewardPerBlock) {
      return _getMultiplier(lastRewardBlock, block.number) * rewardPerBlock;
    } else {
      return _rewardBalance;
    }
  }

  /**
   * @dev Get available reward balance for users.
   * @return return reward balance.
   */
  function getRewardBalance() external view override returns (uint256) {
    if (block.number > lastRewardBlock && totalStakedAmount != 0) {
      uint256 reward = _getReward();
      return _rewardBalance - reward;
    }
    else {
      return _rewardBalance;
    }
  }

  /**
   * @dev Update this contract status (rewardBalance, lastRewardBlock, _accSTKPerShare).
   */
  function _updateStatus() private {
    if (block.number <= lastRewardBlock) {
      return;
    }
    if (totalStakedAmount == 0) {
      lastRewardBlock = block.number;
      return;
    }
    if (_rewardBalance == 0) {
      lastRewardBlock = block.number;
      return;
    }
    uint256 reward = _getReward();
    _rewardBalance = _rewardBalance - reward;
    _accSTKPerShare = _accSTKPerShare + reward * 1e12 / totalStakedAmount;
    lastRewardBlock = block.number;
  }

  /**
   * @dev Stake tokens by user.
   * @param _amount The token amount for staking.
   */
  function stake(uint256 _amount) external override {
    require(_rewardBalance > 0, "rewardBalance is 0");
    UserInfo storage user = userInfo[msg.sender];
    _updateStatus();
    if (user.amount > 0) {
      uint256 pending = user.amount * _accSTKPerShare / 1e12 - user.rewardDebt;
      user.pendingAmount = user.pendingAmount + pending;
    }
    stkToken.safeTransferFrom(msg.sender, address(this), _amount);
    totalStakedAmount = totalStakedAmount + _amount;
    user.amount = user.amount + _amount;
    user.rewardDebt = user.amount * _accSTKPerShare / 1e12;
    emit Stake(msg.sender, _amount);
  }

  /**
   * @dev UnStake tokens by user.
   * @param _amount The token amount for staking.
   */
  function unStake(uint256 _amount) external override {
    UserInfo storage user = userInfo[msg.sender];
    require(user.amount >= _amount, "unStake: amount invalid");
    _updateStatus();
    uint256 pending = user.amount * _accSTKPerShare / 1e12 - user.rewardDebt;
    user.pendingAmount = user.pendingAmount + pending;
    user.amount = user.amount - _amount;
    user.rewardDebt = user.amount * _accSTKPerShare / 1e12;

    stkToken.safeTransfer(msg.sender, _amount);
    totalStakedAmount = totalStakedAmount - _amount;
    emit UnStake(msg.sender, _amount);
  }

  /**
   * @dev harvest tokens by user.
   * @param reStake If restake, True or False.
   */
  function harvest(bool reStake) external override {
    uint256 rewardAmount = _getPending(msg.sender);

    if (reStake) {
      require(_rewardBalance > 0, "rewardBalance is 0");
      UserInfo storage user = userInfo[msg.sender];
      totalStakedAmount = totalStakedAmount - user.amount;
      _updateStatus();
      user.pendingAmount = 0;
      user.amount = user.amount + rewardAmount;
      totalStakedAmount = totalStakedAmount + user.amount;
      user.rewardDebt = user.amount * _accSTKPerShare / 1e12;
      emit ReStake(msg.sender, rewardAmount);
    } else {
      UserInfo storage user = userInfo[msg.sender];
      uint256 _harvestFee = rewardAmount * harvestFee / 1000;
      uint256 amount = rewardAmount - _harvestFee;
      
      stkToken.safeTransfer(msg.sender, amount);
      stkToken.safeTransfer(feeWallet, _harvestFee);
      
      emit Harvest(msg.sender, amount, _harvestFee);

      _updateStatus();
      user.pendingAmount = 0;
      user.rewardDebt = user.amount * _accSTKPerShare / 1e12;
    }
  }
}
