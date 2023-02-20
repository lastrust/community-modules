# KyberAdapter Module

## Overview

KyberAdapter server as a common interface for external contracts to perform queries and swaps for Kyber DMM Pools.
DexAggregator can use adapter to find the best offer between two assets for a given amount and execute this offer. It also accounts for query & swap gas-cost of the offer and for that needs gasEstimate from the adapter.

## How to Use
1. Deploy smart contract via `Bunzz`. When deploying, users can specify name, factory address, fee and swapGasEstimate.
2. Users can call `query` function to perform queries (find the best offer) betwen two assets for a given amount.
3. Users can also call `swap` function to perform swaps between two assets for a given amount.

## Functions

### `query`

Find the path from `tokenIn` to `tokenOut` with `amountIn`.

| name        | type             | description                   |
| :---        |    :----:        |          ---:                 |
| amountIn    |uint256           | Amount of tokens being sold   |
| tokenIn     |address           | ERC20 token being sold        |
| tokenOut    |address           | ERC20 token being bought      |

### `swap`

Executes trades from `tokenIn` to `tokenOut` with `amountIn` and `amountOut`.

| name        | type             | description                   |
| :---        |    :----:        |          ---:                 |
| amountIn    |uint256           | Amount of tokens being sold   |
| amountOut   |uint256           | Amount of tokens being bought |
| tokenIn     |address           | ERC20 token being sold        |
| tokenOut    |address           | ERC20 token being bought      |
| to          |address           | Receiver address              |

### `setSwapGasEstimate`

Set the swap gas estimate for KyberAdapter. Only can called by `maintainer`.

### `revokeAllowance`

Revoke the allowance for the `token` and `spender`. Only can called by `maintainer`.

### `recoverERC20`

Recover ERC-20 token. Only can called by `maintainer`.

### `recoverETH`

Recover native token. Only can called by `maintainer`.

## Events

### `BaseAdapterSwap`
```
event BaseAdapterSwap(address indexed _tokenFrom, address indexed _tokenTo, uint256 _amountIn, uint256 _amountOut);
```

Emitted when swap is finished.

| name        | type             | description                   |
| :---        |    :----:        |          ---:                 |
| _tokenFrom  |address           | ERC20 token being sold        |
| _tokenTo    |address           | ERC20 token being bought      |
| _amountIn   |uint256           | Amount of tokens being sold   |
| _amountOut  |uint256           | Amount of tokens being bought |

### `UpdatedGasEstimate`
```
event UpdatedGasEstimate(address indexed _adapter, uint256 _newEstimate);
```

Emitted when swap gas estimate is updated.

| name        | type             | description                   |
| :---        |    :----:        |          ---:                 |
| _adapter    |address           | Adapter address               |
| _newEstimate|uint256           | Updated swap gas estimate     |

### `Recovered`
```
event Recovered(address indexed _asset, uint256 amount);
```

Emitted when recover is called.

| name        | type             | description                   |
| :---        |    :----:        |          ---:                 |
| _asset      |address           | Recovered token address       |
| amount      |uint256           | Recovered amount              |