import { ethers } from "ethers";
import { RPC_URL, FUND_ADDRESSES } from "./config.js";

// Minimal ABI fragment for RedemptionProcessed event
const redemptionAbi = [
  "event RedemptionProcessed(address indexed holder, uint256 indexed periodId, uint256 amountTokens, uint256 navPerToken, uint256 grossValue, uint256 penaltyAmount, uint256 liquidityFeeAmount, uint256 discountAmount, uint256 netPayout, uint256 timestamp)"
];

export function createProvider() {
  return new ethers.JsonRpcProvider(RPC_URL);
}

export function getFundContracts(provider) {
  const contracts = {};

  if (FUND_ADDRESSES.I) {
    contracts.I = new ethers.Contract(FUND_ADDRESSES.I, redemptionAbi, provider);
  }
  if (FUND_ADDRESSES.II) {
    contracts.II = new ethers.Contract(FUND_ADDRESSES.II, redemptionAbi, provider);
  }
  if (FUND_ADDRESSES.III) {
    contracts.III = new ethers.Contract(FUND_ADDRESSES.III, redemptionAbi, provider);
  }
  if (FUND_ADDRESSES.IV) {
    contracts.IV = new ethers.Contract(FUND_ADDRESSES.IV, redemptionAbi, provider);
  }

  return contracts;
}
