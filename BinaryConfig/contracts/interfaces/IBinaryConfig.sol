// SPDX-License-Identifier: MIT

pragma solidity ^0.8.10;

interface IBinaryConfig {
    /**
     * @notice External function that set new trading fee callable by owner
     * @dev This function is only permitted to owner
     * @param newTradingFee New value for the trading fee for later games
     */
    function setTradingFee(uint256 newTradingFee) external;

    /**
     * @notice External function that set new claim notice period callable by owner
     * @dev This function is only permitted to owner
     * @param newNoticePeriod New value for the claim notice period for later games
     */
    function setClaimNoticePeriod(uint256 newNoticePeriod) external;

    /**
     * @notice External function that set new treasury wallet callable by owner
     * @dev This function is only permitted to owner
     * @param newTreasury New address of the treasury for later games
     */
    function setTreasury(address newTreasury) external;

    /**
     * @notice External function to query the trading fee value
     * @return tradingFee Game fee for the winner
     */
    function getTradingFee() external view returns (uint256);

    /**
     * @notice External function to query the claim notice period value
     * @return claimNoticePeriod Notice period for the winner to claim their reward
     */
    function getClaimNoticePeriod() external view returns (uint256);

    /**
     * @notice External function to query the treasury wallet address value
     * @return treasury Wallet address of the treasury
     */
    function getTreasury() external view returns (address);

    /**
     * @notice External function to query the FEE_BASE constant value
     * @return FEE_BASE Constant value equal to 10000
     */
    function getFeeBase() external pure returns (uint256);
}
