# BinaryMarket Module

## Overview

Market module for Binary Game product.
Contract module that allow players to bet on the price changes of the certain token and win the reward.

## How to Use
1. Deploy smart contract via `Bunzz`. When deploying, the deployer must set default values of the `oracle`, `vault`, `marketName`, `timeframes`, `adminAddress`, `operatorAddress` and `minBetAmount`.
2. Admin can call `setOracle`, `setName`, `setOperator`, `setTimeframes`, `setMinBetAmount` and `setAdmin` functions to update those configuration variables of the Game.
2. Operator can call `genesisStartRound`, `genesisLockRound`, `executeRound` and `setPause` functions to update those configuration variables.
3. Users can call `openPosition`, `claim` and `claimBatch` functions to bet and receive the rewards of the game.
4. Users can call `getExecutableTimeframes`, `getUserRounds`, `getCurrentUserRoundNumber`, `isBettable`, `getUnderlyingToken`, `refundable`, `isClaimable` and `isNecessaryToExecute` to query the current status of the game.

## Functions

### **openPosition**

External function to Bet bull/bear position depending on the current price.
The amount of the token user betted will go to vault.

```solidity
function openPosition(
    uint256 amount,
    uint8 timeframeId,
    Position position
) external;
```


| Input params | Details |
| ------------ | ------- |
| amount     |  Bet amount of the underlying token      |
| timeframeId     |  Id of 1m/5m/10m     |
| position     |  Enum variable represents bull/bear      |


### **claim**

External function to claim winning rewards.

```solidity
function claim(uint8 timeframeId, uint256 epoch) external;
```


| Input params | Details |
| ------------ | ------- |
| timeframeId     |  Timeframe ID to claim winning rewards      |
| epoch     |  Round id     |


### **claimBatch**

External function to claim mutliple winning rewards.

```solidity
function claimBatch(
    uint8[] calldata timeframeIds,
    uint256[][] calldata epochs
) external;
```


| Input params | Details |
| ------------ | ------- |
| timeframeIds     |  Timeframe IDs to claim winning rewards      |
| epochs     |  Round ids for each timeframe     |


### **executeRound**

External function to Start the next round n, lock price for round n-1, end round n-2.

```solidity
function executeRound(
    uint8[] calldata timeframeIds,
    uint256 price
) external;
```


| Input params | Details |
| ------------ | ------- |
| timeframeIds     |  Timeframe IDs to close the betting and calculate the winners and rewards.      |
| price     |  The price of the current timestamp     |


### **getExecutableTimeframes**

External function to Start the next round n, lock price for round n-1, end round n-2.

```solidity
function getExecutableTimeframes() external view returns(uint8[] memory, uint256);
```


| Input params | Details |
| ------------ | ------- |
| result     |  Timeframe IDs which are active      |
| count     |  The number of timeframe IDs     |



### **getUnderlyingToken**

External function to get the underlying token used to bet & win the rewards.

```solidity
function getUnderlyingToken() external view returns (IERC20);
```


| Input params | Details |
| ------------ | ------- |
| underlyingToken     |  ERC20 token used to bet and rewards      |

