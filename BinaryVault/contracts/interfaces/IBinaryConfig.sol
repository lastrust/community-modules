// SPDX-License-Identifier: MIT

pragma solidity ^0.8.10;

interface IBinaryConfig {
    function setTradingFee(uint256 newTradingFee) external;

    function setClaimNoticePeriod(uint256 newNoticePeriod) external;

    function setTreasury(address newTreasury) external;

    function getFeeBase() external pure returns (uint256);
    function getTradingFee() external view returns (uint256);
    function getClaimNoticePeriod() external view returns (uint256);
    function getTreasury() external view returns (address);
}
