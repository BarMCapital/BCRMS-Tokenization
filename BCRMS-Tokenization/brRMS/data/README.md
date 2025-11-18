# BRRMS Data Ingestion Folder

This folder holds BRRMS data snapshots that the settlement engine uses to calculate NAV for BAR M Capital funds.

NAV is defined as the trailing 3-month average of BRRMS netRevenue for each business. These JSON files are the source of truth for that calculation.

## Purpose

- Provide a deterministic, file-based input for NAV calculation (Option D).
- Mirror exports from systems (QuickBooks, Stripe, custom BRRMS, etc.).
- Allow easy inspection, diffing, and auditing of NAV inputs.

In production, these files may be auto-generated or synced from a BRRMS or accounting system. For now, they can be mock JSON files checked into Git.

## File Naming Convention

Each file represents a single business as of a given date.

Pattern:

{businessId}-{asOfDate}.json

Examples (write these literally):

golf-clinic-001-2025-01-31.json  
car-wash-abc-2025-03-31.json

businessId is a stable ID used across BRRMS.  
asOfDate is ISO: YYYY-MM-DD.

## Required Top-Level Fields

Each BRRMS file must contain:

businessId: string  
asOfDate: ISO date  
currency: ISO 4217 code  
netRevenueMonthly: array of objects

Example JSON:

{
  "businessId": "golf-clinic-001",
  "asOfDate": "2025-03-31",
  "currency": "USD",
  "netRevenueMonthly": ```[
    { "month": "2025-01", "amount": 12345.67 },
    { "month": "2025-02", "amount": 23456.78 },
    { "month": "2025-03", "amount": 34567.89 }
  ]
}```

NAV is computed from the last 3 months of netRevenueMonthly.

## Relationship to Schemas

This data aligns with deterministic schemas in brRMS/schemas (e.g., revenue.schema.json).  
Future versions may add COGS, expenses, or other monthly arrays.

For now, only netRevenueMonthly is required for NAV.

## Workflow

1. A BRRMS export or mock JSON file is placed here.
2. nav.js loads the file.
3. NAV is computed.
4. Settlement engine uses NAV for redemption and payout.
5. Audit module later verifies data integrity.

## Future Extensions

- Subfolders per business  
- Versioned snapshots  
- Hash/signature verification  
- Automated ingestion from QuickBooks, Stripe, or BRRMS APIs
