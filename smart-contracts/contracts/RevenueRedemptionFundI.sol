// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "./RevenueRedemptionBase.sol";

/**
 * @title RevenueRedemptionFundI
 *
 * @notice Fund I redemption rules:
 *         - 6 month lockup enforced in base contract.
 *         - Per-period cap: 7.5% of circulating supply.
 *         - Liquidity fee: 2% of gross value.
 *         - NAV discount: 2% of gross value.
 *         - Penalty schedule (in basis points) based on elapsed time:
 *             months 6–8:  1500
 *             months 9–10: 1200
 *             months 11–12:1000
 *             after 12:     500
 */
contract RevenueRedemptionFundI is RevenueRedemptionBase {

    constructor(address _revenueToken)
        RevenueRedemptionBase(
            _revenueToken,
            180 days, // lockup period
            750,      // capBpsPerPeriod = 7.5%
            200,      // liquidityFeeBps = 2%
            200       // navDiscountBps = 2%
        )
    {}

    /**
     * @notice Returns penalty in basis points based on elapsed time.
     * @dev Uses 30 days as the month duration.
     */
    function getPenaltyBps(uint256 elapsedSeconds) public view override returns (uint256) {
        // elapsedSeconds starts at offeringStartTimestamp, lockup logic is in base.
        uint256 monthsElapsed = elapsedSeconds / (30 days);

        if (monthsElapsed < 6) {
            // lockup should have blocked this, but keep a guard
            return 1500;
        } else if (monthsElapsed < 9) {
            return 1500; // months 6–8
        } else if (monthsElapsed < 11) {
            return 1200; // months 9–10
        } else if (monthsElapsed < 13) {
            return 1000; // months 11–12
        } else {
            return 500;  // after 12 months
        }
    }
}
