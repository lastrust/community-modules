# Bunzz MinimalForwarder Module

## Overview

 Simple minimal forwarder to be used together with an ERC2771 compatible contract. See {ERC2771Context}.
 
 MinimalForwarder is mainly meant for testing, as it is missing features to be a good production-ready forwarder. 
 This contract does not intend to have all the properties that are needed for a sound forwarding system. 
 A fully functioning forwarding system with good properties requires more complexity. 
 We suggest you look at other projects such as the GSN which do have the goal of building a system like that.

# MinimalForwarder









## Methods

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



