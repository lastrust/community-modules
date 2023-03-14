// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./IERC20.sol";

/**
 * @dev Interface of the wrapped native token
 */
interface IWETH is IERC20 {
    /**
     * @dev Withdraw the amount of the wrapped token
     */
    function withdraw(uint256 amount) external;

    /**
     * @dev Deposit the native token
     */
    function deposit() external payable;
}
