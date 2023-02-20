// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "./Base64.sol";
import "./interfaces/IBase64Wrapper.sol";

contract Base64Wrapper is IBase64Wrapper {
    function encode(bytes memory data)
        external
        pure
        override
        returns (string memory)
    {
        return Base64.encode(data);
    }

    function decode(string memory data)
        external
        pure
        override
        returns (bytes memory result)
    {
        return Base64.decode(data);
    }
}
