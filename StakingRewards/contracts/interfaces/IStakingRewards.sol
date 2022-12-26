// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

interface IStakingRewards {
  function balanceOf(address account) external view returns (uint256);

  function earned(address account) external view returns (uint256);

  function getRewardForDuration() external view returns (uint256);

  function lastTimeRewardApplicable() external view returns (uint256);

  function rewardPerToken() external view returns (uint256);

  function stake(uint256 amount) external;

  function unstake(uint256 amount) external;

  function claim() external;

  function exit() external;
}
