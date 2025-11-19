# BRRMS Data (Mock for NAV)

This folder holds normalized monthly revenue files for NAV calculation.

File naming pattern:
- `fund_<FUND_KEY>_<PERIOD_ID>.json`

Example:
- `fund_I_202501.json` for Fund I, January 2025

JSON structure example:
{
  "periodId": "202501",
  "fundKey": "I",
  "netRevenue": 100000,
  "tokenizedShareBps": 2000,
  "totalTokenSupply": "100000000000000000000000" 
}
