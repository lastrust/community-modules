// SPDX-License-Identifier: MIT

pragma solidity ^0.8.10;
/**
 * @dev Contract module that provides price data to binary game written by writer.
 */
interface IBinaryOracle {
    /**
     * @notice Struct of price data for each round
     * @param roundId Id of the round data
     * @param timestamp Timestamp of the round
     * @param price Price of round, based 1e18
     * @param writer Address of the price / round writer
     */
    struct Round {
        uint256 roundId;
        uint256 timestamp;
        uint256 price;
        address writer;
    }

    /**
     * @notice External function that records a new price round
     * @dev This function is only permitted to writters
     * @param roundId Round ID should be greater than last round id
     * @param timestamp Timestamp should be greater than last round's time, and less then current time.
     * @param price Price of round, based 1e18
     */
    function writePrice(
        uint256 roundId,
        uint256 timestamp,
        uint256 price
    ) external;

    /**
     * @notice External function that records new prices for multiple rounds
     * @dev This function is only permitted to writters
     * @param roundIds Array of round ids
     * @param timestamps Array of timestamps
     * @param prices Array of prices
     */
    function writeBatchPrices(
        uint256[] calldata roundIds,
        uint256[] calldata timestamps,
        uint256[] calldata prices
    ) external;

    /**
     * @notice External function that returns the price and timestamp by round id
     * @param roundId The ID of the target Round to get the price and timestamp
     * @return timestamp Round Time
     * @return price Round price
     */
    function getRoundData(uint256 roundId)
        external
        view
        returns (uint256 timestamp, uint256 price);

    /**
     * @notice External function that returns the whole round data of the latest round
     * @return latestRoundData Round data of the last round
     */
    function getLatestRoundData()
        external
        view
        returns (Round memory);
}
