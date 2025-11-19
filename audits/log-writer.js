// audits/log-writer.js

/**
 * BAR M Capital Audit Log Writer
 *
 * This module creates structured audit log events that conform to:
 *   audits/schemas/audit-event.schema.json
 *
 * It is designed to be called by:
 *  - Integration adapters (Stripe, Square, QuickBooks)
 *  - BRRMS processes
 *  - Orchestration workflows
 *  - Smart contract indexers
 */

const crypto = require("crypto");
const fs = require("fs");
const path = require("path");

/**
 * Creates a new audit event object.
 *
 * @param {Object} params
 * @param {string} params.actor - System or module responsible for event.
 * @param {string} params.eventType - Type of event (INGESTION, HASH_GENERATION, etc.).
 * @param {Object} params.eventData - Additional structured metadata.
 * @returns {Object} Fully constructed audit event.
 */
function createAuditEvent({ actor, eventType, eventData }) {
  const eventId = crypto.randomUUID();
  const timestamp = new Date().toISOString();

  return {
    eventId,
    timestamp,
    actor,
    eventType,
    eventData,
    signature: null // Placeholder — future insurance/log notarization can sign this
  };
}

/**
 * Writes an audit event to the audit log directory.
 *
 * Each event goes into: audits/logs/YYYY-MM-DD.jsonl
 * (JSON Lines format — one event per line, ideal for streaming logs)
 *
 * @param {Object} event - Audit event object created by createAuditEvent().
 */
function writeAuditEvent(event) {
  const date = event.timestamp.slice(0, 10); // Extract YYYY-MM-DD
  const logDir = path.join(__dirname, "logs");

  if (!fs.existsSync(logDir)) {
    fs.mkdirSync(logDir);
  }

  const logFile = path.join(logDir, `${date}.jsonl`);
  const serialized = JSON.stringify(event);

  fs.appendFileSync(logFile, serialized + "\n");
}

// Export module API
module.exports = {
  createAuditEvent,
  writeAuditEvent
};
