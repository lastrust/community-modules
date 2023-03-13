# PBT



> PBT Implementation of PBT where all chipAddress-&gt;tokenIds are preset in the contract by the contract owner.





## Methods

### approve

```solidity
function approve(address, uint256) external nonpayable
```





#### Parameters

| Name | Type | Description |
|---|---|---|
| _0 | address | undefined |
| _1 | uint256 | undefined |

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

### getMaxBlockhashValidWindow

```solidity
function getMaxBlockhashValidWindow() external pure returns (uint256)
```






#### Returns

| Name | Type | Description |
|---|---|---|
| _0 | uint256 | undefined |

### isApprovedForAll

```solidity
function isApprovedForAll(address, address) external view returns (bool)
```





#### Parameters

| Name | Type | Description |
|---|---|---|
| _0 | address | undefined |
| _1 | address | undefined |

#### Returns

| Name | Type | Description |
|---|---|---|
| _0 | bool | undefined |

### isChipSignatureForToken

```solidity
function isChipSignatureForToken(uint256 tokenId, bytes payload, bytes signature) external view returns (bool)
```

Returns true if the chip for the specified token id is the signer of the signature of the payload.

*Throws if tokenId does not exist in the collection.*

#### Parameters

| Name | Type | Description |
|---|---|---|
| tokenId | uint256 | The token id. |
| payload | bytes | Arbitrary data that is signed by the chip to produce the signature param. |
| signature | bytes | Chip&#39;s signature of the passed-in payload. |

#### Returns

| Name | Type | Description |
|---|---|---|
| _0 | bool | Whether the signature of the payload was signed by the chip linked to the token id. |

### name

```solidity
function name() external view returns (string)
```



*See {IERC721Metadata-name}.*


#### Returns

| Name | Type | Description |
|---|---|---|
| _0 | string | undefined |

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

### safeTransferFrom

```solidity
function safeTransferFrom(address, address, uint256) external nonpayable
```





#### Parameters

| Name | Type | Description |
|---|---|---|
| _0 | address | undefined |
| _1 | address | undefined |
| _2 | uint256 | undefined |

### safeTransferFrom

```solidity
function safeTransferFrom(address, address, uint256, bytes) external nonpayable
```





#### Parameters

| Name | Type | Description |
|---|---|---|
| _0 | address | undefined |
| _1 | address | undefined |
| _2 | uint256 | undefined |
| _3 | bytes | undefined |

### setApprovalForAll

```solidity
function setApprovalForAll(address, bool) external nonpayable
```





#### Parameters

| Name | Type | Description |
|---|---|---|
| _0 | address | undefined |
| _1 | bool | undefined |

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

### tokenIdFor

```solidity
function tokenIdFor(address chipAddress) external view returns (uint256)
```

Returns the token id for a given chip address.

*Throws if there is no existing token for the chip in the collection.*

#### Parameters

| Name | Type | Description |
|---|---|---|
| chipAddress | address | The address for the chip embedded in the physical item (computed from the chip&#39;s public key). |

#### Returns

| Name | Type | Description |
|---|---|---|
| _0 | uint256 | The token id for the passed in chip address. |

### tokenIdMappedFor

```solidity
function tokenIdMappedFor(address chipAddress) external view returns (uint256)
```





#### Parameters

| Name | Type | Description |
|---|---|---|
| chipAddress | address | undefined |

#### Returns

| Name | Type | Description |
|---|---|---|
| _0 | uint256 | undefined |

### tokenURI

```solidity
function tokenURI(uint256 tokenId) external view returns (string)
```



*See {IERC721Metadata-tokenURI}.*

#### Parameters

| Name | Type | Description |
|---|---|---|
| tokenId | uint256 | undefined |

#### Returns

| Name | Type | Description |
|---|---|---|
| _0 | string | undefined |

### transferFrom

```solidity
function transferFrom(address, address, uint256) external nonpayable
```





#### Parameters

| Name | Type | Description |
|---|---|---|
| _0 | address | undefined |
| _1 | address | undefined |
| _2 | uint256 | undefined |

### transferTokenWithChip

```solidity
function transferTokenWithChip(bytes signatureFromChip, uint256 blockNumberUsedInSig) external nonpayable
```

Calls transferTokenWithChip as defined above, with useSafeTransferFrom set to false.



#### Parameters

| Name | Type | Description |
|---|---|---|
| signatureFromChip | bytes | undefined |
| blockNumberUsedInSig | uint256 | undefined |

### transferTokenWithChip

```solidity
function transferTokenWithChip(bytes signatureFromChip, uint256 blockNumberUsedInSig, bool useSafeTransferFrom) external nonpayable
```

Transfers the token into the message sender&#39;s wallet.

*The implementation should check that block number be reasonably recent to avoid replay attacks of stale signatures. The implementation should also verify that the address signed in the signature matches msgSender. If the address recovered from the signature matches a chip address that&#39;s bound to an existing token, the token should be transferred to msgSender. If there is no existing token linked to the chip, the function should error.*

#### Parameters

| Name | Type | Description |
|---|---|---|
| signatureFromChip | bytes | An EIP-191 signature of (msgSender, blockhash), where blockhash is the block hash for blockNumberUsedInSig. |
| blockNumberUsedInSig | uint256 | The block number linked to the blockhash signed in signatureFromChip. Should be a recent block number. |
| useSafeTransferFrom | bool | Whether EIP-721&#39;s safeTransferFrom should be used in the implementation, instead of transferFrom. |



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

### PBTChipRemapping

```solidity
event PBTChipRemapping(uint256 indexed tokenId, address indexed oldChipAddress, address indexed newChipAddress)
```

Emitted when a token is mapped to a different chip. Chip replacements may be useful in certain scenarios (e.g. chip defect).



#### Parameters

| Name | Type | Description |
|---|---|---|
| tokenId `indexed` | uint256 | undefined |
| oldChipAddress `indexed` | address | undefined |
| newChipAddress `indexed` | address | undefined |

### PBTMint

```solidity
event PBTMint(uint256 indexed tokenId, address indexed chipAddress)
```

Emitted when a token is minted.



#### Parameters

| Name | Type | Description |
|---|---|---|
| tokenId `indexed` | uint256 | undefined |
| chipAddress `indexed` | address | undefined |

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

### BlockNumberTooOld

```solidity
error BlockNumberTooOld()
```






### InvalidBlockNumber

```solidity
error InvalidBlockNumber()
```






### InvalidSignature

```solidity
error InvalidSignature()
```






### NoMappedTokenForChip

```solidity
error NoMappedTokenForChip()
```






### NoMintedTokenForChip

```solidity
error NoMintedTokenForChip()
```







