---
description: High-level architecture, security principles (RLS), and implementation phases for the Textile ERP
---

# Textile ERP Architecture Plan

## 1. Executive Summary
Development of a robust, responsive ERP system for a textile business. The system manages Production, Sales, Dispatch, and Accounting, featuring strict data integrity, row-level security, and changing permission contexts.

## 2. Technology Stack
*   **Frontend**: Flutter (v3.x+)
*   **Backend**: Supabase (Postgres 17, Edge Functions, Auth, RLS)
*   **Legacy Sync**: Airbyte (MS SQL → Supabase)

## 3. Core Architecture Highlights

### A. Data Integrity & Security
To solve the "harsh edit/delete" and "read-only" issues:
1.  **PostgreSQL Row Level Security (RLS)**: Policies defined directly in the database.
    *   *Example*: Users can `SELECT` rows but only `UPDATE` rows where `status == 'DRAFT'`. Once `LOCKED`, the DB rejects updates.
2.  **Audit Logging**: Native triggers log every change (Who/What/When).

### B. CSV Data Sync Engine ("The Air-Lock")
1.  **Staging Area**: CSVs (like `qual.csv`) are uploaded to staging tables before production.
2.  **Reconciliation Logic**: 
    *   *New Records*: Inserted.
    *   *Updates*: Applied if the record isn't "Locked" by the ERP.
    *   *Conflicts*: Flagged for human review.

## 4. Database Schema Overview
*   **Auth**: `users`, `roles`, `permissions`.
*   **Masters**: `items` (yarn/fabric), `parties` (customers/vendors), `machines`.
*   **Production**: `production_orders`, `batches`, `processes` (Knitting, Dyeing).
*   **Sales**: `sales_orders`, `dispatch_notes`, `invoices`.
*   **Finance**: `ledger_entries` (Double entry system linked to Invoices/Bills).

## 5. Implementation Phases
1.  **Phase 1: Foundation**: Setup Supabase, RLS Policies, and Basic Auth.
2.  **Phase 2: Master Modules**: Item & Party Masters + Flutter UI.
3.  **Phase 3: The Sync Engine**: CSV parsing (qual.csv) and synchronization.
4.  **Phase 4: Sales & Dispatch**: Order management with status locking.
5.  **Phase 5: Production & Reporting**: Dashboards and Production planning.
