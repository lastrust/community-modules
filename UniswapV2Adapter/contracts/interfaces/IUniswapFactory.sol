// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/**
 * @notice Uniswap V2 Factory
 */
interface IUniswapFactory {
    /**
     * @param tokenA tokenA address
     * @param tokenB tokenB address
     * @return pair address
     * @dev get pair address from tokenA and tokenB
     **/
    function getPair(address tokenA, address tokenB)
        external
        view
        returns (address pair);
}
