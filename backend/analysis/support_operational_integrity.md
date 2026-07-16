# Analysis 4: Support Systems & Operational Integrity
## Overview
This report analyzes the support registries (Logistics, Geography) and the audit/recovery systems of the ERP.

## 🔄 Business Derived Context

### 1. The Logistics Engine (`sq_CITIES` & `sq_TRANSPORTS`)
These tables drive the "Dispatch" part of the `OrganPartyCard` and individual invoice screens.
- **City Distance**: Critical for E-Way Bill auto-validation.
- **Transporter IDs**: `sq_TRANSPORTS.transid` is the key for automated E-Way bill submission.
- **Station Mapping**: Each party (`sq_MASTER`) has a `STATION` which must match a valid `CITY` in `sq_CITIES`.

### 2. Digital Compliance (`sq_BILLS_einv`)
For Sales Invoices, tax compliance requires E-Invoicing (IRN).
- **The QR Re-assembly**: The `qrcode` is split across 6 columns (`qrcode1` to `qrcode6`).
- **Logic**: Use `CONCAT(qrcode1, qcode2, ...)` in your Supabase view to provide a single `signed_qr_code` string for the Flutter app.

### 3. Audit & Trash (`sq_DELETEDITEMS`)
This is the safety net.
- **Traceability**: Unlike the main tables where `UPDATER` only shows the *last* person, this table keeps a historic log of who deleted what and when.
- **Business Utility**: Useful for building a "Recently Deleted" or "Trash" screen in the administrative module of the Flutter app.

---

## 🛠️ Optimized SQL Snippets

### A. Automatic Distance Retrieval (Logistics)
When creating a sample invoice, retrieve the suggested transport and distance:
```sql
SELECT 
    M."NAME" as Party,
    M."STATION",
    C."city_distance" as SuggestedDistance,
    M."TRANSPORT" as PreferredTransporter,
    T."transid" as GstTransporterId
FROM "IMMBE2627"."sq_MASTER" M
LEFT JOIN "IMMBE2627"."sq_CITIES" C ON C."CITY" = M."STATION"
LEFT JOIN "IMMBE2627"."sq_TRANSPORTS" T ON T."TRANSPORT" = M."TRANSPORT"
WHERE M."code" = :targetCode;
```

### B. E-Invoice QR Code Reassembly
```sql
SELECT 
    "VNO",
    "TYPE",
    COALESCE("qrcode1", '') || 
    COALESCE("qrcode2", '') || 
    COALESCE("qrcode3", '') || 
    COALESCE("qrcode4", '') || 
    COALESCE("qrcode5", '') || 
    COALESCE("qrcode6", '') as FullQrCodeText
FROM "IMMBE2627"."sq_BILLS_einv"
WHERE "irn" IS NOT NULL;
```

---

## 📱 UI Component Mapping

### 1. `OrganKpiStrip` (Operational View)
*   **Missing E-Invoices**: `SELECT COUNT(*) FROM sq_BILLS B WHERE TYPE = 'S1' AND NOT EXISTS (SELECT 1 FROM sq_BILLS_einv E WHERE E.VNO = B.VNO)`.

### 2. `OrganInventoryBadge`
*   **Packing Types**: Driven by `sq_PACKING` (e.g., "BOX", "PARCEL").

---

## 💡 Key Insights
1.  **Haste Hierarchy**: `sq_HASTE` groups agents by `PLACE`. Use this to build "Agent-wise Sales Reports" by joining `BILLS.haste` to `HASTE.HASTE`.
2.  **Sync Delta**: `sq_updates_billdet` is a transactional log. If your app needs "Real-time Notifications" for production updates, listen to changes on this table rather than the massive `sq_BILLDET`.
