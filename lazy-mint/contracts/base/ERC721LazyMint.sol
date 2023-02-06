// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

// Interfaces
import "../interface/IERC721Claimable.sol";
// Base
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/utils/Multicall.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
// Extensions
import "../extension/BatchMintMetadata.sol";
// Modules
import "../LazyMint.sol";

/**
 * @title ERC721LazyMint
 * @notice Base ERC721 contract with LazyMint functionality added.
 * @dev
 * BASE: ERC721
 * EXTENSION: LazyMint
 * The `ERC721LazyMint` smart contract implements the ERC721 NFT standard.
 * It includes the following additions to standard ERC721 logic:
 *  - Lazy minting
 *  - Ownership of the contract, with the ability to restrict certain functions to only be called by the contract's owner.
 *  - Multicall capability to perform multiple actions atomically
 * 'Lazy minting' means defining the metadata of NFTs without minting it to an address. Regular 'minting'
 * of NFTs means actually assigning an owner to an NFT.
 * As a contract admin, this lets you prepare the metadata for NFTs that will be minted by an external party,
 * without paying the gas cost for actually minting the NFTs.
 * @author kazunetakeda25
 */
contract ERC721LazyMint is
    ERC721,
    IERC721Claimable,
    BatchMintMetadata,
    LazyMint,
    Multicall,
    Ownable,
    ReentrancyGuard
{
    using Counters for Counters.Counter;
    using Strings for uint256;

    Counters.Counter private _tokenIdCounter;

    error InvalidClaimQuantity();

    constructor(string memory name_, string memory symbol_)
        ERC721(name_, symbol_)
    {}

    /**
     * @notice The tokenId assigned to the next new NFT to be lazy minted.
     * @return (uint256) Next token ID to mint
     */
    function nextTokenIdToMint() public view virtual returns (uint256) {
        return _nextTokenId;
    }

    /**
     * @notice The tokenId assigned to the next new NFT to be claimed.
     * @return (uint256) Next token ID to claim
     */
    function nextTokenIdToClaim() public view virtual returns (uint256) {
        return _tokenIdCounter.current();
    }

    /**
     * @inheritdoc ERC721
     */
    function supportsInterface(bytes4 interfaceId)
        public
        view
        virtual
        override
        returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }

    /**
     * @notice Returns the metadata URI for an NFT.
     * @dev See `BatchMintMetadata` for handling of metadata in this contract.
     * @param tokenId_ (uint256) The tokenId of an NFT.
     * @return (string memory) Token URI
     */
    function tokenURI(uint256 tokenId_)
        public
        view
        virtual
        override
        returns (string memory)
    {
        string memory batchURI = _getBaseURI(tokenId_);

        return string(abi.encodePacked(batchURI, tokenId_.toString()));
    }

    /**
     * @notice Override this function to add logic for claim verification, based on conditions
     * such as allowlist, price, max quantity etc.
     * @dev Checks a request to claim NFTs against a custom condition.
     * Add your claim verification logic by overriding this function.
     * @param to_ (address) Caller of the claim function.
     * @param quantity_ (uint256) The number of NFTs being claimed.
     */
    function verifyClaim(address to_, uint256 quantity_) public view virtual {}

    /**
     * @notice Lets an owner or approved operator burn the NFT of the given tokenId.
     * @dev ERC721A's `_burn(uint256,bool)` internally checks for token approvals.
     * @param tokenId_ (uint256) The tokenId of the NFT to burn.
     */
    function burn(uint256 tokenId_) external virtual {
        _burn(tokenId_);
    }

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
    function claim(address to_, uint256 quantity_)
        external
        payable
        nonReentrant
    {
        if (_tokenIdCounter.current() + quantity_ > _nextTokenId) {
            revert InvalidClaimQuantity();
        }

        verifyClaim(msg.sender, quantity_);

        uint256 startTokenId = _transferTokensOnClaim(to_, quantity_);

        emit TokensClaimed(msg.sender, to_, startTokenId, quantity_);
    }

    /**
     * @notice Mints tokens to receiver on claim.
     * Any state changes related to `claim` must be applied here by overriding this function.
     * @dev Override this function to add logic for state updation.
     * When overriding, apply any state changes before `_safeMint`.
     * @param to_ (address) The recipient of the NFT to mint.
     * @param quantity_ (uint256) The number of NFTs to mint.
     * @return startTokenId (uint256) Start token ID
     */
    function _transferTokensOnClaim(address to_, uint256 quantity_)
        internal
        virtual
        returns (uint256 startTokenId)
    {
        startTokenId = nextTokenIdToClaim();

        _safeMint(to_, quantity_);
    }

    /**
     * @dev Returns whether lazy minting can be done in the given execution context.
     * @return (bool) Can lazy mint
     */
    function _canLazyMint() internal view virtual override returns (bool) {
        return msg.sender == owner();
    }
}
