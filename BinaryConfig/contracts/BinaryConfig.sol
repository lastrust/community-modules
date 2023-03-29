// SPDX-License-Identifier: MIT

pragma solidity ^0.8.10;

import "@openzeppelin/contracts/access/Ownable.sol";

import "./interfaces/IBinaryConfig.sol";

// Common Errors
error ZERO_ADDRESS();

contract BinaryConfig is Ownable, IBinaryConfig {
    uint256 public constant FEE_BASE = 10_000;
    /// @dev Trading fee should be paid when winners claim their rewards, see claim function of Market
    uint256 public tradingFee;
    /// @dev Winners should claim their winning rewards within claim notice period
    uint256 public claimNoticePeriod;
    /// @dev treasury wallet
    address public treasury;

    event TradingFeeChanged(uint256 indexed fee);
    event ClaimNoticeChanged(uint256 indexed period);
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
    
    function setTradingFee(uint256 newTradingFee) external override onlyOwner {
        require(newTradingFee < FEE_BASE, "BinaryConfig: Too high");
        tradingFee = newTradingFee;

        emit TradingFeeChanged(newTradingFee);
    }

    function setClaimNoticePeriod(uint256 newNoticePeriod) external override onlyOwner {
        claimNoticePeriod = newNoticePeriod;

        emit ClaimNoticeChanged(newNoticePeriod);
    }

    function setTreasury(address newTreasury) external override onlyOwner {
        if (newTreasury == address(0)) revert ZERO_ADDRESS();
        treasury = newTreasury;

        emit TreasuryChanged(newTreasury);
    }

    function getFeeBase() external pure returns (uint256) {
        return FEE_BASE;
    }

    function getTradingFee() external view returns (uint256) {
        return tradingFee;
    }

    function getClaimNoticePeriod() external view returns (uint256) {
        return claimNoticePeriod;
    }

    function getTreasury() external view returns (address) {
        return treasury;
    }
}
