// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import "../libraries/PoolAddress.sol";

contract MockPoolAddress {
    function computeAddress(
        address factory,
        address tokenA,
        address tokenB,
        uint24 fee
    ) external pure returns (address) {
        return
            PoolAddress.computeAddress(
                factory,
                PoolAddress.getPoolKey(tokenA, tokenB, fee)
            );
    }
}
