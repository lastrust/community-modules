// SPDX-License-Identifier: MIT

pragma solidity ^0.8.10;

interface IBinaryOracle {
    struct Round {
        uint256 roundId;
        uint256 timestamp;
        uint256 price;
        address writer;
    }

    function writePrice(
        uint256 roundId,
        uint256 timestamp,
        uint256 price
    ) external;

    function writeBatchPrices(
        uint256[] calldata roundIds,
        uint256[] calldata timestamps,
        uint256[] calldata prices
    ) external;

    function getRoundData(uint256 roundId)
        external
        view
        returns (uint256 timestamp, uint256 price);

    function getLatestRoundData()
        external
        view
        returns (Round memory);
}
