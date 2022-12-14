// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./BZAccessControl.sol";

contract InheritContract is BZAccessControl {
    constructor() {
        _grantAdminRole(msg.sender);
    }

    function senderProtected(bytes32 role) public onlyRole(role) {}
}
