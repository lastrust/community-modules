# Bunzz LazyMint Module

## Overview

This connects with other contract and used for sharing accumulated tokens on the contract with shared accounts.

# ERC721LazyMint

*kazunetakeda25*

> ERC721LazyMint

Base ERC721 contract with LazyMint functionality added.

*BASE: ERC721 EXTENSION: LazyMint The `ERC721LazyMint` smart contract implements the ERC721 NFT standard. It includes the following additions to standard ERC721 logic:  - Lazy minting  - Ownership of the contract, with the ability to restrict certain functions to only be called by the contract&#39;s owner.  - Multicall capability to perform multiple actions atomically &#39;Lazy minting&#39; means defining the metadata of NFTs without minting it to an address. Regular &#39;minting&#39; of NFTs means actually assigning an owner to an NFT. As a contract admin, this lets you prepare the metadata for NFTs that will be minted by an external party, without paying the gas cost for actually minting the NFTs.*

## Methods

### approve

```solidity
function approve(address to, uint256 tokenId) external nonpayable
```



*See {IERC721-approve}.*

#### Parameters

| Name | Type | Description |
|---|---|---|
| to | address | undefined |
| tokenId | uint256 | undefined |

### balanceOf

```solidity
function balanceOf(address owner) external view returns (uint256)
```



*See {IERC721-balanceOf}.*

#### Parameters

| Name | Type | Description |
|---|---|---|
| owner | address | undefined |

#### Returns

| Name | Type | Description |
|---|---|---|
| _0 | uint256 | undefined |

### baseURILength

```solidity
function baseURILength() external view returns (uint256)
```

Returns the count of batches of NFTs.

*Each batch of tokens has an in ID and an associated `baseURI`. See {batchIds}.*


#### Returns

| Name | Type | Description |
|---|---|---|
| _0 | uint256 | (uint256) Base URI Length |

### batchIdAtIndex

```solidity
function batchIdAtIndex(uint256 index_) external view returns (uint256)
```

Returns the ID for the batch of tokens the given tokenId belongs to.

*See {baseURILength}.*

#### Parameters

| Name | Type | Description |
|---|---|---|
| index_ | uint256 | (uint256) Batch ID |

#### Returns

| Name | Type | Description |
|---|---|---|
| _0 | uint256 | (uint256) Batch ID |

### burn

```solidity
function burn(uint256 tokenId_) external nonpayable
```

Lets an owner or approved operator burn the NFT of the given tokenId.

*ERC721A&#39;s `_burn(uint256,bool)` internally checks for token approvals.*

#### Parameters

| Name | Type | Description |
|---|---|---|
| tokenId_ | uint256 | (uint256) The tokenId of the NFT to burn. |

### claim

```solidity
function claim(address to_, uint256 quantity_) external payable
```

Lets an address claim multiple lazy minted NFTs at once to a recipient. This function prevents any reentrant calls, and is not allowed to be overridden. Contract creators should override `verifyClaim` and `transferTokensOnClaim` functions to create custom logic for verification and claiming, for e.g. price collection, allowlist, max quantity, etc.

*The logic in `verifyClaim` determines whether the caller is authorized to mint NFTs. The logic in `transferTokensOnClaim` does actual minting of tokens, can also be used to apply other state changes.*

#### Parameters

| Name | Type | Description |
|---|---|---|
| to_ | address | (address) The recipient of the NFT to mint. |
| quantity_ | uint256 | (uint256) The number of NFTs to mint. |

### getApproved

```solidity
function getApproved(uint256 tokenId) external view returns (address)
```



*See {IERC721-getApproved}.*

#### Parameters

| Name | Type | Description |
|---|---|---|
| tokenId | uint256 | undefined |

#### Returns

| Name | Type | Description |
|---|---|---|
| _0 | address | undefined |

### isApprovedForAll

```solidity
function isApprovedForAll(address owner, address operator) external view returns (bool)
```



*See {IERC721-isApprovedForAll}.*

#### Parameters

| Name | Type | Description |
|---|---|---|
| owner | address | undefined |
| operator | address | undefined |

#### Returns

| Name | Type | Description |
|---|---|---|
| _0 | bool | undefined |

### lazyMint

```solidity
function lazyMint(uint256 amount_, string baseURI_, bytes data_) external nonpayable returns (uint256 batchId)
```

Lets an authorized address lazy mint a given amount of NFTs.



#### Parameters

| Name | Type | Description |
|---|---|---|
| amount_ | uint256 | (uint256) The number of NFTs to lazy mint. |
| baseURI_ | string | (string calldata) The base URI for the &#39;n&#39; number of NFTs being lazy minted, where the metadata for each of those NFTs is `${baseURIForTokens}/${tokenId}`. |
| data_ | bytes | (bytes calldata) Additional bytes data to be used at the discretion of the consumer of the contract. |

#### Returns

| Name | Type | Description |
|---|---|---|
| batchId | uint256 | (uint256) A unique integer identifier for the batch of NFTs lazy minted together. |

### multicall

```solidity
function multicall(bytes[] data) external nonpayable returns (bytes[] results)
```



*Receives and executes a batch of function calls on this contract.*

#### Parameters

| Name | Type | Description |
|---|---|---|
| data | bytes[] | undefined |

#### Returns

| Name | Type | Description |
|---|---|---|
| results | bytes[] | undefined |

### name

```solidity
function name() external view returns (string)
```



*See {IERC721Metadata-name}.*


#### Returns

| Name | Type | Description |
|---|---|---|
| _0 | string | undefined |

### nextTokenIdToClaim

```solidity
function nextTokenIdToClaim() external view returns (uint256)
```

The tokenId assigned to the next new NFT to be claimed.




#### Returns

| Name | Type | Description |
|---|---|---|
| _0 | uint256 | (uint256) Next token ID to claim |

### nextTokenIdToMint

```solidity
function nextTokenIdToMint() external view returns (uint256)
```

The tokenId assigned to the next new NFT to be lazy minted.




#### Returns

| Name | Type | Description |
|---|---|---|
| _0 | uint256 | (uint256) Next token ID to mint |

### owner

```solidity
function owner() external view returns (address)
```



*Returns the address of the current owner.*


#### Returns

| Name | Type | Description |
|---|---|---|
| _0 | address | undefined |

### ownerOf

```solidity
function ownerOf(uint256 tokenId) external view returns (address)
```



*See {IERC721-ownerOf}.*

#### Parameters

| Name | Type | Description |
|---|---|---|
| tokenId | uint256 | undefined |

#### Returns

| Name | Type | Description |
|---|---|---|
| _0 | address | undefined |

### renounceOwnership

```solidity
function renounceOwnership() external nonpayable
```



*Leaves the contract without owner. It will not be possible to call `onlyOwner` functions anymore. Can only be called by the current owner. NOTE: Renouncing ownership will leave the contract without an owner, thereby removing any functionality that is only available to the owner.*


### safeTransferFrom

```solidity
function safeTransferFrom(address from, address to, uint256 tokenId) external nonpayable
```



*See {IERC721-safeTransferFrom}.*

#### Parameters

| Name | Type | Description |
|---|---|---|
| from | address | undefined |
| to | address | undefined |
| tokenId | uint256 | undefined |

### safeTransferFrom

```solidity
function safeTransferFrom(address from, address to, uint256 tokenId, bytes data) external nonpayable
```



*See {IERC721-safeTransferFrom}.*

#### Parameters

| Name | Type | Description |
|---|---|---|
| from | address | undefined |
| to | address | undefined |
| tokenId | uint256 | undefined |
| data | bytes | undefined |

### setApprovalForAll

```solidity
function setApprovalForAll(address operator, bool approved) external nonpayable
```



*See {IERC721-setApprovalForAll}.*

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

### symbol

```solidity
function symbol() external view returns (string)
```



*See {IERC721Metadata-symbol}.*


#### Returns

| Name | Type | Description |
|---|---|---|
| _0 | string | undefined |

### tokenURI

```solidity
function tokenURI(uint256 tokenId_) external view returns (string)
```

Returns the metadata URI for an NFT.

*See `BatchMintMetadata` for handling of metadata in this contract.*

#### Parameters

| Name | Type | Description |
|---|---|---|
| tokenId_ | uint256 | (uint256) The tokenId of an NFT. |

#### Returns

| Name | Type | Description |
|---|---|---|
| _0 | string | (string memory) Token URI |

### transferFrom

```solidity
function transferFrom(address from, address to, uint256 tokenId) external nonpayable
```



*See {IERC721-transferFrom}.*

#### Parameters

| Name | Type | Description |
|---|---|---|
| from | address | undefined |
| to | address | undefined |
| tokenId | uint256 | undefined |

### transferOwnership

```solidity
function transferOwnership(address newOwner) external nonpayable
```



*Transfers ownership of the contract to a new account (`newOwner`). Can only be called by the current owner.*

#### Parameters

| Name | Type | Description |
|---|---|---|
| newOwner | address | undefined |

### verifyClaim

```solidity
function verifyClaim(address to_, uint256 quantity_) external view
```

Override this function to add logic for claim verification, based on conditions such as allowlist, price, max quantity etc.

*Checks a request to claim NFTs against a custom condition. Add your claim verification logic by overriding this function.*

#### Parameters

| Name | Type | Description |
|---|---|---|
| to_ | address | (address) Caller of the claim function. |
| quantity_ | uint256 | (uint256) The number of NFTs being claimed. |



## Events

### Approval

```solidity
event Approval(address indexed owner, address indexed approved, uint256 indexed tokenId)
```





#### Parameters

| Name | Type | Description |
|---|---|---|
| owner `indexed` | address | undefined |
| approved `indexed` | address | undefined |
| tokenId `indexed` | uint256 | undefined |

### ApprovalForAll

```solidity
event ApprovalForAll(address indexed owner, address indexed operator, bool approved)
```





#### Parameters

| Name | Type | Description |
|---|---|---|
| owner `indexed` | address | undefined |
| operator `indexed` | address | undefined |
| approved  | bool | undefined |

### OwnershipTransferred

```solidity
event OwnershipTransferred(address indexed previousOwner, address indexed newOwner)
```





#### Parameters

| Name | Type | Description |
|---|---|---|
| previousOwner `indexed` | address | undefined |
| newOwner `indexed` | address | undefined |

### TokensClaimed

```solidity
event TokensClaimed(address indexed claimer, address indexed receiver, uint256 indexed startTokenId, uint256 quantityClaimed)
```





#### Parameters

| Name | Type | Description |
|---|---|---|
| claimer `indexed` | address | undefined |
| receiver `indexed` | address | undefined |
| startTokenId `indexed` | uint256 | undefined |
| quantityClaimed  | uint256 | undefined |

### TokensLazyMinted

```solidity
event TokensLazyMinted(uint256 indexed startTokenId, uint256 endTokenId, string baseURI, bytes data)
```





#### Parameters

| Name | Type | Description |
|---|---|---|
| startTokenId `indexed` | uint256 | undefined |
| endTokenId  | uint256 | undefined |
| baseURI  | string | undefined |
| data  | bytes | undefined |

### Transfer

```solidity
event Transfer(address indexed from, address indexed to, uint256 indexed tokenId)
```





#### Parameters

| Name | Type | Description |
|---|---|---|
| from `indexed` | address | undefined |
| to `indexed` | address | undefined |
| tokenId `indexed` | uint256 | undefined |



## Errors

### InvalidClaimQuantity

```solidity
error InvalidClaimQuantity()
```






### InvalidIndex

```solidity
error InvalidIndex()
```






### InvalidTokenId

```solidity
error InvalidTokenId()
```






### NotAuthorized

```solidity
error NotAuthorized()
```






### ZeroAmount

```solidity
error ZeroAmount()
```







