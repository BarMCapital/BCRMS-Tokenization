// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "./RevenueRedemptionBase.sol";

/**
 * @title RevenueRedemptionFundIII
 *
 * @notice Fund III redemption rules:
 *         - short lockup: 1 month
 *         - per-period cap: 3% of supply
 *         - liquidity fee: 3%
 *         - NAV discount: 3%
 *         - penalty schedule in basis points:
 *             months 0–3: 500
 *             after 3:    0
 */
contract RevenueRedemptionFundIII is RevenueRedemptionBase {

    constructor(address _revenueToken)
        RevenueRedemptionBase(
            _revenueToken,
            30 days, // lockup period
            300,     // capBpsPerPeriod = 3%
            300,     // liquidityFeeBps = 3%
            300      // navDiscountBps = 3%
        )
    {}

    function getPenaltyBps(uint256 elapsedSeconds) public view override returns (uint256) {
        uint256 monthsElapsed = elapsedSeconds / (30 days);

        if (monthsElapsed < 1) {
            // first month, lockup blocks requests; guard value only
            return 500;
        } else if (monthsElapsed < 3) {
            return 500; // months 1–3
        } else {
            return 0;   // after 3 months
        }
    }
}
