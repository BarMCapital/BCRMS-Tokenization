const path = require("path");
const { ingest } = require("./ingest");

(async () => {
  const rawPath = process.argv[2];
  const businessId = process.argv[3];

  if (!rawPath || !businessId) {
    console.error("Usage: node runIngest.js <path/to/raw.json> <businessId>");
    process.exit(1);
  }

  try {
    const fullPath = path.resolve(rawPath);
    const result = await ingest(fullPath, businessId);

    console.log("BRRMS Canonical Output Written:");
    console.log(result.outPath);
  } catch (err) {
    console.error("Ingestion failed:");
    console.error(err.message);
  }
})();
