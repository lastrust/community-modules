// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/**
 * @notice Uniswap V2 Pair
 */
interface IUniswapPair {
    /**
     * @param sender address of sender
     * @param amount0In input amount of token0
     * @param amount1In input amount of token1
     * @param amount0Out out amount of token0
     * @param amount1Out out amount of token1
     * @param to destination address
     **/
    event Swap(
        address indexed sender,
        uint256 amount0In,
        uint256 amount1In,
        uint256 amount0Out,
        uint256 amount1Out,
        address indexed to
    );

    /**
     * @param amount0Out out amount of token0
     * @param amount1Out out amount of token1
     * @param to destintion address
     * @param data bytes data
     **/
    function swap(
        uint256 amount0Out,
        uint256 amount1Out,
        address to,
        bytes calldata data
    ) external;

    /**
     * @dev return factory
     **/
    function factory() external view returns (address);

    /**
     * @dev return token0
     **/
    function token0() external view returns (address);

    /**
     * @dev return token1
     **/
    function token1() external view returns (address);

    /**
     * @return reserve0 reserve amount of token0
     * @return reserve1 reserve amount of token1
     * @return blockTimestampLast last block timestamp
     * @dev get reserve info
     **/
    function getReserves()
        external
        view
        returns (
            uint112 reserve0,
            uint112 reserve1,
            uint32 blockTimestampLast
        );
}
