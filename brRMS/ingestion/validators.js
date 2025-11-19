const Ajv = require("ajv");
const path = require("path");
const fs = require("fs");

const ajv = new Ajv({ allErrors: true });

function loadSchema(schemaFile) {
  const schemaPath = path.join(__dirname, "..", "schemas", schemaFile);
  const raw = fs.readFileSync(schemaPath, "utf8");
  return JSON.parse(raw);
}

// Load schemas
const revenueSchema = loadSchema("revenue.schema.json");
const cogsSchema = loadSchema("cogs.schema.json");
const expenseSchema = loadSchema("expense.schema.json");

// Compile validators
const validateRevenue = ajv.compile(revenueSchema);
const validateCogs = ajv.compile(cogsSchema);
const validateExpenses = ajv.compile(expenseSchema);

module.exports = {
  validateRevenue,
  validateCogs,
  validateExpenses
};
