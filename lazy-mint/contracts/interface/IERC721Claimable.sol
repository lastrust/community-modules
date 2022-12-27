// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.0;

interface IERC721Claimable {
    /// @dev Emitted when tokens are claimed
    event TokensClaimed(
        address indexed claimer,
        address indexed receiver,
        uint256 indexed startTokenId,
        uint256 quantityClaimed
    );

    /**
     * @notice Lets an address claim multiple lazy minted NFTs at once to a recipient.
     * This function prevents any reentrant calls, and is not allowed to be overridden.
     * Contract creators should override `verifyClaim` and `transferTokensOnClaim` functions
     * to create custom logic for verification and claiming, for e.g. price collection, allowlist, max quantity, etc.
     * @dev The logic in `verifyClaim` determines whether the caller is authorized to mint NFTs.
     * The logic in `transferTokensOnClaim` does actual minting of tokens, can also be used to apply other state changes.
     * @param to_ (address) The recipient of the NFT to mint.
     * @param quantity_ (uint256) The number of NFTs to mint.
     */
    function claim(address to_, uint256 quantity_) external payable;

    /**
     * @notice Override this function to add logic for claim verification, based on conditions
     * such as allowlist, price, max quantity etc.
     * @dev Checks a request to claim NFTs against a custom condition.
     * Add your claim verification logic by overriding this function.
     * @param to_ (address) Caller of the claim function.
     * @param quantity_ (uint256) The number of NFTs being claimed.
     */
    function verifyClaim(address to_, uint256 quantity_) external view;
}