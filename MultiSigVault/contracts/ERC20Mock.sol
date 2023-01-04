// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract ERC20Mock is ERC20 {
    uint256 private initalSupply = 10**6 * 1e18;

    constructor(string memory name_, string memory symbol_)
        ERC20(name_, symbol_)
    {
        _mint(msg.sender, initalSupply);
    }
}
