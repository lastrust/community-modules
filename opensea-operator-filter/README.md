# ERC721WithOperatorFitlerer

## Overview

Starting January 2nd, 2023, Opensea will begin validating creator fee enforcement for new collections on all supported EVM chains. After January 2nd, 2023, if OpenSea is unable to validate enforcement, OpenSea will make creator fees optional for that collection. Older collections will continue to have their fees enforced on OpenSea, including on Ethereum Mainnet (previously, enforcement was already required on Ethereum Mainnet).

This module provides ERC721 contract with operator filterer functions.

Token contracts that wish to manage lists of filtered operators and restrict transfers from them may integrate with the registry easily with tokens using the `OperatorFilterer` and `DefaultOperatorFilterer` contracts. These contracts provide modifiers (`onlyAllowedOperator` and `onlyAllowedOperatorApproval`) which can be used on the token's transfer methods to restrict transfers from or approvals of filtered operators.

The module provides the functions to create a nft collection and host its metadata on their own using a third party service like s3.

This module have the feature of minting as many tokens as you want and host their metadata on more centralized solutions like s3, in addition the tokens can be transferred to any address without restrictions.

For this particular example, the only values that the owner needs to be setup up are done during the deployment, but however there are other contract where the setup is more complex and necessitates more steps after deployment.

## How to use

1. Prepare the metadata for your tokens and upload them to a centralized solution like s3.
2. When deploying the contract, you need to prepare 3 arguments, the first argument is a string and represents the name of the token, the second argument is a string and represent the symbol of the token, the third argument represents the base URI of the collection metadata.
3. After you upload your metadata on s3 in return you will receive a link
4. The link represent your metadata identifier and needs to be used during minting
5. Call the “safeMint” function (it can only be called by the owner), with the first argument representing the address that will receive the nft, and the second argument is the web link that represent the metadata identifier inside the contract.
6. The metadata of a token can be retrieved by calling the “tokenURI” function, which the only argument being the id of the token.
7. A user can call the “transfer” function to transfer his nft’s to another user
8. A user can call “transferFrom” function to transfer nft’s from one user to another if he was approved by the owner of the nft


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

| name      |  type   |              description |
| :-------- |:-------:| -----------------------: |
| from | address | The token sender |
| to | address | The token receiver |
| tokenId | uint256 | 	The id of the token |

#### setApprovalForAll

Returns if the operator is allowed to manage all the assets of owner

`onlyAllowedOperatorApproval(operator)` modifier

| name      |  type   |              description |
| :-------- |:-------:| -----------------------: |
| operator | address | The account that will have the right to operator over the owner balance |
| approved |  bool   | Status to set or unset the approval over the all tokens for the operator |


#### safeTransferFrom

Transfer tokens from sender to receiver in a safe manner

`onlyAllowedOperator(from)` modifier

| name      |  type   |              description |
| :-------- |:-------:| -----------------------: |
| from | address | The token sender |
| to | address | The token receiver |
| tokenId | uint256 | The token id |
| _data	 |  bytes  | Optional information to be sent on token transfer |

#### safeTransferFrom

Transfer tokens from sender to receiver in a safe manner

`onlyAllowedOperator(from)` modifier

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