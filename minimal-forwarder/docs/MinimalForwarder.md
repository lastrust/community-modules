# MinimalForwarder









## Methods

### connectToOtherContracts

```solidity
function connectToOtherContracts(address[] contracts) external nonpayable
```





#### Parameters

| Name | Type | Description |
|---|---|---|
| contracts | address[] | undefined |

### execute

```solidity
function execute(IMinimalForwarder.ForwardRequest req_, bytes signature_) external payable returns (bool, bytes)
```





#### Parameters

| Name | Type | Description |
|---|---|---|
| req_ | IMinimalForwarder.ForwardRequest | undefined |
| signature_ | bytes | undefined |

#### Returns

| Name | Type | Description |
|---|---|---|
| _0 | bool | undefined |
| _1 | bytes | undefined |

### getNonce

```solidity
function getNonce(address from_) external view returns (uint256)
```





#### Parameters

| Name | Type | Description |
|---|---|---|
| from_ | address | undefined |

#### Returns

| Name | Type | Description |
|---|---|---|
| _0 | uint256 | undefined |

### minimalForwarderContract

```solidity
function minimalForwarderContract() external view returns (address)
```






#### Returns

| Name | Type | Description |
|---|---|---|
| _0 | address | undefined |

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

### verify

```solidity
function verify(IMinimalForwarder.ForwardRequest req_, bytes signature_) external view returns (bool)
```





#### Parameters

| Name | Type | Description |
|---|---|---|
| req_ | IMinimalForwarder.ForwardRequest | undefined |
| signature_ | bytes | undefined |

#### Returns

| Name | Type | Description |
|---|---|---|
| _0 | bool | undefined |



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



