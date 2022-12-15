// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/**
 * @dev External interface of AccessControl declared to support ERC165 detection.
 */

interface IAccessControl {
    /**
     * @dev Emitted when `newAdminRole` is set as ``role``'s admin role, replacing `previousAdminRole`
     *
     * `DEFAULT_ADMIN_ROLE` is the starting admin for all roles, despite
     * {AdminRoleChanged} not being emitted signaling this.
     *
     */
    event AdminRoleChanged(
        bytes32 indexed role,
        bytes32 indexed previousAdminRole,
        bytes32 indexed newAdminRole
    );

    /**
     * @dev Emitted when `account` is granted `role`.
     *
     * `sender` is the account that originated the contract call, an admin role bearer
     */
    event RoleGranted(
        bytes32 indexed role,
        address indexed account,
        address indexed sender
    );

    /**
     * @dev Emitted when `account` is revoked `role`.
     *
     * `sender` is the account that originated the contract call, an admin role bearer
     */
    event RoleRevoked(
        bytes32 indexed role,
        address indexed account,
        address indexed sender
    );

    /**
     * @dev Emitted when `account` is renounced `role`.
     *
     * `sender` is the account that originated the contract call, an role bearer (i.e. `account`)
     */
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
