// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/**
 * @title BatchMintMetadata
 * @notice The `BatchMintMetadata` is a contract extension for any base NFT contract.
 * It lets the smart contract using this extension set metadata for `n` number of NFTs all at once.
 * This is enabled by storing a single base URI for a batch of `n` NFTs,
 * where the metadata for each NFT in a relevant batch is `baseURI/tokenId`.
 * @author kazunetakeda25
 */
contract BatchMintMetadata {
    /// @dev Largest tokenId of each batch of tokens with the same baseURI.
    uint256[] private _batchIds;
    /// @dev Mapping from id of a batch of tokens => to base URI for the respective batch of tokens.
    mapping(uint256 => string) private _baseURIs;

    error InvalidIndex();
    error InvalidTokenId();

    /**
     * @notice Returns the count of batches of NFTs.
     * @dev Each batch of tokens has an in ID and an associated `baseURI`. See {batchIds}.
     * @return (uint256) Base URI Length
     */
    function baseURILength() public view returns (uint256) {
        return _batchIds.length;
    }

    /**
     * @notice Returns the ID for the batch of tokens the given tokenId belongs to.
     * @dev See {baseURILength}.
     * @param index_ (uint256) Batch ID
     * @return (uint256) Batch ID
     */
    function batchIdAtIndex(uint256 index_) public view returns (uint256) {
        if (index_ >= baseURILength()) {
            revert InvalidIndex();
        }

        return _batchIds[index_];
    }

    /**
     * @dev Returns the id for the batch of tokens the given tokenId belongs to.
     * @param tokenId_ (uint256) Token ID
     * @return batchId (uint256) Batch ID
     * @return index (uint256) Index
     */
    function _getBatchId(uint256 tokenId_)
        internal
        view
        returns (uint256 batchId, uint256 index)
    {
        uint256[] memory batchIds = _batchIds;
        uint256 length = baseURILength();

        for (uint256 i; i < length; ++i) {
            if (tokenId_ < batchIds[i]) {
                index = i;
                batchId = batchIds[i];

                return (batchId, index);
            }
        }

        revert InvalidTokenId();
    }

    /**
     * @dev Returns the baseURI for a token. The intended metadata URI for the token is baseURI + tokenId.
     * @param tokenId_ (uint256) Token ID
     * @return (string memory) Base URI
     */
    function _getBaseURI(uint256 tokenId_)
        internal
        view
        returns (string memory)
    {
        uint256[] memory batchIds = _batchIds;
        uint256 length = baseURILength();

        for (uint256 i; i < length; ++i) {
            if (tokenId_ < batchIds[i]) {
                return _baseURIs[batchIds[i]];
            }
        }

        revert InvalidTokenId();
    }

    /**
     * @dev Sets the base URI for the batch of tokens with the given batchId.
     * @param batchId_ (uint256) Batch ID
     * @param baseURI_ (string memory) Base URI
     */
    function _setBaseURI(uint256 batchId_, string memory baseURI_) internal {
        _baseURIs[batchId_] = baseURI_;
    }

    /**
     * @dev Mints a batch of tokenIds and associates a common baseURI to all those Ids.
     * @param startId_ (uint256) Start token ID
     * @param amount_ (uint256) Amount to mint
     * @param baseURI_ (string memory) Base URI
     * @return nextTokenId (uint256) Next token ID
     * @return batchId (uint256) Batch ID
     */
    function _batchMintMetadata(
        uint256 startId_,
        uint256 amount_,
        string memory baseURI_
    ) internal returns (uint256 nextTokenId, uint256 batchId) {
        batchId = startId_ + amount_;
        nextTokenId = batchId;

        _batchIds.push(batchId);
        _baseURIs[batchId] = baseURI_;
    }
}
