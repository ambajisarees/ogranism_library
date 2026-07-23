# Supabase Row Level Security (RLS) Guidelines for New App Tables

This document outlines the Row Level Security (RLS) policies and security standards for **new tables created directly by the Ambaji Sarees Flutter ERP**.

---

## 1. Airbyte Mirror Tables Contract (`sq_` & `vwsq_`)

> [!IMPORTANT]
> **Airbyte Managed Schema Rule**:
> - All `sq_` tables and `vwsq_` views are mirrored from MSSQL (AMAZE) by Airbyte.
> - **DO NOT MUTATE OR ALTER `sq_` TABLES OR VIEWS**.
> - Airbyte requires direct table access during sync routines. Adding triggers, foreign keys, or RLS policies to `sq_` tables can cause sync failures.

---

## 2. RLS Architecture for New Flutter ERP Tables

For any **new table** created in Supabase (e.g. `cutting_cards`, `production_batch_notes`, `user_preferences`, `new_bill_drafts`):

### A. Always Enable RLS
Every new table created in the `public` or `IMMBE2627` schema MUST have RLS enabled:
```sql
ALTER TABLE "IMMBE2627"."new_table_name" ENABLE ROW LEVEL SECURITY;
```

### B. Standard Policy Templates

#### 1. Tenant / Company Isolation (`CNO`)
Restricts reads and writes so users can only access data belonging to their company (`CNO`):
```sql
CREATE POLICY "Company Isolation Policy"
ON "IMMBE2627"."new_table_name"
FOR ALL
TO authenticated
USING (cno = (auth.jwt() ->> 'cno')::int)
WITH CHECK (cno = (auth.jwt() ->> 'cno')::int);
```

#### 2. User Audit & Ownership (`created_by`)
Allows staff to create records while automatically stamping their user ID:
```sql
CREATE POLICY "User Owns Created Record"
ON "IMMBE2627"."new_table_name"
FOR INSERT
TO authenticated
WITH CHECK (created_by = auth.uid());
```

#### 3. Role-Based Access Control (RBAC)
Grants full management rights (UPDATE/DELETE) to Admins and Production Managers, while restricting Data Entry Clerks to SELECT and INSERT:
```sql
CREATE POLICY "Admin Full Access"
ON "IMMBE2627"."new_table_name"
FOR ALL
TO authenticated
USING ((auth.jwt() ->> 'role') IN ('admin', 'production_manager'));
```
