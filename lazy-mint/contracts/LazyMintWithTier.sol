// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

// Interfaces
import "./interface/ILazyMintWithTier.sol";
// Extensions
import "./extension/BatchMintMetadata.sol";

/**
 * @title LazyMintWithTier
 * @notice The `LazyMint` is a contract extension for any base NFT contract.
 * It lets you 'lazy mint' any number of NFTs at once.
 * @dev LazyMint contract with Tier functionality added.
 * @author kazunetakeda25
 */
abstract contract LazyMintWithTier is ILazyMintWithTier, BatchMintMetadata {
    struct TokenRange {
        uint256 startIdInclusive;
        uint256 endIdNonInclusive;
    }

    struct TierMetadata {
        string tier;
        TokenRange[] ranges;
        string[] baseURIs;
    }

    /// @notice The tokenId assigned to the next new NFT to be lazy minted.
    uint256 internal _nextTokenId;
    /// @notice Mapping from a tier -> the token IDs grouped under that tier.
    mapping(string => TokenRange[]) internal _tokensInTier;

    /// @notice A list of tiers used in this contract.
    string[] private _tiers;

    error NotAuthorized();
    error ZeroAmount();

    /**
     * @notice Lets an authorized address lazy mint a given amount of NFTs.
     * @param amount_ (uint256) The number of NFTs to lazy mint.
     * @param baseURI_ (string calldata) The base URI for the 'n' number of NFTs being lazy minted,
     * where the metadata for each of those NFTs is `${baseURIForTokens}/${tokenId}`.
     * @param tier_ (string calldata)Tier of the NFTs.
     * @param data_ (bytes calldata) Additional bytes data to be used at the discretion of the consumer of the contract.
     * @return batchId (uint256) A unique integer identifier for the batch of NFTs lazy minted together.
     */
    function lazyMint(
        uint256 amount_,
        string calldata baseURI_,
        string calldata tier_,
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

        if (!(_tokensInTier[tier_].length > 0)) {
            _tiers.push(tier_);
        }

        _tokensInTier[tier_].push(TokenRange(startId, batchId));

        emit TokensLazyMinted(
            msg.sender,
            tier_,
            startId,
            startId + amount_ - 1,
            baseURI_,
            data_
        );

        return batchId;
    }

    /**
     * @notice Returns all metadata lazy minted for the given tier.
     * @param tier_ (string memory) Tier of the NFTs.
     * @return tokens (TokenRange[] memory) Tokens in a range
     * @return baseURIs (TokenRange[] memory) Base URIs
     */
    function _getMetadataInTier(string memory tier_)
        private
        view
        returns (TokenRange[] memory tokens, string[] memory baseURIs)
    {
        tokens = _tokensInTier[tier_];

        uint256 len = tokens.length;
        baseURIs = new string[](len);

        for (uint256 i; i < len; ++i) {
            baseURIs[i] = _getBaseURI(tokens[i].startIdInclusive);
        }
    }

    /**
     * @notice Returns all metadata for all tiers created on the contract.
     * @return metadataForAllTiers (TierMetadata[] memory) Metadata for all tiers
     */
    function getMetadataForAllTiers()
        external
        view
        returns (TierMetadata[] memory metadataForAllTiers)
    {
        string[] memory allTiers = _tiers;
        uint256 length = allTiers.length;

        metadataForAllTiers = new TierMetadata[](length);

        for (uint256 i; i < length; ++i) {
            (
                TokenRange[] memory tokens,
                string[] memory baseURIs
            ) = _getMetadataInTier(allTiers[i]);
            metadataForAllTiers[i] = TierMetadata(
                allTiers[i],
                tokens,
                baseURIs
            );
        }
    }

    /**
     * @notice Returns whether any metadata is lazy minted for the given tier.
     * @param tier_ We check whether this given tier is empty.
     * @return (bool) Is tier empty
     */
    function isTierEmpty(string memory tier_) internal view returns (bool) {
        return _tokensInTier[tier_].length == 0;
    }

    /**
     * @dev Returns whether lazy minting can be performed in the given execution context.
     * @return (bool) Can lazy mint
     */
    function _canLazyMint() internal view virtual returns (bool);
}
