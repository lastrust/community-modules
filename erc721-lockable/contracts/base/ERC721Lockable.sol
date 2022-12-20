// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

// Openzeppelin
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
// Interfaces
import "../interface/IBunzz.sol";
import "../interface/IERC721Lockable.sol";

/**
 * @title ERC721Lockable
 * @notice ERC721 Token that can be locked for a certain period and cannot be transferred.
 * This is designed for a non-escrow staking contract that comes later to lock a user's NFT
 * while still letting them keep it in their wallet.
 * This extension can ensure the security of user tokens during the staking period.
 * If the nft lending protocol is compatible with this extension, the trouble caused by the NFT
 * airdrop can be avoided, because the airdrop is still in the user's wallet
 * @dev Implementation ERC721 Lockable Token
 * @author kazunetakeda25
 */
abstract contract ERC721Lockable is ERC721, IERC721Lockable, IBunzz, Ownable {
    // Mapping from token ID to unlock time
    mapping(uint256 => uint256) public lockedTokens;

    // Mapping from token ID to lock approved address
    mapping(uint256 => address) private _lockApprovals;
    // Mapping from owner to lock operator approvals
    mapping(address => mapping(address => bool)) private _lockOperatorApprovals;

    /**
     * @dev Connect to other contracts
     */
    function connectToOtherContracts(address[] calldata _contracts)
        public
        override
        onlyOwner
    {}

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
    function lockApprove(address to, uint256 tokenId) public virtual override {
        require(!isLocked(tokenId), "ERC721Lockable: token is locked");
        address owner = ERC721.ownerOf(tokenId);
        require(to != owner, "ERC721Lockable: lock approval to current owner");

        require(
            _msgSender() == owner || isLockApprovedForAll(owner, _msgSender()),
            "ERC721Lockable: lock approve caller is not owner nor approved for all"
        );

        _lockApprove(owner, to, tokenId);
    }

    /**
     * @dev Returns the account lock approved for `tokenId` token.
     *
     * Requirements:
     *
     * - `tokenId` must exist.
     * @param tokenId (uint256) Token ID
     * @return (address) Lock approved account address
     */
    function getLockApproved(uint256 tokenId)
        public
        view
        virtual
        override
        returns (address)
    {
        require(
            _exists(tokenId),
            "ERC721Lockable: lock approved query for nonexistent token"
        );

        return _lockApprovals[tokenId];
    }

    /**
     * @dev Returns the locker who is locking the `tokenId` token.
     *
     * Requirements:
     *
     * - `tokenId` must exist.
     * @param tokenId (uint256) Token ID
     * @return (address) Locker account address
     */
    function lockerOf(uint256 tokenId)
        public
        view
        virtual
        override
        returns (address)
    {
        require(
            _exists(tokenId),
            "ERC721Lockable: locker query for nonexistent token"
        );
        require(
            isLocked(tokenId),
            "ERC721Lockable: locker query for non-locked token"
        );

        return _lockApprovals[tokenId];
    }

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
    function setLockApprovalForAll(address operator, bool approved)
        public
        virtual
        override
    {
        _setLockApprovalForAll(_msgSender(), operator, approved);
    }

    /**
     * @dev Returns if the `operator` is allowed to lock all of the assets of `owner`.
     *
     * See {setLockApprovalForAll}
     * @param owner (address) Owner account address
     * @param operator (address) Operator account address
     */
    function isLockApprovedForAll(address owner, address operator)
        public
        view
        virtual
        override
        returns (bool)
    {
        return _lockOperatorApprovals[owner][operator];
    }

    /**
     * @dev Returns if the `tokenId` token is locked.
     * @param tokenId (uint256) Token ID
     * @return (bool) True for locked, false for not locked
     */
    function isLocked(uint256 tokenId)
        public
        view
        virtual
        override
        returns (bool)
    {
        return lockedTokens[tokenId] > block.timestamp;
    }

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
    ) public virtual override {
        //solhint-disable-next-line max-line-length
        require(
            _isLockApprovedOrOwner(_msgSender(), tokenId),
            "ERC721Lockable: lock caller is not owner nor approved"
        );
        require(
            expired > block.timestamp,
            "ERC721Lockable: expired time must be greater than current block time"
        );
        require(!isLocked(tokenId), "ERC721Lockable: token is locked");

        _lock(_msgSender(), from, tokenId, expired);
    }

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
    function unlockFrom(address from, uint256 tokenId) public virtual override {
        require(
            lockerOf(tokenId) == _msgSender(),
            "ERC721Lockable: unlock caller is not lock operator"
        );
        require(
            ERC721.ownerOf(tokenId) == from,
            "ERC721Lockable: unlock from incorrect owner"
        );

        _beforeTokenLock(_msgSender(), from, tokenId, 0);

        delete lockedTokens[tokenId];

        emit Unlocked(_msgSender(), from, tokenId);

        _afterTokenLock(_msgSender(), from, tokenId, 0);
    }

    /**
     * @dev Locks `tokenId` from `from`  until `expired`.
     *
     * Requirements:
     *
     * - `tokenId` token must be owned by `from`.
     *
     * Emits a {Locked} event.
     * @param operator (address) Operator account address
     * @param from (address) Lock from address
     * @param tokenId (uint256) Token ID
     * @param expired (uint256) Expire timestamp
     */
    function _lock(
        address operator,
        address from,
        uint256 tokenId,
        uint256 expired
    ) internal virtual {
        require(
            ERC721.ownerOf(tokenId) == from,
            "ERC721Lockable: lock from incorrect owner"
        );

        _beforeTokenLock(operator, from, tokenId, expired);

        lockedTokens[tokenId] = expired;
        _lockApprovals[tokenId] = _msgSender();

        emit Locked(operator, from, tokenId, expired);

        _afterTokenLock(operator, from, tokenId, expired);
    }

    /**
     * @dev Safely mints `tokenId` and transfers it to `to`, but the `tokenId` is locked and cannot be transferred.
     *
     * Requirements:
     *
     * - `tokenId` must not exist.
     *
     * Emits {Locked} and {Transfer} event.
     * @param to (address) Safe lock mint to address
     * @param tokenId (uint256) Token ID
     * @param expired (uint256) Expire timestamp
     * @param _data (bytes memory) Bytes data
     */
    function _safeLockMint(
        address to,
        uint256 tokenId,
        uint256 expired,
        bytes memory _data
    ) internal virtual {
        require(
            expired > block.timestamp,
            "ERC721Lockable: lock mint for invalid lock block time"
        );

        _safeMint(to, tokenId, _data);

        _lock(address(0), to, tokenId, expired);
    }

    /**
     * @dev See {ERC721-_burn}. This override additionally clears the lock approvals for the token.
     */
    function _burn(uint256 tokenId) internal virtual override {
        address owner = ERC721.ownerOf(tokenId);
        super._burn(tokenId);

        _beforeTokenLock(_msgSender(), owner, tokenId, 0);

        // clear lock approvals
        delete lockedTokens[tokenId];
        delete _lockApprovals[tokenId];

        _afterTokenLock(_msgSender(), owner, tokenId, 0);
    }

    /**
     * @dev Approve `to` to lock operate on `tokenId`
     *
     * Emits a {LockApproval} event.
     * @param owner (address) Owner account address
     * @param to (address) Lock approval to address
     * @param tokenId (uint256) Token ID
     */
    function _lockApprove(
        address owner,
        address to,
        uint256 tokenId
    ) internal virtual {
        _lockApprovals[tokenId] = to;
        emit LockApproval(owner, to, tokenId);
    }

    /**
     * @dev Approve `operator` to lock operate on all of `owner` tokens
     *
     * Emits a {LockApprovalForAll} event.
     * @param owner (address) Owner account address
     * @param operator (address) Operator account address
     * @param approved (bool) True for approve, false for remove approval
     */
    function _setLockApprovalForAll(
        address owner,
        address operator,
        bool approved
    ) internal virtual {
        require(owner != operator, "ERC721Lockable: lock approve to caller");
        _lockOperatorApprovals[owner][operator] = approved;
        emit LockApprovalForAll(owner, operator, approved);
    }

    /**
     * @dev Returns whether `spender` is allowed to lock `tokenId`.
     *
     * Requirements:
     *
     * - `tokenId` must exist.
     * @param spender (address) Spender account address
     * @param tokenId (uint256) TokenID
     * @return (bool) True for lock approved or owner, false for not
     */
    function _isLockApprovedOrOwner(address spender, uint256 tokenId)
        internal
        view
        virtual
        returns (bool)
    {
        require(
            _exists(tokenId),
            "ERC721Lockable: lock operator query for nonexistent token"
        );
        address owner = ERC721.ownerOf(tokenId);
        return (spender == owner ||
            isLockApprovedForAll(owner, spender) ||
            getLockApproved(tokenId) == spender);
    }

    /**
     * @dev See {ERC721-_beforeTokenTransfer}.
     *
     * Requirements:
     *
     * - the `tokenId` must not be locked.
     */
    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 firstTokenId,
        uint256 batchSize
    ) internal virtual override {
        super._beforeTokenTransfer(from, to, firstTokenId, batchSize);

        for (uint256 i; i < batchSize; ++i) {
            require(
                !isLocked(firstTokenId + i),
                "ERC721Lockable: Token transfer while locked"
            );
        }
    }

    /**
     * @dev Hook that is called before any token lock/unlock.
     *
     * Calling conditions:
     *
     * - `from` is non-zero.
     * - When `expired` is zero, `tokenId` will be unlock for `from`.
     * - When `expired` is non-zero, ``from``'s `tokenId` will be locked.
     * @param operator (address) Operator account address
     * @param from (address) From account address
     * @param tokenId (uint256) Token ID
     * @param expired (uint256) Expire timestamp
     */
    function _beforeTokenLock(
        address operator,
        address from,
        uint256 tokenId,
        uint256 expired
    ) internal virtual {}

    /**
     * @dev Hook that is called after any lock/unlock of tokens.
     *
     * Calling conditions:
     *
     * - `from` is non-zero.
     * - When `expired` is zero, `tokenId` will be unlock for `from`.
     * - When `expired` is non-zero, ``from``'s `tokenId` will be locked.
     * @param operator (address) Operator account address
     * @param from (address) From account address
     * @param tokenId (uint256) Token ID
     * @param expired (uint256) Expire timestamp
     */
    function _afterTokenLock(
        address operator,
        address from,
        uint256 tokenId,
        uint256 expired
    ) internal virtual {}

    /**
     * @dev See {IERC165-supportsInterface}.
     */
    function supportsInterface(bytes4 interfaceId)
        public
        view
        virtual
        override(IERC165, ERC721)
        returns (bool)
    {
        return
            interfaceId == type(IERC721Lockable).interfaceId ||
            super.supportsInterface(interfaceId);
    }
}
