# StakingERC721

## Overview

The repository contains contracts for farming with any ERC721 compatible NFTs.
Any specified ERC-721 can be used to farm any ERC-20 compatible tokens, by depositing/locking them into the ERC721Staking contract that uses ERC-721 instead of the normal ERC-20 token.
NFT owners can stake or unstake their NFTs at any time.

## How to use

1. Prepares staking token(ERC721), rewards token(ERC20) address, and rewards duration.
2. Owner funds rewards token.
3. Users can stake staking tokens, rewards amount will be calculated by shares.
4. Users can unstake tokens if requires or exit staking.
5. Users can claim rewards anytime.
6. Owner can fund again after rewards duration.

## Functions

### WRITE

#### setPaused

Pause or unpaused contract.

| name      | type |              description |
| :-------- | :--: | -----------------------: |
| newPaused | bool | Flag to new paused state |

#### setRewardsDuration

Set rewards duration, only available to set after finish of previous rewards period.

| name     |  type   |          description |
| :------- | :-----: | -------------------: |
| duration | uint256 | New rewards duration |

#### stake

Stake staking token, callable only when unpaused.
Every staked balance per user will be accumulated and it transfers tokens from user to this contract.

| name     |       type       |        description |
| :------- | :--------------: | -----------------: |
| tokenIds | uint256[] memory | Array of token Ids |

#### unstake

Unstake staking token, callable only when unpaused.
Staked balance per user will be reduced and it transfers tokens back from this contract to the user.

| name     |       type       |        description |
| :------- | :--------------: | -----------------: |
| tokenIds | uint256[] memory | Array of token Ids |

#### claim

Claim rewards tokens, callable only when unpaused.

#### exit

Claim rewards tokens and unstake staked tokens, callable only when unpaused.

| name     |       type       |        description |
| :------- | :--------------: | -----------------: |
| tokenIds | uint256[] memory | Array of token Ids |

#### fund

Fund rewards tokens and re-calculate rewards rate, callable only when unpaused and by owner.
Rewards rate will be calculated again from remaining distributable tokens and awarding rewards tokens.

| name   |  type   |                  description |
| :----- | :-----: | ---------------------------: |
| amount | uint256 | Funding rewards token amount |

#### recoverERC20

Transfer ERC20 tokens back from this contract to the owner except staking token, callable only when unpaused and by owner.

| name         |  type   |              description |
| :----------- | :-----: | -----------------------: |
| tokenAddress | address | Recovering token address |
| tokenAmount  | uint256 |  Recovering token amount |

### READ

#### balanceOf

Returns balance of staked amount per user.

| name    |  type   |  description |
| :------ | :-----: | -----------: |
| account | address | User address |

#### lastTimeRewardApplicable

Returns last time to calculate rewards.
If now is less than the last time, return now.

#### rewardPerToken

Returns total amount of calculated rewards.

#### earned

Returns earned rewards per user.

| name    |  type   |  description |
| :------ | :-----: | -----------: |
| account | address | User address |

#### getRewardForDuration

Returns total rewards amount for current duration.
