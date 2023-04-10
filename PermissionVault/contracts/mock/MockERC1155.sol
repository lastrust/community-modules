// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {ERC1155} from "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";

contract MockERC1155 is Ownable, ERC1155 {
  constructor(string memory uri) ERC1155(uri) {}

  function mintTo(
    address account,
    uint256 tokenId,
    uint256 amount
  ) public onlyOwner {
    _mint(account, tokenId, amount, "");
  }

  function uri(uint256) public pure override returns (string memory) {
    return "uri";
  }
}
