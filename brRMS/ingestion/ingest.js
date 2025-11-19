const fs = require("fs");
const path = require("path");

const { 
  validateRevenue, 
  validateCogs, 
  validateExpenses 
} = require("./validators");

const {
  normalizeRevenue,
  normalizeCogs,
  normalizeExpenses
} = require("./normalizers");

function ensureDir(directoryPath) {
  if (!fs.existsSync(directoryPath)) {
    fs.mkdirSync(directoryPath, { recursive: true });
  }
}

async function ingest(rawFilePath, businessId) {
  // Load raw JSON from source
  const raw = JSON.parse(fs.readFileSync(rawFilePath, "utf8"));

  // Validate against schemas
  if (!validateRevenue(raw.revenue)) {
    throw new Error("Revenue schema validation failed");
  }
  if (!validateCogs(raw.cogs)) {
    throw new Error("COGS schema validation failed");
  }
  if (!validateExpenses(raw.expenses)) {
    throw new Error("Expenses schema validation failed");
  }

  // Normalize into BRRMS canonical format
  const normalizedRevenue = normalizeRevenue(raw.revenue);
  const normalizedCogs = normalizeCogs(raw.cogs);
  const normalizedExpenses = normalizeExpenses(raw.expenses);

  const canonical = {
    revenue: normalizedRevenue,
    cogs: normalizedCogs,
    expenses: normalizedExpenses
  };

  // Output directory
  const outputDir = path.join(__dirname, "..", "data", businessId);
  ensureDir(outputDir);

  // Use revenue.month as filename
  const fileName = `${normalizedRevenue.month}.json`;
  const outPath = path.join(outputDir, fileName);

  fs.writeFileSync(outPath, JSON.stringify(canonical, null, 2));

  return {
    outPath,
    canonical
  };
}

module.exports = { ingest };
