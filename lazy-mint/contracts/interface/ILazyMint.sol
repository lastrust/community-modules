// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/**
 * @notice The `LazyMint` is a contract extension for any base NFT contract.
 * It lets you 'lazy mint' any number of NFTs at once.
 * @author kazunetakeda25
 */
interface ILazyMint {
    /**
     * @dev Emitted when tokens are lazy minted.
     */
    event TokensLazyMinted(
        address indexed minter,
        uint256 indexed startTokenId,
        uint256 endTokenId,
        string baseURI,
        bytes data
    );

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
    ) external returns (uint256 batchId);
}
