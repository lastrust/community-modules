// SPDX-License-Identifier: GPL-3.0-only
pragma solidity ^0.8.0;

import "../interfaces/IERC20.sol";
import "../interfaces/IUniV3Pool.sol";
import "../lib/SafeERC20.sol";
import "./BaseAdapter.sol";

struct QParams {
    address tokenIn;
    address tokenOut;
    int256 amountIn;
    uint24 fee;
}

/**
 * @title UniswapV3likeAdapter
 * @notice Base Adapter for Uniswap V3 like adapters
 */
abstract contract UniswapV3likeAdapter is BaseAdapter {
    using SafeERC20 for IERC20;

    uint160 internal constant MAX_SQRT_RATIO =
        1461446703485210103287273052203988822378723970342;
    uint160 internal constant MIN_SQRT_RATIO = 4295128739;
    /// @notice Quoter gas limit
    uint256 public quoterGasLimit;
    /// @notice Address of the quoter
    address public quoter;

    /**
     * @dev Initialize the contract by setting a `name`, `swapGasEstimate`, `quoter` and `quoterGasEstimate`.
     * @param _name Name of the adapter
     * @param _swapGasEstimate Swap gas estimate of the adpater
     * @param _quoter Quoter of the adapter
     * @param _quoterGasLimit Quoter gas limit of the adapter
     */
    constructor(
        string memory _name,
        uint256 _swapGasEstimate,
        address _quoter,
        uint256 _quoterGasLimit
    ) BaseAdapter(_name, _swapGasEstimate) {
        require(_quoter != address(0));
        setQuoterGasLimit(_quoterGasLimit);
        setQuoter(_quoter);
    }

    /**
     * @notice Returns quote-format for the given `pool`, `amountIn`, `tokenIn` and `tokenOut`.
     * @param pool Address of the pool
     * @param amountIn Amount of tokenIn to be converted
     * @param tokenIn Address of an ERC20 token contract to be converted
     * @param tokenOut Address of an ERC20 token contract to convert into
     */
    function getQuoteForPool(
        address pool,
        int256 amountIn,
        address tokenIn,
        address tokenOut
    ) external view returns (uint256) {
        QParams memory params;
        params.amountIn = amountIn;
        params.tokenIn = tokenIn;
        params.tokenOut = tokenOut;
        return getQuoteForPool(pool, params);
    }

    /**
     * @notice Update new quoter
     * @param newQuoter Address of the new quoter
     */
    function setQuoter(address newQuoter) public onlyMaintainer {
        require(newQuoter != address(0));
        quoter = newQuoter;
    }

    /**
     * @notice Update quoter gas limit
     * @param newLimit New quoter gas limit
     */
    function setQuoterGasLimit(uint256 newLimit) public onlyMaintainer {
        require(newLimit != 0, "queryGasLimit can't be zero");
        quoterGasLimit = newLimit;
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
    ) internal view override returns (uint256 quote) {
        QParams memory params = getQParams(_amountIn, _tokenIn, _tokenOut);
        quote = getQuoteForBestPool(params);
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
        QParams memory params = getQParams(_amountIn, _tokenIn, _tokenOut);
        uint256 amountOut = _underlyingSwap(params, new bytes(0));
        require(amountOut >= _amountOut, "Insufficient amountOut");
        _returnTo(_tokenOut, amountOut, _to);
    }

    /**
     * @notice Returns the quote-format
     */
    function getQParams(
        uint256 amountIn,
        address tokenIn,
        address tokenOut
    ) internal pure returns (QParams memory params) {
        params = QParams({
            amountIn: int256(amountIn),
            tokenIn: tokenIn,
            tokenOut: tokenOut,
            fee: 0
        });
    }

    /**
     * @notice Given a QParam, swap the tokens
     * @param params Quote-format param
     * @param callbackData Callback data
     */
    function _underlyingSwap(QParams memory params, bytes memory callbackData)
        internal
        virtual
        returns (uint256)
    {
        address pool = getBestPool(params.tokenIn, params.tokenOut);
        (bool zeroForOne, uint160 priceLimit) = getZeroOneAndSqrtPriceLimitX96(
            params.tokenIn,
            params.tokenOut
        );
        (int256 amount0, int256 amount1) = IUniV3Pool(pool).swap(
            address(this),
            zeroForOne,
            int256(params.amountIn),
            priceLimit,
            callbackData
        );
        return zeroForOne ? uint256(-amount1) : uint256(-amount0);
    }

    /**
     * @notice Returns the quote of the best pool
     */
    function getQuoteForBestPool(QParams memory params)
        internal
        view
        returns (uint256 quote)
    {
        address bestPool = getBestPool(params.tokenIn, params.tokenOut);
        if (bestPool != address(0)) quote = getQuoteForPool(bestPool, params);
    }

    /**
     * @notice Given token0 and token, returns the best pool
     */
    function getBestPool(address token0, address token1)
        internal
        view
        virtual
        returns (address mostLiquid);

    /**
     * @notice Returns the quote for the pool
     */
    function getQuoteForPool(address pool, QParams memory params)
        internal
        view
        returns (uint256)
    {
        (bool zeroForOne, uint160 priceLimit) = getZeroOneAndSqrtPriceLimitX96(
            params.tokenIn,
            params.tokenOut
        );
        (int256 amount0, int256 amount1) = getQuoteSafe(
            pool,
            zeroForOne,
            params.amountIn,
            priceLimit
        );
        return zeroForOne ? uint256(-amount1) : uint256(-amount0);
    }

    /// @notice Returns the quote
    function getQuoteSafe(
        address pool,
        bool zeroForOne,
        int256 amountIn,
        uint160 priceLimit
    ) internal view returns (int256 amount0, int256 amount1) {
        bytes memory calldata_ = abi.encodeWithSignature(
            "quote(address,bool,int256,uint160)",
            pool,
            zeroForOne,
            amountIn,
            priceLimit
        );
        (bool success, bytes memory data) = staticCallQuoterRaw(calldata_);
        if (success) (amount0, amount1) = abi.decode(data, (int256, int256));
    }

    function staticCallQuoterRaw(bytes memory calldata_)
        internal
        view
        returns (bool success, bytes memory data)
    {
        (success, data) = quoter.staticcall{gas: quoterGasLimit}(calldata_);
    }

    function getZeroOneAndSqrtPriceLimitX96(address tokenIn, address tokenOut)
        internal
        pure
        returns (bool zeroForOne, uint160 sqrtPriceLimitX96)
    {
        zeroForOne = tokenIn < tokenOut;
        sqrtPriceLimitX96 = zeroForOne
            ? MIN_SQRT_RATIO + 1
            : MAX_SQRT_RATIO - 1;
    }
}
