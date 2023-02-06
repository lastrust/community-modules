# IERC721Lockable

*kazunetakeda25*

> IERC721Lockable

ERC721 Token that can be locked for a certain period and cannot be transferred. This is designed for a non-escrow staking contract that comes later to lock a user&#39;s NFT while still letting them keep it in their wallet. This extension can ensure the security of user tokens during the staking period. If the nft lending protocol is compatible with this extension, the trouble caused by the NFT airdrop can be avoided, because the airdrop is still in the user&#39;s wallet

*Interface for ERC721 Lockable Token*

## Methods

### approve

```solidity
function approve(address to, uint256 tokenId) external nonpayable
```



*Gives permission to `to` to transfer `tokenId` token to another account. The approval is cleared when the token is transferred. Only a single account can be approved at a time, so approving the zero address clears previous approvals. Requirements: - The caller must own the token or be an approved operator. - `tokenId` must exist. Emits an {Approval} event.*

#### Parameters

| Name | Type | Description |
|---|---|---|
| to | address | undefined |
| tokenId | uint256 | undefined |

### balanceOf

```solidity
function balanceOf(address owner) external view returns (uint256 balance)
```



*Returns the number of tokens in ``owner``&#39;s account.*

#### Parameters

| Name | Type | Description |
|---|---|---|
| owner | address | undefined |

#### Returns

| Name | Type | Description |
|---|---|---|
| balance | uint256 | undefined |

### getApproved

```solidity
function getApproved(uint256 tokenId) external view returns (address operator)
```



*Returns the account approved for `tokenId` token. Requirements: - `tokenId` must exist.*

#### Parameters

| Name | Type | Description |
|---|---|---|
| tokenId | uint256 | undefined |

#### Returns

| Name | Type | Description |
|---|---|---|
| operator | address | undefined |

### getLockApproved

```solidity
function getLockApproved(uint256 tokenId) external view returns (address operator)
```



*Returns the account lock approved for `tokenId` token. Requirements: - `tokenId` must exist.*

#### Parameters

| Name | Type | Description |
|---|---|---|
| tokenId | uint256 | undefined |

#### Returns

| Name | Type | Description |
|---|---|---|
| operator | address | undefined |

### isApprovedForAll

```solidity
function isApprovedForAll(address owner, address operator) external view returns (bool)
```



*Returns if the `operator` is allowed to manage all of the assets of `owner`. See {setApprovalForAll}*

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

### lockerOf

```solidity
function lockerOf(uint256 tokenId) external view returns (address locker)
```



*Returns the locker who is locking the `tokenId` token. Requirements: - `tokenId` must exist.*

#### Parameters

| Name | Type | Description |
|---|---|---|
| tokenId | uint256 | (uint256) Token ID |

#### Returns

| Name | Type | Description |
|---|---|---|
| locker | address | (address) Locker account address |

### ownerOf

```solidity
function ownerOf(uint256 tokenId) external view returns (address owner)
```



*Returns the owner of the `tokenId` token. Requirements: - `tokenId` must exist.*

#### Parameters

| Name | Type | Description |
|---|---|---|
| tokenId | uint256 | undefined |

#### Returns

| Name | Type | Description |
|---|---|---|
| owner | address | undefined |

### safeTransferFrom

```solidity
function safeTransferFrom(address from, address to, uint256 tokenId) external nonpayable
```



*Safely transfers `tokenId` token from `from` to `to`, checking first that contract recipients are aware of the ERC721 protocol to prevent tokens from being forever locked. Requirements: - `from` cannot be the zero address. - `to` cannot be the zero address. - `tokenId` token must exist and be owned by `from`. - If the caller is not `from`, it must have been allowed to move this token by either {approve} or {setApprovalForAll}. - If `to` refers to a smart contract, it must implement {IERC721Receiver-onERC721Received}, which is called upon a safe transfer. Emits a {Transfer} event.*

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



*Safely transfers `tokenId` token from `from` to `to`. Requirements: - `from` cannot be the zero address. - `to` cannot be the zero address. - `tokenId` token must exist and be owned by `from`. - If the caller is not `from`, it must be approved to move this token by either {approve} or {setApprovalForAll}. - If `to` refers to a smart contract, it must implement {IERC721Receiver-onERC721Received}, which is called upon a safe transfer. Emits a {Transfer} event.*

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



*Approve or remove `operator` as an operator for the caller. Operators can call {transferFrom} or {safeTransferFrom} for any token owned by the caller. Requirements: - The `operator` cannot be the caller. Emits an {ApprovalForAll} event.*

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



*Returns true if this contract implements the interface defined by `interfaceId`. See the corresponding https://eips.ethereum.org/EIPS/eip-165#how-interfaces-are-identified[EIP section] to learn more about how these ids are created. This function call must use less than 30 000 gas.*

#### Parameters

| Name | Type | Description |
|---|---|---|
| interfaceId | bytes4 | undefined |

#### Returns

| Name | Type | Description |
|---|---|---|
| _0 | bool | undefined |

### transferFrom

```solidity
function transferFrom(address from, address to, uint256 tokenId) external nonpayable
```



*Transfers `tokenId` token from `from` to `to`. WARNING: Note that the caller is responsible to confirm that the recipient is capable of receiving ERC721 or else they may be permanently lost. Usage of {safeTransferFrom} prevents loss, though the caller must understand this adds an external call which potentially creates a reentrancy vulnerability. Requirements: - `from` cannot be the zero address. - `to` cannot be the zero address. - `tokenId` token must be owned by `from`. - If the caller is not `from`, it must be approved to move this token by either {approve} or {setApprovalForAll}. Emits a {Transfer} event.*

#### Parameters

| Name | Type | Description |
|---|---|---|
| from | address | undefined |
| to | address | undefined |
| tokenId | uint256 | undefined |

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



*Emitted when `owner` enables `approved` to lock the `tokenId` token.*

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



*Emitted when `owner` enables or disables (`approved`) `operator` to lock all of its tokens.*

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



*Emitted when `tokenId` token is locked by `operator` from `from`.*

#### Parameters

| Name | Type | Description |
|---|---|---|
| operator `indexed` | address | undefined |
| from `indexed` | address | undefined |
| tokenId `indexed` | uint256 | undefined |
| expired  | uint256 | undefined |

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



*Emitted when `tokenId` token is unlocked by `operator` from `from`.*

#### Parameters

| Name | Type | Description |
|---|---|---|
| operator `indexed` | address | undefined |
| from `indexed` | address | undefined |
| tokenId `indexed` | uint256 | undefined |



