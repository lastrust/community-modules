// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {IERC721} from "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import {IERC1155} from "@openzeppelin/contracts/token/ERC1155/IERC1155.sol";

interface IPermissionVault {
  function setPaused(bool newPaused) external;

  function addController(address controller) external;

  function removeController(address controller) external;

  function depositEther() external payable;

  function withdrawEther(address to, uint256 amount) external;

  function depositERC20(IERC20 token, uint256 amount) external;

  function withdrawERC20(address to, IERC20 token, uint256 amount) external;

  function depositERC721(IERC721 token, uint256 id) external;

  function withdrawERC721(address to, IERC721 token, uint256 id) external;

  function depositERC1155(IERC1155 token, uint256 id, uint256 amount) external;

  function withdrawERC1155(
    address to,
    IERC1155 token,
    uint256 id,
    uint256 amount
  ) external;
}
