// SPDX-License-Identifier: MIT

pragma solidity ^0.8.10;

import "@openzeppelin/contracts/access/AccessControl.sol";

import "./interfaces/IBinaryOracle.sol";

error BINARY_ORACLE_NOT_ADMIN();
error BINARY_ORACLE_NOT_WRITER();

contract BinaryOracle is AccessControl, IBinaryOracle {
    bytes32 public constant WRITER_ROLE = keccak256("GAME_ORACLE_WRITER");

    /// @dev Prices by roundId
    mapping(uint256 => Round) public rounds;

    /// @dev round id array
    mapping(uint256 => uint256) public allRoundIds;

    uint256 public roundLength = 0;

    /// @dev Round ID of last round, Round ID is zero-based
    Round public latestRoundData;

    /// @dev flag for initializing, default false.
    bool public genesisStarted;

    /// @dev Emit this event when updating writer status
    event WriterUpdated(address indexed writer, bool enabled);
    /// @dev Emit this event when writing a new price round
    event WrotePrice(
        address indexed writer,
        uint256 indexed roundId,
        uint256 indexed timestamp,
        uint256 price
    );

    modifier onlyAdmin() {
        if (!isAdmin(msg.sender)) revert BINARY_ORACLE_NOT_ADMIN();
        _;
    }

    modifier onlyWriter() {
        if (!isWriter(msg.sender)) revert BINARY_ORACLE_NOT_WRITER();
        _;
    }

    constructor() {
        _setupRole(DEFAULT_ADMIN_ROLE, msg.sender);
        _setRoleAdmin(WRITER_ROLE, DEFAULT_ADMIN_ROLE);
    }

    /**
     * @notice External function that records a new price round
     * @dev This function is only permitted to writters
     * @param roundId Round ID should be greater than last round id
     * @param timestamp Timestamp should be greater than last round's time, and less then current time.
     * @param price Price of round, based 1e18
     */
    function writePrice(
        uint256 roundId,
        uint256 timestamp,
        uint256 price
    ) external override onlyWriter {
        _writePrice(roundId, timestamp, price);
        latestRoundData = rounds[roundId];
    }

    /**
     * @notice External function that records a new price round
     * @dev This function is only permitted to writters
     * @param roundIds Array of round ids
     * @param timestamps Array of timestamps
     * @param prices Array of prices
     */
    function writeBatchPrices(
        uint256[] calldata roundIds,
        uint256[] calldata timestamps,
        uint256[] calldata prices
    ) external override onlyWriter {
        require(
            roundIds.length == timestamps.length &&
            timestamps.length == prices.length,
            "Invalid array length"
        );

        uint256 i;
        for (; i < roundIds.length; ++i) {
            _writePrice(roundIds[i], timestamps[i], prices[i]);
        }

        latestRoundData = rounds[roundIds[i - 1]];
    }

    /**
     * @notice External function to enable/disable price writer
     * @dev This function is only permitted to the owner
     * @param writer Writter address to update
     * @param enable Boolean to enable/disable writer
     */
    function setWriter(address writer, bool enable) external onlyAdmin {
        require(writer != address(0), "Invalid address");
        if (enable) {
            // fixme can you require that it's disabled if you are doing enable 
            grantRole(WRITER_ROLE, writer);
        } else {
            revokeRole(WRITER_ROLE, writer);
        }
        emit WriterUpdated(writer, enable);
    }

    /**
     * @notice External function that returns the price and timestamp by round id
     * @param roundId Round ID to get
     * @return timestamp Round Time
     * @return price Round price
     */
    function getRoundData(uint256 roundId)
        external
        view
        override
        returns (uint256 timestamp, uint256 price)
    {
        timestamp = rounds[roundId].timestamp;
        price = rounds[roundId].price;
        require(timestamp != 0, "Invalid Round ID");
    }

    function getLatestRoundData() external view returns (Round memory) {
        return latestRoundData;
    }

    /// @dev Return `true` if the account belongs to the admin role.
    function isAdmin(address account) public view virtual returns (bool) {
        return hasRole(DEFAULT_ADMIN_ROLE, account);
    }

    /// @dev Return `true` if the account belongs to the user role.
    function isWriter(address account) public view virtual returns (bool) {
        return hasRole(WRITER_ROLE, account);
    }

    /**
     * @notice Internal function that records a new price round
     * @param timestamp Timestamp should be greater than last round's time, and less then current time.
     * @param price Price of round
     */
    function _writePrice(
        uint256 roundId,
        uint256 timestamp,
        uint256 price
    ) internal {
        if (genesisStarted) {
            require(
                roundId > latestRoundData.roundId &&
                timestamp > latestRoundData.timestamp,
                "Invalid Timestamp"
            );
        } else {
            genesisStarted = true;
        }

        Round storage newRound = rounds[roundId];
        newRound.roundId = roundId;
        newRound.price = price;
        newRound.timestamp = timestamp;
        newRound.writer = msg.sender;

        allRoundIds[roundLength] = roundId;
        ++roundLength;
        emit WrotePrice(msg.sender, roundId, timestamp, price);
    }
}
