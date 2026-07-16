# Table: sq_RECPAY (Receipt & Payment Allocations)

## Table Overview
`sq_RECPAY` tracks the "Knock-off" logic between Receipt/Payment vouchers and the original Bill vouchers. It tells you which payment settled which invoice.

## Column Grouping
- `CNO`: Company ID.
- `RECVNO` / `RECTYPE`: The voucher number and type of the Payment/Receipt.
- `BILLVNO` / `BILLTYPE`: The voucher number and type of the Invoice being settled.
- `AMT`: The allocated amount in this link.
- `ACTAMT`: The actual total payment amount.
- `SRNO`: Serial number for multiple bill settlements in one payment.
- `AUTOSRNO`: System-generated serial for sync.

## Column Relevance
- `RECVNO` + `BILLVNO`: This pairing is used to generate the "Outstanding Statement" for a party. If the sum of `AMT` for a `BILLVNO` is less than the `BILLAMT` in `sq_BILLS`, the bill is still outstanding.

## SQL Snippets (Postgres)
```sql
-- Find all payments linked to a specific sales invoice
SELECT "RECVNO", "AMT", "RECTYPE" 
FROM "IMMBE2627"."sq_RECPAY" 
WHERE "BILLVNO" = 1001 AND "BILLTYPE" = 'S1';
```
