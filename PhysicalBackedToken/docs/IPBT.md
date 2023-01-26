# IPBT



> IPBT



*Contract for PBTs (Physical Backed Tokens). NFTs that are backed by a physical asset, through a chip embedded in the physical asset.*

## Methods

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



