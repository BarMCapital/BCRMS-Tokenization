# Business Upload Folder

This folder defines the **standardized upload structure** for businesses onboarding into BAR M Capital’s revenue-tokenization pipeline.

Every business must submit data following the **UPLOAD_SPEC.md** rules so the settlement engine can process NAV, revenue shares, redemptions, and insurance risk checks deterministically.

## Purpose

- Establish a **uniform folder + file layout** for business onboarding.
- Ensure every business provides deterministic, machine-readable data.
- Support NAV calculation, revenue share settlement, insurance hooks, and audits.
- Provide a future-proof structure aligned with BRRMS and the controlled vocabulary.

## Folder Structure (Required)

Each business must upload a folder with this layout:

businessId/  
  revenue.json  
  cogs.json  
  expenses.json  
  business_profile.json  
  (optional) insurance_exposure.json  

Do **not** change filenames.  
Do **not** add additional files unless specified in UPLOAD_SPEC.md.

## Relationship to Settlement Engine

The settlement engine reads this folder when:

- Processing NAV  
- Processing redemptions  
- Running insurance underwriting  
- Writing audit logs  
- Anchoring snapshots on-chain

The upload format is contractually binding for all businesses participating in BAR M Capital Fund structures.
