// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./IEIP2612.sol";

contract Deposit {
    address immutable tokenAddress;

    mapping(address => uint256) depositBalances;

    constructor(address _tokenAddress) {
        bytes4 interfaceId = type(IEIP2612).interfaceId;
        require(
            IEIP2612(_tokenAddress).supportsInterface(interfaceId),
            "TOKEN_MUST_BE_EIP2612"
        );
        tokenAddress = _tokenAddress;
    }

    function deposit(
        uint256 amount,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external {
        IEIP2612 token = IEIP2612(tokenAddress);
        token.permit(msg.sender, address(this), amount, deadline, v, r, s);
        token.transferFrom(msg.sender, address(this), amount);

        depositBalances[msg.sender] += amount;
    }

    function withdraw(uint256 amount) external {
        require(depositBalances[msg.sender] >= amount, "INSUFFICIENT_BALANCE");
        depositBalances[msg.sender] -= amount;

        IEIP2612 token = IEIP2612(tokenAddress);
        token.transfer(msg.sender, amount);
    }

    function balanceOf(address user) public returns (uint256) {
        return depositBalances[user];
    }
}
