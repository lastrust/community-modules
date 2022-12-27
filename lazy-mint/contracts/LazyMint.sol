// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

// Interfaces
import "./interface/ILazyMint.sol";
// Extensions
import "./extension/BatchMintMetadata.sol";

/**
 * @title LazyMint
 * @notice The `LazyMint` is a contract extension for any base NFT contract.
 * It lets you 'lazy mint' any number of NFTs at once.
 * @author kazunetakeda25
 */
abstract contract LazyMint is ILazyMint, BatchMintMetadata {
    /// @notice The tokenId assigned to the next new NFT to be lazy minted.
    uint256 internal _nextTokenId;

    error NotAuthorized();
    error ZeroAmount();

    /**
     * @notice Lets an authorized address lazy mint a given amount of NFTs.
     * @param amount_ (uint256) The number of NFTs to lazy mint.
     * @param baseURI_ (string calldata) The base URI for the 'n' number of NFTs being lazy minted,
     * where the metadata for each of those NFTs is `${baseURIForTokens}/${tokenId}`.
     * @param data_ (bytes calldata) Additional bytes data to be used at the discretion of the consumer of the contract.
     * @return batchId (uint256) A unique integer identifier for the batch of NFTs lazy minted together.
     */
    function lazyMint(
        uint256 amount_,
        string calldata baseURI_,
        bytes calldata data_
    ) public virtual override returns (uint256 batchId) {
        if (!_canLazyMint()) {
            revert NotAuthorized();
        }

        if (amount_ == 0) {
            revert ZeroAmount();
        }

        uint256 startId = _nextTokenId;

        (_nextTokenId, batchId) = _batchMintMetadata(
            startId,
            amount_,
            baseURI_
        );

        emit TokensLazyMinted(msg.sender, startId, startId + amount_ - 1, baseURI_, data_);

        return batchId;
    }

    /**
     * @dev Returns whether lazy minting can be performed in the given execution context.
     * @return (bool) Can lazy mint
     */
    function _canLazyMint() internal view virtual returns (bool);
}
