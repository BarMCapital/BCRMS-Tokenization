/**
 * Insurance Hook Module
 *
 * This module evaluates business risk factors from the business upload package
 * and returns a deterministic risk score or adjustment multiplier.
 *
 * It is intentionally simple for now, but structured so the BAR M Capital
 * insurance vertical can expand this into a full underwriting model.
 */

const path = require("path");
const fs = require("fs");

function loadJSON(filepath) {
  const raw = fs.readFileSync(filepath, "utf-8");
  return JSON.parse(raw);
}

/**
 * getInsuranceAdjustment(businessId)
 *
 * Returns:
 *   {
 *     riskScore: Number,
 *     adjustmentMultiplier: Number,
 *     factors: {...}
 *   }
 *
 * If the business does not include insurance_exposure.json,
 * returns a neutral multiplier of 1.0.
 */
function getInsuranceAdjustment(businessId) {
  const businessFolder = path.join(__dirname, "..", "business_uploads", businessId);

  const exposurePath = path.join(businessFolder, "insurance_exposure.json");

  // Case 1: No insurance_exposure file → neutral
  if (!fs.existsSync(exposurePath)) {
    return {
      riskScore: 0,
      adjustmentMultiplier: 1.0,
      factors: {},
      note: "No insurance_exposure.json, neutral multiplier applied"
    };
  }

  // Case 2: Insurance exposure exists → load and compute score
  const exposure = loadJSON(exposurePath);
  const factors = exposure.riskFactors || {};

  // Deterministic scoring rules
  let riskScore = 0;

  if (factors.revenueVolatility > 0.20) riskScore += 3;
  else if (factors.revenueVolatility > 0.10) riskScore += 2;
  else if (factors.revenueVolatility > 0.05) riskScore += 1;

  if (factors.industryRiskTier) {
    riskScore += factors.industryRiskTier;
  }

  // Convert risk score → adjustment multiplier
  // Higher risk → slightly reduced redemption value
  const adjustmentMultiplier = Math.max(0.85, 1.0 - riskScore * 0.02);

  return {
    riskScore,
    adjustmentMultiplier,
    factors,
    note: "Insurance risk adjustment applied"
  };
}

module.exports = { getInsuranceAdjustment };
