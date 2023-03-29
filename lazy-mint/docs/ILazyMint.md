# ILazyMint

*kazunetakeda25*



The `LazyMint` is a contract extension for any base NFT contract. It lets you &#39;lazy mint&#39; any number of NFTs at once.



## Methods

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



## Events

### TokensLazyMinted

```solidity
event TokensLazyMinted(address indexed minter, uint256 indexed startTokenId, uint256 endTokenId, string baseURI, bytes data)
```



*Emitted when tokens are lazy minted.*

#### Parameters

| Name | Type | Description |
|---|---|---|
| minter `indexed` | address | undefined |
| startTokenId `indexed` | uint256 | undefined |
| endTokenId  | uint256 | undefined |
| baseURI  | string | undefined |
| data  | bytes | undefined |



