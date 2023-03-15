// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/AccessControl.sol";

/**
 * @dev Contract module which extends the basic access control mechanism of Ownable
 * to include many maintainers, whom only the owner (DEFAULT_ADMIN_ROLE) may add and
 * remove.
 *
 * By default, the owner account will be the one that deploys the contract. This can
 * later be changed with {transferOwnership}.
 *
 * This module is used through inheritance. It will make available this modifier:
 * `onlyMaintainer`, which can be applied to your functions to restrict their use to
 * the accounts with the role of maintainer.
 */

abstract contract Maintainable is Context, AccessControl {
    bytes32 public constant MAINTAINER_ROLE = keccak256("MAINTAINER_ROLE");

    modifier onlyMaintainer() {
        address msgSender = _msgSender();
        require(
            hasRole(MAINTAINER_ROLE, msgSender),
            "Maintainable: Caller is not a maintainer"
        );
        _;
    }

    /**
     @dev Initialize the contract by setting up role
     */
    constructor() {
        address msgSender = _msgSender();
        // members of the DEFAULT_ADMIN_ROLE alone may revoke and grant role membership
        _setupRole(DEFAULT_ADMIN_ROLE, msgSender);
        _setupRole(MAINTAINER_ROLE, msgSender);
    }

    /**
     * @notice Grant maintainer role to the address
     * @param addedMaintainer Address of the new maintainer
     */
    function addMaintainer(address addedMaintainer) public virtual {
        grantRole(MAINTAINER_ROLE, addedMaintainer);
    }

    /**
     * @notice Remove maintainer role from the address
     * @param removedMaintainer Address to remove the role
     */
    function removeMaintainer(address removedMaintainer) public virtual {
        revokeRole(MAINTAINER_ROLE, removedMaintainer);
    }

    /**
     * @notice Renounce the role
     * @param role Role to renounce
     */
    function renounceRole(bytes32 role) public virtual {
        address msgSender = _msgSender();
        renounceRole(role, msgSender);
    }

    /**
     * @notice Transfer the ownership to the new address
     * @param newOwner Address of the new owner
     */
    function transferOwnership(address newOwner) public virtual {
        address msgSender = _msgSender();
        grantRole(DEFAULT_ADMIN_ROLE, newOwner);
        renounceRole(DEFAULT_ADMIN_ROLE, msgSender);
    }
}
