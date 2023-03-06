// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "../ERC20Votes.sol";

contract ERC20VotesMock is ERC20Votes {
    constructor(string memory name_, string memory symbol_)
        ERC20Votes(name_, symbol_)
    {}

    /**
     * @dev Get the `pos`-th checkpoint for `account`.
     */
    function checkpoints(address account, uint32 pos)
        public
        view
        override
        returns (Checkpoint memory)
    {
        return super.checkpoints(account, pos);
    }

    /**
     * @dev Get number of checkpoints for `account`.
     */
    function numCheckpoints(address account)
        public
        view
        override
        returns (uint32)
    {
        return super.numCheckpoints(account);
    }

    /**
     * @dev Maximum token supply. Defaults to `type(uint224).max` (2^224^ - 1).
     */
    function _maxSupply() internal view override returns (uint224) {
        return super._maxSupply();
    }

    /**
     * @dev Change delegation for `delegator` to `delegatee`.
     *
     * Emits events {IVotes-DelegateChanged} and {IVotes-DelegateVotesChanged}.
     */
    function _delegate(address delegator, address delegatee) internal override {
        super._delegate(delegator, delegatee);
    }

    /**
     * @dev Snapshots the totalSupply after it has been increased.
     */
    function mint(address account, uint256 amount) public virtual {
        super._mint(account, amount);
    }

    /**
     * @dev Snapshots the totalSupply after it has been decreased.
     */
    function burn(address account, uint256 amount) public virtual {
        super._burn(account, amount);
    }
}
