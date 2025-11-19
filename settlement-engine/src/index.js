import { createProvider, getFundContracts } from "./contracts.js";
import { appendPayoutRecord } from "./storage.js";
import { executePayout } from "./payout.js";

async function main() {
  const provider = createProvider();
  const funds = getFundContracts(provider);

  console.log("[ENGINE] Settlement engine starting…");
  Object.entries(funds).forEach(([key, contract]) => {
    console.log(`[ENGINE] Listening for RedemptionProcessed on Fund ${key} at ${contract.target}`);
    contract.on(
      "RedemptionProcessed",
      async (
        holder,
        periodId,
        amountTokens,
        navPerToken,
        grossValue,
        penaltyAmount,
        liquidityFeeAmount,
        discountAmount,
        netPayout,
        eventTimestamp,
        event
      ) => {
        const record = {
          fundKey: key,
          holder,
          periodId: periodId.toString(),
          amountTokens: amountTokens.toString(),
          navPerToken: navPerToken.toString(),
          grossValue: grossValue.toString(),
          penaltyAmount: penaltyAmount.toString(),
          liquidityFeeAmount: liquidityFeeAmount.toString(),
          discountAmount: discountAmount.toString(),
          netPayout: netPayout.toString(),
          eventTimestamp: eventTimestamp.toString(),
          txHash: event.log.transactionHash
        };

        console.log("[ENGINE] RedemptionProcessed event received:", record);

        // Log to local storage for audit
        appendPayoutRecord(record);

        // Trigger payout procedure (external system integration)
        await executePayout(record);
      }
    );
  });
}

main().catch((err) => {
  console.error("[ENGINE] Fatal error in settlement engine:", err);
  process.exit(1);
});
