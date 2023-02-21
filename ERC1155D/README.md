# Bunzz ERC1155D Module

## Overview

The ERC1155D contract is a gas efficient NFT contract. An alternative to ERC721. It is intended to only be used for 1/1 NFT's (supply of 1) and does not support tokens with supply greater than 1.

To use the ERC1155D contract in your project, copy contracts/ERC1155D.sol to your project. Then, you can import it, and write an implementation that extends the contract as is ERC1155

NOTE: ERC1155D does not maintain tokenID enumeration. You will need to implement a counter for it in your contract, similar to supply in the example below.

# ERC1155D



> ERC1155D



*Implementation of the basic standard multi-token. See https://eips.ethereum.org/EIPS/eip-1155 Originally based on code by Enjin: https://github.com/enjin/erc-1155*

## Methods

### MAX_SUPPLY

```solidity
function MAX_SUPPLY() external view returns (uint256)
```






#### Returns

| Name | Type | Description |
|---|---|---|
| _0 | uint256 | undefined |

### balanceOf

```solidity
function balanceOf(address account, uint256 id) external view returns (uint256)
```



*See {IERC1155-balanceOf}. Requirements: - `account` cannot be the zero address.*

#### Parameters

| Name | Type | Description |
|---|---|---|
| account | address | undefined |
| id | uint256 | undefined |

#### Returns

| Name | Type | Description |
|---|---|---|
| _0 | uint256 | undefined |

### balanceOfBatch

```solidity
function balanceOfBatch(address[] accounts, uint256[] ids) external view returns (uint256[])
```



*See {IERC1155-balanceOfBatch}. Requirements: - `accounts` and `ids` must have the same length.*

#### Parameters

| Name | Type | Description |
|---|---|---|
| accounts | address[] | undefined |
| ids | uint256[] | undefined |

#### Returns

| Name | Type | Description |
|---|---|---|
| _0 | uint256[] | undefined |

### getERC721BalanceOffChain

```solidity
function getERC721BalanceOffChain(address _address) external view returns (uint256)
```





#### Parameters

| Name | Type | Description |
|---|---|---|
| _address | address | undefined |

#### Returns

| Name | Type | Description |
|---|---|---|
| _0 | uint256 | undefined |

### getOwnershipRecordOffChain

```solidity
function getOwnershipRecordOffChain() external view returns (address[5000])
```






#### Returns

| Name | Type | Description |
|---|---|---|
| _0 | address[5000] | undefined |

### isApprovedForAll

```solidity
function isApprovedForAll(address account, address operator) external view returns (bool)
```



*See {IERC1155-isApprovedForAll}.*

#### Parameters

| Name | Type | Description |
|---|---|---|
| account | address | undefined |
| operator | address | undefined |

#### Returns

| Name | Type | Description |
|---|---|---|
| _0 | bool | undefined |

### ownerOfERC721Like

```solidity
function ownerOfERC721Like(uint256 id) external view returns (address)
```





#### Parameters

| Name | Type | Description |
|---|---|---|
| id | uint256 | undefined |

#### Returns

| Name | Type | Description |
|---|---|---|
| _0 | address | undefined |

### safeBatchTransferFrom

```solidity
function safeBatchTransferFrom(address from, address to, uint256[] ids, uint256[] amounts, bytes data) external nonpayable
```



*See {IERC1155-safeBatchTransferFrom}.*

#### Parameters

| Name | Type | Description |
|---|---|---|
| from | address | undefined |
| to | address | undefined |
| ids | uint256[] | undefined |
| amounts | uint256[] | undefined |
| data | bytes | undefined |

### safeTransferFrom

```solidity
function safeTransferFrom(address from, address to, uint256 id, uint256 amount, bytes data) external nonpayable
```



*See {IERC1155-safeTransferFrom}.*

#### Parameters

| Name | Type | Description |
|---|---|---|
| from | address | undefined |
| to | address | undefined |
| id | uint256 | undefined |
| amount | uint256 | undefined |
| data | bytes | undefined |

### setApprovalForAll

```solidity
function setApprovalForAll(address operator, bool approved) external nonpayable
```



*See {IERC1155-setApprovalForAll}.*

#### Parameters

| Name | Type | Description |
|---|---|---|
| operator | address | undefined |
| approved | bool | undefined |

### supportsInterface

```solidity
function supportsInterface(bytes4 interfaceId) external view returns (bool)
```



*See {IERC165-supportsInterface}.*

#### Parameters

| Name | Type | Description |
|---|---|---|
| interfaceId | bytes4 | undefined |

#### Returns

| Name | Type | Description |
|---|---|---|
| _0 | bool | undefined |

### uri

```solidity
function uri(uint256) external view returns (string)
```



*See {IERC1155MetadataURI-uri}. This implementation returns the same URI for *all* token types. It relies on the token type ID substitution mechanism https://eips.ethereum.org/EIPS/eip-1155#metadata[defined in the EIP]. Clients calling this function must replace the `\{id\}` substring with the actual token type ID.*

#### Parameters

| Name | Type | Description |
|---|---|---|
| _0 | uint256 | undefined |

#### Returns

| Name | Type | Description |
|---|---|---|
| _0 | string | undefined |



## Events

### ApprovalForAll

```solidity
event ApprovalForAll(address indexed account, address indexed operator, bool approved)
```





#### Parameters

| Name | Type | Description |
|---|---|---|
| account `indexed` | address | undefined |
| operator `indexed` | address | undefined |
| approved  | bool | undefined |

### TransferBatch

```solidity
event TransferBatch(address indexed operator, address indexed from, address indexed to, uint256[] ids, uint256[] values)
```





#### Parameters

| Name | Type | Description |
|---|---|---|
| operator `indexed` | address | undefined |
| from `indexed` | address | undefined |
| to `indexed` | address | undefined |
| ids  | uint256[] | undefined |
| values  | uint256[] | undefined |

### TransferSingle

```solidity
event TransferSingle(address indexed operator, address indexed from, address indexed to, uint256 id, uint256 value)
```





#### Parameters

| Name | Type | Description |
|---|---|---|
| operator `indexed` | address | undefined |
| from `indexed` | address | undefined |
| to `indexed` | address | undefined |
| id  | uint256 | undefined |
| value  | uint256 | undefined |

### URI

```solidity
event URI(string value, uint256 indexed id)
```





#### Parameters

| Name | Type | Description |
|---|---|---|
| value  | string | undefined |
| id `indexed` | uint256 | undefined |



# Maximally efficient Implementation

This is more for vanity metrics, but it is possible to acheive 50,434 gas with the following code. This eliminates the fallback function due to the function selector being all zeros, so if anyone sends ether directly to your contract, the transaction will revert.

```solidity
pragma solidity 0.8.13;

contract ExampleMint {

    uint256 public constant MAX_SUPPLY = 10000;
    address[MAX_SUPPLY] _owners;
    uint256 public constant PRICE = 0.01 ether;
    uint256 private index = 1;
    
    event TransferSingle(address, address, address, uint256, uint256);

    function mint_efficient_1268F998() external payable {
        require(msg.value == PRICE, "wrong price");
        uint256 _index = index;
        require(_index < MAX_SUPPLY, "supply limit");

        emit TransferSingle(msg.sender, address(0), msg.sender, _index, 1);
        assembly {
            sstore(add(_owners.slot, _index), caller())
        }

        unchecked {
            _index++;
        }
        index = _index;
    }
}
```