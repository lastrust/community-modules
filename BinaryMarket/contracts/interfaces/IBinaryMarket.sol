// SPDX-License-Identifier: MIT

pragma solidity ^0.8.10;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

interface IBinaryMarket {
    enum Position {
        Bull,
        Bear
    }
    
    struct TimeFrame {
        uint8 id;
        uint256 interval;
        uint256 intervalBlocks;
        uint256 bufferBlocks;
    }

    /**
     * @dev Bet bull/bear position
     * @param amount Bet amount
     * @param timeframeId id of 1m/5m/10m
     * @param position bull/bear
     */
    function openPosition(
        uint256 amount,
        uint8 timeframeId,
        Position position
    ) external;

    /**
     * @notice claim winning rewards
     * @param timeframeId Timeframe ID to claim winning rewards
     * @param epoch round id
     */
    function claim(uint8 timeframeId, uint256 epoch) external;

    /**
     * @notice Batch claim winning rewards
     * @param timeframeIds Timeframe IDs to claim winning rewards
     * @param epochs round ids
     */
    function claimBatch(uint8[] calldata timeframeIds, uint256[][] calldata epochs)
        external;

    /**
     * @dev Start the next round n, lock price for round n-1, end round n-2
     * @param timeframeIds Timeframe IDs to close the betting and calculate the winners and rewards.
     * @param price The price of the current timestamp
     */
    function executeRound(
        uint8[] calldata timeframeIds,
        uint256 price
    ) external;

    /**
     * @dev Check if bet is active and returns the avaialble timeframe IDs
     * @return result Timeframe IDs which are active.
     * @return count The number of timeframe IDs
     */
    function getExecutableTimeframes() external view returns(uint8[] memory, uint256);

    /**
    * @dev Get the underlying token used to bet & win the rewards
    * @return underlyingToken ERC20 token used to bet and rewards
    */
    function getUnderlyingToken() external view returns (IERC20);
}
