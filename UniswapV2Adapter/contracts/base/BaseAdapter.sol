// SPDX-License-Identifier: GPL-3.0-only
pragma solidity ^0.8.0;

import "../interfaces/IERC20.sol";
import "../interfaces/IAdapter.sol";
import "../lib/SafeERC20.sol";
import "../lib/Maintainable.sol";

/**
 * @title BaseAdapter
 * @author Top-Kraken <topkyle521@gmail.com>
 * @notice BaseAdapter for DexAggregator Adapters
 */
abstract contract BaseAdapter is IAdapter, Maintainable {
    using SafeERC20 for IERC20;

    uint256 internal constant UINT_MAX = type(uint256).max;
    /// @notice Swap Gas Estimate of the Adapter
    uint256 public swapGasEstimate;
    /// @notice Name of the Adapter
    string public name;

    /**
     * @notice Emitted when swap is finished
     * @param _tokenFrom Address of an ERC20 token contract to be converted
     * @param _tokenTo Address of an ERC20 token contract to convert into
     * @param _amountIn Amount of tokenFrom to be converted
     * @param _amountOut Amount of tokenTo received for amountIn of tokenFrom
     */
    event BaseAdapterSwap(
        address indexed _tokenFrom,
        address indexed _tokenTo,
        uint256 _amountIn,
        uint256 _amountOut
    );
    /**
     * @notice Emitted when swapGasEstimate is changed by the adapter
     * @param _adapter Address of the adapter
     * @param _newEstimate The updated value of the swapGasEstimate
     */
    event UpdatedGasEstimate(address indexed _adapter, uint256 _newEstimate);
    /**
     * @notice Emitted when tokens in the adapter are recovered (Only can called by the maintainer)
     * @param _asset Address of the recovered token
     * @param amount Amount of the recovered token
     */
    event Recovered(address indexed _asset, uint256 amount);

    /**
     * @dev Initialize the contract by setting a `name` and a `gasEstimate`
     * @param _name Name of the adapter
     * @param _gasEstimate Swap gas estimate of the adapter
     */
    constructor(string memory _name, uint256 _gasEstimate) {
        setName(_name);
        setSwapGasEstimate(_gasEstimate);
    }

    receive() external payable {}

    /**
     * @notice Revoke the allowance for the `token` and `spender`. Only can called by `maintainer`.
     * @param _token Address of the token to revoke
     * @param _spender Address to revoke token
     */
    function revokeAllowance(address _token, address _spender)
        external
        onlyMaintainer
    {
        require(_token != address(0), "BaseAdapter: Invalid token address");
        IERC20(_token).safeApprove(_spender, 0);
    }

    /**
     * @notice Recover ERC20 token in the adapter. Only can called by `maintainer`.
     * @param _tokenAddress Address of an ERC20 token to recover
     * @param _tokenAmount Amount of the token to recover
     */
    function recoverERC20(address _tokenAddress, uint256 _tokenAmount)
        external
        onlyMaintainer
    {
        require(
            _tokenAddress != address(0),
            "BaseAdapter: Invalid token address"
        );
        require(_tokenAmount > 0, "BaseAdapter: Nothing to recover");
        IERC20(_tokenAddress).safeTransfer(msg.sender, _tokenAmount);
        emit Recovered(_tokenAddress, _tokenAmount);
    }

    /**
     * @notice Recover the native token in the adapter. Only can called by `maintainer`.
     * @param _amount Amount of the native token to recover
     */
    function recoverETH(uint256 _amount) external onlyMaintainer {
        require(_amount > 0, "BaseAdapter: Nothing to recover");
        payable(msg.sender).transfer(_amount);
        emit Recovered(address(0), _amount);
    }

    /// @inheritdoc IAdapter
    function swap(
        uint256 _amountIn,
        uint256 _amountOut,
        address _fromToken,
        address _toToken,
        address _to
    ) external {
        require(
            _fromToken != address(0),
            "BaseAdapter: Invalid fromToken address"
        );
        require(
            _fromToken != address(0),
            "BaseAdapter: Invalid toToken address"
        );
        require(_amountIn > 0, "BaseAdapter: Invalid amountIn");
        uint256 toBal0 = IERC20(_toToken).balanceOf(_to);
        _swap(_amountIn, _amountOut, _fromToken, _toToken, _to);
        uint256 diff = IERC20(_toToken).balanceOf(_to) - toBal0;
        require(diff >= _amountOut, "Insufficient amount-out");
        emit BaseAdapterSwap(_fromToken, _toToken, _amountIn, _amountOut);
    }

    /// @inheritdoc IAdapter
    function query(
        uint256 _amountIn,
        address _tokenIn,
        address _tokenOut
    ) external view returns (uint256) {
        return _query(_amountIn, _tokenIn, _tokenOut);
    }

    /**
     * @notice Set the swap gas estimate for UniswapV2Adapter. Only can called by `maintainer`.
     * @param _estimate The updated value of the swapGasEstimate
     */
    function setSwapGasEstimate(uint256 _estimate) public onlyMaintainer {
        require(_estimate != 0, "Invalid gas-estimate");
        swapGasEstimate = _estimate;
        emit UpdatedGasEstimate(address(this), _estimate);
    }

    /**
     * @notice Set the name for UniswapV2Adapter. Only can called by `maintainer`.
     * @param _name The updated name of the adapter
     */
    function setName(string memory _name) internal {
        require(bytes(_name).length != 0, "Invalid adapter name");
        name = _name;
    }

    /**
     * @notice Given a token and its amount, send the equivalent value in another token
     * @param _amountIn Amount of tokenIn to be converted
     * @param _amountOut Amount of tokenOut received for amountIn of tokenIn
     * @param _tokenIn Address of an ERC20 token contract to be converted
     * @param _tokenOut Address of an ERC20 token contract to convert into
     * @param _to Address that receive amountOut of tokenOut token
     */
    function _swap(
        uint256 _amountIn,
        uint256 _amountOut,
        address _tokenIn,
        address _tokenOut,
        address _to
    ) internal virtual;

    /**
     * @notice Get the query based on tokenIn and tokenOut and returns the amount out for the input
     * @param _amountIn Amount of tokenIn to be converted
     * @param _tokenIn Address of an ERC20 token contract to be converted
     * @param _tokenOut Address of an ERC20 token contract to convert into
     */
    function _query(
        uint256 _amountIn,
        address _tokenIn,
        address _tokenOut
    ) internal view virtual returns (uint256);
}
