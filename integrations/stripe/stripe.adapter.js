// integrations/stripe/stripe.adapter.js

/**
 * Stripe → BRRMS Adapter
 *
 * This module takes raw Stripe charge/fee data and converts it into
 * a normalized BusinessRevenueRecord that matches:
 *   brRMS/schemas/revenue.schema.json
 *
 * This is a first-pass stub for BAR M Capital engineering.
 */

/**
 * @typedef {Object} StripeCharge
 * @property {number} amount - Charge amount in the smallest currency unit (e.g., cents).
 * @property {boolean} paid - Whether the charge was successfully paid.
 * @property {boolean} refunded - Whether the charge was refunded.
 * @property {number} amount_refunded - Refunded amount in smallest currency unit.
 * @property {number} created - Unix timestamp (seconds) when the charge was created.
 * @property {string} currency - Currency code (e.g., "usd").
 * @property {string} id - Stripe charge ID.
 */

/**
 * @typedef {Object} StripeFeeSummary
 * @property {number} totalFees - Total processor fees in smallest currency unit.
 */

/**
 * Aggregates a list of Stripe charges and fee data into a single BRRMS
 * BusinessRevenueRecord for a given business and date.
 *
 * @param {Object} params
 * @param {string} params.businessId - Internal BAR M business ID.
 * @param {string} params.date - Target date (YYYY-MM-DD) for aggregation.
 * @param {string} [params.timezone="America/Chicago"] - IANA timezone string.
 * @param {StripeCharge[]} params.charges - Array of Stripe charge objects.
 * @param {StripeFeeSummary} params.feeSummary - Aggregated fee info.
 * @param {string} [params.currency="USD"] - ISO currency code.
 * @returns {Object} BusinessRevenueRecord compatible object.
 */
function buildDailyRevenueRecord({
  businessId,
  date,
  timezone = "America/Chicago",
  charges = [],
  feeSummary = { totalFees: 0 },
  currency = "USD"
}) {
  // Filter charges that belong to the given date
  // NOTE: In a real implementation, we would normalize timestamps according to the business timezone.
  const chargesForDate = charges.filter((charge) => {
    const chargeDateIso = new Date(charge.created * 1000).toISOString().slice(0, 10);
    return chargeDateIso === date;
  });

  let grossRevenue = 0;
  let refunds = 0;
  let chargebacks = 0; // Placeholder for future use if chargeback data is provided
  let cashSales = 0;   // Deterministic default: Stripe events include only card/digital transactions unless cash is reported separately.
  let cardSales = 0;

  chargesForDate.forEach((charge) => {
    const amount = (charge.amount || 0) / 100; // convert from cents
    const refundedAmount = (charge.amount_refunded || 0) / 100;

    if (charge.paid) {
      grossRevenue += amount;
      cardSales += amount;
    }

    if (charge.refunded && refundedAmount > 0) {
      refunds += refundedAmount;
    }
  });

  const processorFees = (feeSummary.totalFees || 0) / 100;

  const netRevenue = grossRevenue - (processorFees + refunds + chargebacks);

  const nowIso = new Date().toISOString();

  const record = {
    businessId,
    externalBusinessRef: null,
    date,
    timezone,
    grossRevenue: roundToTwo(grossRevenue),
    processorFees: roundToTwo(processorFees),
    chargebacks: roundToTwo(chargebacks),
    refunds: roundToTwo(refunds),
    netRevenue: roundToTwo(netRevenue),
    cashSales: roundToTwo(cashSales),
    cardSales: roundToTwo(cardSales),
    sourceSystem: "Stripe",
    sourceRecordId: null, // Could be a batch ID or omitted for aggregated records
    ingestedAt: nowIso,
    hash: null,           // To be filled in by BRRMS hashing/anchoring process
    currency,
    notes: ""
  };

  return record;
}

/**
 * Simple helper to avoid long floating-point noise.
 *
 * @param {number} value
 * @returns {number}
 */
function roundToTwo(value) {
  return Math.round((value + Number.EPSILON) * 100) / 100;
}

module.exports = {
  buildDailyRevenueRecord
};

