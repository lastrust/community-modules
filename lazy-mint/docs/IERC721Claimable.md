# IERC721Claimable









## Methods

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

### TokensClaimed

```solidity
event TokensClaimed(address indexed claimer, address indexed receiver, uint256 indexed startTokenId, uint256 quantityClaimed)
```



*Emitted when tokens are claimed*

#### Parameters

| Name | Type | Description |
|---|---|---|
| claimer `indexed` | address | undefined |
| receiver `indexed` | address | undefined |
| startTokenId `indexed` | uint256 | undefined |
| quantityClaimed  | uint256 | undefined |



