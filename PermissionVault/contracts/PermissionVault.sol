// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {AccessControl} from "@openzeppelin/contracts/access/AccessControl.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {IERC721} from "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import {IERC721Receiver} from "@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol";
import {IERC1155} from "@openzeppelin/contracts/token/ERC1155/IERC1155.sol";
import {IERC1155Receiver} from "@openzeppelin/contracts/token/ERC1155/IERC1155Receiver.sol";

import {SafeERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import {ReentrancyGuard} from "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import {IPermissionVault} from "./interfaces/IPermissionVault.sol";

error NotController();
error NotEOA();
error NotEnoughBalance();
error ZeroAmount();
error NotExistToken();
error NotOwnerOf();

contract PermissionVault is
  IPermissionVault,
  IERC721Receiver,
  IERC1155Receiver,
  Ownable,
  AccessControl,
  ReentrancyGuard
{
  using SafeERC20 for IERC20;

  bytes32 public constant CONTROLLER_ROLE =
    bytes32(keccak256("CONTROLLER_ROLE"));

  /* -------------------------------------------------------------------------- */
  /*                                   Events                                   */
  /* -------------------------------------------------------------------------- */

  /**
   * Emitted when new controller was added
   */
  event AddController(address controller);
  /**
   * Emitted when controller was removed
   */
  event RemoveController(address controller);

  /**
   * Emitted when controller deposited Ether
   */
  event DepositEther(address controller, uint256 amount);
  /**
   * Emitted when controller withdrawed Ether
   */
  event WithdrawEther(address controller, address to, uint256 amount);

  /**
   * Emitted when controller deposited ERC20
   */
  event DepositERC20(address controller, IERC20 token, uint256 amount);
  /**
   * Emitted when controller withdrawed ERC20
   */
  event WithdrawERC20(
    address controller,
    address to,
    IERC20 token,
    uint256 amount
  );

  /**
   * Emitted when controller deposited ERC721
   */
  event DepositERC721(address controller, IERC721 token, uint256 id);
  /**
   * Emitted when controller withdrawed ERC721
   */
  event WithdrawERC721(
    address controller,
    address to,
    IERC721 token,
    uint256 id
  );

  /**
   * Emitted when controller deposited ERC1155
   */
  event DepositERC1155(
    address controller,
    IERC1155 token,
    uint256 id,
    uint256 amount
  );
  /**
   * Emitted when controller withdrawed ERC1155
   */
  event WithdrawERC1155(
    address controller,
    address to,
    IERC1155 token,
    uint256 id,
    uint256 amount
  );

  /* -------------------------------------------------------------------------- */
  /*                                  Modifiers                                 */
  /* -------------------------------------------------------------------------- */

  modifier onlyController() {
    if (!hasRole(CONTROLLER_ROLE, msg.sender)) {
      revert NotController();
    }
    _;
  }

  /* -------------------------------------------------------------------------- */
  /*                             External Functions                             */
  /* -------------------------------------------------------------------------- */

  /**
   * @dev Constructor
   */
  constructor() {
    _setupRole(DEFAULT_ADMIN_ROLE, msg.sender);
    _setupRole(CONTROLLER_ROLE, msg.sender);
  }

  /**
   * @notice The owner can use this function to grant the CONTROLLER_ROLE to a
   * new address. The controller parameter is the address that will be granted
   * the CONTROLLER_ROLE.
   * @dev Callable by owner
   * @param controller new controller address
   */
  function addController(address controller) external onlyOwner {
    _setupRole(CONTROLLER_ROLE, controller);

    emit AddController(controller);
  }

  /**
   * @notice The owner can use this function to revoke the CONTROLLER_ROLE from
   * an address. The controller parameter is the address that will have the
   * CONTROLLER_ROLE revoked.
   * @dev Callable by owner
   * @param controller controller address
   */
  function removeController(address controller) external onlyOwner {
    revokeRole(CONTROLLER_ROLE, controller);

    emit RemoveController(controller);
  }

  /**
   * @notice A controller can use this function to deposit Ether into the
   * contract.
   */
  function depositEther() external payable {
    if (msg.value == 0) {
      revert ZeroAmount();
    }

    emit DepositEther(msg.sender, msg.value);
  }

  /**
   * @notice A controller can use this function to withdraw Ether from the contract.
   * @dev Callable by controller
   * @param to the address that will receive the withdrawn Ether
   * @param amount the amount of Ether to withdraw
   */
  function withdrawEther(
    address to,
    uint256 amount
  ) external nonReentrant onlyController {
    if (amount > address(this).balance) {
      revert NotEnoughBalance();
    }

    (bool success, ) = to.call{value: amount}("");
    require(success, "Transfer ether failed");

    emit WithdrawEther(msg.sender, to, amount);
  }

  /**
   * @notice A controller can use this function to deposit ERC20 tokens into the contract.
   * @param token the ERC20 token contract address
   * @param amount the amount of tokens to deposit
   */
  function depositERC20(IERC20 token, uint256 amount) external {
    if (amount == 0) {
      revert ZeroAmount();
    }
    if (token.balanceOf(msg.sender) < amount) {
      revert NotEnoughBalance();
    }

    token.safeTransferFrom(msg.sender, address(this), amount);
    emit DepositERC20(msg.sender, token, amount);
  }

  /**
   * @notice A controller can use this function to withdraw ERC20 tokens from the contract.
   * @param to the address that will receive the withdrawn tokens
   * @param token the ERC20 token contract address
   * @param amount the amount of tokens to withdraw
   */
  function withdrawERC20(
    address to,
    IERC20 token,
    uint256 amount
  ) external onlyController {
    if (amount > token.balanceOf(address(this))) {
      revert NotEnoughBalance();
    }

    token.safeTransfer(to, amount);
    emit WithdrawERC20(msg.sender, to, token, amount);
  }

  /**
   * @notice A controller can use this function to deposit ERC721 tokens into the contract.
   * @param token the ERC721 token contract address
   * @param id the token ID to deposit
   */
  function depositERC721(IERC721 token, uint256 id) external {
    if (token.ownerOf(id) != msg.sender) {
      revert NotOwnerOf();
    }
    token.safeTransferFrom(msg.sender, address(this), id);
    emit DepositERC721(msg.sender, token, id);
  }

  /**
   * @notice A controller can use this function to withdraw ERC721 tokens from the contract.
   * @param to the address that will receive the withdrawn token
   * @param token the ERC721 token contract address
   * @param id the token ID to withdraw
   */
  function withdrawERC721(
    address to,
    IERC721 token,
    uint256 id
  ) external onlyController {
    if (token.ownerOf(id) != address(this)) {
      revert NotExistToken();
    }

    token.safeTransferFrom(address(this), to, id);
    emit WithdrawERC721(msg.sender, to, token, id);
  }

  /**
   * @notice A controller can use this function to deposit ERC1155 tokens into the contract.
   * @param token the ERC1155 token contract address
   * @param id the token ID to deposit
   * @param amount the amount of tokens to deposit
   */
  function depositERC1155(IERC1155 token, uint256 id, uint256 amount) external {
    if (amount == 0) {
      revert ZeroAmount();
    }
    if (token.balanceOf(msg.sender, id) < amount) {
      revert NotEnoughBalance();
    }

    token.safeTransferFrom(msg.sender, address(this), id, amount, "");
    emit DepositERC1155(msg.sender, token, id, amount);
  }

  /**
   * @notice A controller can use this function to withdraw ERC1155 tokens from the contract.
   * @param to the address that will receive the withdrawn token
   * @param token the ERC1155 token contract address
   * @param id the token ID to withdraw
   * @param amount the amount of tokens to withdraw
   */
  function withdrawERC1155(
    address to,
    IERC1155 token,
    uint256 id,
    uint256 amount
  ) external onlyController {
    if (amount > token.balanceOf(address(this), id)) {
      revert NotEnoughBalance();
    }

    token.safeTransferFrom(address(this), to, id, amount, "");
    emit WithdrawERC1155(msg.sender, to, token, id, amount);
  }

  /**
   * @notice Whenever an {IERC721} `tokenId` token is transferred to this contract via {IERC721-safeTransferFrom}
   * by `operator` from `from`, this function is called.
   *
   * It must return its Solidity selector to confirm the token transfer.
   * If any other value is returned or the interface is not implemented by the recipient, the transfer will be reverted.
   *
   * The selector can be obtained in Solidity with `IERC721.onERC721Received.selector`.
   * @param operator The address which initiated the transfer (i.e. msg.sender)
   * @param from The address which previously owned the token
   * @param tokenId The ID of the token being transferred
   * @param data Additional data with no specified format
   */
  function onERC721Received(
    address operator,
    address from,
    uint256 tokenId,
    bytes calldata data
  ) external pure override returns (bytes4) {
    return IERC721Receiver.onERC721Received.selector;
  }

  /**
   * @notice Handles the receipt of a single ERC1155 token type. This function
   * is called at the end of a `safeTransferFrom` after the balance has been
   * updated. To accept the transfer, this must return `bytes4(keccak256
   * ("onERC1155Received(address,address,uint256,uint256,bytes)"))`
   * (i.e. 0xf23a6e61, or its own function selector).
   * @param operator The address which initiated the transfer (i.e. msg.sender)
   * @param from The address which previously owned the token
   * @param id The ID of the token being transferred
   * @param value The amount of tokens being transferred
   * @param data Additional data with no specified format
   * @return `bytes4(keccak256("onERC1155Received(address,address,uint256,uint256,bytes)"))` if transfer is allowed
   */
  function onERC1155Received(
    address operator,
    address from,
    uint256 id,
    uint256 value,
    bytes calldata data
  ) external pure override returns (bytes4) {
    return IERC1155Receiver.onERC1155Received.selector;
  }

  function onERC1155BatchReceived(
    address operator,
    address from,
    uint256[] calldata ids,
    uint256[] calldata values,
    bytes calldata data
  ) external pure override returns (bytes4) {
    return IERC1155Receiver.onERC1155BatchReceived.selector;
  }
}
