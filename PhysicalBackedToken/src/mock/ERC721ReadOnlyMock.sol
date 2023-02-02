// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

// Utils
import "../util/ERC721ReadOnly.sol";

contract ERC721ReadOnlyMock is ERC721ReadOnly {
    constructor(string memory name_, string memory symbol_)
        ERC721ReadOnly(name_, symbol_)
    {}

    function mint(address to, uint256 tokenId) public {
        _mint(to, tokenId);
    }
}
