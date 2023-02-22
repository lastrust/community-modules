# ERC721WithOperatorFitlerer

## Overview

Starting January 2nd, 2023, Opensea will begin validating creator fee enforcement for new collections on all supported EVM chains. After January 2nd, 2023, if OpenSea is unable to validate enforcement, OpenSea will make creator fees optional for that collection. Older collections will continue to have their fees enforced on OpenSea, including on Ethereum Mainnet (previously, enforcement was already required on Ethereum Mainnet).

OpenSea will enforce creator earnings for smart contracts that make best efforts to filter transfers from operators known to not respect creator earnings.

Contract owners may implement their own filtering outside of this registry.
But in this module, we use `OperatorFilterRegistry` deployed by Opensea.


#### Filtered addresses


Ownership of this list [has been transferred](https://etherscan.io/tx/0xf15e8ac08a333b2e4f884250ace94baccf7ba8908c119736d9cc8f063183a496/advanced#eventlog) to the [Creator Ownership Research Institute](https://corinstitute.co/) to administer. You may read more on [OpenSea's Twitter](https://twitter.com/opensea/status/1600913295300792321).

Entries in this list are added according to the following criteria:

-   If the application most commonly used to interface with the contract gives buyers and sellers the ability to bypass creator earnings when a similar transaction for the same item would require creator earnings payment on OpenSea.io
-   If the contract is facilitating the evasion of on-chain creator earnings enforcement measures. For example, the contract uses a wrapper contract to bypass earnings enforcement.

<table>
<tr>
<th>Name</th>
<th>Address</th>
<th>Network</th>
</tr>

<tr>
<td>Blur.io ExecutionDelegate</td>
<td >
0x00000000000111AbE46ff893f3B2fdF1F759a8A8
</td>
<td >
Ethereum Mainnet
</td>
</tr>

<tr>
<td>LooksRare TransferManagerERC721</td>
<td>0xf42aa99F011A1fA7CDA90E5E98b277E306BcA83e</td>
<td>Ethereum Mainnet</td>
</tr>

<tr>
<td>LooksRare TransferManagerERC1155</td>
<td>0xFED24eC7E22f573c2e08AEF55aA6797Ca2b3A051</td>
<td>Ethereum Mainnet</td>
</tr>

<tr>
<td>SudoSwap LSSVMPairEnumerableERC20</td>
<td>0xD42638863462d2F21bb7D4275d7637eE5d5541eB</td>
<td>Ethereum Mainnet</td>
</tr>

<tr>
<td>SudoSwap LSSVMPairEnumerableETH</td>
<td>0x08CE97807A81896E85841d74FB7E7B065ab3ef05</td>
<td>Ethereum Mainnet</td>
</tr>

<tr>
<td>SudoSwap LSSVMPairMissingEnumerableERC20</td>
<td>0x92de3a1511EF22AbCf3526c302159882a4755B22</td>
<td>Ethereum Mainnet</td>
</tr>

<tr>
<td>SudoSwap LSSVMPairMissingEnumerableETH</td>
<td>0xCd80C916B1194beB48aBF007D0b79a7238436D56</td>
<td>Ethereum Mainnet</td>
</tr>

<tr>
<td>SudoSwap LSSVMPairFactory</td>
<td>0xb16c1342E617A5B6E4b631EB114483FDB289c0A4</td>
<td>Ethereum Mainnet</td>
</tr>

<tr>
<td>NFTX NFTXMarketplaceZap</td>
<td>0x0fc584529a2aefa997697fafacba5831fac0c22d</td>
<td>Ethereum Mainnet</td>
</tr>

</table>

Token contracts that wish to manage lists of filtered operators and restrict transfers from them may integrate with the registry easily with tokens using the `OperatorFilterer` and `DefaultOperatorFilterer` contracts. These contracts provide modifiers (`onlyAllowedOperator` and `onlyAllowedOperatorApproval`) which can be used on the token's transfer methods to restrict transfers from or approvals of filtered operators.


#### Deployments

<table>
<tr>
<th>Network</th>
<th>CORI Subscription TimelockController</th>
<th>OperatorFilterRegistry</th>
<th>CORI Curated Subscription Address</th>
</tr>

<tr><td>Ethereum</td>
<td>

0x178AD648e66815E1B01791eBBdbF7b2D7C5B1626

</td>
<td rowspan="20">

[0x000000000000AAeB6D7670E522A718067333cd4E](https://etherscan.io/address/0x000000000000AAeB6D7670E522A718067333cd4E#code)

</td><td rowspan="20">

0x3cc6CddA760b79bAfa08dF41ECFA224f810dCeB6

</td></tr>

<tr>
<td>Polygon</td>

<td>
0x87bCD4735CbCF9CE98ea2822fBf3F05F2ce10f96
</td>
<td></td>
<td></td>
</tr>

<tr><td>Goerli</td><td rowspan="20">0xe3A6CD067a1193b903143C36dA00557c9d95C41e</td></tr>
<tr><td>Mumbai</td></tr>
<tr><td>Optimism</td></tr>
<tr><td>Optimism Goerli</td></tr>
<tr><td>Arbitrum One</td></tr>
<tr><td>Arbitrum Nova</td></tr>
<tr><td>Arbitrum Goerli</td></tr>
<tr><td>Avalanche</td></tr>
<tr><td>Avalanche Fuji</td></tr>
<tr><td>Klaytn</td></tr>
<tr><td>Baobab</td></tr>
<tr><td>BSC</td></tr>
<tr><td>BSC Testnet</td></tr>
<tr><td>Gnosis</td></tr>

</table>

To mitigate abuse of the CORI curated subscription of filtered operators and codehashes, the CORI curated subscription is owned by a `TimelockController`, which is in turn owned by a multi-signature wallet. Any update to CORI's list of filtered operators must be approved by at least two members of the Creator Ownership Research Institute, and is then subject to a minimum 24-hour delay before being executed. During this time, updates may be reviewed and revoked. 

This module provides ERC721 contract to intergrate with [OperatorFilterRegistry](https://etherscan.io/address/0x000000000000AAeB6D7670E522A718067333cd4E) inheriting `OperatorFilterer` and `DefaultOperatorFilterer` contracts.  

Using this module, you can easily create a NFT collection that make best efforts to filter transfers from operators known to not respect creator earnings.

To learn more about NFT token used in this module, please check [NFT (Custom-URI) Created by bunzz](https://app.bunzz.dev/module-templates/b9754505-40f2-4224-b11f-5a08e152fe97)

## How to use

### General steps

1. Prepare the metadata for your tokens and upload them to a centralized solution like s3.
Once you upload the data on s3 or IPFS, you can't change the data. And you save the link with a NFT token onchain. 
2. When deploying the contract, you need to prepare 3 arguments, the first argument is a string and represents the name of the token, the second argument is a string and represent the symbol of the token, the third argument represents the base URI of the collection metadata.
3. After you upload your metadata on s3 in return you will receive a link
4. The link represent your metadata identifier and needs to be used during minting
5. Call the `safeMint` function (it can only be called by the owner), with the first argument representing the address that will receive the nft, and the second argument is the web link that represent the metadata identifier inside the contract.
6. The metadata of a token can be retrieved by calling the `tokenURI` function, which the only argument being the id of the token.
7. A user can call the `transfer` function to transfer his nft’s to another user
8. A user can call `transferFrom` function to transfer nft’s from one user to another if he was approved by the owner of the nft


## Functions

### WRITE

#### transferOwnership

Transfer the ownership rights from one account to another

| name      |  type   |           description   |
| :-------- |:-------:|-----------------------------------: |
| newOwner | address | The account that will get the new owner rights |


#### transferFrom

Transfer a particular tokenId from the token owner to an certai address if the caller have the permision to transfer it

`onlyAllowedOperator(from)` modifier
This modifier will revert if the `from` or its code hash is filtered by the `OperatorFilterRegistry` contract.

| name      |  type   |              description |
| :-------- |:-------:| -----------------------: |
| from | address | The token sender |
| to | address | The token receiver |
| tokenId | uint256 | 	The id of the token |

#### setApprovalForAll

Returns if the operator is allowed to manage all the assets of owner

`onlyAllowedOperatorApproval(operator)` modifier
This modifier will revert if the `operator` or its code hash is filtered by the `OperatorFilterRegistry` contract.

| name      |  type   |              description |
| :-------- |:-------:| -----------------------: |
| operator | address | The account that will have the right to operator over the owner balance |
| approved |  bool   | Status to set or unset the approval over the all tokens for the operator |


#### safeTransferFrom

Transfer tokens from sender to receiver in a safe manner

`onlyAllowedOperator(from)` modifier
This modifier will revert if the `from` or its code hash is filtered by the `OperatorFilterRegistry` contract.

| name      |  type   |              description |
| :-------- |:-------:| -----------------------: |
| from | address | The token sender |
| to | address | The token receiver |
| tokenId | uint256 | The token id |
| _data	 |  bytes  | Optional information to be sent on token transfer |

#### safeTransferFrom

Transfer tokens from sender to receiver in a safe manner

`onlyAllowedOperator(from)` modifier
This modifier will revert if the `from` or its code hash is filtered by the `OperatorFilterRegistry` contract.

| name      |  type   |              description |
| :-------- |:-------:| -----------------------: |
| from | address | The token sender |
| to | address | The token receiver |
| tokenId | uint256 | The token id |

#### safeTransferFrom

Mint new tokens 

| name      |  type   |              description |
| :-------- |:-------:| -----------------------: |
| to | address | The token receiver |
| metadataURI | string  | The uri of the metadata, represented by an ipfs hash or api link |

#### renounceOwnership

Renounce the ownership rights of the contract

#### burn

Set token uri for token id

| name      |  type   |              description |
| :-------- |:-------:| -----------------------: |
| tokenId | uint256 | The id of the tokens category you want to check the balance of |

#### approve

Gives an certain address permision to move tokens for the token owner

`onlyAllowedOperatorApproval(operator)` modifier
This modifier will revert if the `operator` or its code hash is filtered by the `OperatorFilterRegistry` contract.

| name      |  type   |              description |
| :-------- |:-------:| -----------------------: |
| operator  | address | The address to approve as an operator over the caller token |
| tokenId   | uint256 | The id of the token you want to give the operator right to operate over |


### READ

#### totalSupply

Returns the amount of tokens in existence

#### tokenURI

Returns the uri of the metadata

| name    |  type   |  description |
| :------ | :-----: | -----------: |
| tokenId | uint256 | The id of the token |

#### tokenOfOwnerByIndex

Returns all the tokens owned by an address and given index

| name    |  type   |  description |
| :------ | :-----: | -----------: |
| owner | address | The account on which you want to retrieve the token index upon |
| index | uint256 | The id of the token |

#### tokenOfOwnerByIndex

Returns a token ID at a given index of all the tokens stored by the contract. Use along with totalSupply to enumerate all tokens

| name    |  type   |  description |
| :------ | :-----: | -----------: |
| index | uint256 | The index of the token in the owner list |

#### symbol

Returns the symbol of the collection

#### supportsInterface

Returns a boolean that tells us if the contract supports royalties

| name    |  type   |  description |
| :------ | :-----: | -----------: |
| interfaceId | bytes4 | The index of the token in the owner list |

#### ownerOf

| name    |  type   |  description |
| :------ | :-----: | -----------: |
| tokenId | uint256 | The id of the token |

#### owner

Returns the owner of the contract

#### name

Returns the name of the collection

#### isApprovedForAll

Retrieves if a user is approved to operate over all the tokens owned by another user

| name    |  type   |  description |
| :------ | :-----: | -----------: |
| owner | address | The owner of the tokens balance |
| operator | address | The owner of the tokens balance |

#### getApproved

Returns the account approved for a token

| name    |  type   |  description |
| :------ | :-----: | -----------: |
| tokenId | uint256 |  |

#### balanceOf

Returns the token amount owned by an address

| name    |  type   |  description |
| :------ | :-----: | -----------: |
| owner | address | The address of the user you want to check the balance of |


## Events

#### Transfer

Event that will be emitted when there is a token transfer

| name    |  type   |      description |
| :------ | :-----: |-----------------:|
| from | address | The token sender |
| to | address |                 The token receiver |
| tokenId | uint256 | The id of the token that will be sent |

#### OwnershipTransferred

Event that will be emitted when there will be an ownership transfer

| name    |  type   |                                                   description |
| :------ | :-----: |--------------------------------------------------------------:|
| previousOwner | address |  The previous address that had owner rights over the contract |
| newOwner | address | The new address that will have owner rights over the contract |
| tokenId | uint256 |                         The id of the token that will be sent |


#### ApprovalForAll

Event that will be emitted when an owner approved an account to operate over all his tokens

| name    |  type   |      description |
| :------ | :-----: |-----------------:|
| owner | address | The owner of the tokens |
| operator	 | address |                 The address of the user that will be approved to operate over the tokens |
| approved | bool | The status of the approval |

#### Approval

Event that will be emitted when an owner approved an account to operate over a particular token

| name    |  type   |      description |
| :------ | :-----: |-----------------:|
| owner | address | The address of the token owner |
| approved	 | address |                 The status of the approval |
| tokenId | uint256 | The id of the token |