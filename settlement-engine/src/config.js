import dotenv from "dotenv";
dotenv.config();

export const RPC_URL = process.env.RPC_URL;
export const FUND_ADDRESSES = {
  I: process.env.REDEMPTION_FUND_I_ADDRESS,
  II: process.env.REDEMPTION_FUND_II_ADDRESS,
  III: process.env.REDEMPTION_FUND_III_ADDRESS,
  IV: process.env.REDEMPTION_FUND_IV_ADDRESS
};

export const PAYOUT_LOG_FILE = process.env.PAYOUT_LOG_FILE || "./payout-log.json";

if (!RPC_URL) {
  throw new Error("RPC_URL is not set");
}
