// SPDX-License-Identifier: MIT

pragma solidity ^0.8.10;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

interface IBinaryVault {
    struct TokenOwnership {
        // The address of the owner.
        address addr;
        // Stores the start time of ownership with minimal overhead for tokenomics.
        uint64 startTimestamp;
        // Whether the token has been burned.
        bool burned;
        // Arbitrary data similar to `startTimestamp` that can be set via {_extraData}.
        uint24 extraData;
    }

    function claimBettingRewards(address to, uint256 amount) external;

    /**
    * @dev Supply underlying token to this vault (new position)
    * @param user Receipt for share
    * @param amount Underlying token amount
    */
    function addNewLiquidityPosition(address user, uint256 amount) external;

    /**
    * @dev Add liquidity. Burn existing token, mint new one.
    * @param user Receipt for share
    * @param amount Underlying token amount
    * @param tokenId nft id to be added liquidity. This should be existing id.
    */
    function addLiquidityPosition(address user, uint256 amount, uint256 tokenId) external;

     /**
    * @dev Merge all owned nfts into new one
    */
    function mergeAllPositions(address user) external;

    /**
    * @dev Remove liquidity from position
    * @param user Receipent
    * @param tokenId position that where remove liquidity from
    * @param shareAmount amount of share
    */
    function removeLiquidityPosition(address user, uint256 tokenId, uint256 shareAmount) external;

    /**
    *@dev Remove share, and merge to one
    *@param user receipent
    *@param shareAmount Share amount
    */
    function removeLiquidity(address user, uint256 shareAmount) external;

    /**
    * @dev Get shares of user.
    */
    function getSharesOfUser(address user) external view returns(uint256 shares, uint256 underlyingTokenAmount);

    function getUnderlyingToken() external view returns (IERC20);

        function totalSupply() external view returns (uint256);
            function supportsInterface(bytes4 interfaceId) external view returns (bool);
    function balanceOf(address owner) external view returns (uint256 balance);
    function ownerOf(uint256 tokenId) external view returns (address owner);
    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId,
        bytes calldata data
    ) external;
    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId
    ) external;
    function transferFrom(
        address from,
        address to,
        uint256 tokenId
    ) external;
    function approve(address to, uint256 tokenId) external;
    function setApprovalForAll(address operator, bool _approved) external;
    function getApproved(uint256 tokenId) external view returns (address operator);
    function isApprovedForAll(address owner, address operator) external view returns (bool);
    function name() external view returns (string memory);
    function symbol() external view returns (string memory);
    function tokenURI(uint256 tokenId) external view returns (string memory);
    function explicitOwnershipOf(uint256 tokenId) external view returns (TokenOwnership memory);
    function explicitOwnershipsOf(uint256[] memory tokenIds) external view returns (TokenOwnership[] memory);
    function tokensOfOwnerIn(
        address owner,
        uint256 start,
        uint256 stop
    ) external view returns (uint256[] memory);
    function tokensOfOwner(address owner) external view returns (uint256[] memory);

}