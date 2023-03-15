// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {SafeERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

import {MerkleDistributor} from "./MerkleDistributor.sol";
import {IBunzz} from "./interfaces/IBunzz.sol";

contract MerkleTreeAirdrop is IBunzz, Ownable, MerkleDistributor {
  using SafeERC20 for IERC20;

  event Claimed(uint256 index, address account, uint256 amount);

  address public token;

  constructor(bytes32 merkleRoot_) {
    __MerkleDistributor_init(merkleRoot_);
  }

  function connectToOtherContracts(
    address[] calldata contracts
  ) external override onlyOwner {
    require(contracts.length > 0, "No contract to connect");
    require(token != address(0x0), "Token address was already set");
    token = contracts[0];
  }

  /**
   * @dev Claims a token distribution
   * @param index The merkle tree index
   * @param account The account that is claiming tokens
   * @param amount The amount of tokens to claim
   * @param merkleProof The merkle proofs
   */
  function claim(
    uint256 index,
    address account,
    uint256 amount,
    bytes32[] calldata merkleProof
  ) external {
    require(!isClaimed(index), "Tokens already claimed.");

    // Verify the merkle proof.
    bytes32 node = keccak256(abi.encodePacked(index, account, amount));
    _verifyClaim(merkleProof, node);

    // Mark it claimed and send the token.
    _setClaimed(index);

    IERC20(token).safeTransfer(account, amount);

    emit Claimed(index, account, amount);
  }
}
