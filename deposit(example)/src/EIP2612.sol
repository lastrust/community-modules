// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "openzeppelin-contracts/contracts/token/ERC20/ERC20.sol";
import "openzeppelin-contracts/contracts/token/ERC20/IERC20.sol";
import "openzeppelin-contracts/contracts/utils/introspection/ERC165.sol";

import "./IEIP2612.sol";
import "./EIP712.sol";

contract EIP2612 is ERC20, EIP712, IEIP2612, ERC165 {
    bytes32 private constant _PERMIT_TYPEHASH =
        keccak256(
            "Permit(address owner,address spender,uint256 value,uint256 nonce,uint256 deadline)"
        );
    uint8 private immutable _decimals;

    mapping(address => uint256) public nonces;

    constructor(
        string memory _name,
        string memory _symbol,
        string memory _version,
        uint8 decimals
    ) ERC20(_name, _symbol) EIP712(_name, _version) {
        _decimals = decimals;
    }

    function decimals() public view virtual override returns (uint8) {
        return _decimals;
    }

    function permit(
        address owner,
        address spender,
        uint256 value,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) public virtual {
        require(deadline >= block.timestamp, "PERMIT_DEADLINE_EXPIRED");

        unchecked {
            bytes32 structHash = keccak256(
                abi.encode(
                    _PERMIT_TYPEHASH,
                    owner,
                    spender,
                    value,
                    nonces[owner]++,
                    deadline
                )
            );
            bytes32 hash = keccak256(
                abi.encodePacked("\x19\x01", DOMAIN_SEPARATOR(), structHash)
            );
            address recoveredAddress = ecrecover(hash, v, r, s);

            require(
                recoveredAddress != address(0) && recoveredAddress == owner,
                "INVALID_SIGNER"
            );

            _approve(owner, spender, value);
        }
        emit Approval(owner, spender, value);
    }

    function DOMAIN_SEPARATOR() public view virtual returns (bytes32) {
        return _getDomainSeparator();
    }

    function supportsInterface(bytes4 interfaceId)
        public
        view
        virtual
        override(ERC165, IERC165)
        returns (bool)
    {
        return
            interfaceId == type(IEIP2612).interfaceId ||
            interfaceId == type(IERC20).interfaceId ||
            super.supportsInterface(interfaceId);
    }
}
