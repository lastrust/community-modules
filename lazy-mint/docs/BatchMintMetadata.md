# BatchMintMetadata

*kazunetakeda25*

> BatchMintMetadata

The `BatchMintMetadata` is a contract extension for any base NFT contract. It lets the smart contract using this extension set metadata for `n` number of NFTs all at once. This is enabled by storing a single base URI for a batch of `n` NFTs, where the metadata for each NFT in a relevant batch is `baseURI/tokenId`.



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




## Errors

### InvalidIndex

```solidity
error InvalidIndex()
```






### InvalidTokenId

```solidity
error InvalidTokenId()
```







