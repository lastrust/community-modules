# Base64 Module

## Overview

Wrapper contract based on Base64 library.
`Base64` allows users to transform `bytes32` data into its Base64 `string` and Base64 `string` to `bytes32` data representation.
This is especially useful for building URL-safe tokenURIs for both `ERC721` or `ERC1155`. This module provides a clever way to serve URL-safe Data URI compliant strings to serve on-chain data structures.

## How to Use
1. Deploy smart contract via `Bunzz`
2. Encode `bytes32` to Base64 encoded string using `encode` function.

```
await base64Wrapper.encode(web3.utils.asciiToHex('test'));
```

3. Also decode Base64 encoded `bytes32` using `decode` function.

```
await base64Wrapper.decode('TQ==');
```

## Functions

### encode

Converts a `bytes32` to its Bytes64 `string` representation.

| name        | type             | description       |
| :---        |    :----:        |          ---:     |
| data        |bytes memory      | data to encode    |

### decode

Converts a Base64 encoded `string` to `bytes32` representation.

| name        | type             | description       |
| :---        |    :----:        |          ---:     |
| data        |string memory     | string to decode  |