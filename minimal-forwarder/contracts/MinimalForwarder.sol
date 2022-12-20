// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

// Interfaces
import "./interface/IBunzz.sol";
import "./interface/IMinimalForwarder.sol";
// Openzeppelin
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";
import "@openzeppelin/contracts/utils/cryptography/draft-EIP712.sol";

contract MinimalForwarder is IBunzz, IMinimalForwarder, EIP712, Ownable {
    using ECDSA for bytes32;

    bytes32 private constant _TYPEHASH =
        keccak256(
            "ForwardRequest(address from,address to,uint256 value,uint256 gas,uint256 nonce,bytes data)"
        );
    mapping(address => uint256) private _nonces;

    address public minimalForwarderContract;

    constructor(string memory name_, string memory version_)
        EIP712(name_, version_)
    {}

    function getNonce(address from_) public view returns (uint256) {
        return _nonces[from_];
    }

    function verify(ForwardRequest calldata req_, bytes calldata signature_)
        public
        view
        returns (bool)
    {
        address signer = _hashTypedDataV4(
            keccak256(
                abi.encode(
                    _TYPEHASH,
                    req_.from,
                    req_.to,
                    req_.value,
                    req_.gas,
                    req_.nonce,
                    keccak256(req_.data)
                )
            )
        ).recover(signature_);
        return _nonces[req_.from] == req_.nonce && signer == req_.from;
    }

    function execute(ForwardRequest calldata req_, bytes calldata signature_)
        public
        payable
        returns (bool, bytes memory)
    {
        require(
            verify(req_, signature_),
            "MinimalForwarder: signature does not match request"
        );
        _nonces[req_.from] = req_.nonce + 1;

        (bool success, bytes memory returndata) = req_.to.call{
            gas: req_.gas,
            value: req_.value
        }(abi.encodePacked(req_.data, req_.from));

        // Validate that the relayer has sent enough gas for the call.
        // See https://ronan.eth.limo/blog/ethereum-gas-dangers/
        if (gasleft() <= req_.gas / 63) {
            // We explicitly trigger invalid opcode to consume all gas and bubble-up the effects, since
            // neither revert or assert consume all gas since Solidity 0.8.0
            // https://docs.soliditylang.org/en/v0.8.0/control-structures.html#panic-via-assert-and-error-via-require
            /// @solidity memory-safe-assembly
            assembly {
                invalid()
            }
        }

        return (success, returndata);
    }

    function connectToOtherContracts(address[] calldata contracts)
        external
        override
        onlyOwner
    {
        minimalForwarderContract = contracts[0];
    }
}
