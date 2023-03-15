// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract MockERC20 is Ownable, ERC20 {
  constructor(string memory name, string memory symbol) ERC20(name, symbol) {}

  function mintTo(address account, uint256 amount) public onlyOwner {
    _mint(account, amount);
  }
}
