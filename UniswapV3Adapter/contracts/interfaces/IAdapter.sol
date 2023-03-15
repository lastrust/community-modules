// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/**
 * @title IAdapter
 * @author Top-Kraken <topkyle521@gmail.com>
 * @notice Provides interface for the adapters of the DexAggregator
 */
interface IAdapter {
    /**
     * @notice Executes trades from `tokenIn` to `tokenOut` with `amountIn` and `amountOut`.
     * @param _amountIn Amount of tokenIn to be converted
     * @param _amountOut Amount of tokenOut received for amountIn of tokenIn
     * @param _tokenIn Address of an ERC20 token contract to be converted
     * @param _tokenOut Address of an ERC20 token contract to convert into
     * @param _to Address that receive amountOut of tokenOut token
     */
    function swap(
        uint256 _amountIn,
        uint256 _amountOut,
        address _tokenIn,
        address _tokenOut,
        address _to
    ) external;

    /// @notice Name of the Adapter
    function name() external view returns (string memory);

    /// @notice Swap Gas Estimate of the Adapter
    function swapGasEstimate() external view returns (uint256);

    /**
     * @notice Find the path from `tokenIn` to `tokenOut` with `amountIn`.
     * @param _amountIn Amount of tokenIn to be converted
     * @param _tokenIn Address of an ERC20 token contract to be converted
     * @param _tokenOut Address of an ERC20 token contract to convert into
     */
    function query(
        uint256 _amountIn,
        address _tokenIn,
        address _tokenOut
    ) external view returns (uint256);
}
