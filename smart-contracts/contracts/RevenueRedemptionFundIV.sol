// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "./RevenueRedemptionBase.sol";

/**
 * @title RevenueRedemptionFundIV
 *
 * @notice Fund IV redemption rules:
 *         - lockup: 12 months
 *         - per-period cap: 5% of supply
 *         - liquidity fee: 3%
 *         - NAV discount: 4%
 *         - penalty schedule in basis points:
 *             months 12–18: 2000
 *             months 19–24: 1500
 *             months 25–36: 1000
 *             after 36:     500
 */
contract RevenueRedemptionFundIV is RevenueRedemptionBase {

    constructor(address _revenueToken)
        RevenueRedemptionBase(
            _revenueToken,
            360 days, // lockup period
            500,      // capBpsPerPeriod = 5%
            300,      // liquidityFeeBps = 3%
            400       // navDiscountBps = 4%
        )
    {}

    function getPenaltyBps(uint256 elapsedSeconds) public view override returns (uint256) {
        uint256 monthsElapsed = elapsedSeconds / (30 days);

        if (monthsElapsed < 12) {
            // lockup covers this, guard value only
            return 2000;
        } else if (monthsElapsed < 19) {
            return 2000; // months 12–18
        } else if (monthsElapsed < 25) {
            return 1500; // months 19–24
        } else if (monthsElapsed < 37) {
            return 1000; // months 25–36
        } else {
            return 500;  // after 36 months
        }
    }
}
