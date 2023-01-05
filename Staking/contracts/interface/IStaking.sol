// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

/**
 * @dev Interface of Refundable Escrow
 * @notice Require to use with Ownable contract
 */
interface IStaking {
  event Stake(address indexed user, uint256 amount);
  event ReStake(address indexed user, uint256 amount);
  event DepositReward(address indexed user, uint256 amount);
  event UnStake(address indexed user, uint256 amount);
  event Harvest(address indexed user, uint256 amount, uint256 harvestFee);
  event SetFeeWallet(address indexed _feeWallet);
  event SetHarvestFee(uint256 _harvestFee);

  function depositReward(uint256 _amount) external;
  function getPending(address _user) external view returns (uint256);
  function getRewardBalance() external view returns (uint256);

  function stake(uint256 _amount) external;
  function unStake(uint256 _amount) external;
  function harvest(bool reStake) external;
}
