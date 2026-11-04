# Ambaji Sarees ERP — Complete Empire (`AMAZE 1.0`) System, UI & Architecture Encyclopedia

> **Purpose of This Permanent Reference Document**
> This encyclopedia is the **single source of truth** capturing every architectural, database, formula, workflow, hardware, keyboard-ergonomic, and UI finding from our 4-layer audit of legacy **Empire (`AMAZE 1.0` / `IMMACULATE`)**:
> 1. **MSSQL Server (`MAIN-PC\SQLEXPRESS`, `IMMBE2223`–`IMMBE2627`)**: `1.CSV` (1,785 columns), `2.CSV` (3-year row counts across 69 tables), `3.CSV` (2.87 MB `SERIES`, `formsettings`, `CONFIG`, `UDRS`, triggers, and 26 `dbo.sq_*` Airbyte views).
> 2. **Compiled MS Access 2010 Engine (`IMMGSTSQL_2010.mde` & `EMPIRE_2010.mde`)**: Vaulted offline in `docs/empire_intake/offline_vault/` + **3,863 embedded SQL queries & formulas** (`mde_extracted_sql.txt`).
> 3. **LAN File & Hardware Ecosystem (`Z:\` $\rightarrow$ `\\Main-pc\d`)**: QR code generator (`qrgen.exe`), BarTender + TSC thermal stickers (`.btw`), CZUR Shine evening Bilty/Challan scanner, NIC JSON/Excel GST bridges, and webcam captures.
> 4. **Visual UI & Operator Walkthrough (`docs/empire_intake/screens/`)**: Step-by-step screenshots of menus, forms, sub-tabs, popups, broken legacy screens, and status-bar hotkeys (cataloged in [`screens/INDEX.md`](file:///c:/Users/smitt/.gemini/antigravity/scratch/textile_erp/docs/empire_intake/screens/INDEX.md)).
>
> **Consult this file before designing or coding ANY new module (`mdl_*`, `srv_*`, `scr_*`, `sb_*` schema, or Edge Function) in Ambaji Sarees ERP.**

---

## 1. Executive Architecture: Why Replacing Empire Is 3× Simpler Than It Looked

At first glance, Empire looked like a sprawling 93-table ERP with 100+ menu items. Our 4-layer audit proved:
1. **Only 7 Polymorphic UI Form Engines Power 98% of Daily Entry**:
   - **`CHALLAN`**: Powers **30+ voucher `TYPE`s** (`S1` Finish Sales, `O1` Sales Orders, `O13`–`O16` POs, `P2`/`p11`/`P4`/`P6` Purchases, `P3` Sales Returns, `O4` Mother Jobcard, `O5`–`O12` Stitching/Diamond/Emb/Charak Despatch & Receipt, `P26`–`P29` Jobwork Vendor Bills, `O45` Ready Product, and RCM Self-Invoices) by dynamically hiding/relabelling fields via `dbo.formsettings` (`1,055` rows).
   - **`PURBILL` (`P1`) + `TAKA DETAILS` (`CHALTRN`)**: Single-screen Grey Weaver Purchase + inline Weaver-to-Mill Despatch splitter (`PINVTRN`).
   - **`PINVTRN` + `LOT NO. ENTRY TABLE`**: Standalone Mill Despatch + high-speed yellow-cell Mill Lot No. datasheet (`375+` pending rows per mill).
   - **`JOBBILL` (`J1`) + Shrinkage Popup**: Mill Receipt & Jobwork Billing (`MILLREC`) with per-taka `SHORT %` and `F4` roll-length auto-pairing.
   - **`CUTDET3` / Single Cutting Card (`O3`)**: Already **99.7% migrated** to our Flutter `sb_cutdet` (`6,735` rows in FY25-26 $\rightarrow$ `23` rows in FY26-27!).
   - **`SALEREC` / `PURTALLY` (`B1/B2/C1/C2/V1`)**: Bill-wise Bank/Cash Receipts & Payments with 23 Surat textile deduction columns (`RECPAY`).
   - **`BILLSDIR` & `BILLGREY`**: Line-less summary GST bills/CN/DN (`P76`, `P91`/`P92`, `S91`/`S92`) and Grey Weaver Returns (`S2`).
   - **Batch Evening Tables**: `LR NO. ENTRY TABLE`, `PARCEL GATEPASS ENTRY`, and `Bulk E-Invoice / E-Waybill JSON + QR` tables.
2. **Massive Scope Elimination (Dead & Broken Screens Confirmed)**:
   - **21 SQL tables have `0` rows** across 3 years (`BILLS_lr`, `BILLS_lr_inw`, `LRDET`, `GREYRET`, `RG1_REG`, `TAXFORMS`, `pack_cons`, `SAREEDESORD`, etc.).
   - **Multiple menu items are literally broken (`#Name?`) or unused (`0` rows)** in Empire today:
     - `CARTON PACK. MAT. CONS.` $\rightarrow$ **Broken (`#Name?` error)**
     - `PURCHASE Reconciliation with 2A` $\rightarrow$ **Broken (`#Name?` error)**
     - `TDS ADJUSTMENT AGAINST CHALLAN` $\rightarrow$ **Broken (`#Name?` & `#Error` across all columns/totals)**
     - `BOX PURCHASES` $\rightarrow$ **Fails to open** (`P4` under `PURCHASE / PACKING ETC.` is used instead)
     - `EXPENSES -> DIRECT ENTRIES` $\rightarrow$ **Legacy Petty-Cash Randomizer / Auto-Spreader** (do not port)
     - `GREY PURCHASE ORDERS` (`dbo.PURORD`), `MULTI MILL DESP. (EQUAL MTS)`, `STOCK TRANSFER / GODOWN TRANSFER / GODOWN INWARD`, `DESIGN WISE OPENING STOCK`, `DESIGN WISE WITH PHOTOS`, `BOX OPENING STOCK`, `TDS FORM 16A` (`dbo.TAXFORMS`) $\rightarrow$ **All `0` rows in FY26-27!**

---

## 2. Database, Fiscal Rollover & Airbyte Mirror Rules

### 2.1 Multi-Year Database Spawning & Airbyte View Gotcha
- Empire runs on `MAIN-PC\SQLEXPRESS,1092` (SQL Server 2012). Every April 1st (`UTILITIES -> CREATE NEW YEAR`), it spawns a new database (`IMMBE2223` $\rightarrow$ `IMMBE2324` $\rightarrow$ `IMMBE2425` $\rightarrow$ `IMMBE2526` $\rightarrow$ **`IMMBE2627`**).
- **CRITICAL AIRBYTE GOTCHA**: Airbyte does **not** stream raw `dbo.*` tables! It streams **26 custom SQL Views (`dbo.sq_*`)** created inside `IMMBE2627` that strip Access UI columns (`SELECTED` bit flags, `einv_pwd`, `QUAL_PATH`, `SCAN_PATH`). If Empire spawns `IMMBE2728` on April 1, 2027 while still active, those 26 `dbo.sq_*` views must be recreated in `IMMBE2728` — unless Ambaji Sarees retires Empire before March 31, 2027!
- **April 1 Rollover ID Offsets (`.mde` `[0011]`, `[0020]`, `[0023]`, `[0062]`)**:
  - Carried-over pending vouchers get `+100000` added to `VNO`, `CARDNO`, and `DESPNO`, and `'*'` appended to `BILL`, `LOT`, and `WCHAL` (e.g., `LOT NO. 47126*`).
  - `BILLDET.SRNO` shifts by `-200000`; `CHALTRN.SRNO` shifts by `-1000000`.
  - Prior year Finish Stock (`STOCKUNION`) collapses into **1 lump-sum row** in `dbo.QOPSTOCK` (`01/04/26`, `SAREE`, `19,49,285.00 MTS`).
  - Always filter current-year operational lists with `VNO > 0 AND VNO < 100000` (while including carried-over `ABS(VNO) > 100000` in **Pendency & Outstanding** queries!).

### 2.2 Composite Keys & Name-Based Foreign Keys
- **Universal Voucher Join**: `BILLS.CNO = DETAIL.CNO AND BILLS.TYPE = DETAIL.TYPE AND BILLS.VNO = DETAIL.VNO` (omitting `TYPE` causes massive cross-series fan-out!).
- **4th Voucher Sub-Detail Table (`dbo.SAREEDES` — `32,313` rows in FY26-27)**:
  - **NOT a static Master!** Primary key is `(cno, TYPE, vno, srno, DESIGNNO)`.
  - Stores design-wise piece breakdowns underneath `BILLDET` rows for **`S1` Finish Sales (`32,248` rows)**, **`O45` Ready Product (`66` rows)**, and **`O1` Sales Orders (`62` rows)**.
- **4 Server-Side MSSQL Triggers**:
  - `PINVTRN`: `DUPLLOT` (blocks duplicate `CNO + TYPE + MILL + LOT`) and `DUPLCHAL` (blocks duplicate `CNO + TYPE + DESPNO + DESPNO_CHR`).
  - `MASTER`: `T_MASTER_UTrig` & `T_MASTER_UTrig2` cascade `MASTER.CODE` (Account Name string) edits into `FAS` (`CONFIG.NAMEbasedsystem = 1`). *In our new `sb_` schema, use immutable UUID/integer IDs while preserving clean display names!*

### 2.3 Complete Corrected Voucher `TYPE` Map (`dbo.SERIES`)
| Domain | `TYPE` Code | Actual Business Meaning in `IMMBE2627` | FY26-27 Vol (Nov 4) | Primary UI Engine |
| :--- | :---: | :--- | ---: | :--- |
| **Grey & Mill** | `P1` | Grey Fabric Purchase + Inline Mill Despatch | `2,127` bills / `85k` takas | `PURBILL` + `CHALTRN` |
| **Grey Return** | `S2` | Grey Purchase Return to Weaver (`BILLGREY`) | Active | `BILLGREY` |
| **Mill Receipt** | `J1` | Mill Dyeing/Printing Receipt & Jobwork Bill (2% 194C TDS) | `4,286` bills / `22.2k` cards | `JOBBILL` (`MILLREC`) |
| **Cutting** | `O3` | Multi-Cutting Card (`99.7%` migrated to Flutter `sb_cutdet`!) | `23` legacy (`6,735` in 25-26) | Flutter `ScrCcForm` |
| **Purchase Orders** | `O13` / `O14` / `O15` / `O16` | Finish PO (`401`) / Lace PO (`61`) / Packing PO (`1`) / Modelling PO | `463` orders (in `BILLS`!) | `CHALLAN` |
| **Direct Purchases** | `P2` / `p11` / `P4` / `P6` | Finish Saree (`877`) / Lace (`72`) / Box & Packing (`633`) / Modelling (`610`) | `2,192` bills | `CHALLAN` |
| **Mother Jobcard** | `O4` | **Work In-House Card** (Root `TRACK_TYPE='O4'` anchor) | `696` batch cards | `CHALLAN` (JW Mode) |
| **Stitching** | `O5` $\rightarrow$ `O6` $\rightarrow$ `P26` | Desp (`1,200`) $\rightarrow$ Rec (`1,336`) $\rightarrow$ Vendor Bill (`1,567`, 1% TDS) | `4,103` docs | `CHALLAN` (JW Mode) |
| **Diamond Work** | `O7` $\rightarrow$ `O8` $\rightarrow$ `P27` | Desp (`107`, `WD`) $\rightarrow$ Rec (`76`) $\rightarrow$ Vendor Bill (`220`, 1% TDS) | `403` docs | `CHALLAN` (JW Mode) |
| **Embroidery** | `O9` $\rightarrow$ `O10` $\rightarrow$ `P28` | Desp (`46`, `WL`) $\rightarrow$ Rec (`78`) $\rightarrow$ Vendor Bill (`75`, 1% TDS) | `199` docs | `CHALLAN` (JW Mode) |
| **Charak** | `O11` $\rightarrow$ `O12` $\rightarrow$ `P29` | Desp (`WC`) $\rightarrow$ Rec $\rightarrow$ Vendor Bill (`9` active bills, 1% TDS) | `9+` docs | `CHALLAN` (JW Mode) |
| **Ready Stock** | `O45` | **Ready Product** (`STAGE_FINAL=true`, closes `O4`, Finish Stock `+1`) | `67` vouchers | `CHALLAN` (JW Mode) |
| **Sales & Orders** | `O1` $\rightarrow$ `S1` | Sales Orders (`27`) $\rightarrow$ **Finish Sales Invoices** (`19,509`) | `19,536` docs | `CHALLAN` + `Sareedes` |
| **Sales Returns** | `P3` / `P25` | **Sales Goods Return** (`595` + `15` — *NOT Yarn!*) | `610` credit memos | `CHALLAN` |
| **Broker Comm.** | `P76` | **Broker/Agent Sales & Purchase Commission Bills** (`18% GST`, `5% 194H`) | `148` bills | `BILLSDIR` / Auto-Gen |
| **GST CN / DN** | `P91`/`P92` · `S91`/`S92` | Credit Notes (Sales/Pur) · Debit Notes (Sales/Pur) | Active | `BILLSDIR` |
| **194Q / TCS / RCM**| `P66`/`S66` · `P77`/`S77` | Auto 194Q TDS Notes · Auto TCS Notes · GTA Freight Self-Invoice RCM | Active | Auto-Gen / `CHALLAN` |
| **Finance / Ledger**| `B1`/`B2` · `C1`/`C2` · `J2`/`T1`/`V1` | Bank Rec/Pay · Cash Rec/Pay · Journal · TDS JV (`2,943`) · Vatav (`V1`) | `48,321` `FAS` rows | `SALEREC` / `GEN.` |
| **Synthetic Adv.** | `XX` | **Auto-generated Unadjusted Advance/JV rows** (`FAS` minus `RECPAY`) | `1,923` rows | Engine-generated! |

---

## 3. Core Business Formulas & Hidden Engine Rules (Decoded from `.mde` + Verified on UI)

### 3.1 Three-Tier Saree Costing Formula (`.mde` `[0014]` + Verified on Cut Card `#23`)
- **Inputs**: Grey Mts (`WMTS`), Grey Rate (`RATE`), Grey Disc (`GREY_DISC`), Fin Mts (`RMTS - FOLD_DIFF_MTS`), Mill Rate (`JOBRATE`), Mill Disc (`MILL_DISC`), Salvage (`OUTCUT * OUTCUT1_RATE + SECONDS * SECONDS_RATE + FENT_WT * FENT_RATE`), Cut Pcs (`CPCS`), Seconds (`SECONDS`), Fresh Pcs (`CPCS - SECONDS`).
- **Mill Working-Capital Interest (`INT. P.P.`)**: Charges **24% p.a. (`2% per month` = `/ 1500`)** on grey value for `DAYS_IN_MILL = DateDiff("d", Nz(WCHDAT, DDATE), CUTDATE)`:
  $$\text{Interest Total} = \frac{\text{WMTS} \times \text{RATE} \times \text{DAYS\_IN\_MILL}}{1500}$$
- **Three Displayed Costs on Cutting Card (`06_inv_04_single_cutting_card_entry_costing_view.png`)**:
  1. **`BASIC COST`** (No discounts + includes 24% p.a. mill holding interest, e.g., `₹153.90` with `INT. P.P. = ₹2.72`)
  2. **`COST W/DIS`** (Net of `GREY_DISC %` & `MILL_DISC %`, without holding interest, e.g., `₹149.19`)
  3. **`COST W/O INT.`** (Without mill holding interest)
  - *All three divide strictly by **Fresh Pieces (`CPCS - SECONDS`)** and add per-piece `ADD_OTH1 + ADD_OTH2`!*
- **Net Realized Selling Price**: `Sell1 * (1 - dhara / 100) - packadd`.

### 3.2 Order & Batch Pendency Rules (`.mde` `[0015]`, `[0016]`)
- **The `90%` & `<40 Pcs` Auto-Completion Tolerance (`ACTCOMPLETED`)**:
  - For `UNIT = 'PCS'`: Order/line auto-completes (`Pendency = 0`) even when `CLOSED != 'Y'` if **`(SUMPCS / PCS > 0.90 AND PCS - SUMPCS < 40)`** OR `(PCS - SUMPCS < 2 AND PCS > 1)`.
  - For `UNIT = 'MTS'`: Auto-completes if **`SUMMTS / MTS > 0.90`** (unless `ORDER_EXACT_QTY = TRUE`).
- **3-Pointer Value-Addition Batch Tracking (`BILLDET`)**:
  1. `JOB CARD` = **`TRACK_CNO / TRACK_TYPE ('O4') / TRACK_VNO / TRACK_SRNO`** (Always points back to Mother `O4` batch!).
  2. `REF VNO` = **`STAGE_CNO / STAGE_TYPE / STAGE_VNO / STAGE_SRNO`** (Points to immediate prior hop: `O4` $\rightarrow$ `O5` $\rightarrow$ `O6` $\rightarrow$ `O9` $\rightarrow$ `O10` $\rightarrow$ `O7` $\rightarrow$ `O8` $\rightarrow$ `O45`).
  3. `ORD*` = **`ORDCNO / ORDTYPE / ORDBILL / ORDSRNO`** (Links commercial bills `P26`/`P27`/`P28`/`P29` via `Ctrl+F8` to `O6`/`O8`/`O10`/`O12`, and `P2`/`p11`/`S1` to `O13`/`O14`/`O1`).
  - **Root `O4` Closure**: Intermediate hops do *not* close `O4`; only rows with **`STAGE_FINAL <> 0` (`O45` Ready Product)** decrement root `O4` pendency!
  - **Quality Rebranding (`SCREEN (SALE)` = `BILLDET.ALTQUAL`)**: When plain/finished fabric (e.g., `STAR GEORGETTE (FINISH)`) comes back from value addition (`O6`/`O8`/`O10`/`O45`), operators stamp the commercial catalog name (e.g., `BUTTERSCOTCH`) in **`SCREEN (SALE)` (`ALTQUAL`)**, shifting Finish Stock into `BUTTERSCOTCH`!

### 3.3 Tax, RCM, TDS & Settlement Rules
- **CGST/SGST vs. IGST Storage in `BILLS`**:
  - Local (`State = 24` Gujarat): `VATRATE = 2.5` (`VATAMT` = CGST) + `ADD_VATRATE = 2.5` (`ADD_VATAMT` = SGST).
  - Inter-State (`State != 24`): `VATRATE = 5.0` (`VATAMT` = full IGST) + `ADD_VATRATE = 0, ADD_VATAMT = 0`.
- **Unit `PC` vs. `CUT` Line Math**: When `UNIT = 'PC'`, `MTS/QTY. = PCS * CUT` (for fabric/lace consumption tracking), while **`AMOUNT = PCS * RATE`**. Typing `'5*4'` in `BILLDET.DETAILS` auto-calculates `20` pcs (`5 pcs/set × 4 sets`).
- **RCM Self-Invoice Double-Entry Rule**: GTA Freight RCM (`SHREE YOGI EXPRESS`, 5%) posts equal & opposite entries to **`IGST RCM (Receivable) A/C` (Dr)** and **`IGST RCM (Payable) A/C` (Cr)** (same 2-ledger structure for CGST/SGST RCM).
- **TDS Rates in Active Use**:
  - `J1` Dyeing/Printing Mill Corporate Jobwork: **`2.0%` (194C)** (`HSN 998821`).
  - `P26`–`P29` Stitching/Diamond/Embroidery/Charak Individual Jobwork: **`1.0%` (194C)**.
  - `P76` Broker Commission Bills: **`5.0%` (194H)** (+ `18%` GST).
  - Purchase of Goods `> ₹50,00,000` (`194Q`): **`0.1%`** (or **`5.0%`** if `MASTER.PNRNO` PAN is blank), `CEILING` rounded.
- **23-Column Surat Textile Receipt/Payment Deductions (`SALEREC` / `RECPAY`)**:
  Supports `DAYS` (bill age), `DIS.% / DISC. AMT`, `RD @ / RATE DIFF`, `COMM LS % / AMT`, `PACK / FOLD`, `INT % / INT`, `JOB LESS`, `GOODS RET (G.R.)`, **`DEKA LESS`**, **`SWEETS`** (Diwali Boni!), `OTH/BC` (Bank Charges), `DISPUTE AMT / REMARK / (Y/N)`, and `3B MONTH`.

---

## 4. Daily Operator Workflows & UX Blueprints for Ambaji Sarees ERP

### 4.1 Morning-to-Evening Sales & Logistics Workflow (Critical Architecture Pattern!)
Operators do **NOT** do everything inside a single `S1` form save! Sales runs in **4 decoupled high-speed waves**:
1. **Wave 1 — Daytime Fast Billing (`S1` `CHALLAN` + `SAREEDES`)**:
   - Operator bills rapidly (`CASE NO.` defaults to `BILL NO.`, `BUNDLES` records rack `V01`/`V07`, `COUNTED BY` picks counter staff from `RMKLIST`, `LR No.` is left **blank**).
2. **Wave 2 — Tempo / Handcart Loading (`PARCEL GATEPASS ENTRY`)**:
   - Assigns `GATE PASS NO.` and **`MUKADAM NAME`** across parcels leaving the godown (`OFFICE DELIVERY` vs Transport).
3. **Wave 3 — Evening Batch E-Invoice, E-Waybill & QR Print (`20–40 bills at once`)**:
   - Accounts/dispatch opens `e-Invoice Bulk Generation` & `E-Way Bill Bulk Generation` $\rightarrow$ ticks all day's inter-state/B2B invoices $\rightarrow$ generates IRN + EWB + QR codes (`QRCODE1..5`) $\rightarrow$ batch-prints invoices + thermal stickers!
4. **Wave 4 — Next-Day / Evening Bilty Entry (`LR NO. ENTRY TABLE` + CZUR Scanner)**:
   - When transport bilties arrive (`311` pending queue), staff punch `LR NO.` top-to-bottom using **`COPY LAST LR NO. TO BILL`** for multi-bale shipments to the same buyer, print **`COVERING LETTER`**, trigger **WhatsApp/Email to Party & Broker**, and scan physical bilties on the **CZUR Shine** overhead scanner!
- **Architectural Mandate for Flutter Sales Module (`so` / `si`)**:
  Build a **4-Tab "Sales & Dispatch Command Center"** (`1. Invoices` | `2. Gatepass & Mukadam` | `3. Fast LR / Bilty Punch + CZUR Scan Drop` | `4. 1-Click Bulk E-Invoice & EWB Queue`) so Ambaji retires all 5 separate Empire screens in one cohesive workspace!

### 4.2 Grey Weaver-to-Mill Pipeline (`pb` / `mp` / `mr`)
1. **Inline Weaver-to-Mill Split (`P1`)**: Allow splitting a Grey Purchase Bill (`71` takas = `8,149.25m`) directly into multiple Mill Despatch Challans (`6466`–`6471`) with **Auto Equal-Meter Card Generation (`Alt+R`)**, **Gram-Weight Variation Check (`Ctrl+V`)**, and **Blind Challan Print (`W/O Weaver Name`)**.
2. **Pending Lot No. Speed Mode (`mp`)**: Dedicated inline-editable `LOT NO` + `MILL RMK` column mode filtered by Mill (`AAISWARYA`, `SHAILJA`) + Bulk Jobwork Challan E-Waybill queue.
3. **Mill Receipt Shrinkage Pairing (`mr` — `J1`)**: Per-taka `SHORT %` badge + 1-click **"Auto-Pair Finish Rolls by Grey Length (`F4`)"** button.

### 4.3 Operator Muscle-Memory Keyboard Reference (Preserve Where Compatible with `GEMINI.md`!)
| Context | Empire Shortcut | Action in Empire | Ambaji Flutter ERP Mapping Strategy |
| :--- | :--- | :--- | :--- |
| **Global** | `F10` / `F4` | Quick Reports / Trial Balance | Map `Ctrl+K` Command Palette + quick jump pills |
| **Toolbar** | `BAL.` / `LEDGER` | Instant Party Balance / Open Party Ledger | Show live **Party Balance & Credit Days badge** inline on Party selection (like `SALEREC`!) + 1-click Ledger drawer |
| **Reports / Grids** | `/` · `*` · `Enter` · `-` | Summarise · Details · Zoom In · Zoom Out | Support `Enter` drill-down & `Esc`/`Backspace` back + Summary/Detail density toggle |
| **Forms** | `Alt+N` · `Alt+E` / `F8` · `Ctrl+S` (`F3` in Empire) | Add New · Edit Mode · Save | Support `Ctrl+S` Save, `Alt+N` New, `F8`/`Alt+E` Edit, `NumPad Enter` field traversal *(never hijack `F5`/`Ctrl+R`/`Ctrl+T`/`Ctrl+W` per `GEMINI.md`)* |
| **Party Combobox** | Typing in `PARTY` | 4-column dropdown: `Name \| Broker (Group) \| City \| Type` | Replicate exact 4-column rich search popover in `shadcn_flutter` (`Party Name + Broker + City + GST State + Cur. Bal.`)! |
| **Jobwork (`O6`)** | `Ctrl+F8` | Jump from Work Receipt Challan (`O6`) $\rightarrow$ Vendor Bill (`P26`) | Add 1-click **"Generate / Open Vendor Bill (`Ctrl+F8`)"** action on `O6`/`O8`/`O10`/`O12`! |



---

## 5. Financial Accounting, Multi-Entity Group & `GEN. ENTRIES` Architecture (Batch 8 Audit)

### 5.1 Multi-Entity Family & Partnership Structure (`dbo.COMPMST` + `CAPITAL A/C/PROFIT SHARE`)
- **Why `CNO` Exists Everywhere**: A single `IMMBE2627` database houses **16 distinct accounting books (`COMPMST`)** across the flagship partnership firm, sister firm (`SAI SILK`), archived/parallel firm books (`*`, `.`, `..` suffixes), and personal/HUF tax files of the Mittal family (`KRISHNADEVI MITTAL`, `MAHEK MITTAL`, `NITI MITTAL`, `RASHMI MITTAL`, `SHUBHAM MITTAL`, `SUMAN SUSHILKUMAR MITTAL`, `SUNILKUMAR MITTAL` + HUF, `SUSHILKUMAR SADHURAM MITTAL` + HUF).
- **Flagship Firm (`AMBAJI SAREES` — `CNO = 4`) Partnership Profit-Sharing Ratios (`100.00%`)**:
  - `SUSHIL KUMAR MITTAL*`: **`20.00%`** · `SUSHIL KUMAR MITTAL(H.U.F)*`: **`10.00%`**
  - `SUNIL KUMAR MITTAL*`: **`15.00%`** · `SUNIL KUMAR MITTAL(HUF)*`: **`10.00%`**
  - `SHUBHAM MITTAL*`: **`15.00%`**
  - `SMT. KRISHNADEVI MITTAL*`: **`10.00%`** · `RASHMI MITTAL**`: **`10.00%`** · `SUMAN MITTAL`: **`10.00%`**
  - *(Sister concern `SAI SILK` is `100.00%` `MAHEK MITTAL`.)*
- **Bank Accounts (`dbo.banks`) & Physical Premises (from Fixed Assets Ledger)**:
  - Primary Operating Bank (`AMBAJI SAREES`): **`HDFC BANK`** (`A/C No. 50200031166612`, CC/OD Recon Balance `₹4,47,87,241.42 Cr`).
  - Secondary / Sister Firm Banks: **`INDIAN BANK`** (`955761877` for `SAI SILK`, `955767959` for `AMBAJI SAREES*`) + personal HDFC accounts.
  - Shop & Market Premises on Fixed Assets: **`305 RAGHUVIR PLANTIUM`** and **`5003 & 5019 ASHIRWAD TEXTILES MARKET`**.

### 5.2 Three-Tier Receipt, Payment & Journal Workflow
1. **Mode A — Header-Only On-Account Entry (`GENERAL REC. / PAY.`)**:
   - Captures rapid unallocated NEFT/RTGS/Cheque entries (`REC. SLIP NO.` e.g. `0411CA`, `CLEAR/TRANSFER: C`) and exposes a 1-click **`ADJUST BILLS`** button to allocate against invoices later (while unallocated portion sits in `XX` synthetic rows!).
   - *Security Note*: Non-authorized users see `INSERTION BLOCKED THRU SECURITY SETTINGS FOR BANK RECEIPT` in the status bar — replicate granular Voucher-Type RBAC (`CanInsert / CanEdit / CanDelete` per `SERIES`) in Supabase RLS / app permissions!
2. **Mode B — Multi-Invoice Settlement (`BILL-WISE REC. / PAY.` — `SALEREC` / `RECPAY`)**:
   - Single NEFT receipt (e.g. `B1 #3693` `₹68,198.00` from `SANKET`) settles **multiple `S1` invoices (`11358` & `11364`)** simultaneously, auto-calculates exact **`DAYS`** (`23` days from bill date to receipt date), applies per-bill Surat deductions (`PACK = ₹72.00`, `DISC %`, `RATE DIFF`, `GOODS RET`, `SWEETS`), and computes **`Taxable Value(Paid Bills)`** (`₹64,950.50`) at the footer for 194Q/TCS compliance.
3. **Mode C — Rapid Datasheet & Automated TDS Journals (`MULTIPLE ENTRIES` & `JOURNAL WITH T.D.S.`)**:
   - **`MULTIPLE ENTRIES` / `MULTI JOURNAL`**: Pins one `MAIN A/C` (`HDFC BANK`, `CASH`, or a Control Ledger) at the top and lets the accountant punch dozens of contra lines continuously in a grid (`F3 - NEW ENTRY`) with a 2-column **`Ledger Name | Account Group`** combobox.
   - **`JOURNAL WITH T.D.S.`**: 1-screen wizard (`CREDIT A/C`, `DEBIT A/C`, `TDS A/C`, `AMOUNT`, `TDS %`, `TDS AMT.`) whose **`PASS J.V.s`** button automatically posts balanced gross + TDS split entries (`T1` / `J2`).

### 5.3 Periodic Closing Stock Valuation Architecture (`dbo.CLOSSTOCK` — Critical Final Accounts Rule!)
- Empire's Trading Account & Balance Sheet **do NOT compute closing stock value dynamically from `BILLDET` / `MILLREC`**. Instead, they read `dbo.CLOSSTOCK`, where management maintains **two separate periodic valuation rows** for `AMBAJI SAREES`:
  1. **`CLOSING STOCK A/C`** (In-House Godown & Shop Stock): **`₹6,22,93,900.00`** (`₹6.23 Cr`)
  2. **`CLOSING STOCK AT MILL A/C`** (WIP Grey/Dying Stock lying across Process Houses): **`₹3,36,06,689.16`** (`₹3.36 Cr`)
  *(Combined inventory book value $\approx$ **`₹9.59 Cr`**!)*
- **Ambaji ERP Design Decision**: Provide **live real-time stock valuation** (powered by Cutting Card `COST W/DIS` for Finish Stock + `PINVTRN` Grey Rate for Mill WIP) **side-by-side** with a `CLOSSTOCK`-compatible **Statutory Closing Stock Lock / Override** per period so the CA's audited Trading & P&L figures always match to the paisa!


---

## 6. Master Data Architecture, Pricing Deltas & Data Hygiene Mandates (Batch 9 Audit)

### 6.1 Five High-Value Domain Discoveries Inside `MASTERS`
1. **Packing-Type Price Delta Engine (`dbo.PACKING` — `6` Rows)**:
   - Every Finish Saree catalog's base `SELLING RATE` in `dbo.QUAL` assumes **`CHAINBAG` (`packadd = 0`)**. Selecting a different packing style adjusts per-saree pricing automatically:
     - **`BOX C. TD`**: **`+₹50`** · **`BOX COMBO`**: **`+₹20`** · **`BOX QS`**: **`+₹15`**
     - **`CHAINBAG`**: **`₹0` (Base Standard)**
     - **`THELI PACK`**: **`-₹8`** · **`LOOSE NAKED`**: **`-₹10`**
2. **`ACCOUNT GROUPS` = Brokers / Sub-Agents (`dbo.ACGROUP`)**:
   - In Empire, `ACCOUNT GROUPS MANAGER` is used as the **Broker & Commission Agent Master** (`ISCON TEXTILE`, `S.S.D TEXTILE AGENCEY`, `AAKASH BHAI (NITIN)`), storing Broker address, mobile, `DEBIT LIMIT`, `LIMIT DAYS`, `GRADE`, `BILL CO.`, and `EXTRA DISC.`.
   - Meanwhile, **`HASTE LIST` (`dbo.HASTE`)** maps **Adatiya (Guarantor Agent)** $\leftrightarrow$ **Haste (Upcountry Sub-Buyer / Consignee)** + default `TRANSPORT` + destination `STATION` (e.g. `AMIT KUMAR AGRAWAL` $\rightarrow$ `SHUBHAM VASTRA BHANDAR`, `ANUP ROADNLINE`, `RAIGARH`).
3. **3 Brands (`dbo.SCREENSERIES`), 13 Base Cloth Types (`dbo.CLOTHTYPE`) & Main/Sub-Screen Hierarchy (`dbo.QUAL`)**:
   - **3 In-House Brands**: `AMBAJI SAREES` (`AS`), `Manyata Fashion` (`MS`), and `Sai Silk` (`SS`).
   - **Main Screen $\rightarrow$ Sub-Screen Item Hierarchy**: `dbo.QUAL` links finish catalogs back to `MAIN SCREEN` and `GREY QUALITY`, tracks launch cohort in `CATEGORY` (e.g., `SAREE 09-26`), links catalog photos (`Z:\PHOTO\*.jpg` + `Amazelite App`), and embeds **8 instant context drill-downs** (`Pend Sales Order`, `Pend Purch Order`, `Sales Report`, `Purch Report`, `Jobwork Stock`, `Finish Stock`, `Sticker Print`, `View Catalog`) right inside the Item Master!
4. **Dual-Purpose `dbo.RMKLIST` Lookup (`Staff Masters` vs `Lace/Border Designs`)**:
   - `rmktype = 0` (`ALL`): Stores the **13 in-house Cutting / Checking / Sales Counter Masters** (`DHANENJA`, `DHARA`, `HITESH`, `INDRAJEET`, `JEETU`, `MODI`, `NILESH`, `PARIMAL`, `PATEL`, `SANJAY PATEL`, `SATISH`, `TIWARI`, `VIRENDRA MASTER`) used in `CHECKER` and `COUNTED BY`!
   - `rmktype = 2` (`INVENTORY`): Stores **Lace / Border / Zari / Design Pattern Names** (`7072 AASTHA ZARI`, `7072 DHAMAL PATTA`, `CHATAI BORDER`, `BOX BUTTA`, `D.N. 02..239`).
5. **Chart of Accounts (`dbo.ACTYPE` — `43` Heads) & Polymorphic `SERIES` Matrix (`74` Codes)**:
   - `ACTYPE` drives Trial Balance ordering (`TRIAL BAL. DISPLAY POSN.`) and financial statement routing via 3 boolean flags (`IN BAL. SH`, `IN P & L`, `IN TRADING` — where `23 CLOSING STOCK` sets **both** `IN BAL. SH = Y` and `IN TRADING = Y`).
   - `SERIES` (`74` rows) stores the exact `GST DOCUMENT TYPE`, **bill suffix** (`WC`, `WD`, `WL`, `ADV`, `RFV`, `GR`), UI form engine (`CHALLAN`, `JOBBILL`, `CUTDET3`, `PURBILL`, `BILLSDIR`, `STOCKTFR`), default GL account, and allowed party `A/C TYPE` — and confirms **`P25` = `SALES GOODS RETURN (BYMISTEK)`** (suffix `GR`).

### 6.2 Critical Master Data Hygiene Mandates for Ambaji Sarees ERP
Inspecting Empire's live `CITIES`, `TRANSPORTS`, `MARKET`, and `MASTER` tables exposed why operators struggle with E-Invoice/E-Waybill rejections today — and how our Flutter + Supabase ERP will eliminate them on Day 1:
1. **Ban Silent Combobox Auto-Creation**: In Empire, typing `114.50` into `TRANSPORT` or a phone number (`9687669502 ARVIN`) into `MARKET` silently polluted the master table! In our `shadcn_flutter` comboboxes, require an explicit **`+ Add New <Entity>` modal** with format validation.
2. **1-Click GSTIN & PIN-Code Auto-Fill**:
   - Preserve and upgrade Empire's **`AUTO-FILL GSTIN`** workflow on Party & Transport Masters (auto-populating Legal/Trade Name, PAN, State Code `24`, PIN, Address, and E-Waybill Transporter ID).
   - Replace Empire's broken `CITIES` table (`#Name?` on `STD CODE` + 4x duplicate spellings like `AHEMADNAGAR`/`AHMADNAGAR`/`AHMEDNAGAR`/`AHILYANAGAR`) with a canonical **Indian PIN Code $\rightarrow$ City + State + NIC E-Waybill Distance (km)** lookup!
3. **Separate Dedicated Tables Instead of Overloaded `RMKLIST` / `ACGROUP`**:
   - Promote **Staff / Cutting Masters** (`rmktype=0`), **Border/Lace Design Patterns** (`rmktype=2`), and **Brokers** (`ACGROUP`) into clean, typed, first-class Supabase `sb_*` master tables while keeping backwards-compatible Airbyte sync mappings to `sq_*`.


---

## 7. Reporting Engine Critique, Statutory Analytics & UX De-Bloat Strategy (Batch 10 Audit)

### 7.1 Root-Cause UX Critique: Why Empire Feels Bloated, Text-Heavy & Unresponsive
Our visual walkthrough of `REPORTS` (`#100`–`#140`) proves **why operators hate navigating Empire** despite its deep textile math:
1. **3-to-5 Hop Friction Before Seeing Data**:
   - Opening a simple Trial Balance or Pending Mill Report forces: `Menu Dropdown` $\rightarrow$ `Magenta Text Listbox (18 options)` $\rightarrow$ `30-Field Filter Form (with 4 stacked SUB-TOTAL comboboxes)` $\rightarrow$ `Modal Popup #1 ("Show Latest Trial Balance?")` $\rightarrow$ `Modal Popup #2 ("Show Zero Bal. A/c Also?")` $\rightarrow$ `Read-Only Paginated Grid`!
2. **Broken Default States**:
   - In [`08_rep_34_ledger_summary_ungrouped_raw_grid.png`](file:///c:/Users/smitt/.gemini/antigravity/scratch/textile_erp/docs/empire_intake/screens/08_rep_34_ledger_summary_ungrouped_raw_grid.png), leaving `SELECT SUB-TOTALS` as `NONE` generates **28 pages of anonymous numbers (`FIELDmain1`) without Party/Ledger Names**!
3. **Disconnected Entry vs. Reporting Silos**:
   - Operators cannot filter, group, or inspect aging directly inside entry lists — they have to abandon their work and open a `742`-page `FINISH SALES DETAILED REPORT` or `171`-page `SALES OUTSTANDING BILLS` grid.

### 7.2 How Ambaji Sarees ERP Eliminates 90% of Separate "Report Screens"
Instead of building 150 separate report screens, our **`DynamicDenseTable` + `DynamicFilterBar` (`shadcn_flutter`)** architecture collapses Entry + Reporting into **1 unified zero-hop workspace per domain**:
- **Instant Group-By Chips**: Replace Empire's 4-dropdown `SELECT SUB-TOTALS` form with 1-click live `Group By` pills right above the table (`None` | `Mill` | `Quality` | `Broker` | `Party` | `City` | `Month`) and a single `/` or `Summary` toggle.
- **Inline Overdue & Shrinkage Badges**:
  - Replicate Empire's useful **overdue Jobwork highlight** (`>15 days` pending at Stitching/Embroidery Karigars, shown as green-underlined rows in `08_rep_31`) using native `shad.Badge` aging pills (`15d`, `30d`, `45d+ MSME!`).
  - Surface Mill Dyeing Shrinkage (`SHORTAGE %`, typically **`11.2%–15.4%`** on `DANI` qualities per `08_rep_13`) inline on Mill Receipt rows with outlier alerts when `SHORTAGE % > 16%`.
- **1-Click Unallocated Advance Matcher**:
  - `08_rep_20_sales_outstanding_bills_multiyear_grid.png` revealed `2,919-day` (`2018`) invoices and `-₹1,40,000` unadjusted `RTGS` rows sitting side-by-side under the same party (`RUKMANI SAREE CENTRE`). Add a **"Smart Auto-Match Unallocated Receipts (`XX`)"** banner on the Party Outstanding view!

### 7.3 Must-Have Statutory & Domain Reports Discovered in Batch 10
Do **not** miss these 5 critical business/statutory reports hidden inside Empire's `REPORTS` menus:
1. **Section 43B(h) Income Tax & ROC `MSME-1` Reports (`08_rep_19`, `08_rep_32`)**:
   - `MSME OVERDUE REPORT (SMALL AND MICRO)`, `CREDITORS AGEING MSME (above 45 DAYS)`, `Audit MSME Reversal/Payment details`, and `OUTSTANDING BILLS (MSME-1 for ROC)` — **mandatory in India** because unpaid Micro/Small vendor bills `> 45 days` on March 31 are disallowed as tax deductions under Sec 43B(h)! (Driven by `Udyam Aadhar no.` & `MSME Type` on Party Master!)
2. **Realized-Collection Broker Commission Engine (`08_rep_32`)**:
   - `RECEIVING -> COMMISSION BILLS` & `COMMISSION AUTO-JVS REPORT`: Brokers in Surat are paid commission (`P76` with 18% GST & 5% 194H TDS) **only after customer payment is received** (net of Goods Return `GR` & deductions), NOT merely when `S1` sales bills are raised!
3. **194Q Purchase TDS & TCS Statutory Registers (`08_rep_21`, `08_rep_32`)**:
   - `TDS ON GOODS (194Q) REGISTER` & `TCS REGISTER` monitoring cumulative ₹50L party thresholds.
4. **4-Bucket Jobwork WIP Tracker (`08_rep_29`)**:
   - Tracks sarees across 4 distinct physical stages: `WORK STOCK AT PARTY` (`O5`/`O7`/`O9`/`O11`), `WORK REC. STOCK AT GODOWN`, `CHECKING STOCK AT GODOWN`, and `WORK REC. DETAILS WITH SEC/LOST` (tracking `SECOND` & `LOSS` pieces per Karigar).
5. **12 Printable Business Documents (`08_rep_16`)**:
   - `Sale Bill` (Tax Invoice + QR + Cut/Design breakdown), `Delivery Challan` (`Full` vs `Blind W/O Weaver Name`), `Forwarding/Covering Note` (for Transport Bilty), `Payment/Discount Slip`, `Cheque Print`, `Voucher`, and `Address/Envelope/Thermal Sticker` prints — plus **`O/S Letter / PDF Mail / WhatsApp`** (`08_rep_22`).


---

## 8. System Configuration (`CONFIG`), Printed Invoice Spec, Barcode Hardware, RBAC & Modern Performance Blueprint (Batch 11 Audit)

### 8.1 Exact Business Policy Switches Active in `AMBAJI SAREES` (`10_cust_05`–`10_cust_14`)
1. **GST Taxable Value Formula on `S1` Sales Bills (`10_cust_14`)**:
   - **`Less Dhara in Sales-Bill Automatically before GST = TRUE`** and **`Less Scheme (Extra Discount) in Sales-Bill Automatically before GST = TRUE`**.
   - **Exact Invoice Math**:
     $$\text{Taxable Value} = \text{Gross Item Amount} - \text{Dhara Discount} - \text{Scheme/Extra Discount} + \text{Taxable Freight/Packing}$$
     $$\text{GST (5\%)} = \text{Taxable Value} \times 0.05 \quad (\text{2.5\% CGST + 2.5\% SGST for State } 24, \text{ else 5\% IGST})$$
2. **Strict Weaver-to-Mill Traceability (`10_cust_09`)**:
   - **`DISABLE UNLINKED MILL CHALLAN ENTRY WITHOUT PUR SR. = TRUE`**: Operators cannot dispatch orphan grey takas to a dyeing mill without linking them to an authentic `P1` Weaver Purchase `SRNO`!
3. **Interest, Period Locks & Clearing Slips (`10_cust_06`, `10_cust_07`)**:
   - **Overdue Interest Math**: `365`-day year, **`+1` inclusive day (`ADD ONE DAY FOR INTEREST = 1`)**, default **`12%` p.a.** Dr/Cr interest.
   - **Period Freeze**: `LOCK CHANGES TO ENTRIES UPTO DATE = 31/03/26`; tallied/frozen entries can only be edited by a `SUPERVISOR`.
   - **Auto Clearing Slip Code**: `ASSIGN RECEIPT CLEARING SLIP NO. AUTOMATICALLY = TRUE` (generates `DDMMCA` codes like `0411CA`, `1105CA`).
4. **Quarterly/Half-Yearly `ITC-04` Jobwork GST Return (`08_rep_49`)**:
   - Must export **`ITC-04` (`MFG TO JW` + `JW TO MFG`)** covering both Grey Dyeing Mills (`PINVTRN` $\leftrightarrow$ `J1`) and Value-Addition Karigars (`O5/O7/O9/O11` $\leftrightarrow$ `O6/O8/O10/O12`), alongside `GSTR-1`, `GSTR-3B` (with RCM `3.1.d` & `4.A.3`), and cross-year `GSTR-2B` reconciliation!

### 8.2 Exact Hardware, Print & RBAC Specifications
- **Printed `S1` Tax Invoice (`SALEBILLnew` — `08_rep_42`)**:
  - Current HQ Header: `AMBAJI SAREES`, `2001 TO 2005 HINDUSTAN TEXTILE CENTER-2, CANAL ROAD, SURAT`, `PAN: ABLFA2723Q`, `ACCOUNTS: 9998097475, SALES: 9998351033`.
  - Prints Buyer + Place of Supply, Consignee (`HASTE`), Agent/Broker (with full Surat market address & phone!), `L.R. NO.`, `TRANSPORT`, `CASE NO` (`13564x1`), `STATION` with NIC distance (`WADWANI -> (500 km)`), `HSN: 540754`, item table (`DESCRIPTION`, `CATEGORY`, `PACKING`, `PCS`, `CUT`, `MTS.`, `RATE`, `AMOUNT`) + sub-line **`D.NO- V07x109`**, and supports **Duplex PDF Print** + **1-Click WhatsApp PDF**.
- **Thermal Barcode Sticker (`09_util_14`)**:
  - Printer: **`TSC TTP-244 Pro`** · Label Size: **`7.6 cm × 4.8 cm` (`1 Across`)** · Template: **`ZALAK`** (`[ITEMSRNO]` in **Code 39 / `Free 3 of 9`** barcode + `[NAME]` in bold Arial).
- **Live 9-User RBAC Roster (`10_cust_03`)**:
  - Active staff accounts to provision in Supabase Auth + RLS: **`JATIN`** (Admin / Full Authority), **`SANTOSH`**, **`SUBHAM`**, **`YASH`**, **`AKSHAY`**, **`ARVIND`**, **`DEEPAK`**, **`GIRDHARI`**, and **`ROSHAN`**, with per-module `can_open`, `can_insert`, `can_edit`, `can_delete` permissions and role-cloning (`Copy User`).

### 8.3 Why Empire's Split-Brain Stock Is `-43,288` Today (`08_rep_44`) — & Our High-Speed Architecture Plan
- [`08_rep_44_finish_stock_main_screen_negative_qty_grid.png`](file:///c:/Users/smitt/.gemini/antigravity/scratch/textile_erp/docs/empire_intake/screens/08_rep_44_finish_stock_main_screen_negative_qty_grid.png) caught Empire showing **`-43,288` pcs of `3 STAR`** and **`-37,824` pcs of `7072 (FINISH)`** because Cutting Cards (`O3`) already moved `99.7%` to our Flutter `sb_cutdet`, leaving Empire blind to Finish Stock production while `S1` sales still deduct in Empire!
- **Cutting-Edge Flutter + Supabase Speed Architecture (For Our Rapid Sprint)**:
  1. **Intent-Driven Workspaces (Zero Modal Hops)**: Design around *operator jobs-to-be-done* (e.g., *Daytime Counter Billing*, *Evening Bilty & Bulk E-Invoice Wave*, *Weaver-to-Mill Taka Split*, *Karigar Jobcard Pipeline*, *Multi-Bill Bank Settlement*) instead of 100 disconnected database forms.
  2. **Postgres Materialized / Indexed Rollup Views + Keyset Pagination**: Replace Empire's slow 742-page Access cursor scans with sub-20ms Supabase Postgres RPCs/views (`IMMBE2627`), client-side hot-cached Masters (`9.1k` Parties, `QUAL`, `PACKING`, `SERIES`) in memory with instant fuzzy search (`< 2ms` keystroke latency), and virtualized `DynamicDenseTable` rendering at 60/120fps!
  3. **Optimistic Keyboard-First Entry**: `NumPad Enter` field traversal, inline Party Balance + Last Sold Rate hint (`SHOW LAST RATE/BILLING DETAILS IF SALE TO SAME PARTY` from `10_cust_08`!), and `Ctrl+S` single-RPC transactional commits.


---

## 9. Paisa-Exact Final Accounts Reconciliation Benchmark (`AMBAJI SAREES` `01/04/26`–`04/11/26` — Batch 12 Audit)

Screenshots [`08_rep_51`](file:///c:/Users/smitt/.gemini/antigravity/scratch/textile_erp/docs/empire_intake/screens/08_rep_51_final_accounts_profit_and_loss_with_pct_sale.png), [`08_rep_52`](file:///c:/Users/smitt/.gemini/antigravity/scratch/textile_erp/docs/empire_intake/screens/08_rep_52_final_accounts_trading_with_pnl_page1_stocks.png), and [`08_rep_53`](file:///c:/Users/smitt/.gemini/antigravity/scratch/textile_erp/docs/empire_intake/screens/08_rep_53_final_accounts_trading_with_pnl_page2_totals.png) give us an **airtight, paisa-exact accounting unit test** against `IMMBE2627` (`CNO = 4`, `01/04/2026` to `04/11/2026`):

| Financial Head (`ACTYPE`) | Key Constituent Ledgers (`01/04/26–04/11/26`) | Credit / Income (`₹`) | Debit / Expense (`₹`) | `% of Net Sale` |
| :--- | :--- | ---: | ---: | ---: |
| **Opening Stock** (`102`) | In-House (`7,75,81,366.00`) + At Mill (`3,79,17,645.00`) | `0.00` | `11,54,99,011.00` | `24.03%` |
| **Sales** (`7`) | `SALES A/C` (`48,76,97,448.59`) less `SALES RETURN` (`64,36,936.11`) & `DISC` (`6,57,278.31`) | `48,76,97,448.59` | `70,94,214.42` | `100.00%` *(Net `₹48.06 Cr`)* |
| **Direct Trading Costs** (`8`, `10`) | Grey Pur (`14.83 Cr`), Mill Job (`10.04 Cr`), Work Job (`7.58 Cr`), Finish Pur (`3.81 Cr`), Packing (`2.74 Cr`), Modelling (`31.70L`), Lace (`25.53L`) vs Pur Disc (`25.53L`) & Ret (`9.28L`) | `34,81,563.80` | `39,59,88,690.70` | `81.67%` *(Net `₹39.25 Cr`)* |
| **Closing Stock** (`23` — `CLOSSTOCK`) | In-House (`6,22,93,900.00`) + At Mill (`3,36,06,689.16`) | `9,59,00,589.16` | `0.00` | `19.95%` |
| **Gross Profit (`TRADING A/C`)** | **Carried forward to Profit & Loss A/c** | — | **`6,84,97,685.43`** | **`14.25%`** |
| **P & L Indirect Expenses** (`4`) | Income Tax (`30.00L`), Sales Comm (`25.54L`), Salaries (`19.57L`), Bank Int (`15.87L`), Packing Exp (`14.27L`), Cutting Exp (`13.05L`), Hamali (`11.35L`), Rebate/Vatav (`6.56L`), Rent (`3.00L`), etc. | `0.00` | `1,48,31,464.37` | `3.09%` |
| **Net Profit (`01/04/26–04/11/26`)** | **Divisible across 8 Partners (`05_gen_15`) at Year-End** | — | **`5,36,66,221.06`** | **`11.17%`** |
| **Combined Statement Grand Total** | **Exact Double-Entry Proof (`Page 2 of 2`)** | **`65,55,77,286.98`** | **`65,55,77,286.98`** | **100% Balanced** |

> [!TIP]
> **UX Gem to Keep in Our Flutter Financial Statements**: Notice the **`% BY SALE`** column in [`08_rep_51_final_accounts_profit_and_loss_with_pct_sale.png`](file:///c:/Users/smitt/.gemini/antigravity/scratch/textile_erp/docs/empire_intake/screens/08_rep_51_final_accounts_profit_and_loss_with_pct_sale.png) (`GP = 14.25%`, `P&L Opex = 3.09%`, `Net Margin = 11.17%`, `Sales Comm = 0.53%`, `Cutting = 0.27%`)! Including a live `% of Revenue` column + YoY delta pill on our native `shadcn_flutter` Trading & P&L view will give management instant executive clarity.
