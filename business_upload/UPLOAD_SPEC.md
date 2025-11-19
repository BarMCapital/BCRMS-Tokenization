# UPLOAD_SPEC — Standardized Business Upload Specification

This document defines the required file formats, fields, and validation rules for any business onboarding into BAR M Capital’s revenue-tokenization pipeline.

Every business must comply with this specification exactly. Names, structures, and field types are deterministic and non-negotiable.

This ensures consistent NAV calculation, revenue-sharing, redemption logic, audit integrity, and insurance underwriting.

---

## 1. REQUIRED FILES

Each business must upload a single folder named after its `businessId` with the following files:

Required files:

1. `revenue.json`
2. `cogs.json`
3. `expenses.json`
4. `business_profile.json`

Optional file:

5. `insurance_exposure.json`

No other files may be included unless BAR M Capital updates this specification.

---

## 2. FILE SCHEMAS

Below are the required structures for each file. All examples use JSON.

---

### 2.1 revenue.json

Tracks monthly net revenue.

Example:

    {
      "businessId": "golf-clinic-001",
      "currency": "USD",
      "netRevenueMonthly": [
        { "month": "2025-01", "amount": 12345.67 },
        { "month": "2025-02", "amount": 15678.90 },
        { "month": "2025-03", "amount": 18345.22 }
      ]
    }

Required fields:

- `businessId` — string  
- `currency` — ISO 4217 code  
- `netRevenueMonthly` — array of objects with:
  - `month` — `YYYY-MM`
  - `amount` — numeric

This file feeds:

- NAV calculation (trailing 3-month average)
- Redemption contract logic
- Insurance risk assessment (revenue stability)

---

### 2.2 cogs.json

Cost of goods sold (COGS). Required for analytics and audit, optional for the initial NAV math.

Example:

    {
      "businessId": "golf-clinic-001",
      "currency": "USD",
      "cogsMonthly": [
        { "month": "2025-01", "amount": 3456.78 },
        { "month": "2025-02", "amount": 3890.11 },
        { "month": "2025-03", "amount": 4210.55 }
      ]
    }

Required fields mirror `revenue.json`:

- `businessId`
- `currency`
- `cogsMonthly` — array of `{ month, amount }`

---

### 2.3 expenses.json

Operating expenses (non-COGS).

Example:

    {
      "businessId": "golf-clinic-001",
      "currency": "USD",
      "operatingExpensesMonthly": [
        { "month": "2025-01", "amount": 6789.00 },
        { "month": "2025-02", "amount": 7020.50 },
        { "month": "2025-03", "amount": 7345.10 }
      ]
    }

Required fields:

- `businessId`
- `currency`
- `operatingExpensesMonthly` — array of `{ month, amount }`

---

### 2.4 business_profile.json

Core identity and metadata for underwriting, risk weighting, NAV mapping, and audit.

Example:

    {
      "businessId": "golf-clinic-001",
      "legalName": "Golf Performance Clinic LLC",
      "industry": "Sports Medicine",
      "location": "Texas, USA",
      "foundedYear": 2019,
      "ownership": ["Owner A", "Owner B"],
      "taxClassification": "LLC",
      "contactEmail": "info@gpc.com"
    }

Required fields:

- `businessId`
- `legalName`
- `industry`
- `location`
- `taxClassification`

Other fields are recommended but not strictly required.

---

### 2.5 insurance_exposure.json (optional)

Future integration: BAR M Capital insurance underwriting layer.

Example:

    {
      "businessId": "golf-clinic-001",
      "riskFactors": {
        "seasonality": "moderate",
        "revenueVolatility": 0.12,
        "industryRiskTier": 2
      },
      "coveragePreferences": {
        "smartContractFailure": true,
        "businessContinuity": true
      }
    }

If present, this file is used by the insurance module to score risk and configure coverage.

---

## 3. VALIDATION RULES

1. All `amount` values must be numeric.  
2. All `month` values must follow the `YYYY-MM` format.  
3. All files must include the same `businessId`.  
4. No extra top-level fields unless approved by BAR M Capital.  
5. No nested folders inside the business folder.  
6. Only JSON files are allowed (no CSV, XLSX, or PDF).

Failure to meet these rules results in rejecting the business onboarding package.

---

## 4. HOW THE SETTLEMENT ENGINE USES THIS DATA

- `revenue.json` → NAV & redemption math  
- `cogs.json` → margin analysis and audit support  
- `expenses.json` → business stability modeling  
- `business_profile.json` → eligibility, underwriting, and mapping into fund structures  
- `insurance_exposure.json` → BAR M insurance vertical risk scoring

This is the primary input into BAR M Capital’s BRRMS → Tokenization → Settlement pipeline.
