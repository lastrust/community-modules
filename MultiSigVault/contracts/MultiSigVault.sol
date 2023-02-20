// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/access/AccessControlEnumerable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "./interfaces/IMultiSigVault.sol";
import "./interfaces/IBunzz.sol";

/**
 * @dev Contract module that allows implementing multi signature vault.
 */
contract MultiSigVault is
    Ownable,
    AccessControlEnumerable,
    ReentrancyGuard,
    IMultiSigVault,
    IBunzz
{
    using SafeERC20 for IERC20;
    using SafeMath for uint256;
    using Counters for Counters.Counter;

    bytes32 public constant SIGNER = keccak256("SIGNER");
    uint256 public signerLimit;
    IERC20 public token;

    struct Transaction {
        address payable to;
        uint256 amount;
        uint256 unlockTime;
        uint256 signatureCount;
        mapping(address => bool) signatures;
        bool executed;
    }

    modifier hasToken() {
        require(token != IERC20(address(0)), "token isn't set");
        _;
    }

    Counters.Counter private _txIds;
    mapping(uint256 => Transaction) public transactions;

    /**
     * @dev Grants `DEFAULT_ADMIN_ROLE` to `_msgSender()`.
     */
    constructor() {
        _setupRole(DEFAULT_ADMIN_ROLE, msg.sender);
    }

    /**
     * @dev Set the main token of the vault
     *
     * If the main token exists and balance > 0, revert
     */
    function connectToOtherContracts(address[] calldata contracts)
        external
        override
        onlyOwner
    {
        require(contracts.length > 0, "invalid contracts length");
        require(contracts[0] != address(0), "invalid contract address");

        if (token != IERC20(address(0))) {
            require(
                token.balanceOf(address(this)) == 0,
                "remain origin tokens."
            );
        }
        token = IERC20(contracts[0]);
    }

    /**
     * @dev Set the signer limit of the vault
     * Requirements:
     *
     * the caller must be owner.
     */
    function setSignerLimit(uint256 _signerLimit) external override onlyOwner {
        require(_signerLimit > 0, "signer limit is 0");
        require(
            _signerLimit <= getRoleMemberCount(SIGNER),
            "signer limit is greater than member count"
        );
        signerLimit = _signerLimit;

        emit SignerLimitChange(signerLimit);
    }

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
    ) external override nonReentrant onlyRole(SIGNER) hasToken returns (uint256) {
        require(_to != address(0), "invalid to address");
        require(_amount > 0, "amount is 0");
        require(
            _unlockTime < 10000000000,
            "Enter an unix timestamp in seconds, not miliseconds"
        );

        uint256 current = _txIds.current();
        transactions[current].to = _to;
        transactions[current].amount = _amount;
        transactions[current].unlockTime = _unlockTime;

        _txIds.increment();
        emit TransactionCreated(msg.sender, _to, _amount, _unlockTime, current);

        return current;
    }

    /**
     * @dev Sign the transaction
     *
     * Emits a {TransactionSigned} event.
     *
     * Requirements:
     *
     * the caller must have `SIGNER` role.
     */
    function signTransaction(uint256 _transactionId)
        external
        override
        nonReentrant
        onlyRole(SIGNER)
        hasToken
    {
        Transaction storage transaction = transactions[_transactionId];

        require(transaction.to != address(0), "invalid transaction");
        require(transaction.signatures[msg.sender] != true, "already signed");

        transaction.signatures[msg.sender] = true;
        transaction.signatureCount = transaction.signatureCount.add(1);

        emit TransactionSigned(msg.sender, _transactionId);
    }

    /**
     * @dev Reject the transaction
     *
     * Emits a {TransactionRejected} event.
     *
     * Requirements:
     *
     * the caller must have `SIGNER` role.
     */
    function rejectTransaction(uint256 _transactionId)
        external
        override
        nonReentrant
        onlyRole(SIGNER)
        hasToken
    {
        Transaction storage transaction = transactions[_transactionId];

        require(transaction.to != address(0), "invalid transaction");
        require(
            transaction.signatures[msg.sender] != false,
            "already rejected"
        );

        transaction.signatures[msg.sender] = false;
        transaction.signatureCount = transaction.signatureCount.sub(1);

        emit TransactionRejected(msg.sender, _transactionId);
    }

    /**
     * @dev Execute the transaction
     *
     * Emits a {TransactionCompleted} event.
     *
     * Requirements:
     *
     * the caller must have `SIGNER` role.
     */
    function executeTransaction(uint256 _transactionId)
        external
        override
        nonReentrant
        onlyRole(SIGNER)
        hasToken
    {
        Transaction storage transaction = transactions[_transactionId];

        if (transaction.unlockTime > 0) {
            require(
                block.timestamp >= transaction.unlockTime,
                "transaction is locked"
            );
        }
        require(transaction.to != address(0), "invalid transaction");
        require(!transaction.executed, "transaction already executed");
        require(
            token.balanceOf(address(this)) >= transaction.amount,
            "you don't have enough funds"
        );
        require(
            transaction.signatureCount >= signerLimit,
            "you don't have enough signatures"
        );

        SafeERC20.safeTransfer(token, transaction.to, transaction.amount);

        transactions[_transactionId].executed = true;

        emit TransactionCompleted(
            msg.sender,
            transaction.to,
            transaction.amount,
            transaction.unlockTime,
            _transactionId
        );
    }

    /**
     * @dev Returns the balance of the token in vault.
     */
    function balance() external override view hasToken returns (uint256) {
        return token.balanceOf(address(this));
    }

    /**
     * @dev Emergency withdraw all balance to the owner
     */
    function emergencyWithdraw() external override onlyOwner hasToken {
        uint256 _amount = token.balanceOf(address(this));
        require(_amount > 0, "balance is 0");
        SafeERC20.safeTransfer(token, owner(), _amount);
    }

    /**
     * @dev Returns number of confirmations of a transaction.
     */
    function getConfirmationCount(uint256 _transactionId)
        external
        view
        returns (uint256)
    {
        return transactions[_transactionId].signatureCount;
    }

    /**
     * @dev Returns number of transactions
     */
    function getTransactionCount(bool pending, bool executed)
        external
        view
        returns (uint256 count)
    {
        uint256 current = _txIds.current();
        for (uint256 i = 0; i < current; i++)
            if (
                (pending && !transactions[i].executed) ||
                (executed && transactions[i].executed)
            ) count += 1;
    }

    /**
     * @dev Returns array with signer addresses, which confirmed transaction
     */
    function getConfirmations(uint256 _transactionId)
        external
        view
        returns (address[] memory _confirmations)
    {
        uint256 count = 0;
        uint256 members = getRoleMemberCount(SIGNER);
        uint256 i;
        address[] memory confirmationsTemp = new address[](members);
        for (i = 0; i < members; i++)
            if (
                transactions[_transactionId].signatures[
                    getRoleMember(SIGNER, i)
                ]
            ) {
                confirmationsTemp[count] = getRoleMember(SIGNER, i);
                count += 1;
            }
        _confirmations = new address[](count);
        for (i = 0; i < count; i++) _confirmations[i] = confirmationsTemp[i];
    }
}
