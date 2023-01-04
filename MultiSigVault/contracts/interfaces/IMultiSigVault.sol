// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/**
 * @dev External interface of Bunzz MultiSigVault
 */

interface IMultiSigVault {
    /**
     * @dev Emitted when new transaction is created
     */
    event TransactionCreated(
        address indexed account,
        address indexed to,
        uint256 amount,
        uint256 unlockTime,
        uint256 transactionId
    );

    /**
     * @dev Emitted when the transaction is signed
     */
    event TransactionSigned(address indexed account, uint256 transactionId);

    /**
     * @dev Emitted when the transaction is rejected
     */
    event TransactionRejected(address indexed account, uint256 transactionId);

    /**
     * @dev Emitted when the transaction is completed
     */
    event TransactionCompleted(
        address indexed account,
        address indexed to,
        uint256 amount,
        uint256 unlockTime,
        uint256 transactionId
    );

    /**
     * @dev Emitted when the signer limit is changed
     */
    event SignerLimitChange(uint256 signerLimit);

    /**
     * @dev Returns the balance of the token in vault.
     */
    function balance() external view returns (uint256);

    /**
     * @dev Set the signer limit of the vault
     * Requirements:
     *
     * the caller must be owner.
     */
    function setSignerLimit(uint256 _signerLimit) external;

    /**
     * @dev Add new transaction
     *
     * Emits a {TransactionCreated} event.
     *
     * Requirements:
     *
     * the caller must have `SIGNER` role.
     */
    function addTransaction(
        address payable _to,
        uint256 _amount,
        uint256 _unlockTime
    ) external returns (uint256);

    /**
     * @dev Sign the transaction
     *
     * Emits a {TransactionSigned} event.
     *
     * Requirements:
     *
     * the caller must have `SIGNER` role.
     */
    function signTransaction(uint256 _transactionId) external;

    /**
     * @dev Reject the transaction
     *
     * Emits a {TransactionRejected} event.
     *
     * Requirements:
     *
     * the caller must have `SIGNER` role.
     */
    function rejectTransaction(uint256 _transactionId) external;

    /**
     * @dev Execute the transaction
     *
     * Emits a {TransactionCompleted} event.
     *
     * Requirements:
     *
     * the caller must have `SIGNER` role.
     */
    function executeTransaction(uint256 _transactionId) external;

    /**
     * @dev Emergency withdraw all balance to the owner
     */
    function emergencyWithdraw() external;
}
