// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/**
 * @dev Interface of Bunzz Access Control
 */

interface IBZAccessControl {
    event AdminRoleChanged(
        bytes32 indexed role,
        bytes32 indexed previousAdminRole,
        bytes32 indexed newAdminRole
    );

    event RoleGranted(
        bytes32 indexed role,
        address indexed account,
        address indexed sender
    );

    event RoleRevoked(
        bytes32 indexed role,
        address indexed account,
        address indexed sender
    );

    event RoleRenounced(bytes32 indexed role, address indexed account);

    function hasRole(bytes32 role, address account)
        external
        view
        returns (bool);

    function grantRole(bytes32 role, address account) external;

    function revokeRole(bytes32 role, address account) external;

    function renounceRole(bytes32 role, address account) external;

    function setRoleAdmin(bytes32 role, bytes32 adminRole) external;

    function getRoleAdmin(bytes32 role) external view returns (bytes32);

    function getRoleAt(bytes32 role, uint256 index)
        external
        view
        returns (address);

    function getRoleCount(bytes32 role) external view returns (uint256);
}
