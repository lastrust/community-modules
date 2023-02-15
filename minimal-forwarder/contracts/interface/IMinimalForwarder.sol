// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IMinimalForwarder {
    struct ForwardRequest {
        address from;
        address to;
        uint256 value;
        uint256 gas;
        uint256 nonce;
        bytes data;
    }

    function getNonce(address from_) external view returns (uint256);

    function verify(ForwardRequest calldata req_, bytes calldata signature_)
        external
        view
        returns (bool);

    function execute(ForwardRequest calldata req_, bytes calldata signature_)
        external
        payable
        returns (bool, bytes memory);
}
