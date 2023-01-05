// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

/**
 * @dev External interface of Base64Wrapper
 */

interface IBase64Wrapper {
    function encode(bytes memory data) external pure returns (string memory);

    function decode(string memory data)
        external
        pure
        returns (bytes memory result);
}
