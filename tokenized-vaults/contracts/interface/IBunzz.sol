// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/**
 * @title IBunzz
 */
interface IBunzz {
    function connectToOtherContracts(address[] calldata contracts) external;
}
