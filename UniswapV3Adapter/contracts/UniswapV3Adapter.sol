// SPDX-License-Identifier: GPL-3.0-only
pragma solidity ^0.8.0;

import "./interfaces/IUniV3Factory.sol";
import "./base/UniswapV3likeAdapter.sol";

/**
 * @title UniswapV2Adapter
 * @author Top-Kraken <topkyle521@gmail.com>
 * @notice Adapter for interacting with Uniswap v3.
 */
contract UniswapV3Adapter is UniswapV3likeAdapter {
    using SafeERC20 for IERC20;

    address immutable FACTORY;
    /// @notice Mapping for the fee amount is enabled
    mapping(uint24 => bool) public isFeeAmountEnabled;
    /// @notice Fee amounts
    uint24[] public feeAmounts;

    /**
     * @dev Initialize the contract by setting a `name`, `swapGasEstimate`, `quoterGasLimit`, `quoter` and `factory`
     * @param _name Name of the adapter
     * @param _swapGasEstimate Swap gas estimate of the adapter
     * @param _quoterGasLimit Quoter gas limit of the adapter
     * @param _quoter Address of the quoter
     * @param _factory Address of the uniswap v3 factory
     */
    constructor(
        string memory _name,
        uint256 _swapGasEstimate,
        uint256 _quoterGasLimit,
        address _quoter,
        address _factory
    ) UniswapV3likeAdapter(_name, _swapGasEstimate, _quoter, _quoterGasLimit) {
        require(_factory != address(0));
        addDefaultFeeAmounts();
        FACTORY = _factory;
    }

    /**
     * @notice Enable fee amounts
     * @param _amounts Array of fee amounts to enable fee
     */
    function enableFeeAmounts(uint24[] calldata _amounts)
        external
        onlyMaintainer
    {
        for (uint256 i; i < _amounts.length; ++i) enableFeeAmount(_amounts[i]);
    }

    /// @notice Called to `msg.sender` after executing a swap via IUniswapV3Pool#swap.
    /// @dev In the implementation you must pay the pool tokens owed for the swap.
    /// The caller of this method must be checked to be a UniswapV3Pool deployed by the canonical UniswapV3Factory.
    /// amount0Delta and amount1Delta can both be 0 if no tokens were swapped.
    /// @param amount0Delta The amount of token0 that was sent (negative) or must be received (positive) by the pool by
    /// the end of the swap. If positive, the callback must send that amount of token0 to the pool.
    /// @param amount1Delta The amount of token1 that was sent (negative) or must be received (positive) by the pool by
    /// the end of the swap. If positive, the callback must send that amount of token1 to the pool.
    function uniswapV3SwapCallback(
        int256 amount0Delta,
        int256 amount1Delta,
        bytes calldata
    ) external {
        if (amount0Delta > 0) {
            IERC20(IUniV3Pool(msg.sender).token0()).transfer(
                msg.sender,
                uint256(amount0Delta)
            );
        } else {
            IERC20(IUniV3Pool(msg.sender).token1()).transfer(
                msg.sender,
                uint256(amount1Delta)
            );
        }
    }

    function addDefaultFeeAmounts() internal {
        addFeeAmount(500);
        addFeeAmount(3000);
        addFeeAmount(10000);
    }

    /**
     * @notice Enable fee amount
     * @param _fee Fee amount to enable
     */
    function enableFeeAmount(uint24 _fee) internal {
        require(!isFeeAmountEnabled[_fee], "Fee already enabled");
        if (IUniV3Factory(FACTORY).feeAmountTickSpacing(_fee) == 0)
            revert("Factory doesn't support fee");
        addFeeAmount(_fee);
    }

    /**
     * @notice Add fee amount and enable
     * @param _fee Fee amount to add and enable
     */
    function addFeeAmount(uint24 _fee) internal {
        isFeeAmountEnabled[_fee] = true;
        feeAmounts.push(_fee);
    }

    /**
     * @notice Given token0 and token, returns the best pool
     */
    function getBestPool(address token0, address token1)
        internal
        view
        override
        returns (address mostLiquid)
    {
        uint128 deepestLiquidity;
        for (uint256 i; i < feeAmounts.length; ++i) {
            address pool = IUniV3Factory(FACTORY).getPool(
                token0,
                token1,
                feeAmounts[i]
            );
            if (pool == address(0)) continue;
            uint128 liquidity = IUniV3Pool(pool).liquidity();
            if (liquidity > deepestLiquidity) {
                deepestLiquidity = liquidity;
                mostLiquid = pool;
            }
        }
    }
}
