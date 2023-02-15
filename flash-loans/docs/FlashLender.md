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



