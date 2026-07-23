# Purchase Bills Series & Data Architecture Breakdown

## 1. Overview & Data Flow
In the `IMMBE2627` schema:
- **`sq_BILLS`** serves as the universal header table for all 10 Purchase Bill categories.
- **Line Items** are stored in three different tables depending on the transaction series:
  1. **Grey Purchase (`P1`)**: Line items are stored in **`sq_PINVTRN`** (Takhta roll stock).
  2. **Job Work Mill Bills (`J1`)**: Line items are stored in **`sq_MILLREC`** (Mill receipt records).
  3. **All Other Purchase Bills (`P2`, `P4`, `P6`, `P11`, `P26`, `P27`, `P28`, `P29`, etc.)**: Line items are stored in **`sq_BILLDET`** (Standard bill details).
- **`sq_CHALTRN`**: Dives deeper into sub-line items per `CARDNO` and `RECCARDNO` for grey/mill takhta folding & cutting history. *Note: `sq_CHALTRN` is sub-item inventory history and is currently out of scope for high-level purchase bill entry.*

---

## 2. Complete Series Code Row Counts Table

Below is the verified row count across `IMMBE2627` for all transaction types present in the system, sorted vertically by `sq_BILLS` count:

| Series Code (`TYPE`) | Category / Module Name | `sq_BILLS` (Headers) | `sq_BILLDET` (Details) | `sq_PINVTRN` (Takhtas) | `sq_MILLREC` (Mill Receipts) | `sq_CHALTRN` (Sub-Items) |
| :--- | :--- | :---: | :---: | :---: | :---: | :---: |
| **S1** | Sales Invoice | 12,091 | 12,993 | 0 | 0 | 0 |
| **J1** | **Mill (Job Work Bills)** | **3,448** | **0** | **51** | **14,190** | **41** |
| **XX** | Internal Vouchers | 1,923 | 0 | 0 | 0 | 0 |
| **P1** | **Grey Purchase** | **1,455** | **0** | **6,301** | **0** | **56,108** |
| **P26** | **Stitching (Work Rec)** | **1,127** | **1,238** | **0** | **0** | **0** |
| **O6** | Work Rec Stitching | 753 | 1,112 | 0 | 0 | 0 |
| **O5** | Work Desp Stitching | 749 | 761 | 0 | 0 | 0 |
| **P2** | **Finish Purchase** | **627** | **340** | **0** | **0** | **0** |
| **P6** | **Modelling Photo Materials**| **577** | **73** | **0** | **0** | **0** |
| **P3** | Yarn Purchase / Sales Ret | 389 | 1,453 | 0 | 0 | 0 |
| **P4** | **Packing Material** | **389** | **282** | **0** | **0** | **0** |
| **O4** | Work In House Card | 350 | 357 | 0 | 0 | 0 |
| **P27** | **Diamond (Work Rec)** | **183** | **97** | **0** | **0** | **0** |
| **O13**| Finish Purchase Order | 177 | 177 | 0 | 0 | 0 |
| **S92**| Credit Note - Sales | 95 | 0 | 0 | 0 | 0 |
| **P76**| Debit Note - Purchase | 87 | 0 | 0 | 0 | 0 |
| **O10**| Work Rec Emb | 78 | 178 | 0 | 0 | 0 |
| **P28**| **Embroidery (Work Rec)** | **75** | **181** | **0** | **0** | **0** |
| **O7** | Work Desp Diamond | 70 | 115 | 0 | 0 | 0 |
| **O45**| Ready Product | 67 | 71 | 0 | 0 | 0 |
| **p11**| **Lace Purchase** | **50** | **20** | **0** | **0** | **0** |
| **O14**| Lace Purchase Order | 46 | 46 | 0 | 0 | 0 |
| **O9** | Work Desp Emb | 45 | 87 | 0 | 0 | 0 |
| **O8** | Work Rec Diamond | 39 | 92 | 0 | 0 | 0 |
| **P29**| **Charak (Work Rec)** | **N/A (in O12)**| **N/A** | **0** | **0** | **0** |

---

## 3. The 10 Primary Purchase Bill Categories

The 10 specific Purchase Bill categories supported in the ERP and their line item table bindings:

| Index | Category Name | Series Code (`TYPE`) | Header Table | Line Item Table |
| :---: | :--- | :---: | :--- | :--- |
| 1 | **Grey** | `P1` | `sq_BILLS` | `sq_PINVTRN` |
| 2 | **Mill** | `J1` | `sq_BILLS` | `sq_MILLREC` |
| 3 | **Lace** | `p11` | `sq_BILLS` | `sq_BILLDET` |
| 4 | **Finish** | `P2` | `sq_BILLS` | `sq_BILLDET` |
| 5 | **Modelling** | `P6` | `sq_BILLS` | `sq_BILLDET` |
| 6 | **Stitching** | `P26` | `sq_BILLS` | `sq_BILLDET` |
| 7 | **Diamond** | `P27` | `sq_BILLS` | `sq_BILLDET` |
| 8 | **Embroidery** | `P28` | `sq_BILLS` | `sq_BILLDET` |
| 9 | **Charak** | `P29` | `sq_BILLS` | `sq_BILLDET` |
| 10 | **Packing Material** | `P4` | `sq_BILLS` | `sq_BILLDET` |
