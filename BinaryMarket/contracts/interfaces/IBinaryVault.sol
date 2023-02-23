// SPDX-License-Identifier: MIT

pragma solidity ^0.8.10;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

interface IBinaryVault {
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
}