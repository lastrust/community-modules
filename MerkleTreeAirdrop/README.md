# MerkleTreeAirdrop

## Overview

Requires a list of wallet address and root hash which are the leaves and merkle proofs needed to verify that a given data exists for that address in the tree.
Contract acts as Airdrop for ERC20 and only sends out tokens on data verification i.e merkle proof and appropriate arguments used to build the merkle tree for that user.

## How to use

1. Prepare an ERC20 token as an airdrop token. You can use existing token or deploy a new ERC20 token on DApps page.
2. Prepare the whitelist and their drop amount, generate the merkle tree and output to the JSON file. Check JSON file format in `test/resources/airdrop/testMerkle.json`.
   It contains the merkle root, total token amount for airdrop, individual token amounts and list of merkle proof.
3. Deploy `MerkleTreeAirdrop` contract with merkle root.
4. Transfer drop assets to this contract.
5. Beneficiaries can claim their drop tokens by `claim` function.
6. Only verified users can claim.

## Functions

### WRITE

#### isClaimed

Used to check if a merkle claim has been claimed from the merkle tree.

| name  |  type   |       description |
| :---- | :-----: | ----------------: |
| index | uint256 | merkle tree index |

#### claim

Claim drop tokens to account who would be verified through merkle tree.

| name        |   type   |                     description |
| :---------- | :------: | ------------------------------: |
| index       | uint256  |               merkle tree index |
| account     | address  | account that is claiming tokens |
| amount      | uint256  |       amount of tokens to claim |
| merkleProof | byte32[] |                   merkle proofs |

### READ

#### isClaimed

Used to check if a merkle claim has been claimed from the merkle tree.

| name  |  type   |            description |
| :---- | :-----: | ---------------------: |
| index | uint256 | The index of the award |
