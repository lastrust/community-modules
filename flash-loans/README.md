# Bunzz Flash Loans (ERC3156) Module

## Overview

Flash loans allow smart contracts to lend an amount of tokens without a requirement for collateral, with the condition that they must be returned within the same transaction.

Early adopters of the flash loan pattern have produced different interfaces and different use patterns. The diversification is expected to intensify, and with it the technical debt required to integrate with diverse flash lending patterns.

Some of the high level differences in the approaches across the protocols include:

- Repayment approaches at the end of the transaction, where some pull the principal plus the fee from the loan receiver, and others where the loan receiver needs to manually return the principal and the fee to the lender.
- Some lenders offer the ability to repay the loan using a token that is different to what was originally borrowed, which can reduce the overall complexity of the flash transaction and gas fees.
- Some lenders offer a single entry point into the protocol regardless of whether you’re buying, selling, depositing or chaining them together as a flash loan, whereas other protocols offer discrete entry points.
- Some lenders allow to flash mint any amount of their native token without charging a fee, effectively allowing flash loans bounded by computational constraints instead of asset ownership constraints.

# FlashBorrower

*kazunetakeda25*

> FlashBorrower





## Methods

### approveRepayment

```solidity
function approveRepayment(address token, uint256 amount) external nonpayable
```





#### Parameters

| Name | Type | Description |
|---|---|---|
| token | address | undefined |
| amount | uint256 | undefined |

### flashAmount

```solidity
function flashAmount() external view returns (uint256)
```






#### Returns

| Name | Type | Description |
|---|---|---|
| _0 | uint256 | undefined |

### flashBalance

```solidity
function flashBalance() external view returns (uint256)
```






#### Returns

| Name | Type | Description |
|---|---|---|
| _0 | uint256 | undefined |

### flashBorrow

```solidity
function flashBorrow(address token, uint256 amount) external nonpayable
```





#### Parameters

| Name | Type | Description |
|---|---|---|
| token | address | undefined |
| amount | uint256 | undefined |

### flashBorrowAndReenter

```solidity
function flashBorrowAndReenter(address token, uint256 amount) external nonpayable
```





#### Parameters

| Name | Type | Description |
|---|---|---|
| token | address | undefined |
| amount | uint256 | undefined |

### flashBorrowAndSteal

```solidity
function flashBorrowAndSteal(address token, uint256 amount) external nonpayable
```





#### Parameters

| Name | Type | Description |
|---|---|---|
| token | address | undefined |
| amount | uint256 | undefined |

### flashFee

```solidity
function flashFee() external view returns (uint256)
```






#### Returns

| Name | Type | Description |
|---|---|---|
| _0 | uint256 | undefined |

### flashInitiator

```solidity
function flashInitiator() external view returns (address)
```






#### Returns

| Name | Type | Description |
|---|---|---|
| _0 | address | undefined |

### flashToken

```solidity
function flashToken() external view returns (address)
```






#### Returns

| Name | Type | Description |
|---|---|---|
| _0 | address | undefined |

### onFlashLoan

```solidity
function onFlashLoan(address initiator, address token, uint256 amount, uint256 fee, bytes data) external nonpayable returns (bytes32)
```



*ERC-3156 Flash loan callback*

#### Parameters

| Name | Type | Description |
|---|---|---|
| initiator | address | undefined |
| token | address | undefined |
| amount | uint256 | undefined |
| fee | uint256 | undefined |
| data | bytes | undefined |

#### Returns

| Name | Type | Description |
|---|---|---|
| _0 | bytes32 | undefined |

### owner

```solidity
function owner() external view returns (address)
```



*Returns the address of the current owner.*


#### Returns

| Name | Type | Description |
|---|---|---|
| _0 | address | undefined |

### renounceOwnership

```solidity
function renounceOwnership() external nonpayable
```



*Leaves the contract without owner. It will not be possible to call `onlyOwner` functions anymore. Can only be called by the current owner. NOTE: Renouncing ownership will leave the contract without an owner, thereby removing any functionality that is only available to the owner.*


### transferOwnership

```solidity
function transferOwnership(address newOwner) external nonpayable
```



*Transfers ownership of the contract to a new account (`newOwner`). Can only be called by the current owner.*

#### Parameters

| Name | Type | Description |
|---|---|---|
| newOwner | address | undefined |



## Events

### OwnershipTransferred

```solidity
event OwnershipTransferred(address indexed previousOwner, address indexed newOwner)
```





#### Parameters

| Name | Type | Description |
|---|---|---|
| previousOwner `indexed` | address | undefined |
| newOwner `indexed` | address | undefined |



# FlashLender

*kazunetakeda25*

> FlashLender



*Extension of {ERC20} that allows flash lending.*

## Methods

### CALLBACK_SUCCESS

```solidity
function CALLBACK_SUCCESS() external view returns (bytes32)
```






#### Returns

| Name | Type | Description |
|---|---|---|
| _0 | bytes32 | undefined |

### fee

```solidity
function fee() external view returns (uint256)
```






#### Returns

| Name | Type | Description |
|---|---|---|
| _0 | uint256 | undefined |

### flashFee

```solidity
function flashFee(address token, uint256 amount) external view returns (uint256)
```



*The fee to be charged for a given loan.*

#### Parameters

| Name | Type | Description |
|---|---|---|
| token | address | The loan currency. |
| amount | uint256 | The amount of tokens lent. |

#### Returns

| Name | Type | Description |
|---|---|---|
| _0 | uint256 | The amount of `token` to be charged for the loan, on top of the returned principal. |

### flashLoan

```solidity
function flashLoan(contract IERC3156FlashBorrower receiver, address token, uint256 amount, bytes data) external nonpayable returns (bool)
```



*Loan `amount` tokens to `receiver`, and takes it back plus a `flashFee` after the callback.*

#### Parameters

| Name | Type | Description |
|---|---|---|
| receiver | contract IERC3156FlashBorrower | The contract receiving the tokens, needs to implement the `onFlashLoan(address user, uint256 amount, uint256 fee, bytes calldata)` interface. |
| token | address | The loan currency. |
| amount | uint256 | The amount of tokens lent. |
| data | bytes | A data parameter to be passed on to the `receiver` for any custom use. |

#### Returns

| Name | Type | Description |
|---|---|---|
| _0 | bool | undefined |

### maxFlashLoan

```solidity
function maxFlashLoan(address token) external view returns (uint256)
```



*The amount of currency available to be lended.*

#### Parameters

| Name | Type | Description |
|---|---|---|
| token | address | The loan currency. |

#### Returns

| Name | Type | Description |
|---|---|---|
| _0 | uint256 | The amount of `token` that can be borrowed. |

### owner

```solidity
function owner() external view returns (address)
```



*Returns the address of the current owner.*


#### Returns

| Name | Type | Description |
|---|---|---|
| _0 | address | undefined |

### renounceOwnership

```solidity
function renounceOwnership() external nonpayable
```



*Leaves the contract without owner. It will not be possible to call `onlyOwner` functions anymore. Can only be called by the current owner. NOTE: Renouncing ownership will leave the contract without an owner, thereby removing any functionality that is only available to the owner.*


### supportedTokens

```solidity
function supportedTokens(address) external view returns (bool)
```





#### Parameters

| Name | Type | Description |
|---|---|---|
| _0 | address | undefined |

#### Returns

| Name | Type | Description |
|---|---|---|
| _0 | bool | undefined |

### transferOwnership

```solidity
function transferOwnership(address newOwner) external nonpayable
```



*Transfers ownership of the contract to a new account (`newOwner`). Can only be called by the current owner.*

#### Parameters

| Name | Type | Description |
|---|---|---|
| newOwner | address | undefined |



## Events

### OwnershipTransferred

```solidity
event OwnershipTransferred(address indexed previousOwner, address indexed newOwner)
```





#### Parameters

| Name | Type | Description |
|---|---|---|
| previousOwner `indexed` | address | undefined |
| newOwner `indexed` | address | undefined |



# FlashMinter

*kazunetakeda25*

> FlashMinter



*Extension of {ERC20} that allows flash minting.*

## Methods

### CALLBACK_SUCCESS

```solidity
function CALLBACK_SUCCESS() external view returns (bytes32)
```






#### Returns

| Name | Type | Description |
|---|---|---|
| _0 | bytes32 | undefined |

### allowance

```solidity
function allowance(address owner, address spender) external view returns (uint256)
```



*See {IERC20-allowance}.*

#### Parameters

| Name | Type | Description |
|---|---|---|
| owner | address | undefined |
| spender | address | undefined |

#### Returns

| Name | Type | Description |
|---|---|---|
| _0 | uint256 | undefined |

### approve

```solidity
function approve(address spender, uint256 amount) external nonpayable returns (bool)
```



*See {IERC20-approve}. NOTE: If `amount` is the maximum `uint256`, the allowance is not updated on `transferFrom`. This is semantically equivalent to an infinite approval. Requirements: - `spender` cannot be the zero address.*

#### Parameters

| Name | Type | Description |
|---|---|---|
| spender | address | undefined |
| amount | uint256 | undefined |

#### Returns

| Name | Type | Description |
|---|---|---|
| _0 | bool | undefined |

### balanceOf

```solidity
function balanceOf(address account) external view returns (uint256)
```



*See {IERC20-balanceOf}.*

#### Parameters

| Name | Type | Description |
|---|---|---|
| account | address | undefined |

#### Returns

| Name | Type | Description |
|---|---|---|
| _0 | uint256 | undefined |

### connectToOtherContracts

```solidity
function connectToOtherContracts(address[] _contracts) external nonpayable
```



*Connect to other contracts*

#### Parameters

| Name | Type | Description |
|---|---|---|
| _contracts | address[] | undefined |

### decimals

```solidity
function decimals() external view returns (uint8)
```



*Returns the number of decimals used to get its user representation. For example, if `decimals` equals `2`, a balance of `505` tokens should be displayed to a user as `5.05` (`505 / 10 ** 2`). Tokens usually opt for a value of 18, imitating the relationship between Ether and Wei. This is the value {ERC20} uses, unless this function is overridden; NOTE: This information is only used for _display_ purposes: it in no way affects any of the arithmetic of the contract, including {IERC20-balanceOf} and {IERC20-transfer}.*


#### Returns

| Name | Type | Description |
|---|---|---|
| _0 | uint8 | undefined |

### decreaseAllowance

```solidity
function decreaseAllowance(address spender, uint256 subtractedValue) external nonpayable returns (bool)
```



*Atomically decreases the allowance granted to `spender` by the caller. This is an alternative to {approve} that can be used as a mitigation for problems described in {IERC20-approve}. Emits an {Approval} event indicating the updated allowance. Requirements: - `spender` cannot be the zero address. - `spender` must have allowance for the caller of at least `subtractedValue`.*

#### Parameters

| Name | Type | Description |
|---|---|---|
| spender | address | undefined |
| subtractedValue | uint256 | undefined |

#### Returns

| Name | Type | Description |
|---|---|---|
| _0 | bool | undefined |

### fee

```solidity
function fee() external view returns (uint256)
```






#### Returns

| Name | Type | Description |
|---|---|---|
| _0 | uint256 | undefined |

### flashFee

```solidity
function flashFee(address token, uint256 amount) external view returns (uint256)
```



*The fee to be charged for a given loan.*

#### Parameters

| Name | Type | Description |
|---|---|---|
| token | address | The loan currency. Must match the address of this contract. |
| amount | uint256 | The amount of tokens lent. |

#### Returns

| Name | Type | Description |
|---|---|---|
| _0 | uint256 | The amount of `token` to be charged for the loan, on top of the returned principal. |

### flashLoan

```solidity
function flashLoan(contract IERC3156FlashBorrower receiver, address token, uint256 amount, bytes data) external nonpayable returns (bool)
```



*Loan `amount` tokens to `receiver`, and takes it back plus a `flashFee` after the ERC3156 callback.*

#### Parameters

| Name | Type | Description |
|---|---|---|
| receiver | contract IERC3156FlashBorrower | The contract receiving the tokens, needs to implement the `onFlashLoan(address user, uint256 amount, uint256 fee, bytes calldata)` interface. |
| token | address | The loan currency. Must match the address of this contract. |
| amount | uint256 | The amount of tokens lent. |
| data | bytes | A data parameter to be passed on to the `receiver` for any custom use. |

#### Returns

| Name | Type | Description |
|---|---|---|
| _0 | bool | undefined |

### increaseAllowance

```solidity
function increaseAllowance(address spender, uint256 addedValue) external nonpayable returns (bool)
```



*Atomically increases the allowance granted to `spender` by the caller. This is an alternative to {approve} that can be used as a mitigation for problems described in {IERC20-approve}. Emits an {Approval} event indicating the updated allowance. Requirements: - `spender` cannot be the zero address.*

#### Parameters

| Name | Type | Description |
|---|---|---|
| spender | address | undefined |
| addedValue | uint256 | undefined |

#### Returns

| Name | Type | Description |
|---|---|---|
| _0 | bool | undefined |

### maxFlashLoan

```solidity
function maxFlashLoan(address) external view returns (uint256)
```



*The amount of currency available to be lended.*

#### Parameters

| Name | Type | Description |
|---|---|---|
| _0 | address | undefined |

#### Returns

| Name | Type | Description |
|---|---|---|
| _0 | uint256 | The amount of `token` that can be borrowed. |

### name

```solidity
function name() external view returns (string)
```



*Returns the name of the token.*


#### Returns

| Name | Type | Description |
|---|---|---|
| _0 | string | undefined |

### owner

```solidity
function owner() external view returns (address)
```



*Returns the address of the current owner.*


#### Returns

| Name | Type | Description |
|---|---|---|
| _0 | address | undefined |

### renounceOwnership

```solidity
function renounceOwnership() external nonpayable
```



*Leaves the contract without owner. It will not be possible to call `onlyOwner` functions anymore. Can only be called by the current owner. NOTE: Renouncing ownership will leave the contract without an owner, thereby removing any functionality that is only available to the owner.*


### symbol

```solidity
function symbol() external view returns (string)
```



*Returns the symbol of the token, usually a shorter version of the name.*


#### Returns

| Name | Type | Description |
|---|---|---|
| _0 | string | undefined |

### totalSupply

```solidity
function totalSupply() external view returns (uint256)
```



*See {IERC20-totalSupply}.*


#### Returns

| Name | Type | Description |
|---|---|---|
| _0 | uint256 | undefined |

### transfer

```solidity
function transfer(address to, uint256 amount) external nonpayable returns (bool)
```



*See {IERC20-transfer}. Requirements: - `to` cannot be the zero address. - the caller must have a balance of at least `amount`.*

#### Parameters

| Name | Type | Description |
|---|---|---|
| to | address | undefined |
| amount | uint256 | undefined |

#### Returns

| Name | Type | Description |
|---|---|---|
| _0 | bool | undefined |

### transferFrom

```solidity
function transferFrom(address from, address to, uint256 amount) external nonpayable returns (bool)
```



*See {IERC20-transferFrom}. Emits an {Approval} event indicating the updated allowance. This is not required by the EIP. See the note at the beginning of {ERC20}. NOTE: Does not update the allowance if the current allowance is the maximum `uint256`. Requirements: - `from` and `to` cannot be the zero address. - `from` must have a balance of at least `amount`. - the caller must have allowance for ``from``&#39;s tokens of at least `amount`.*

#### Parameters

| Name | Type | Description |
|---|---|---|
| from | address | undefined |
| to | address | undefined |
| amount | uint256 | undefined |

#### Returns

| Name | Type | Description |
|---|---|---|
| _0 | bool | undefined |

### transferOwnership

```solidity
function transferOwnership(address newOwner) external nonpayable
```



*Transfers ownership of the contract to a new account (`newOwner`). Can only be called by the current owner.*

#### Parameters

| Name | Type | Description |
|---|---|---|
| newOwner | address | undefined |



## Events

### Approval

```solidity
event Approval(address indexed owner, address indexed spender, uint256 value)
```





#### Parameters

| Name | Type | Description |
|---|---|---|
| owner `indexed` | address | undefined |
| spender `indexed` | address | undefined |
| value  | uint256 | undefined |

### OwnershipTransferred

```solidity
event OwnershipTransferred(address indexed previousOwner, address indexed newOwner)
```





#### Parameters

| Name | Type | Description |
|---|---|---|
| previousOwner `indexed` | address | undefined |
| newOwner `indexed` | address | undefined |

### Transfer

```solidity
event Transfer(address indexed from, address indexed to, uint256 value)
```





#### Parameters

| Name | Type | Description |
|---|---|---|
| from `indexed` | address | undefined |
| to `indexed` | address | undefined |
| value  | uint256 | undefined |



