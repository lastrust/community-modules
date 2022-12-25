# AccessControl Module


## Overview

Contract module that allows user to implement role-based access control mechanisms.
Its usage is straightforward: for each role that you want to define, you will create a new role identifier that is used to grant, revoke, and check if an account has that role.
You can connect `AdminRole` using `connectOtherContracts` function.

Roles are referred to by their `bytes32` identifier. These should be exposed
in the external API and be unique. The best way to achieve this is by
using `public constant` hash digests:

```
bytes32 public constant MY_ROLE = keccak256("MY_ROLE");
```

Roles can be used to represent a set of permissions. To restrict access to a
function call, use {hasRole}:

```
function foo() public {
    require(hasRole(MY_ROLE, msg.sender));
    ...
}
```

Roles can be granted and revoked dynamically via the {grantRole} and
{revokeRole} functions. Each role has an associated admin role, and only
accounts that have a role's admin role can call {grantRole} and {revokeRole}.

By default, the admin role for all roles is `DEFAULT_ADMIN_ROLE`, which means
that only accounts with this role will be able to grant or revoke other
roles. More complex role relationships can be created by using
{_setRoleAdmin}.

WARNING: The `DEFAULT_ADMIN_ROLE` is also its own admin: it has permission to
grant and revoke this role. Extra precautions should be taken to secure
accounts that have been granted it.

## How to Use
1. Deploy smart contract via `Bunzz`
2. Set `Default AdminRole` address by calling `connectToOtherContracts` function.
3. Using `grantRole`, `revokeRole` function, AdminRole users/contracts can grant/revoke roles and users can renounce their role using `renounceRole` function.
4. AdminRole users/contracts can set the role admin by calling `setRoleAdmin` function and users can get RoleAdmin by calling `getRoleAdmin` function.
5. Users can check if the address has role using `hasRole` function and by calling `getRoleCount` and `getRoleAt` function to get count of addresses and addresses for the  roles.

## Functions


### `connectToOtherContracts`

`Bunzz` style function.
`contracts` length is 1 and contracts[0] is default admin role address.

| name        | type             | description                       |
| :---        |    :----:        |          ---:                     |
| contracts   |address[] calldata| Default admin role address        |

### `hasRole`
Returns `true` if `account` has been granted `role`.

### `grantRole`
Grants `role` to `account`.

### `revokeRole`
Revokes `role` from `account`.

### `renounceRole`
Revokes `role` from the calling account.

### `setRoleAdmin`
Sets `adminRole` as ``role``'s admin role.

### `getRoleAdmin`
Returns the admin role of the `role`.

### `getRoleAt`
Returns one of the accounts that have `role` by `index`. `index` must be a value between 0 and {getRoleCount}.

### `getRoleCount`
Returns the number of accounts that have `role`.