// SPDX-License-Identifier: MIT

pragma solidity ^0.8.10;

import "@openzeppelin/contracts/security/Pausable.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

import "./interfaces/IBinaryMarket.sol";
import "./interfaces/IBinaryVault.sol";
import "./interfaces/IOracle.sol";

// fixme I would personally get rid of roundid in oracle. Its redundant information. No need to have it in oracle and I would like if possible to switch oracle to chain link (to allow to write it like we can not that we will do it). That means we can use same oracle for perps. We want to configure perps from existing contracts we have. Less code we need to test and maintain.
// fixme decide if use error constants or error string, not both. Better to use "ERROR_LIKE_THIS" then "like this"
contract BinaryMarket is
    Pausable,
    ReentrancyGuard,
    IBinaryMarket
{
    using SafeERC20 for IERC20;

    /// @dev Price data for each period
    struct Round {
        uint256 epoch;
        uint256 startBlock;
        uint256 lockBlock;
        uint256 closeBlock;
        uint256 lockPrice;
        uint256 closePrice;
        uint256 lockOracleId;
        uint256 closeOracleId;
        uint256 totalAmount;
        uint256 bullAmount;
        uint256 bearAmount;
        bool oracleCalled;
    }

    /// @dev Data for bet from Players
    struct BetInfo {
        Position position;
        uint256 amount;
        bool claimed; // default false
    }

    /// @dev Market Name
    string public marketName;

    /// @dev Price Oracle
    IOracle public oracle;

    /// @dev Vault for this Market
    IBinaryVault public vault;

    IERC20 public underlyingToken;

    /// @dev Timeframes supported in this market.
    TimeFrame[] public timeframes;

    /// @dev Rounds per timeframe
    mapping(uint8 => mapping(uint256 => Round)) public rounds; // timeframe id => round id => round

    /// @dev bet info per user and round
    mapping(uint8 => mapping(uint256 => mapping(address => BetInfo)))
        public ledger; // timeframe id => round id => address => bet info

    /// @dev user rounds per timeframe
    mapping(uint8 => mapping(address => uint256[])) public userRounds; // timeframe id => user address => round ids

    /// @dev current round id per timeframe.
    mapping(uint8 => uint256) public currentEpochs; // timeframe id => current round id

    /// @dev This should be modified
    uint256 public minBetAmount;
    uint256 public oracleLatestRoundId;
    uint256 public genesisStartBlockTimestamp;
    uint256 public genesisStartBlockNumber;

    /// @dev owner will be binary market. So needs admin & operator roles
    address public adminAddress;
    address public operatorAddress;

    /// @dev default false
    bool public genesisStartOnce;
    /// @dev timeframe id => genesis locked? default false
    mapping(uint8 => bool) public genesisLockOnces;

    event PositionOpened(
        string indexed marketName,
        address user,
        uint256 amount,
        uint8 timeframeId,
        uint256 roundId,
        Position position
    );

    event Claimed(
        string indexed marketName,
        address indexed user,
        uint8 timeframeId,
        uint256 indexed roundId,
        uint256 amount
    );

    event MinBetAmountChanged(uint256 indexed amount);

    event StartRound(uint8 indexed timeframeId, uint256 indexed epoch);
    event LockRound(
        uint8 indexed timeframeId,
        uint256 indexed epoch,
        uint256 indexed oracleRoundId,
        uint256 price
    );
    event EndRound(
        uint8 indexed timeframeId,
        uint256 indexed epoch,
        uint256 indexed oracleRoundId,
        uint256 price
    );

    event OracleChanged(
        address indexed oldOracle,
        address indexed newOracle
    );
    event MarketNameChanged(
        string oldName,
        string newName
    );
    event AdminChanged(
        address indexed oldAdmin,
        address indexed newAdmin
    );
    event OperatorChanged(
        address indexed oldOperator,
        address indexed newOperator
    );

    modifier onlyAdmin() {
        require(msg.sender == adminAddress, "BinaryMarket: invalid admin");
        _;
    }

    modifier onlyOperator() {
        require(msg.sender == operatorAddress, "BinaryMarket: invalid operator");
        _;
    }

    modifier onlyAdminOrOperator() {
        require(
            msg.sender == adminAddress || msg.sender == operatorAddress,
            "BinaryMarket: invalid admin or operator"
        );
        _;
    }

    constructor(
        address oracle_,
        address vault_,
        string memory marketName_,
        TimeFrame[] memory timeframes_,
        address adminAddress_,
        address operatorAddress_,
        uint256 minBetAmount_
    ) {
        require(oracle_ != address(0), "ZERO_ADDRESS()");
        require(vault_ != address(0), "ZERO_ADDRESS()");
        require(adminAddress_ != address(0), "ZERO_ADDRESS()");
        require(operatorAddress_ != address(0), "ZERO_ADDRESS()");
        require(timeframes_.length != 0, "INVALID_TIMEFRAMES()");

        oracle = IOracle(oracle_);
        vault = IBinaryVault(vault_);

        marketName = marketName_;
        adminAddress = adminAddress_;
        operatorAddress = operatorAddress_;
        minBetAmount = minBetAmount_;

        for (uint256 i = 0; i < timeframes_.length; i = i + 1) {
            timeframes.push(timeframes_[i]);
        }

        underlyingToken = vault.getUnderlyingToken();
    }

    /**
     * @notice Set oracle of underlying token of this market
     * @dev Only owner can set the oracle
     * @param oracle_ New oracle address to set
     */
    function setOracle(address oracle_) external onlyAdmin {
        if (oracle_ == address(0)) revert("ZERO_ADDRESS()");
        emit OracleChanged(address(oracle), oracle_);
        oracle = IOracle(oracle_);
    }

    /**
     * @notice Set name of this market
     * @dev Only owner can set name
     * @param name_ New name to set
     */
    function setName(string calldata name_) external onlyAdmin {
        emit MarketNameChanged(marketName, name_);
        marketName = name_;
    }

    /**
     * @notice Set new admin of this market
     * @dev Only owner can set new admin
     * @param admin_ New admin to set
     */
    function setAdmin(address admin_) external onlyAdmin {
        require(admin_ != address(0), "Zero address");
        emit AdminChanged(adminAddress, admin_);
        adminAddress = admin_;
    }

    /**
     * @notice Set new operator of this market
     * @dev Only admin can set new operator
     * @param operator_ New operator to set
     */
    function setOperator(address operator_) external onlyAdmin {
        require(operator_ != address(0), "Zero address");
        emit OperatorChanged(operatorAddress, operator_);
        operatorAddress = operator_;
    }

    /**
     * @notice Set timeframes of this market
     * @dev Only admin can set new timeframe, format genesis
     * @param timeframes_ New timeframe to set
     */
    function setTimeframes(TimeFrame[] calldata timeframes_) external onlyAdmin {
        require(timeframes_.length > 0, "Invalid length");
        genesisStartOnce = false;
        delete timeframes;
        for (uint256 i = 0; i < timeframes_.length; i = i + 1) {
            timeframes.push(timeframes_[i]);
            genesisLockOnces[timeframes_[i].id] = false;
        }
    }

    /**
     * @dev Bet bear position
     * @param amount Bet amount
     * @param timeframeId id of 1m/5m/10m
     * @param position bull/bear
     */
    function openPosition(
        uint256 amount,
        uint8 timeframeId,
        Position position
    ) external override whenNotPaused nonReentrant {
        uint256 currentEpoch = currentEpochs[timeframeId];
        underlyingToken.safeTransferFrom(msg.sender, address(vault), amount);

        require(_bettable(timeframeId, currentEpoch), "Round not bettable");
        require(
            amount >= minBetAmount,
            "Bet amount must be greater than minBetAmount"
        );
        require(
            ledger[timeframeId][currentEpoch][msg.sender].amount == 0,
            "Can only bet once per round"
        );

        // Update round data
        Round storage round = rounds[timeframeId][currentEpoch];
        round.totalAmount = round.totalAmount + amount;
        
        if (position == Position.Bear) {
            round.bearAmount = round.bearAmount + amount;
        } else {
            round.bullAmount = round.bullAmount + amount;
        }

        // Update user data
        BetInfo storage betInfo = ledger[timeframeId][currentEpoch][msg.sender];
        betInfo.position = position;
        betInfo.amount = amount;
        userRounds[timeframeId][msg.sender].push(currentEpoch);

        emit PositionOpened(
            marketName,
            msg.sender,
            amount,
            timeframeId,
            currentEpoch,
            position
        );
    }

    /**
     * @notice claim winning rewards
     * @param timeframeId Timeframe ID to claim winning rewards
     * @param epoch round id
     */
    function claim(uint8 timeframeId, uint256 epoch) external override {
        _claim(timeframeId, epoch);
    }

    /**
     * @dev Start genesis round
     */
    function genesisStartRound() external onlyOperator whenNotPaused {
        require(!genesisStartOnce, "Can only run genesisStartRound once");
        genesisStartBlockTimestamp = block.timestamp;
        genesisStartBlockNumber = block.number;
        for (uint256 i = 0; i < timeframes.length; i = i + 1) {
            currentEpochs[timeframes[i].id] = currentEpochs[timeframes[i].id] + 1;
            _startRound(timeframes[i].id, currentEpochs[timeframes[i].id]);

        }
        genesisStartOnce = true;
    }

    /**
     * @dev Lock genesis round
     */
    function genesisLockRound(uint8 timeframeId) external onlyOperator whenNotPaused {
        require(genesisStartOnce, "Can only run after genesisStartRound is triggered");
        require(!genesisLockOnces[timeframeId], "Can only run genesisLockRound once");
        
        _writeOraclePrice(block.timestamp, 1 wei);
        (uint256 currentRoundId, uint256 currentPrice, ) = _getPriceFromOracle();

        _safeLockRound(timeframeId, currentEpochs[timeframeId], currentRoundId, currentPrice);
        currentEpochs[timeframeId] = currentEpochs[timeframeId] + 1;
        _startRound(timeframeId, currentEpochs[timeframeId]);
        genesisLockOnces[timeframeId] = true;
    }

    /**
     * @dev Start the next round n, lock price for round n-1, end round n-2
     */
    function executeRound(
        uint8[] calldata timeframeIds,
        uint256 price
    ) external override onlyOperator whenNotPaused {
        require(
            genesisStartOnce,
            "Can only run after genesisStartRound is triggered"
        );
        uint256 timestamp = block.timestamp;
        // Update oracle price
        _writeOraclePrice(timestamp, price);

        (uint256 currentRoundId, uint256 currentPrice, ) = _getPriceFromOracle();

        for (uint8 i = 0; i < timeframeIds.length; i = i + 1) {
            uint8 timeframeId = timeframeIds[i];
            if(genesisLockOnces[timeframeId]) {

                uint256 currentEpoch = currentEpochs[timeframeId];
                // CurrentEpoch refers to previous round (n-1)
                _safeLockRound(
                    timeframeId,
                    currentEpoch,
                    currentRoundId,
                    currentPrice
                );
                _safeEndRound(
                    timeframeId,
                    currentEpoch - 1,
                    currentRoundId,
                    currentPrice
                );

                // Increment currentEpoch to current round (n)
                currentEpoch = currentEpoch + 1;
                currentEpochs[timeframeId] = currentEpoch;
                _safeStartRound(timeframeId, currentEpoch);
            }

        }
    }

    /**
     * @notice Batch claim winning rewards
     * @param timeframeIds Timeframe IDs to claim winning rewards
     * @param epochs round ids
     */
    function claimBatch(uint8[] calldata timeframeIds, uint256[][] calldata epochs) external override {
        require(timeframeIds.length == epochs.length, "Invalid array length");

        for (uint256 i = 0; i < timeframeIds.length; i = i + 1) {
            uint8 timeframeId = timeframeIds[i];
            for (uint256 j = 0; j < epochs[i].length; j = j + 1) {
                _claim(timeframeId, epochs[i][j]);
            }
        }
    }

    function getUnderlyingToken() external view returns (IERC20) {
        return underlyingToken;
    }


    /**
     * @dev Get the refundable stats of specific epoch and user account
     */
    function refundable(
        uint8 timeframeId,
        uint256 epoch,
        address user
    ) public view returns (bool) {
        BetInfo memory betInfo = ledger[timeframeId][epoch][user];
        Round memory round = rounds[timeframeId][epoch];
        return
            !round.oracleCalled &&
            block.number > round.closeBlock + timeframes[timeframeId].bufferBlocks &&
            betInfo.amount != 0;
    }

    /**
    * @dev Pause/unpause
    */

    function setPause(bool value) external onlyOperator {
        if (value) {
            _pause();
        } else {
            genesisStartOnce = false;
            for (uint i; i < timeframes.length; i = i + 1) {
                genesisLockOnces[timeframes[i].id] = false;
            }
            _unpause();
        }
    }

    
    /**
     * @dev set minBetAmount
     * callable by admin
     */
    function setMinBetAmount(uint256 _minBetAmount) external onlyAdmin {
        minBetAmount = _minBetAmount;

        emit MinBetAmountChanged(_minBetAmount);
    }

    /// @dev check if bet is active

    function getExecutableTimeframes() external view override returns(uint8[] memory result, uint256 count) {
        result = new uint8[](timeframes.length);

        for (uint256 i = 0; i < timeframes.length; i = i + 1) {
            uint8 timeframeId = timeframes[i].id;

            if (isNecessaryToExecute(timeframeId)) {
                result[i] = timeframeId;
                count = count + 1;
            }
        }
    }

    /**
     * @dev Return round epochs that a user has participated in specific timeframe
     */
    function getUserRounds(
        uint8 timeframeId,
        address user,
        uint256 cursor,
        uint256 size
    ) external view returns (uint256[] memory, uint256) {
        uint256 length = size;
        if (length > userRounds[timeframeId][user].length - cursor) {
            length = userRounds[timeframeId][user].length - cursor;
        }

        uint256[] memory values = new uint256[](length);
        for (uint256 i = 0; i < length; i++) {
            values[i] = userRounds[timeframeId][user][cursor + i];
        }

        return (values, cursor + length);
    }

    /**
     * @dev Caluclate current round based on genesis timestamp and block number
     * @param timeframeId timeframe id what we want to get round number
    */
    function getCurrentUserRoundNumber(uint8 timeframeId) 
        external 
        view 
        returns(uint256 roundFromBlockNumber, uint256 roundFromBlockTime )
    {
        roundFromBlockNumber = (block.number - genesisStartBlockNumber) / timeframes[timeframeId].intervalBlocks;
        roundFromBlockTime = (block.timestamp - genesisStartBlockTimestamp) / timeframes[timeframeId].interval;
    }

    /**
    * @dev Check if round is bettable
    */
    function isBettable(uint8 timeframeId, uint256 epoch)
        external
        view
        returns(bool)
    {
        return _bettable(timeframeId, epoch);
    }

    /**
     * @dev Get the claimable stats of specific epoch and user account
     */
    function isClaimable(
        uint8 timeframeId,
        uint256 epoch,
        address user
    ) public view returns (bool) {
        BetInfo memory betInfo = ledger[timeframeId][epoch][user];
        Round memory round = rounds[timeframeId][epoch];
        if (round.lockPrice == round.closePrice) {
            return false;
        }
        return
            round.oracleCalled &&
            betInfo.amount > 0 &&
            !betInfo.claimed && 
            ((round.closePrice > round.lockPrice &&
                betInfo.position == Position.Bull) ||
                (round.closePrice < round.lockPrice &&
                    betInfo.position == Position.Bear));
    }

    function isNecessaryToExecute(uint8 timeframeId) public view returns(bool) {
        if (!genesisLockOnces[timeframeId] || !genesisStartOnce) {
            return false;
        }

        uint256 currentEpoch = currentEpochs[timeframeId];
        Round memory round = rounds[timeframeId][currentEpoch];
        Round memory prevRound = rounds[timeframeId][currentEpoch - 1];

        bool lockable = round.startBlock != 0 && round.lockPrice == 0 && block.number >= round.lockBlock;
        bool closable = prevRound.lockBlock !=0 && prevRound.closePrice == 0 && !prevRound.oracleCalled && block.number >= prevRound.closeBlock;

        return lockable && closable && (prevRound.totalAmount > 0 || round.totalAmount > 0);
    }

    /**
     * @dev Get latest recorded price from oracle
     */
    function _getPriceFromOracle() internal returns (uint256, uint256, uint256) {
        IOracle.Round memory latestRound = oracle.getLatestRoundData();
        require(
            latestRound.roundId > oracleLatestRoundId,
            "Oracle update roundId must be larger than oracleLatestRoundId"
        );
        oracleLatestRoundId = latestRound.roundId;
        return (latestRound.roundId, latestRound.price, latestRound.timestamp);
    }

    function _writeOraclePrice(uint256 timestamp, uint256 price) internal {
        IOracle.Round memory latestRound = oracle.getLatestRoundData();
        oracle.writePrice(latestRound.roundId + 1, timestamp, price);
    }

    /**
     * @dev Start round
     * Previous round n-2 must end
     */
    function _safeStartRound(uint8 timeframeId, uint256 epoch) internal {
        require(
            block.number >= rounds[timeframeId][epoch - 2].closeBlock,
            "Can only start new round after round n-2 closeBlock"
        );
        _startRound(timeframeId, epoch);
    }

    function _startRound(uint8 timeframeId, uint256 epoch) internal {
        Round storage round = rounds[timeframeId][epoch];
        round.startBlock = block.number;
        round.lockBlock = block.number + timeframes[timeframeId].intervalBlocks;
        round.closeBlock = block.number + timeframes[timeframeId].intervalBlocks * 2;
        round.epoch = epoch;
        round.totalAmount = 0;

        emit StartRound(timeframeId, epoch);
    }

    /**
     * @dev Lock round
     */
    function _safeLockRound(
        uint8 timeframeId,
        uint256 epoch,
        uint256 roundId,
        uint256 price
    ) internal {
        require(
            rounds[timeframeId][epoch].startBlock != 0,
            "Can only lock round after round has started"
        );
        require(
            block.number >= rounds[timeframeId][epoch].lockBlock,
            "Can only lock round after lockBlock"
        );
        _lockRound(timeframeId, epoch, roundId, price);
    }

    function _lockRound(
        uint8 timeframeId,
        uint256 epoch,
        uint256 roundId,
        uint256 price
    ) internal {
        Round storage round = rounds[timeframeId][epoch];
        round.lockPrice = price;
        round.lockOracleId = roundId;

        emit LockRound(timeframeId, epoch, roundId, round.lockPrice);
    }

    /**
     * @dev End round
     */
    function _safeEndRound(
        uint8 timeframeId,
        uint256 epoch,
        uint256 roundId,
        uint256 price
    ) internal {
        require(
            rounds[timeframeId][epoch].lockBlock != 0,
            "Can only end round after round has locked"
        );
        require(
            block.number >= rounds[timeframeId][epoch].closeBlock,
            "Can only end round after closeBlock"
        );
        _endRound(timeframeId, epoch, roundId, price);
    }

    function _endRound(
        uint8 timeframeId,
        uint256 epoch,
        uint256 roundId,
        uint256 price
    ) internal {
        Round storage round = rounds[timeframeId][epoch];
        round.closePrice = price;
        round.closeOracleId = roundId;
        round.oracleCalled = true;

        emit EndRound(timeframeId, epoch, roundId, round.closePrice);
    }

    function _claim(uint8 timeframeId, uint256 epoch) internal {
        require(
            rounds[timeframeId][epoch].startBlock != 0,
            "Round has not started"
        );
        require(
            block.number > rounds[timeframeId][epoch].closeBlock,
            "Round has not ended"
        );
        require(
            !ledger[timeframeId][epoch][msg.sender].claimed,
            "Rewards claimed"
        );

        uint256 rewardAmount = 0;
        BetInfo storage betInfo = ledger[timeframeId][epoch][msg.sender];

        // Round valid, claim rewards
        if (rounds[timeframeId][epoch].oracleCalled) {
            require(
                isClaimable(timeframeId, epoch, msg.sender),
                "Not eligible for claim"
            );
            rewardAmount = betInfo.amount * 2;
        }
        // Round invalid, refund bet amount
        else {
            require(
                refundable(timeframeId, epoch, msg.sender),
                "Not eligible for refund"
            );

            rewardAmount = betInfo.amount;
        }

        betInfo.claimed = true;
        vault.claimBettingRewards(msg.sender, rewardAmount);

        emit Claimed(marketName, msg.sender, timeframeId, epoch, rewardAmount);
    }

    /**
     * @dev Determine if a round is valid for receiving bets
     * Round must have started and locked
     * Current block must be within startBlock and closeBlock
     */
    function _bettable(uint8 timeframeId, uint256 epoch)
        internal
        view
        returns (bool)
    {
        return
            rounds[timeframeId][epoch].startBlock != 0 &&
            rounds[timeframeId][epoch].lockBlock != 0 &&
            rounds[timeframeId][epoch].lockPrice == 0 &&
            block.number > rounds[timeframeId][epoch].startBlock;
    }

}
