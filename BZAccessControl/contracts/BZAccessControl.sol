// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/utils/Context.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";
import "./interfaces/IBZAccessControl.sol";
import "./interfaces/IBunzz.sol";
import "@openzeppelin/contracts/utils/introspection/ERC165.sol";

contract BZAccessControl is Context, Ownable, IBZAccessControl, IBunzz, ERC165 {
    using EnumerableSet for EnumerableSet.AddressSet;

    struct RoleData {
        EnumerableSet.AddressSet accounts;
        bytes32 adminRole;
    }

    mapping(bytes32 => RoleData) private _roles;

    bytes32 public constant DEFAULT_ADMIN_ROLE = 0x00;

    constructor() {
        _grantAdminRole(_msgSender());
    }

    function connectToOtherContracts(address[] calldata _contracts)
        public
        override
        onlyOwner
    {
        _grantAdminRole(_contracts[0]);
    }

    modifier onlyRole(bytes32 role) {
        _checkRole(role, _msgSender());
        _;
    }

    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return interfaceId == type(IBZAccessControl).interfaceId || super.supportsInterface(interfaceId);
    }

    function hasRole(bytes32 role, address account) public view returns (bool) {
        return _roles[role].accounts.contains(account);
    }

    function grantRole(bytes32 role, address account)
        public
        onlyRole(getRoleAdmin(role))
    {
        _grantRole(role, account);
    }

    function revokeRole(bytes32 role, address account)
        public
        onlyRole(getRoleAdmin(role))
    {
        _revokeRole(role, account);
    }

    function renounceRole(bytes32 role, address account) public onlyRole(role) {
        _renounceRole(role, account);
    }

    function getRoleAdmin(bytes32 role) public view returns (bytes32) {
        return _roles[role].adminRole;
    }

    function setRoleAdmin(bytes32 role, bytes32 adminRole)
        public
        onlyRole(getRoleAdmin(role))
    {
        _setRoleAdmin(role, adminRole);
    }

    function getRoleAt(bytes32 role, uint256 index)
        public
        view
        returns (address)
    {
        return _roles[role].accounts.at(index);
    }

    function getRoleCount(bytes32 role) public view returns (uint256) {
        return _roles[role].accounts.length();
    }

    function _checkRole(bytes32 role, address account) internal view {
        if (!hasRole(role, account)) {
            revert(
                string(
                    abi.encodePacked(
                        "BZAccessControl: account ",
                        Strings.toHexString(uint160(account), 20),
                        " is missing role ",
                        Strings.toHexString(uint256(role), 32)
                    )
                )
            );
        }
    }

    function _setRoleAdmin(bytes32 role, bytes32 adminRole) internal {
        bytes32 previousAdminRole = getRoleAdmin(role);
        _roles[role].adminRole = adminRole;

        emit AdminRoleChanged(role, previousAdminRole, adminRole);
    }

    function _grantAdminRole(address account) internal {
        if (!hasRole(DEFAULT_ADMIN_ROLE, account)) {
            _roles[DEFAULT_ADMIN_ROLE].accounts.add(account);

            emit RoleGranted(DEFAULT_ADMIN_ROLE, account, _msgSender());
        }
    }

    function _grantRole(bytes32 role, address account) internal {
        require(
            role != DEFAULT_ADMIN_ROLE,
            "BZAccessControl: can only grant default admin role"
        );
        if (!hasRole(role, account)) {
            _roles[role].accounts.add(account);

            emit RoleGranted(role, account, _msgSender());
        }
    }

    function _revokeRole(bytes32 role, address account) internal {
        require(
            role != DEFAULT_ADMIN_ROLE,
            "BZAccessControl: can only revoke default admin role"
        );
        if (hasRole(role, account)) {
            _roles[role].accounts.remove(account);

            emit RoleRevoked(role, account, _msgSender());
        }
    }

    function _renounceRole(bytes32 role, address account) internal {
        require(
            account == _msgSender(),
            "BZAccessControl: can only renounce role for self"
        );

        if (hasRole(role, account)) {
            _roles[role].accounts.remove(account);

            emit RoleRenounced(role, account);
        }
    }
}
