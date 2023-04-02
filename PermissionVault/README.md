# PermissionVault Module

## Overview

PermissionVault is a smart contract that provides a way to store assets on the blockchain with multiple controllers. The assets can be in the form of Ether, ERC20 tokens, ERC721 tokens, or ERC1155 tokens. The contract is designed to allow the owner of the contract to manage a list of controllers who can deposit, withdraw, or transfer assets.

## How to use

- Deploy the PermissionVault contract on the blockchain.
- Call the `addController` function to add controllers who can manage the assets.
- The controllers can then deposit, withdraw or transfer assets by calling the appropriate function in the contract.
- The owner of the contract can pause and unpause the contract by calling the `setPaused` function.

## Functions

### CONTROLLER_ROLE

```solidity
function CONTROLLER_ROLE() external view returns (bytes32)
```

#### Returns

| Name | Type    | Description |
| ---- | ------- | ----------- |
| \_0  | bytes32 | undefined   |

### setPaused

```solidity
function setPaused(bool newPaused) external
```

_The owner can use this function to pause or unpause the contract._

#### Parameters

| Name      | Type | Description |
| --------- | ---- | ----------- |
| newPaused | bool | undefined   |

### addController

```solidity
function addController(address controller) external
```

_The owner can use this function to grant the CONTROLLER_ROLE to a new address._

#### Parameters

| Name       | Type    | Description |
| ---------- | ------- | ----------- |
| controller | address | undefined   |

### removeController

```solidity
function addController(address controller) external
```

_The owner can use this function to revoke the CONTROLLER_ROLE from an address._

#### Parameters

| Name       | Type    | Description |
| ---------- | ------- | ----------- |
| controller | address | undefined   |

### depositEther

```solidity
function depositEther() external payable
```

_A controller can use this function to deposit Ether into the contract._

### withdrawEther

```solidity
function withdrawEther(address to, uint256 amount) external
```

_A controller can use this function to withdraw Ether from the contract._

#### Parameters

| Name   | Type    | Description |
| ------ | ------- | ----------- |
| to     | address | undefined   |
| amount | uint256 | undefined   |

### depositERC20

```solidity
function depositERC20(IERC20 token, uint256 amount) external
```

_A controller can use this function to deposit ERC20 tokens into the contract._

#### Parameters

| Name   | Type    | Description |
| ------ | ------- | ----------- |
| token  | address | undefined   |
| amount | uint256 | undefined   |

### withdrawERC20

```solidity
function withdrawERC20(address to, IERC20 token, uint256 amount) external
```

_A controller can use this function to withdraw ERC20 tokens from the contract._

#### Parameters

| Name   | Type    | Description |
| ------ | ------- | ----------- |
| to     | address | undefined   |
| token  | address | undefined   |
| amount | uint256 | undefined   |

### depositERC721

```solidity
function depositERC721(IERC721 token, uint256 id) external
```

_A controller can use this function to deposit ERC721 tokens into the contract._

#### Parameters

| Name  | Type    | Description |
| ----- | ------- | ----------- |
| token | address | undefined   |
| id    | uint256 | undefined   |

### withdrawERC721

```solidity
function withdrawERC721(address to, IERC721 token, uint256 id) external
```

_A controller can use this function to withdraw ERC721 tokens from the contract._

#### Parameters

| Name  | Type    | Description |
| ----- | ------- | ----------- |
| to    | address | undefined   |
| token | address | undefined   |
| id    | uint256 | undefined   |

### depositERC1155

```solidity
function depositERC1155(IERC1155 token, uint256 id, uint256 amount) external
```

_A controller can use this function to deposit ERC1155 tokens into the contract._

#### Parameters

| Name   | Type    | Description |
| ------ | ------- | ----------- |
| token  | address | undefined   |
| id     | uint256 | undefined   |
| amount | uint256 | undefined   |

### withdrawERC1155

```solidity
function withdrawERC1155(address to, IERC1155 token, uint256 id, uint256 amount) external
```

_A controller can use this function to withdraw ERC1155 tokens from the contract._

#### Parameters

| Name   | Type    | Description |
| ------ | ------- | ----------- |
| to     | address | undefined   |
| token  | address | undefined   |
| id     | uint256 | undefined   |
| amount | uint256 | undefined   |

## Events

### AddController

```solidity
event AddController(address controller)
```

#### Parameters

| Name       | Type    | Description |
| ---------- | ------- | ----------- |
| controller | address | undefined   |

### RemoveController

```solidity
event RemoveController(address controller)
```

#### Parameters

| Name       | Type    | Description |
| ---------- | ------- | ----------- |
| controller | address | undefined   |

### DepositEther

```solidity
event DepositEther(address controller, uint256 amount)
```

#### Parameters

| Name       | Type    | Description |
| ---------- | ------- | ----------- |
| controller | address | undefined   |
| amount     | uint256 | undefined   |

### WithdrawEther

```solidity
event WithdrawEther(address controller, address to, uint256 amount)
```

#### Parameters

| Name       | Type    | Description |
| ---------- | ------- | ----------- |
| controller | address | undefined   |
| to         | address | undefined   |
| amount     | uint256 | undefined   |

### DepositERC20

```solidity
event DepositERC20(address controller, IERC20 token, uint256 amount)
```

#### Parameters

| Name       | Type    | Description |
| ---------- | ------- | ----------- |
| controller | address | undefined   |
| token      | address | undefined   |
| amount     | uint256 | undefined   |

### WithdrawERC20

```solidity
event WithdrawERC20(address controller, address to, IERC20 token, uint256 amount)
```

#### Parameters

| Name       | Type    | Description |
| ---------- | ------- | ----------- |
| controller | address | undefined   |
| to         | address | undefined   |
| token      | address | undefined   |
| amount     | uint256 | undefined   |

### DepositERC721

```solidity
event DepositERC721(address controller, IERC721 token, uint256 id)
```

#### Parameters

| Name       | Type    | Description |
| ---------- | ------- | ----------- |
| controller | address | undefined   |
| token      | address | undefined   |
| id         | uint256 | undefined   |

### WithdrawERC721

```solidity
event WithdrawERC721(address controller, address to, IERC721 token, uint256 id)
```

#### Parameters

| Name       | Type    | Description |
| ---------- | ------- | ----------- |
| controller | address | undefined   |
| to         | address | undefined   |
| token      | address | undefined   |
| id         | uint256 | undefined   |

### DepositERC1155

```solidity
event DepositERC1155(address controller, IERC1155 token, uint256 id, uint256 amount)
```

#### Parameters

| Name       | Type    | Description |
| ---------- | ------- | ----------- |
| controller | address | undefined   |
| token      | address | undefined   |
| id         | uint256 | undefined   |
| amount     | uint256 | undefined   |

### WithdrawERC1155

```solidity
event WithdrawERC1155(address controller, address to, IERC1155 token, uint256 id, uint256 amount)
```

#### Parameters

| Name       | Type    | Description |
| ---------- | ------- | ----------- |
| controller | address | undefined   |
| to         | address | undefined   |
| token      | address | undefined   |
| id         | uint256 | undefined   |
| amount     | uint256 | undefined   |
