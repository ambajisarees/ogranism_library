# Empire Operator & Form UX Intake Brief

> **Instructions**: Copy-paste this brief into chat (along with an Empire screenshot or physical slip photo) whenever we start building or refining a module's Add/Edit Form (`scr_<mns>_form.dart`). Takes < 2 minutes to fill out.

---

## 1. Module & Voucher Context
- **Target ERP Module (`mns`)**: `[e.g. pb / po / jw / so / mp / mr / itm / org]`
- **Empire Menu Path / Voucher Series (`TYPE`)**: `[e.g. O5 Stitching Dispatch / P26 Stitching Bill / S1 Finish Sales]`
- **Related SQL Tables (from the 93 tables)**: `[e.g. sq_BILLS, sq_BILLDET, sq_CHALTRN, or newly discovered table]`

---

## 2. The Empire User (Operator Persona)
- **Who enters this data?**: `[e.g. Godown Clerk / Senior Accountant / Cutting Master / Sales Desk]`
- **When & how often?**: `[e.g. 40 times/day in real-time as tempo arrives / Batch entry at 6 PM from paper slips]`
- **What physical document is in their hand?**: `[e.g. Handwritten Mill Slip / Tailor Challan Book / Broker WhatsApp message]`

---

## 3. The 80/20 Field Audit (Crucial for Clean UX)
*In Empire, there are dozens of text boxes on screen. Which ones matter?*

- **Fields they ACTUALLY type/select every time (The 20%)**:
  1. `[e.g. Party / Tailor Name]`
  2. `[e.g. Challan Date & Ref No]`
  3. `[e.g. Selecting Pending Lot / Card No]`
  4. `[e.g. Pcs / Meters / Rate]`
- **Fields they ALWAYS skip by hitting `Enter` (The 80% noise)**:
  - `[e.g. Transport, LR No, Excise, Sub-Broker, Due Days, Disc % — hide or move to collapsible 'Advanced' drawer]`
- **Fields that SHOULD auto-populate from our Masters/Recipes (`sb_recipes` / `sq_QUAL` / `sq_MASTER`)**:
  - `[e.g. Auto-fill Broker & Credit Days from sq_MASTER; Auto-fill Stitching Rate from sb_stitching_diamond_recipes]`

---

## 4. Empire Pain Points & Manual Workarounds
- **Where do they make mistakes or use a physical calculator today?**:
  - `[e.g. Checking if Tailor billed higher rate than agreed recipe; checking if returned pcs > dispatched pcs]`
- **What live summary metrics should sit in the bottom `DySummaryBar` (or right 340px pane)?**:
  - `[e.g. Total Dispatched Pcs | Pending Pcs at Tailor | Recipe Rate vs Bill Rate Variance ₹]`

---

## 5. Layout Shell Choice (`dynamic_ai/shells/`)
- [ ] **Pattern A: `DyShlAdd` (Split Selection + Form + Bottom Summary Bar)**
  - *Best when selecting pending rows from an upstream stage (like `ScrCcForm` selecting uncut `sq_MILLREC` rolls, or `P26` Bill selecting unbilled `O6` receipts).*
- [ ] **Pattern B: `DyPageCanvas(layoutMode: DyPageLayoutMode.form)` / `PageFormCanvas`**
  - *Best when creating a master or standalone document (like New Item, New Design, New Org, or New Grey Deal) with a 68% main form + 340px live preview/summary pane.*
- [ ] **Pattern C: Compact Modal Dialog (`scr_<mns>_form_dialog.dart`)**
  - *Best for quick 4–6 field entries or inline status/supplement updates.*

