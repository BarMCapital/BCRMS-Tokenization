import fs from "fs";
import path from "path";
import { fileURLToPath } from "url";
import { ethers } from "ethers";

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);

// Folder where mock BRRMS JSON files live for now.
const BRRMS_DATA_DIR = path.join(__dirname, "..", "br_rms_data");

/**
 * Each BRRMS file is expected to look like:
 * {
 *   "month": "2025-01",
 *   "businessId": "fundI",  // simple label for now
 *   "grossRevenue": 145200,
 *   "refunds": 3200,
 *   "fees": 5400,
 *   "netRevenue": 136600,
 *   "tokenizedPercentBps": 2000  // 20% of revenue
 * }
 */

/**
 * Read the last N months of BRRMS files for a given fund/business key
 * and compute the average netRevenue and navPerToken.
 *
 * @param {string} fundKey - "I", "II", "III", "IV" for now.
 * @param {number} months - how many trailing months to average (e.g. 3).
 * @param {number} totalSupply - total token supply (as a BigInt).
 * @returns {Promise<bigint>} navPerToken scaled to 1e18.
 */
export async function computeNavPerToken(fundKey, months, totalSupply) {
  if (totalSupply === 0n) {
    throw new Error("Total supply is zero, cannot compute NAV.");
  }

  const files = fs
    .readdirSync(BRRMS_DATA_DIR)
    .filter((f) => f.toLowerCase().endsWith(".json"));

  // For now we use businessId = fund key label mapping like "fundI", "fundII"
  const businessId = `fund${fundKey}`;

  // Filter files for this business
  const businessFiles = files.filter((f) => f.includes(businessId));

  if (businessFiles.length === 0) {
    throw new Error(`No BRRMS files found for businessId ${businessId}`);
  }

  // Sort files by filename descending so we can take the latest N
  const sorted = businessFiles.sort().reverse();
  const selected = sorted.slice(0, months);

  let totalNetRevenue = 0;
  let totalWeight = 0;

  let tokenizedPercentBps = 0;

  for (const file of selected) {
    const fullPath = path.join(BRRMS_DATA_DIR, file);
    const raw = fs.readFileSync(fullPath, "utf8");
    const data = JSON.parse(raw);

    if (data.businessId !== businessId) continue;

    const netRevenue = Number(data.netRevenue || 0);
    const percentBps = Number(data.tokenizedPercentBps || 0);

    totalNetRevenue += netRevenue;
    totalWeight += 1;

    // assume tokenizedPercentBps is consistent; just read last one
    tokenizedPercentBps = percentBps;
  }

  if (totalWeight === 0) {
    throw new Error(`No BRRMS records with netRevenue for ${businessId}`);
  }

  const avgNetRevenue = totalNetRevenue / totalWeight;

  // tokenizedPortion = avgNetRevenue * (tokenizedPercentBps / 10000)
  const tokenizedPortion = (avgNetRevenue * tokenizedPercentBps) / 10000;

  // navPerToken = tokenizedPortion / totalSupply
  // scale to 1e18 for Solidity
  const scale = ethers.parseUnits("1", 18); // 1e18
  // Use BigInt math
  const tokenizedBig = BigInt(Math.round(tokenizedPortion * 100)); // scale cents
  const supplyBig = totalSupply;

  // convert cents to wei-like scale
  const tokenizedScaled = (tokenizedBig * scale) / 100n;

  const navPerToken = tokenizedScaled / supplyBig;

  return navPerToken;
}
