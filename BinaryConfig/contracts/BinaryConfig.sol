// SPDX-License-Identifier: MIT

pragma solidity ^0.8.10;

import "@openzeppelin/contracts/access/Ownable.sol";

import "./interfaces/IBinaryConfig.sol";

// Common Errors
error ZERO_ADDRESS();

/**
 * @dev Contract module that provides basic configuration for the Price Games. One BinaryConfig can serve multiple Price Games.
 */
contract BinaryConfig is Ownable, IBinaryConfig {
    uint256 public constant FEE_BASE = 10_000;
    /// @dev Trading fee should be paid when winners claim their rewards, see claim function of Market
    uint256 public tradingFee;
    /// @dev Winners should claim their winning rewards within claim notice period
    uint256 public claimNoticePeriod;
    /// @dev treasury wallet
    address public treasury;

    /// @dev Emit this event when updating trading fee
    event TradingFeeChanged(uint256 indexed fee);
    /// @dev Emit this event when updating claim notice period
    event ClaimNoticeChanged(uint256 indexed period);
    /// @dev Emit this event when updating treasury wallet
    event TreasuryChanged(address indexed newTreasury);

    constructor(
        uint16 tradingFee_,
        uint256 claimNoticePeriod_,
        address treasury_
    ) {
        require(tradingFee_ < FEE_BASE, "BinaryConfig: Too high");
        require(treasury_ != address(0), "BinaryConfig: Invalid address");
        tradingFee = tradingFee_; // 10% as default
        claimNoticePeriod = claimNoticePeriod_;
        treasury = treasury_;
    }

    /**
     * @notice External function that set new trading fee callable by owner
     * @dev This function is only permitted to owner
     * @param newTradingFee New value for the trading fee for later games
     */
    function setTradingFee(uint256 newTradingFee) external override onlyOwner {
        require(newTradingFee < FEE_BASE, "BinaryConfig: Too high");
        tradingFee = newTradingFee;

        emit TradingFeeChanged(newTradingFee);
    }

    /**
     * @notice External function that set new claim notice period callable by owner
     * @dev This function is only permitted to owner
     * @param newNoticePeriod New value for the claim notice period for later games
     */
    function setClaimNoticePeriod(uint256 newNoticePeriod) external override onlyOwner {
        claimNoticePeriod = newNoticePeriod;

        emit ClaimNoticeChanged(newNoticePeriod);
    }

    /**
     * @notice External function that set new treasury wallet callable by owner
     * @dev This function is only permitted to owner
     * @param newTreasury New address of the treasury for later games
     */
    function setTreasury(address newTreasury) external override onlyOwner {
        if (newTreasury == address(0)) revert ZERO_ADDRESS();
        treasury = newTreasury;

        emit TreasuryChanged(newTreasury);
    }

    /**
     * @notice External function to query the FEE_BASE constant value
     * @return FEE_BASE Constant value equal to 10000
     */
    function getFeeBase() external pure returns (uint256) {
        return FEE_BASE;
    }

    /**
     * @notice External function to query the trading fee value
     * @return tradingFee Game fee for the winner
     */
    function getTradingFee() external view returns (uint256) {
        return tradingFee;
    }

    /**
     * @notice External function to query the claim notice period value
     * @return claimNoticePeriod Notice period for the winner to claim their reward
     */
    function getClaimNoticePeriod() external view returns (uint256) {
        return claimNoticePeriod;
    }

    /**
     * @notice External function to query the treasury wallet address value
     * @return treasury Wallet address of the treasury
     */
    function getTreasury() external view returns (address) {
        return treasury;
    }
}
