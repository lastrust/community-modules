# LazyMintWithTier

*kazunetakeda25*

> LazyMintWithTier

The `LazyMint` is a contract extension for any base NFT contract. It lets you &#39;lazy mint&#39; any number of NFTs at once.

*LazyMint contract with Tier functionality added.*

## Methods

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

### getMetadataForAllTiers

```solidity
function getMetadataForAllTiers() external view returns (struct LazyMintWithTier.TierMetadata[] metadataForAllTiers)
```

Returns all metadata for all tiers created on the contract.




#### Returns

| Name | Type | Description |
|---|---|---|
| metadataForAllTiers | LazyMintWithTier.TierMetadata[] | (TierMetadata[] memory) Metadata for all tiers |

### lazyMint

```solidity
function lazyMint(uint256 amount_, string baseURI_, string tier_, bytes data_) external nonpayable returns (uint256 batchId)
```

Lets an authorized address lazy mint a given amount of NFTs.



#### Parameters

| Name | Type | Description |
|---|---|---|
| amount_ | uint256 | (uint256) The number of NFTs to lazy mint. |
| baseURI_ | string | (string calldata) The base URI for the &#39;n&#39; number of NFTs being lazy minted, where the metadata for each of those NFTs is `${baseURIForTokens}/${tokenId}`. |
| tier_ | string | (string calldata)Tier of the NFTs. |
| data_ | bytes | (bytes calldata) Additional bytes data to be used at the discretion of the consumer of the contract. |

#### Returns

| Name | Type | Description |
|---|---|---|
| batchId | uint256 | (uint256) A unique integer identifier for the batch of NFTs lazy minted together. |



## Events

### TokensLazyMinted

```solidity
event TokensLazyMinted(address indexed minter, string indexed tier, uint256 indexed startTokenId, uint256 endTokenId, string baseURI, bytes data)
```





#### Parameters

| Name | Type | Description |
|---|---|---|
| minter `indexed` | address | undefined |
| tier `indexed` | string | undefined |
| startTokenId `indexed` | uint256 | undefined |
| endTokenId  | uint256 | undefined |
| baseURI  | string | undefined |
| data  | bytes | undefined |



## Errors

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







