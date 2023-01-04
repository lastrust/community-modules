# MultiSigVault Module

## Overview

The main purpose of MultiSigVault is to increase security by requring multiple accounts to agree on transactions before execution. Transactions can be executed only when confirmed by a predefined numbers of signers. It supports ERC-20 tokens for the transactions.

## How to Use
1. Deploy smart contract via `Bunzz`
2. Set `token` address by calling `connectToOtherContracts` function and deposit tokens to the vault.
3. Add SIGNER_ROLE to the signers accounts by calling `grantRole` function.

```
const SIGNER_ROLE = web3.utils.soliditySha3("SIGNER");
await multiSigVault.grantRole(SIGNER_ROLE, signer_account);
```

4. Using `setSignerLimit` function, set the required number of confirmations of every transactions.
5. By calling `addTransaction` function, add new transaction. Any signer account can add transactions.
6. Signer accounts can sign/reject the transaction by calling `signTransaction` and `rejectTransaction` functions.
7. After transaction has enough confirmations, signers can execute transaction by calling `executeTransaction` functions.

## Functions


### `connectToOtherContracts`

`Bunzz` style function.
`contracts` length is 1 and contracts[0] is vault token address.
This function can be called by only owner.

| name        | type             | description                                      |
| :---        |    :----:        |          ---:                                    |
| contracts   |address[] calldata| addresses should be connected to multisigvault   |

### `token`
Return vault token address.

### `setSignerLimit`

Set the number of `signers` for each `transaction` to execute.
This function can be called by only owner.

| name          | type              | description                           |
| :---          |    :----:         |          ---:                         |
| _signerLimit  |uint256            | The number of `signers` to execute.   |

### `addTransaction`

Add a new `transaction`.
This function can be called by only accounts with SIGNER role.

| name          | type              | description                       |
| :---          |    :----:         |          ---:                     |
| _to           |address            | The address to send the tokens    |
| _amount       |uint256            | Amount of token to send           |
| _unlockTime   |uint256            | The unlock time of transaction    |

### `signTransaction`

Sign the `transaction`.
This function can be called by only accounts with SIGNER role.

| name          | type              | description        |
| :---          |    :----:         |          ---:      |
| _transactionId|uint256            | The transaction Id |

### `rejectTransaction`

Reject the `transaction`.
This function can be called by only accounts with SIGNER role.

| name          | type              | description        |
| :---          |    :----:         |          ---:      |
| _transactionId|uint256            | The transaction Id |

### `executeTransaction`

Execute the `transaction`. Check if the transaction has `unlockTime` of `transaction` before execute transaction.
And check if the number of signed accounts is greater than `signerLimit`.
If the transaction is not executed and balance is enough, send `amount` tokens to the `to` of the `transaction`.
This function can be called by only accounts with SIGNER role.

| name          | type              | description        |
| :---          |    :----:         |          ---:      |
| _transactionId|uint256            | The transaction Id |

### `balance`

Returns the balance of vault tokens.

### `emergencyWithdraw`

Withdraw the vault tokens that `multisigvault` contract has. Only called by the owner.

### `getConfirmationCount`

Returns the number of signed accounts of the transaction.

### `getTransactionCount`

Returns the transaction counts by filtering pending/executed.

### `getConfirmations`

Returns the signed accounts of the transaction.

## Events


### TransactionCreated
```
event TransactionCreated(address indexed account, address indexed to, uint256 amount, uint256 unlockTime, uint256 transactionId);
```

Emitted when a new transaction is created.

| name          | type              | description                         |
| :---          |    :----:         |          ---:                       |
| account       |address            | Account that created a transaction. |
| to            |address            | Account that send the tokens.       |
| amount        |uint256            | Token amounts to send.              |
| unlockTime    |uint256            | Unlock time for the transaction.    |
| transactionId |uint256            | Created transaction id.             |

### TransactionSigned
```
event TransactionSigned(address indexed account, uint256 transactionId);
```

Emitted when the transaction is signed.

| name          | type              | description                          |
| :---          |    :----:         |          ---:                        |
| account       |address            | Account that signed the transaction. |
| transactionId |uint256            | Signed transaction id.               |

### TransactionRejected
```
event TransactionRejected(address indexed account, uint256 transactionId);
```

Emitted when the transaction is rejected.

| name          | type              | description                            |
| :---          |    :----:         |          ---:                          |
| account       |address            | Account that rejected the transaction. |
| transactionId |uint256            | Rejected transaction id.               |

### TransactionCompleted
```
event TransactionCompleted(address indexed account, address indexed to, uint256 amount, uint256 unlockTime, uint256 transactionId);
```

Emitted when the transaction is executed.

| name          | type              | description                            |
| :---          |    :----:         |          ---:                          |
| account       |address            | Account that executed the transaction. |
| to            |address            | Account that send the tokens.          |
| amount        |uint256            | Token amounts to send.                 |
| unlockTime    |uint256            | Unlock time for the transaction.       |
| transactionId |uint256            | Executed transaction id.               |

### SignerLimitChange
```
event SignerLimitChange(uint256 signerLimit);
```

Emitted when the signer limit is changed.

| name          | type              | description                                   |
| :---          |    :----:         |          ---:                                 |
| signerLimit   |uint256            | Number of signers to execute the transaction. |