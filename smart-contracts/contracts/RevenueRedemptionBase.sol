// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

interface IRevenueShareToken {
    function totalSupply() external view returns (uint256);
}

/**
 * @title RevenueRedemptionBase
 *
 * @notice Base contract for deterministic redemption logic for BAR M funds.
 *         This contract records redemption requests and computes payout math.
 *         It does not move money; off-chain systems use its events and data.
 */
abstract contract RevenueRedemptionBase {
    struct RedemptionRequest {
        uint256 amountTokens;  // amount of tokens requested for redemption
        uint256 timestamp;     // request time
        bool processed;        // true once processed
    }

    address public owner;
    IRevenueShareToken public revenueToken;
    uint256 public offeringStartTimestamp;

    // lockup duration in seconds
    uint256 public lockupPeriod;

    // maximum percentage of circulating supply redeemable per period (in basis points)
    uint256 public capBpsPerPeriod;

    // fees in basis points
    uint256 public liquidityFeeBps; // applied to gross value
    uint256 public navDiscountBps;  // applied to gross value

    // periodId => total tokens requested in that period
    mapping(uint256 => uint256) public totalRequestedInPeriod;

    // user => periodId => redemption request
    mapping(address => mapping(uint256 => RedemptionRequest)) public requests;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
    event RedemptionRequested(address indexed holder, uint256 indexed periodId, uint256 amountTokens, uint256 timestamp);
    event RedemptionProcessed(
        address indexed holder,
        uint256 indexed periodId,
        uint256 amountTokens,
        uint256 navPerToken,
        uint256 grossValue,
        uint256 penaltyAmount,
        uint256 liquidityFeeAmount,
        uint256 discountAmount,
        uint256 netPayout,
        uint256 timestamp
    );

    modifier onlyOwner() {
        require(msg.sender == owner, "NOT_OWNER");
        _;
    }

    constructor(
        address _revenueToken,
        uint256 _lockupPeriod,
        uint256 _capBpsPerPeriod,
        uint256 _liquidityFeeBps,
        uint256 _navDiscountBps
    ) {
        require(_revenueToken != address(0), "ZERO_ADDRESS");
        require(_capBpsPerPeriod <= 10000, "CAP_TOO_HIGH");

        owner = msg.sender;
        revenueToken = IRevenueShareToken(_revenueToken);
        offeringStartTimestamp = block.timestamp;

        lockupPeriod = _lockupPeriod;
        capBpsPerPeriod = _capBpsPerPeriod;
        liquidityFeeBps = _liquidityFeeBps;
        navDiscountBps = _navDiscountBps;

        emit OwnershipTransferred(address(0), msg.sender);
    }

    /**
     * @notice Child contract defines penalty schedule in basis points.
     * @param elapsedSeconds Time since offeringStartTimestamp.
     */
    function getPenaltyBps(uint256 elapsedSeconds) public view virtual returns (uint256);

    /**
     * @notice Holder requests redemption of tokens for a given period.
     * @dev periodId is a caller-defined identifier (for example, a quarter).
     */
    function requestRedemption(uint256 periodId, uint256 amountTokens) external {
        require(block.timestamp >= offeringStartTimestamp + lockupPeriod, "LOCKUP_ACTIVE");
        require(amountTokens > 0, "ZERO_AMOUNT");
        require(requests[msg.sender][periodId].amountTokens == 0, "ALREADY_REQUESTED");

        uint256 supply = revenueToken.totalSupply();
        require(supply > 0, "ZERO_SUPPLY");

        uint256 newTotal = totalRequestedInPeriod[periodId] + amountTokens;
        require(newTotal * 10000 <= supply * capBpsPerPeriod, "CAP_EXCEEDED");

        totalRequestedInPeriod[periodId] = newTotal;

        requests[msg.sender][periodId] = RedemptionRequest({
            amountTokens: amountTokens,
            timestamp: block.timestamp,
            processed: false
        });

        emit RedemptionRequested(msg.sender, periodId, amountTokens, block.timestamp);
    }

    /**
     * @notice Owner processes a redemption using a provided navPerToken.
     * @dev navPerToken should use the same decimals as the token (e.g. 1e18).
     *      This does not move money; it emits data for off-chain payout logic.
     */
    function processRedemption(
        address holder,
        uint256 periodId,
        uint256 navPerToken
    )
        external
        onlyOwner
        returns (
            uint256 grossValue,
            uint256 netPayout,
            uint256 penaltyAmount,
            uint256 liquidityFeeAmount,
            uint256 discountAmount
        )
    {
        RedemptionRequest storage req = requests[holder][periodId];
        require(!req.processed, "ALREADY_PROCESSED");
        require(req.amountTokens > 0, "NO_REQUEST");

        // mark as processed
        req.processed = true;

        // compute gross value: tokens * navPerToken / 1e18
        grossValue = (req.amountTokens * navPerToken) / 1e18;

        uint256 elapsed = block.timestamp - offeringStartTimestamp;
        uint256 penaltyBps = getPenaltyBps(elapsed);

        penaltyAmount = (grossValue * penaltyBps) / 10000;
        liquidityFeeAmount = (grossValue * liquidityFeeBps) / 10000;
        discountAmount = (grossValue * navDiscountBps) / 10000;

        netPayout = grossValue - penaltyAmount - liquidityFeeAmount - discountAmount;

        emit RedemptionProcessed(
            holder,
            periodId,
            req.amountTokens,
            navPerToken,
            grossValue,
            penaltyAmount,
            liquidityFeeAmount,
            discountAmount,
            netPayout,
            block.timestamp
        );
    }

    function transferOwnership(address newOwner) external onlyOwner {
        require(newOwner != address(0), "ZERO_ADDRESS");
        address previous = owner;
        owner = newOwner;
        emit OwnershipTransferred(previous, newOwner);
    }
}
