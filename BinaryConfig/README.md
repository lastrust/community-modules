# BinaryConfig Module

## Overview

Config module for Binary Game product.
Contract module that provides basic configuration for the Price Games. One BinaryConfig can serve multiple Price Games.

## How to Use
1. Deploy smart contract via `Bunzz`. When deploying, the deployer must set default values of the `tradingFee`, `claimNoticePeriod` and `treasury`.
2. Owner can call `setTradingFee`, `setClaimNoticePeriod` and `setTreasury` functions to update those configuration variables.
3. Users can call `getFeeBase`, `getTradingFee`, `getClaimNoticePeriod` and `getTreasury` functions to query the configuratino details.

## Functions

### **setTradingFee**

External function that set new trading fee callable by owner.

```solidity
function setTradingFee(uint256 newTradingFee) external;
```


| Input params | Details |
| ------------ | ------- |
| newTradingFee     |  New value for the trading fee for later games      |


### **setClaimNoticePeriod**

External function that set new claim notice period callable by owner.

```solidity
function setClaimNoticePeriod(uint256 newNoticePeriod) external;
```


| Input params | Details |
| ------------ | ------- |
| newNoticePeriod     |  New value for the claim notice period for later games      |


### **setTreasury**

External function that set new treasury wallet callable by owner.

```solidity
function setTreasury(address newTreasury) external;
```


| Input params | Details |
| ------------ | ------- |
| newTreasury     |  New address of the treasury for later games      |


### **getFeeBase**

External function to query the FEE_BASE constant value.

```solidity
function getFeeBase() external pure returns (uint256);
```


| Return values | Details |
| ------------ | ------- |
| FEE_BASE     |  Constant value equal to 10000      |

### **getTradingFee**

External function to query the trading fee value

```solidity
function getTradingFee() external view returns (uint256);
```


| Return values | Details |
| ------------ | ------- |
| tradingFee     |  Game fee for the winner      |
### **getClaimNoticePeriod**

External function to query the claim notice period value

```solidity
function getClaimNoticePeriod() external view returns (uint256);
```


| Return values | Details |
| ------------ | ------- |
| claimNoticePeriod     |  Notice period for the winner to claim their reward      |
### **getTreasury**

External function to query the treasury wallet address value

```solidity
function getTreasury() external view returns (address);
```


| Return values | Details |
| ------------ | ------- |
| treasury     |  Wallet address of the treasury      |
