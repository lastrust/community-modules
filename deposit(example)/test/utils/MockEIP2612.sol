// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "../../src/EIP2612.sol";

contract MockEIP2612 is EIP2612 {
    constructor() EIP2612("Mock Token", "Mock", "1.0.0", 18) {}

    function mint(address _to, uint256 _amount) public {
        _mint(_to, _amount);
    }
}
