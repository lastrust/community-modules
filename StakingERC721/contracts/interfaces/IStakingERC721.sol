// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

interface IStakingERC721 {
  function balanceOf(address account) external view returns (uint256);

  function earned(address account) external view returns (uint256);

  function getRewardForDuration() external view returns (uint256);

  function lastTimeRewardApplicable() external view returns (uint256);

  function rewardPerToken() external view returns (uint256);

  function stake(uint256[] memory tokenIds) external;

  function unstake(uint256[] memory tokenIds) external;

  function claim() external;

  function exit(uint256[] memory tokenIds) external;
}
