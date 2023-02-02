// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import {ERC721WithOperatorFilterer} from "../src/ERC721WithOperatorFilterer.sol";
import {BaseRegistryTest} from "./BaseRegistryTest.sol";
import {IERC165} from "openzeppelin-contracts/interfaces/IERC165.sol";
import {ERC721Enumerable, ERC721, IERC721, IERC721Enumerable} from "openzeppelin-contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import {IERC2981} from "../src/utils/ERC2981.sol";

contract TestableERC721WithOperatorFilterer is ERC721WithOperatorFilterer {
    constructor(string memory name, string memory symbol, string memory baseTokenURI) ERC721WithOperatorFilterer(name, symbol, baseTokenURI) {
    }
}

contract ExampleERC721Test is BaseRegistryTest {
    TestableERC721WithOperatorFilterer example;
    address filteredAddress;

    address constant DEFAULT_SUBSCRIPTION = address(0x3cc6CddA760b79bAfa08dF41ECFA224f810dCeB6);

    function setUp() public override {
        super.setUp();

        vm.startPrank(DEFAULT_SUBSCRIPTION);
        registry.register(DEFAULT_SUBSCRIPTION);

        filteredAddress = makeAddr("filtered address");
        registry.updateOperator(address(DEFAULT_SUBSCRIPTION), filteredAddress, true);
        vm.stopPrank();

        example = new TestableERC721WithOperatorFilterer("test nft token", "NFT", "test_base_uri");
    }

    function testFilter() public {
        vm.startPrank(address(filteredAddress));
        vm.expectRevert(abi.encodeWithSelector(AddressFiltered.selector, filteredAddress));
        example.transferFrom(makeAddr("from"), makeAddr("to"), 1);
        vm.expectRevert(abi.encodeWithSelector(AddressFiltered.selector, filteredAddress));
        example.safeTransferFrom(makeAddr("from"), makeAddr("to"), 1);
        vm.expectRevert(abi.encodeWithSelector(AddressFiltered.selector, filteredAddress));
        example.safeTransferFrom(makeAddr("from"), makeAddr("to"), 1, "");
    }

    function testOwnersNotExcluded() public {
        address alice = address(0xA11CE);
        example.safeMint(alice, "testToken_1");

        vm.prank(DEFAULT_SUBSCRIPTION);
        registry.updateOperator(address(DEFAULT_SUBSCRIPTION), alice, true);

        vm.prank(alice);
        example.transferFrom(alice, makeAddr("to"), 0);
    }

    function testOwnersNotExcludedSafeTransfer() public {
        address alice = address(0xA11CE);
        example.safeMint(alice, "testToken_2");
        example.safeMint(alice, "testToken_3");
     

        vm.prank(DEFAULT_SUBSCRIPTION);
        registry.updateOperator(address(DEFAULT_SUBSCRIPTION), alice, true);

        vm.startPrank(alice);
        example.safeTransferFrom(alice, makeAddr("to"), 1, "");

    }

    function testExclusionExceptionDoesNotApplyToOperators() public {
        address alice = address(0xA11CE);
        address bob = address(0xB0B);
        example.safeMint(bob, "testToken_4");
        vm.prank(bob);
        example.setApprovalForAll(alice, true);

        vm.prank(DEFAULT_SUBSCRIPTION);
        registry.updateOperator(address(DEFAULT_SUBSCRIPTION), alice, true);

        vm.startPrank(alice);
        vm.expectRevert(abi.encodeWithSelector(AddressFiltered.selector, alice));
        example.transferFrom(bob, makeAddr("to"), 1);
    }

    function testExcludeApprovals() public {
        address alice = address(0xA11CE);
        address bob = address(0xB0B);

        example.safeMint(bob, "testToken_5");

        vm.prank(DEFAULT_SUBSCRIPTION);
        registry.updateOperator(address(DEFAULT_SUBSCRIPTION), alice, true);

        vm.startPrank(bob);
        vm.expectRevert(abi.encodeWithSelector(AddressFiltered.selector, alice));
        example.setApprovalForAll(alice, true);

        vm.expectRevert(abi.encodeWithSelector(AddressFiltered.selector, alice));
        example.approve(alice, 1);
    }

    function testSupportsInterface() public {
        assertTrue(example.supportsInterface(type(IERC165).interfaceId));
        assertTrue(example.supportsInterface(type(IERC2981).interfaceId));
    }
}
