// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {Counters} from "@openzeppelin/contracts/utils/Counters.sol";
import {ERC721} from "@openzeppelin/contracts/token/ERC721/ERC721.sol";

contract MockERC721 is Ownable, ERC721 {
  using Counters for Counters.Counter;

  Counters.Counter internal _total;

  constructor(string memory name, string memory symbol) ERC721(name, symbol) {}

  function mintTo(address account, uint256 tokenId) public onlyOwner {
    _safeMint(account, tokenId);
  }

  function mintBulkTo(address account, uint256 amount) external onlyOwner {
    for (uint256 i = 0; i < amount; i++) {
      _total.increment();
      mintTo(account, _total.current());
    }
  }
}
