/**
 * Admin Process Redemption Script
 *
 * This script:
 * 1. Computes NAV for a specified business
 * 2. Loads the correct Fund redemption contract (I–IV)
 * 3. Executes processRedemption()
 * 4. Writes audit-ready output for settlement
 */

const path = require("path");
const { getNAVForBusiness } = require("../nav");
const { loadRedemptionContract } = require("../contracts");
const storage = require("../storage");
const payout = require("../payout");
const { getInsuranceAdjustment } = require("../insurance");


// Hard-coded fund parameters (already committed)
const FUNDS = {
  I:  "FundI",
  II: "FundII",
  III:"FundIII",
  IV: "FundIV"
};

/**
 * EXECUTION ENTRYPOINT
 *
 * Usage:
 *   node adminProcessRedemption.js <businessId> <fundKey> <tokenAmount>
 */
async function main() {
  const [businessId, fundKey, tokenAmountRaw] = process.argv.slice(2);

  if (!businessId || !fundKey || !tokenAmountRaw) {
    console.error("Usage: node adminProcessRedemption.js <businessId> <fundKey> <tokenAmount>");
    process.exit(1);
  }

  const tokenAmount = Number(tokenAmountRaw);
  if (isNaN(tokenAmount)) {
    console.error("Invalid tokenAmount. Must be a number.");
    process.exit(1);
  }

  // 1. Compute NAV
  console.log(`\n[1] Computing NAV for business: ${businessId}`);
  const nav = await getNAVForBusiness(businessId);
  console.log(`NAV = ${nav}`);

  // 2. Load Fund redemption contract
  const fundName = FUNDS[fundKey];
  if (!fundName) {
    console.error(`Unknown fundKey "${fundKey}". Expected: I, II, III, or IV.`);
    process.exit(1);
  }

  console.log(`\n[2] Loading redemption contract for ${fundName}`);
  const redemptionContract = await loadRedemptionContract(fundName);

  // 3. Execute redemption
  console.log(`\n[3] Executing redemption for tokenAmount: ${tokenAmount}`);
  const redemptionResult = redemptionContract.processRedemption({
    nav,
    tokenAmount
  });

  console.log("\nRedemption Result:");
  console.log(JSON.stringify(redemptionResult, null, 2));
  // === Insurance Adjustment Hook ===
console.log("\n[Insurance] Evaluating business insurance risk…");

const insurance = getInsuranceAdjustment(businessId);

console.log("[Insurance] Risk Adjustment Factors:");
console.log(JSON.stringify(insurance, null, 2));

// Compute adjusted redemption value
const adjustedValue =
  redemptionResult.redemptionValue * insurance.adjustmentMultiplier;

redemptionResult.adjustedRedemptionValue = adjustedValue;

console.log(
  `\n[Insurance] Adjusted redemption value (post-insurance): ${adjustedValue}`
);


  // 4. Write audit snapshot
  console.log("\n[4] Writing audit snapshot...");
  await storage.writeAuditRecord({
    businessId,
    fund: fundName,
    nav,
    tokenAmount,
    timestamp: new Date().toISOString(),
    redemptionResult
  });

  console.log("[OK] Audit record written.");

  // 5. Trigger payout logic
  console.log("\n[5] Triggering payout engine...");
  await payout.distribute(redemptionResult);

  console.log("\n[✔] Redemption process complete.\n");
}

main().catch((err) => {
  console.error("FATAL ERROR in adminProcessRedemption:", err);
  process.exit(1);
});
