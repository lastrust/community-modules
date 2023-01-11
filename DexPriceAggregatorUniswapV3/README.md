# DEXPriceAggregatorUniswapV3 Module

## Overview
A DEX-based price oracle aggregating spot and TWAP rates from Uniswap V3 that selects the worser rate between spot and TWAP.

Able to handle queries for asset prices across an intermediate liquidity pool (e.g. WBTC -> WETH -> USDC).

Useful for all price queries:

- Reverts if no pool route is found for the given `tokenIn` and `tokenOut`
- Reverts if `twapPeriod` is `0`
- Reverts if the `twapPeriod` is too large for the underlying pool's history. In this case, you will have to increase the history stored by the pool by calling `UniswapV3Pool#increaseObservationCardinalityNext()` (see [v3 whitepaper section 5.1](https://uniswap.org/whitepaper-v3.pdf)).

## How to Use
1. Deploy smart contract via `Bunzz`
2. When deploy, specify UniswapV3Factory address, wrapped native token address (for example, for Ethereum, WETH address), and default pool fee (for example 3000).
3. Users can set pool for the route using `setPoolForRoute` function.
4. Users can query prices using `assetToAsset`, `assetToEth`, `ethToAsset` functions.

## Functions

### `assetToAsset()`

Query price of one asset in another asset.

Example query:

- `tokenIn`: [`0x2260FAC5E5542a773Aa44fBCfeDf7C193bc2C599`](https://etherscan.io/address/0x2260fac5e5542a773aa44fbcfedf7c193bc2c599) (WBTC)
- `amountIn`: `100000000` (1 WBTC; 8 decimals)
- `tokenOut`: [`0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48`](https://etherscan.io/address/0xa0b86991c6218b36c1d19d4a2e9eb0ce3606eb48) (USDC)
- `twapPeriod`: `1800` (30min)

Outputs ~`50099000000` (50099 USDC) as the WBTC/USDC price on 09-03-2021.

### `assetToEth()`

Query price of asset in ETH.

Example query:

- `tokenIn`: [`0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48`](https://etherscan.io/address/0xa0b86991c6218b36c1d19d4a2e9eb0ce3606eb48) (USDC)
- `amountIn`: `1000000000` (1000 USDC; 6 decimals)
- `twapPeriod`: `1800` (30min)

Outputs ~`254000000000000000` (0.254 ETH) as the USDC/ETH price on 09-03-2021.

### `ethToAsset()`

Query price of ETH in asset.

Example query:

- `ethAmountIn`: `1000000000000000000` (1 ETH; 18 decimals)
- `tokenOut`: [`0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48`](https://etherscan.io/address/0xa0b86991c6218b36c1d19d4a2e9eb0ce3606eb48) (USDC)
- `twapPeriod`: `1800` (30min)

Outputs ~`3912000000` (3912 USDC) as the ETH/USDC price on 09-03-2021.

### `setPoolForRoute()`

Set the pool to query for a given `tokenIn` and `tokenOut`.

This can be used to configure the oracle to query alternative pools (e.g. 5bps fee pools) instead of the default pool. It can also be used to configure a direct `tokenIn` to `tokenOut` pool for tokens that would have normally crossed with an intermediate pool (e.g. `WBTC -> USDC` instead of `WBTC -> WETH -> USDC`).