// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/test.sol";

import "./utils/MockEIP2612.sol";
import "./utils/SigUtils.sol";

contract EIP2612Test is Test {
    MockEIP2612 internal token;
    SigUtils internal sigUtils;

    uint256 internal ownerPrivateKey;
    uint256 internal spenderPrivateKey;

    address internal owner;
    address internal spender;

    ///////////////////////////////////////
    // Setup
    ///////////////////////////////////////
    function setUp() public {
        token = new MockEIP2612();
        sigUtils = new SigUtils(token.DOMAIN_SEPARATOR());

        ownerPrivateKey = 0xA11CE;
        spenderPrivateKey = 0xB0B;

        owner = vm.addr(ownerPrivateKey);
        spender = vm.addr(spenderPrivateKey);

        token.mint(owner, 1e18);
    }

    ///////////////////////////////////////
    // Permit
    ///////////////////////////////////////
    function test_Permit() public {
        SigUtils.Permit memory permit = SigUtils.Permit({
            owner: owner,
            spender: spender,
            value: 1e18,
            nonce: token.nonces(owner),
            deadline: 1 days
        });

        bytes32 digest = sigUtils.getTypedDataHash(permit);

        (uint8 v, bytes32 r, bytes32 s) = vm.sign(ownerPrivateKey, digest);

        token.permit(
            permit.owner,
            permit.spender,
            permit.value,
            permit.deadline,
            v,
            r,
            s
        );

        assertEq(token.allowance(owner, spender), 1e18);
        assertEq(token.nonces(owner), 1);
    }

    function testRevert_ExpiredPermit() public {
        SigUtils.Permit memory permit = SigUtils.Permit({
            owner: owner,
            spender: spender,
            value: 1e18,
            nonce: token.nonces(owner),
            deadline: 1 days
        });

        bytes32 digest = sigUtils.getTypedDataHash(permit);

        (uint8 v, bytes32 r, bytes32 s) = vm.sign(ownerPrivateKey, digest);

        vm.warp(1 days + 1 seconds);

        vm.expectRevert("PERMIT_DEADLINE_EXPIRED");
        token.permit(
            permit.owner,
            permit.spender,
            permit.value,
            permit.deadline,
            v,
            r,
            s
        );
    }

    function testRevert_InvalidSigner() public {
        SigUtils.Permit memory permit = SigUtils.Permit({
            owner: owner,
            spender: spender,
            value: 1e18,
            nonce: token.nonces(owner),
            deadline: 1 days
        });

        bytes32 digest = sigUtils.getTypedDataHash(permit);

        // using the SPENDER's private key
        (uint8 v, bytes32 r, bytes32 s) = vm.sign(spenderPrivateKey, digest);

        vm.expectRevert("INVALID_SIGNER");
        token.permit(
            permit.owner,
            permit.spender,
            permit.value,
            permit.deadline,
            v,
            r,
            s
        );
    }

    function testRevert_InvalidNonce() public {
        SigUtils.Permit memory permit = SigUtils.Permit({
            owner: owner,
            spender: spender,
            value: 1e18,
            nonce: token.nonces(owner) + 1, // invalid nonce
            deadline: 1 days
        });

        bytes32 digest = sigUtils.getTypedDataHash(permit);

        (uint8 v, bytes32 r, bytes32 s) = vm.sign(ownerPrivateKey, digest);

        vm.expectRevert("INVALID_SIGNER");
        token.permit(
            permit.owner,
            permit.spender,
            permit.value,
            permit.deadline,
            v,
            r,
            s
        );
    }

    function testRevert_SignatureReplay() public {
        SigUtils.Permit memory permit = SigUtils.Permit({
            owner: owner,
            spender: spender,
            value: 1e18,
            nonce: token.nonces(owner),
            deadline: 1 days
        });

        bytes32 digest = sigUtils.getTypedDataHash(permit);

        (uint8 v, bytes32 r, bytes32 s) = vm.sign(ownerPrivateKey, digest);

        token.permit(
            permit.owner,
            permit.spender,
            permit.value,
            permit.deadline,
            v,
            r,
            s
        );

        vm.expectRevert("INVALID_SIGNER");
        token.permit(
            permit.owner,
            permit.spender,
            permit.value,
            permit.deadline,
            v,
            r,
            s
        );
    }

    ///////////////////////////////////////
    // transferFrom
    ///////////////////////////////////////
    function test_TransferFromLimitedPermit() public {
        SigUtils.Permit memory permit = SigUtils.Permit({
            owner: owner,
            spender: spender,
            value: 1e18,
            nonce: token.nonces(owner),
            deadline: 1 days
        });

        bytes32 digest = sigUtils.getTypedDataHash(permit);
        (uint8 v, bytes32 r, bytes32 s) = vm.sign(ownerPrivateKey, digest);

        token.permit(
            permit.owner,
            permit.spender,
            permit.value,
            permit.deadline,
            v,
            r,
            s
        );

        assertEq(token.allowance(owner, spender), 1e18);

        vm.prank(spender);
        token.transferFrom(owner, spender, 1e18);

        assertEq(token.balanceOf(owner), 0);
        assertEq(token.balanceOf(spender), 1e18);
        assertEq(token.allowance(owner, spender), 0);
    }

    function test_TransferFromMaxPermit() public {
        SigUtils.Permit memory permit = SigUtils.Permit({
            owner: owner,
            spender: spender,
            value: type(uint256).max,
            nonce: token.nonces(owner),
            deadline: 1 days
        });

        bytes32 digest = sigUtils.getTypedDataHash(permit);
        (uint8 v, bytes32 r, bytes32 s) = vm.sign(ownerPrivateKey, digest);

        token.permit(
            permit.owner,
            permit.spender,
            permit.value,
            permit.deadline,
            v,
            r,
            s
        );

        assertEq(token.allowance(owner, spender), type(uint256).max);

        vm.prank(spender);
        token.transferFrom(owner, spender, 1e18);

        assertEq(token.balanceOf(owner), 0);
        assertEq(token.balanceOf(spender), 1e18);
        assertEq(token.allowance(owner, spender), type(uint256).max);
    }
}
