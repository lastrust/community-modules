# Staking

## Overview

This is a staking module.
Staking contracts are widely used to stabilize token prices by locking certain tokens into contracts and increasing TVLs.
One ERC20 token is used for staking and rewards.
The user will receive compensation in proportion to amount of token that he staked.

## How to use
1. Need to calculate the rewardPerBlock.
This contract uses block number instead of time.
Now you want to run this contract with X (total reward amount) token for a year, and the contract will be deployed on Ethereum mainnet.
In ethereum network, the block time is about 12 sec.
Then for a year, the number of total block is :
```angular2html
blockCount = 365 * 24 * 3600 / 12;
```
The rewardPerBlock is :
```angular2html
rewardPerBlock = X / blockCount;
```

2. Deploy this contract with token address, rewardPerBlock, feeWallet, maxFeePercent and harvestFeePercent.
If you don't want the harvest fee, you can use Zero address for feeWallet and set the harvestFeePercent to Zero.
3. Deposit reward tokens for users.
When the reward balance is 0, users can't stake. So prefer you deposit X tokens when you are going to start the staking service.
4. Now users can stake with their tokens.
5. Users can unstake whenever they want.
6. Users can harvest when they want.
At same time, they will pay harvest fee if the owner set the harvest fee.
7. When users harvest their reward tokens, they can restake with the reward token.
In this case, they don't pay the harvest fee.

## Functions

| Function Name    | Action | Description                               | Permission |
|:-----------------|:-------|:------------------------------------------|------------|
| setFeeWallet     | write  | Set fee wallet by contract owner          | onlyOwner  |
| setHarvestFee    | write  | Set harvest fee percent by contract owner | onlyOwner  |
| depositReward    | write  | Deposit reward token by contract owner    | onlyOwner  |
| stake            | write  | Stake tokens by users                     | any        |
| unStake          | write  | UnStake by users                          | any        |
| harvest          | write  | Harvest by users                          | any        |
| getPending       | read   | Return reward amount of target user       | any        |
| getRewardBalance | read   | Return current reward balance in contract | any        |


### Function I/O parameters

1) setFeeWallet - onlyOwner
   Set fee wallet by contract owner

| name       |  type   | description         |
|:-----------|:-------:|:--------------------|
| _feeWallet | address | fee wallet address  |

2) setHarvestFee - onlyOwner
   Set harvest fee percent by contract owner

| name        |  type   | description         |
|:------------|:-------:|:--------------------|
| _feePercent | uint256 | harvest fee percent |

3) depositReward - onlyOwner
   Deposit reward token by contract owner

| name    |  type   | description             |
|:--------|:-------:|:------------------------|
| _amount | uint256 | Reward amount for users |

4) stake
   Stake tokens by users

| name    |  type   | description        |
|:--------|:-------:|:-------------------|
| _amount | uint256 | Amount for staking |

5) unStake

| name    |  type   | description          |
|:--------|:-------:|:---------------------|
| _amount | uint256 | Amount for unStaking |

6) harvest
   Deposit reward token by contract owner

| name     | type | description               |
|:---------|:----:|:--------------------------|
| _reStake | bool | If restake, true or false |

7) getPending
   Return current reward amount of target user.

| name  |  type   | description         |
|:------|:-------:|:--------------------|
| _user | address | target user address |

8) getPending
   Return current reward balance in contract.

## Events
```
  event Stake(address indexed user, uint256 amount);
  event ReStake(address indexed user, uint256 amount);
  event DepositReward(address indexed user, uint256 amount);
  event UnStake(address indexed user, uint256 amount);
  event Harvest(address indexed user, uint256 amount, uint256 harvestFee);
  event SetFeeWallet(address indexed _feeWallet);
  event SetHarvestFee(uint256 _harvestFee);
```

## Parameters

##### _stkToken
Target ERC20 token address for staking and rewards.

##### _rewardPerBlock
reward amount per block

##### _feeWallet
fee wallet address for harvest fee.

##### __maxFeePercent
max fee percent

##### _harvestFee
harvest fee percent
1000 means 100%
so if you want to set the fee percent to 5%, feePercent is 50


# Bunzz-Staking
