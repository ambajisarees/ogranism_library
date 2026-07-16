# Analysis 3: Financial Integrity & Accounting
## Overview
This report analyzes the central accounting engine (`FAS`), party master stratification, and the settlement logic between bills and payments.

## 🔄 Business Derived Context

### 1. The Double-Entry Engine (`sq_FAS`)
The `sq_FAS` table is the "Final Proof" of all business transactions. 
- **Debit (`DRAMT`)**: Increases Assets or Expenses (e.g., Sales Invoice to a Debtor).
- **Credit (`CRAMT`)**: Increases Liabilities or Income (e.g., Cash Receipt from a Debtor).
- **The Balance Reality**: While `RUNBAL` exists, it is best practice to calculate `SUM(DRAMT - CRAMT)` per `code` for real-time reporting in the app to avoid synchronization drift errors.

### 2. Bill Knocking-off (`sq_RECPAY`)
Empire uses a "Bill-to-Bill" settlement system. 
- A single Payment Voucher (`sq_BILLS.TYPE = 'B1'`) can settle 10 different Sales Invoices.
- `sq_RECPAY` keeps the map. 
- **Business Rule**: A bill is "Outstanding" if `sq_BILLS.finalamt > (SELECT SUM(AMT) FROM sq_RECPAY WHERE BILLVNO = ... AND BILLTYPE = ...)`.

### 3. Party Stratification (`sq_ACGROUP` & `sq_ATYPE`)
Parties are not just "List of Names". They are logically siloed for specific ERP functions:
- **Group "EMB WORK"**: Parties here automatically appear in the Embroidery Job Work screens.
- **Group "TOP DYED"**: Parties here are preferred suppliers for processed fabric.
- **`ATYPE` 1 (Debtors)**: Targeted by Sales and Collection screens.
- **`ATYPE` 2 (Creditors)**: Targeted by Purchase and Payment screens.

---

## 🛠️ Optimized SQL Snippets

### A. Party Ledger (High Performance)
To feed a `DomainLedger` or `OrganPartyCard`:
```sql
SELECT 
    "DATE", 
    "TYPE", 
    "DOCNO" as Instrument, 
    "RMK" as Description,
    "DRAMT" as Debit, 
    "CRAMT" as Credit,
    SUM("DRAMT" - "CRAMT") OVER (ORDER BY "DATE", "SRNO") as RunningBalance
FROM "IMMBE2627"."sq_FAS"
WHERE "code" = :partyCode
ORDER BY "DATE" DESC, "SRNO" DESC
LIMIT 50;
```

### B. Aging Analysis (Days Outstanding)
```sql
SELECT 
    B."code",
    M."NAME",
    B."VNO",
    B."DATE" as BillDate,
    B."finalamt" as Total,
    CURRENT_DATE - B."DATE"::date as DaysOld
FROM "IMMBE2627"."sq_BILLS" B
JOIN "IMMBE2627"."sq_MASTER" M ON M."code" = B."code"
WHERE B."TYPE" = 'S1' 
AND NOT EXISTS (
    SELECT 1 FROM "IMMBE2627"."sq_RECPAY" RP 
    WHERE RP."BILLVNO" = B."VNO" AND RP."BILLTYPE" = B."TYPE"
)
ORDER BY DaysOld DESC;
```

---

## 📱 UI Component Mapping

### 1. `OrganKpiStrip` (Financial View)
*   **Total Receivables**: `SELECT SUM(DRAMT - CRAMT) FROM sq_FAS WHERE code IN (SELECT code FROM sq_MASTER WHERE ATYPE = 1)`.
*   **Bank Liquidity**: `SELECT SUM(RECONBALANCE) FROM sq_banks`.

### 2. `OrganPartyCard`
*   **Balance Badge**: Color-coded (`Debit` = Burgundy/Warning, `Credit` = Gold/Credit).
*   **Status**: If `CURRENT_DATE - LAST_PAY_DATE > 90` then set status to "Overdue".

---

## 💡 Key Insights
1.  **Opening Balance**: Every party has a matching entry in `sq_FAS` with `TYPE = '00'` and `RMK = 'OPENING BALANCE'`. This must be the starting point for any ledger calculation.
2.  **Document Reset**: Voucher numbers (`VNO`) are unique ONLY within a `(TYPE, CNO)` combination. For example, `B1` and `B2` can both have `VNO = 1`.
