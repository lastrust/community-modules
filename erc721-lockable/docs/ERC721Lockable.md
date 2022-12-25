# ERC721Lockable

*kazunetakeda25*

> ERC721Lockable

ERC721 Token that can be locked for a certain period and cannot be transferred. This is designed for a non-escrow staking contract that comes later to lock a user&#39;s NFT while still letting them keep it in their wallet. This extension can ensure the security of user tokens during the staking period. If the nft lending protocol is compatible with this extension, the trouble caused by the NFT airdrop can be avoided, because the airdrop is still in the user&#39;s wallet

*Implementation ERC721 Lockable Token*

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

### connectToOtherContracts

```solidity
function connectToOtherContracts(address[] _contracts) external nonpayable
```



*Connect to other contracts*

#### Parameters

| Name | Type | Description |
|---|---|---|
| _contracts | address[] | undefined |

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

### getLockApproved

```solidity
function getLockApproved(uint256 tokenId) external view returns (address)
```



*Returns the account lock approved for `tokenId` token. Requirements: - `tokenId` must exist.*

#### Parameters

| Name | Type | Description |
|---|---|---|
| tokenId | uint256 | (uint256) Token ID |

#### Returns

| Name | Type | Description |
|---|---|---|
| _0 | address | (address) Lock approved account address |

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

### isLockApprovedForAll

```solidity
function isLockApprovedForAll(address owner, address operator) external view returns (bool)
```



*Returns if the `operator` is allowed to lock all of the assets of `owner`. See {setLockApprovalForAll}*

#### Parameters

| Name | Type | Description |
|---|---|---|
| owner | address | (address) Owner account address |
| operator | address | (address) Operator account address |

#### Returns

| Name | Type | Description |
|---|---|---|
| _0 | bool | undefined |

### isLocked

```solidity
function isLocked(uint256 tokenId) external view returns (bool)
```



*Returns if the `tokenId` token is locked.*

#### Parameters

| Name | Type | Description |
|---|---|---|
| tokenId | uint256 | (uint256) Token ID |

#### Returns

| Name | Type | Description |
|---|---|---|
| _0 | bool | (bool) True for locked, false for not locked |

### lockApprove

```solidity
function lockApprove(address to, uint256 tokenId) external nonpayable
```



*Gives permission to `to` to lock `tokenId` token. Requirements: - The caller must own the token or be an approved lock operator. - `tokenId` must exist. Emits an {LockApproval} event.*

#### Parameters

| Name | Type | Description |
|---|---|---|
| to | address | (address) Lock approval to address |
| tokenId | uint256 | (uint256) Token ID |

### lockFrom

```solidity
function lockFrom(address from, uint256 tokenId, uint256 expired) external nonpayable
```



*Lock `tokenId` token until the block number is greater than `expired` to be unlocked. Requirements: - `from` cannot be the zero address. - `tokenId` token must be owned by `from`. - `expired` must be greater than block.timestamp - If the caller is not `from`, it must be approved to lock this token by either {lockApprove} or {setLockApprovalForAll}. Emits a {Locked} event.*

#### Parameters

| Name | Type | Description |
|---|---|---|
| from | address | (address) Lock from address |
| tokenId | uint256 | (uint256) Token ID |
| expired | uint256 | (uint256) Expire timestamp |

### lockedTokens

```solidity
function lockedTokens(uint256) external view returns (uint256)
```





#### Parameters

| Name | Type | Description |
|---|---|---|
| _0 | uint256 | undefined |

#### Returns

| Name | Type | Description |
|---|---|---|
| _0 | uint256 | undefined |

### lockerOf

```solidity
function lockerOf(uint256 tokenId) external view returns (address)
```



*Returns the locker who is locking the `tokenId` token. Requirements: - `tokenId` must exist.*

#### Parameters

| Name | Type | Description |
|---|---|---|
| tokenId | uint256 | (uint256) Token ID |

#### Returns

| Name | Type | Description |
|---|---|---|
| _0 | address | (address) Locker account address |

### name

```solidity
function name() external view returns (string)
```



*See {IERC721Metadata-name}.*


#### Returns

| Name | Type | Description |
|---|---|---|
| _0 | string | undefined |

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

### setLockApprovalForAll

```solidity
function setLockApprovalForAll(address operator, bool approved) external nonpayable
```



*Approve or remove `operator` as an lock operator for the caller. Operators can call {lockFrom} for any token owned by the caller. Requirements: - The `operator` cannot be the caller. Emits an {LockApprovalForAll} event.*

#### Parameters

| Name | Type | Description |
|---|---|---|
| operator | address | (address) Lock operator for the caller |
| approved | bool | (bool) True for approved, false for removing approval |

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

### unlockFrom

```solidity
function unlockFrom(address from, uint256 tokenId) external nonpayable
```



*Unlock `tokenId` token. Requirements: - `from` cannot be the zero address. - `tokenId` token must be owned by `from`. - the caller must be the operator who locks the token by {lockFrom} Emits a {Unlocked} event.*

#### Parameters

| Name | Type | Description |
|---|---|---|
| from | address | (address) Unlock from address |
| tokenId | uint256 | (uint256) Token ID |



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

### LockApproval

```solidity
event LockApproval(address indexed owner, address indexed approved, uint256 indexed tokenId)
```





#### Parameters

| Name | Type | Description |
|---|---|---|
| owner `indexed` | address | undefined |
| approved `indexed` | address | undefined |
| tokenId `indexed` | uint256 | undefined |

### LockApprovalForAll

```solidity
event LockApprovalForAll(address indexed owner, address indexed operator, bool approved)
```





#### Parameters

| Name | Type | Description |
|---|---|---|
| owner `indexed` | address | undefined |
| operator `indexed` | address | undefined |
| approved  | bool | undefined |

### Locked

```solidity
event Locked(address indexed operator, address indexed from, uint256 indexed tokenId, uint256 expired)
```





#### Parameters

| Name | Type | Description |
|---|---|---|
| operator `indexed` | address | undefined |
| from `indexed` | address | undefined |
| tokenId `indexed` | uint256 | undefined |
| expired  | uint256 | undefined |

### OwnershipTransferred

```solidity
event OwnershipTransferred(address indexed previousOwner, address indexed newOwner)
```





#### Parameters

| Name | Type | Description |
|---|---|---|
| previousOwner `indexed` | address | undefined |
| newOwner `indexed` | address | undefined |

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

### Unlocked

```solidity
event Unlocked(address indexed operator, address indexed from, uint256 indexed tokenId)
```





#### Parameters

| Name | Type | Description |
|---|---|---|
| operator `indexed` | address | undefined |
| from `indexed` | address | undefined |
| tokenId `indexed` | uint256 | undefined |



