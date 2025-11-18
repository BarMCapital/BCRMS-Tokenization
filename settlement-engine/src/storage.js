import fs from "fs";
import { PAYOUT_LOG_FILE } from "./config.js";

export function appendPayoutRecord(record) {
  let current = [];
  if (fs.existsSync(PAYOUT_LOG_FILE)) {
    const raw = fs.readFileSync(PAYOUT_LOG_FILE, "utf8");
    if (raw.trim().length > 0) {
      current = JSON.parse(raw);
    }
  }

  current.push(record);
  fs.writeFileSync(PAYOUT_LOG_FILE, JSON.stringify(current, null, 2), "utf8");
}
