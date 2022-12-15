# AccessControl Module


## Overview

Using AccessControl Module, users can define multiple roles and manage the user access by the roles. Users can create a new role identifier (AdminRole) that is used to grant, revoke, and check if the account has the role. You can connect the contract as the AdminRole using connectOtherContracts function.

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