// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "openzeppelin-contracts/contracts/token/ERC721/ERC721.sol";
import "forge-std/test.sol";
import "forge-std/console.sol";

import "./utils/MockEIP2612.sol";
import "./utils/SigUtils.sol";
import "../src/Deposit.sol";

contract DepoisitTest is Test {
    Deposit internal sut;
    MockEIP2612 internal token;
    SigUtils.Permit internal permit;

    address internal user;
    address internal cracker;

    uint8 internal v;
    bytes32 internal r;
    bytes32 internal s;

    uint256 permitedAmount = 1e18;

    ///////////////////////////////////////
    // Setup
    ///////////////////////////////////////
    function setUp() public {
        uint256 userPrivateKey = 0xA11CE;
        user = vm.addr(userPrivateKey);

        uint256 crackerPrivateKey = 0xB0B;
        cracker = vm.addr(crackerPrivateKey);

        token = new MockEIP2612();
        token.mint(user, 3e18);

        sut = new Deposit(address(token));

        permit = SigUtils.Permit({
            owner: user,
            spender: address(sut),
            value: permitedAmount,
            nonce: token.nonces(user),
            deadline: 1 days
        });
        SigUtils sigUtils = new SigUtils(token.DOMAIN_SEPARATOR());
        bytes32 digest = sigUtils.getTypedDataHash(permit);
        (v, r, s) = vm.sign(userPrivateKey, digest);
    }

    ///////////////////////////////////////
    // constructor
    ///////////////////////////////////////
    function testRevert_ConstructorShouldAcceptOnlyEIP2612() public {
        ERC721 dummy = new ERC721("Test", "TEST");

        vm.expectRevert("TOKEN_MUST_BE_EIP2612");
        Deposit sut = new Deposit(address(dummy));
    }

    ///////////////////////////////////////
    // deposit
    ///////////////////////////////////////
    function test_Deposit() public {
        vm.prank(user);
        sut.deposit(permit.value, permit.deadline, v, r, s);

        assertEq(token.balanceOf(address(sut)), permit.value);
    }

    ///////////////////////////////////////
    // withdraw
    ///////////////////////////////////////
    function test_UserShouldWithdraw() public {
        vm.prank(user);
        sut.deposit(permit.value, permit.deadline, v, r, s);

        vm.prank(user);
        sut.withdraw(permitedAmount);
        assertEq(token.balanceOf(address(sut)), 0);
    }

    function testRevert_AmountShouldNotExceedDeposit() public {
        vm.prank(user);
        sut.deposit(permit.value, permit.deadline, v, r, s);

        uint256 balanceBeforeWithdraw = token.balanceOf(address(sut));
        vm.expectRevert("INSUFFICIENT_BALANCE");
        sut.withdraw(2e18);
        assertEq(token.balanceOf(address(sut)), balanceBeforeWithdraw);
    }

    function testRevert_CrackerShouldNotWithdraw() public {
        vm.prank(user);
        sut.deposit(permit.value, permit.deadline, v, r, s);

        uint256 balanceBeforeWithdraw = token.balanceOf(address(sut));

        vm.prank(cracker);
        vm.expectRevert("INSUFFICIENT_BALANCE");
        sut.withdraw(permitedAmount);

        assertEq(token.balanceOf(address(sut)), balanceBeforeWithdraw);
    }

    ///////////////////////////////////////
    // balanceOf
    ///////////////////////////////////////
    function test_BalanceShouldEqualDepositedAmount() public {
        vm.prank(user);
        sut.deposit(permit.value, permit.deadline, v, r, s);

        assertEq(sut.balanceOf(user), permitedAmount);
    }
}
