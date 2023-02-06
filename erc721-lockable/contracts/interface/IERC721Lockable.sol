// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

// Interfaces
import "./IERC721.sol";

/**
 * @title IERC721Lockable
 * @notice ERC721 Token that can be locked for a certain period and cannot be transferred.
 * This is designed for a non-escrow staking contract that comes later to lock a user's NFT
 * while still letting them keep it in their wallet.
 * This extension can ensure the security of user tokens during the staking period.
 * If the nft lending protocol is compatible with this extension, the trouble caused by the NFT
 * airdrop can be avoided, because the airdrop is still in the user's wallet
 * @dev Interface for ERC721 Lockable Token
 * @author kazunetakeda25
 */
interface IERC721Lockable is IERC721 {
    /**
     * @dev Emitted when `tokenId` token is locked by `operator` from `from`.
     */
    event Locked(
        address indexed operator,
        address indexed from,
        uint256 indexed tokenId,
        uint256 expired
    );

    /**
     * @dev Emitted when `tokenId` token is unlocked by `operator` from `from`.
     */
    event Unlocked(
        address indexed operator,
        address indexed from,
        uint256 indexed tokenId
    );

    /**
     * @dev Emitted when `owner` enables `approved` to lock the `tokenId` token.
     */
    event LockApproval(
        address indexed owner,
        address indexed approved,
        uint256 indexed tokenId
    );

    /**
     * @dev Emitted when `owner` enables or disables (`approved`) `operator` to lock all of its tokens.
     */
    event LockApprovalForAll(
        address indexed owner,
        address indexed operator,
        bool approved
    );

    /**
     * @dev Returns the locker who is locking the `tokenId` token.
     *
     * Requirements:
     *
     * - `tokenId` must exist.
     * @param tokenId (uint256) Token ID
     * @return locker (address) Locker account address
     */
    function lockerOf(uint256 tokenId) external view returns (address locker);

    /**
     * @dev Lock `tokenId` token until the block number is greater than `expired` to be unlocked.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `tokenId` token must be owned by `from`.
     * - `expired` must be greater than block.timestamp
     * - If the caller is not `from`, it must be approved to lock this token
     * by either {lockApprove} or {setLockApprovalForAll}.
     *
     * Emits a {Locked} event.
     * @param from (address) Lock from address
     * @param tokenId (uint256) Token ID
     * @param expired (uint256) Expire timestamp
     */
    function lockFrom(
        address from,
        uint256 tokenId,
        uint256 expired
    ) external;

    /**
     * @dev Unlock `tokenId` token.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `tokenId` token must be owned by `from`.
     * - the caller must be the operator who locks the token by {lockFrom}
     *
     * Emits a {Unlocked} event.
     * @param from (address) Unlock from address
     * @param tokenId (uint256) Token ID
     */
    function unlockFrom(address from, uint256 tokenId) external;

    /**
     * @dev Gives permission to `to` to lock `tokenId` token.
     *
     * Requirements:
     *
     * - The caller must own the token or be an approved lock operator.
     * - `tokenId` must exist.
     *
     * Emits an {LockApproval} event.
     * @param to (address) Lock approval to address
     * @param tokenId (uint256) Token ID
     */
    function lockApprove(address to, uint256 tokenId) external;

    /**
     * @dev Approve or remove `operator` as an lock operator for the caller.
     * Operators can call {lockFrom} for any token owned by the caller.
     *
     * Requirements:
     *
     * - The `operator` cannot be the caller.
     *
     * Emits an {LockApprovalForAll} event.
     * @param operator (address) Lock operator for the caller
     * @param approved (bool) True for approved, false for removing approval
     */
    function setLockApprovalForAll(address operator, bool approved) external;

    /**
     * @dev Returns the account lock approved for `tokenId` token.
     *
     * Requirements:
     *
     * - `tokenId` must exist.
     */
    function getLockApproved(uint256 tokenId)
        external
        view
        returns (address operator);

    /**
     * @dev Returns if the `operator` is allowed to lock all of the assets of `owner`.
     *
     * See {setLockApprovalForAll}
     * @param owner (address) Owner account address
     * @param operator (address) Operator account address
     */
    function isLockApprovedForAll(address owner, address operator)
        external
        view
        returns (bool);

    /**
     * @dev Returns if the `tokenId` token is locked.
     * @param tokenId (uint256) Token ID
     * @return (bool) True for locked, false for not locked
     */
    function isLocked(uint256 tokenId) external view returns (bool);
}
