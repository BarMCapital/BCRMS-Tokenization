// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "./RevenueRedemptionBase.sol";

/**
 * @title RevenueRedemptionFundII
 *
 * @notice Fund II redemption rules:
 *         - lockup: 3 months
 *         - per-period cap: 5% of supply
 *         - liquidity fee: 2%
 *         - NAV discount: 1%
 *         - penalty schedule in basis points:
 *             months 3–6:  1000
 *             months 7–12: 500
 *             after 12:    300
 */
contract RevenueRedemptionFundII is RevenueRedemptionBase {

    constructor(address _revenueToken)
        RevenueRedemptionBase(
            _revenueToken,
            90 days, // lockup period
            500,     // capBpsPerPeriod = 5%
            200,     // liquidityFeeBps = 2%
            100      // navDiscountBps = 1%
        )
    {}

    /**
     * @notice Returns penalty in basis points based on elapsed time.
     * @dev Uses 30 days as the month duration.
     */
    function getPenaltyBps(uint256 elapsedSeconds) public view override returns (uint256) {
        uint256 monthsElapsed = elapsedSeconds / (30 days);

        if (monthsElapsed < 3) {
            // lockup covers this range, guard value only
            return 1000;
        } else if (monthsElapsed < 7) {
            return 1000; // months 3–6
        } else if (monthsElapsed < 13) {
            return 500;  // months 7–12
        } else {
            return 300;  // after 12 months
        }
    }
}
