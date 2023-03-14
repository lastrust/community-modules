// SPDX-License-Identifier: GPL-3.0-only
pragma solidity ^0.8.0;

import "./interfaces/IUniswapFactory.sol";
import "./interfaces/IUniswapPair.sol";
import "./interfaces/IERC20.sol";
import "./lib/SafeERC20.sol";
import "./base/BaseAdapter.sol";

/**
 * @title UniswapV2Adapter
 * @author Top-Kraken <topkyle521@gmail.com>
 * @notice Adapter for interacting with Uniswap v2.
 */
contract UniswapV2Adapter is BaseAdapter {
    using SafeERC20 for IERC20;

    /// @notice Fee dominator (1000)
    uint256 internal constant FEE_DENOMINATOR = 1e3;
    /// @notice Fee complement
    uint256 public immutable feeCompliment;
    /// @notice Address for Uniswap v2 factory
    address public immutable factory;

    /**
     * @dev Initialize the contract by setting a `name`, `factory`, `fee` and `swapGasEstimate`.
     * @param _name Name of the Adapter
     * @param _factory Address of the uniswap v2 factory
     * @param _fee Fee of the adapter
     * @param _swapGasEstimate Swap gas estimate for the adapter
     */
    constructor(
        string memory _name,
        address _factory,
        uint256 _fee,
        uint256 _swapGasEstimate
    ) BaseAdapter(_name, _swapGasEstimate) {
        require(
            _factory != address(0),
            "You should set the UniswapV2Factory address"
        );
        require(_fee <= FEE_DENOMINATOR, "Invalid fee value");
        feeCompliment = FEE_DENOMINATOR - _fee;
        factory = _factory;
    }

    /**
     * @notice Returns the amount out based on the amountIn, reserveIn, reserveOut and the fee
     * @param _amountIn Amount of the input
     * @param _reserveIn Reserved input
     * @param _reserveOut Reserved output
     */
    function _getAmountOut(
        uint256 _amountIn,
        uint256 _reserveIn,
        uint256 _reserveOut
    ) internal view returns (uint256 amountOut) {
        // Based on https://github.com/Uniswap/uniswap-v2-periphery/blob/master/contracts/UniswapV2Router02.sol
        uint256 amountInWithFee = _amountIn * feeCompliment;
        uint256 numerator = amountInWithFee * _reserveOut;
        uint256 denominator = _reserveIn * FEE_DENOMINATOR + amountInWithFee;
        amountOut = numerator / denominator;
    }

    /**
     * @notice Get the query based on tokenIn and tokenOut and returns the amount out for the input
     * @param _amountIn Amount of tokenIn to be converted
     * @param _tokenIn Address of an ERC20 token contract to be converted
     * @param _tokenOut Address of an ERC20 token contract to convert into
     */
    function _query(
        uint256 _amountIn,
        address _tokenIn,
        address _tokenOut
    ) internal view override returns (uint256 amountOut) {
        if (_tokenIn == _tokenOut || _amountIn == 0) {
            return 0;
        }
        address pair = IUniswapFactory(factory).getPair(_tokenIn, _tokenOut);
        if (pair == address(0)) {
            return 0;
        }
        (uint256 r0, uint256 r1, ) = IUniswapPair(pair).getReserves();
        (uint256 reserveIn, uint256 reserveOut) = _tokenIn < _tokenOut
            ? (r0, r1)
            : (r1, r0);
        if (reserveIn > 0 && reserveOut > 0) {
            amountOut = _getAmountOut(_amountIn, reserveIn, reserveOut);
        }
    }

    /**
     * @notice Given a token and its amount, send the equivalent value in another token
     * @param _amountIn Amount of tokenIn to be converted
     * @param _amountOut Amount of tokenOut received for amountIn of tokenIn
     * @param _tokenIn Address of an ERC20 token contract to be converted
     * @param _tokenOut Address of an ERC20 token contract to convert into
     * @param _to Address that receive amountOut of tokenOut token
     */
    function _swap(
        uint256 _amountIn,
        uint256 _amountOut,
        address _tokenIn,
        address _tokenOut,
        address _to
    ) internal override {
        address pair = IUniswapFactory(factory).getPair(_tokenIn, _tokenOut);
        (uint256 amount0Out, uint256 amount1Out) = (_tokenIn < _tokenOut)
            ? (uint256(0), _amountOut)
            : (_amountOut, uint256(0));
        IERC20(_tokenIn).safeTransfer(pair, _amountIn);
        IUniswapPair(pair).swap(amount0Out, amount1Out, _to, new bytes(0));
    }
}
