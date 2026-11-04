# Complete Empire (`IMMBE2627`) Table Catalog: 26 Streamed vs 43 Unstreamed User Tables

> Transcribed directly from `MAIN-PC\SQLEXPRESS` (`IMMBE2627`) SSMS Object Explorer (`dbo.ACGROUP` $\rightarrow$ `dbo.USERS`) and diffed against live Supabase `"IMMBE2627".sq_*` tables.
> *(Note: 69 user base tables + ~24 MSSQL internal/system tables = 93 total objects).*

---

## 1. Currently Streamed via Airbyte into Supabase (`26 Tables`)

| # | MSSQL Table (`dbo.*`) | Supabase Mirror (`IMMBE2627.*`) | ERP Domain |
| :- | :--- | :--- | :--- |
| 1 | `ACGROUP` | `sq_ACGROUP` | Accounting Groups Hierarchy |
| 2 | `ATYPE` | `sq_ATYPE` | Voucher / Book Type Master (`O13`, `O5`, `P1`, `S1`, etc.) |
| 3 | `BANKREC` | `sq_BANKREC` | Bank Reconciliation |
| 4 | `banks` | `sq_banks` | Bank Master |
| 5 | `BILLDET` | `sq_BILLDET` | Universal Voucher Line Items (Purchase, Jobwork, Sales) |
| 6 | `BILLS` | `sq_BILLS` | Universal Voucher Headers (`CNO + TYPE + VNO`) |
| 7 | `BILLS_einv` | `sq_BILLS_einv` | GST E-Invoice IRN / Ack / QR Metadata |
| 8 | `CHALTRN` | `sq_CHALTRN` | Grey Dispatch / Mill Program Challans (`MP`) |
| 9 | `CITIES` | `sq_CITIES` | City & Station Master |
| 10 | `CLOTHTYPE` | `sq_CLOTHTYPE` | Cloth Category Master |
| 11 | `COMPMST` | `sq_COMPMST` | Company / Firm Master (`CNO`) |
| 12 | `CUTDET` | `sq_CUTDET` | Cutting Card Taka/Piece Detail (`CC`) |
| 13 | `DELETEDITEMS` | `sq_DELETEDITEMS` | Audit Log of Deleted Vouchers/Items |
| 14 | `FAS` | `sq_FAS` | Financial Accounting Ledger Postings |
| 15 | `HASTE` | `sq_HASTE` | Agent / Sub-Agent (Haste) Master |
| 16 | `MASTER` | `sq_MASTER` | Party / Account / Broker / Supplier / Customer Master |
| 17 | `MILLREC` | `sq_MILLREC` | Mill Finished Receipt Cards (`MR`) |
| 18 | `PACKING` | `sq_PACKING` | Packing Slip / Bale Header |
| 19 | `PINVTRN` | `sq_PINVTRN` | Grey Purchase Bill Taka Inventory (`PB`) |
| 20 | `PURORD` | `sq_PURORD` | Purchase Orders & Sales Orders (`O13`–`O16`, `O1`) |
| 21 | `QUAL` | `sq_QUAL` | Quality / Fabric / Saree Item Master |
| 22 | `RECPAY` | `sq_RECPAY` | Receipt & Payment Bill-Wise Adjustments |
| 23 | `SAREEDES` | `sq_SAREEDES` | Saree Design Master |
| 24 | `SERIES` | `sq_SERIES` | Voucher Numbering Series & Book Prefixes |
| 25 | `TRANSPORTS` | `sq_TRANSPORTS` | Transport / Carrier Master |
| 26 | `updates_billdet` | `sq_updates_billdet` | Bill Line-Item Update / Edit Audit Trail |

---

## 2. The 43 Unstreamed User Tables (Grouped by Strategic Value)

### A. Empire's "UI, Screen & Form Brain" (`12 Tables` — Highest UX Priority)
These tables reveal **every screen in Empire**, which fields are enabled/hidden on each form, custom layouts, standard remarks, and operator permissions:
1. **`SCREENLIST`**: Master catalog of every UI screen/module inside Empire.
2. **`SCREENCOMP`**: Every UI input control/component inside Empire's screens!
3. **`SCREEN_EXPOSE`**: Exposed screen actions/links.
4. **`formsettings`**: Per-form field visibility, tab-stop, mandatory, and default rules.
5. **`CUSTOMFORMS`**: Custom entry/print form definitions.
6. **`FORMPERM`**: Role/User Add-Edit-Delete-Print permission matrix per form.
7. **`CONFIG`**: Company-level ERP behavioral switches.
8. **`settings`**: Application-level settings.
9. **`uniq_config`**: Unique constraint / duplicate bill prevention rules.
10. **`USERS`**: Operator user accounts.
11. **`logins`**: Operator login session history (shows *who* actively uses Empire and when!).
12. **`RMKLIST`**: Standard pre-saved remarks dropdown list for fast data entry.

### B. Empire's "Report & SQL Formula Brain" (`5 Tables` — Highest Logic Priority)
Empire stores its built-in and custom report SQL logic directly inside these tables:
13. **`REPORTQUERIES`**: Actual SQL queries used to generate Empire reports!
14. **`QUICKREPORTS`**: Quick-access operational reports.
15. **`Reportoptions`**: Filter checkboxes and parameter options for reports.
16. **`REPORTGROUPING`**: Sub-total and group-by hierarchies for reports.
17. **`UDRS`**: User-Defined Reports.

### C. Dispatch, Lorry Receipt (LR) & Packing Extensions (`6 Tables`)
Crucial context for **Purchase Inward LR**, **Sales Dispatch**, and **Parcel/Bale Packing** UX:
18. **`BILLS_lr`**: Outward Sales Bill Lorry Receipt (Transport LR No, LR Date, Freight, Bale No).
19. **`BILLS_lr_inw`**: Inward Purchase Bill Lorry Receipt tracking.
20. **`LRDET`**: Detailed LR line items / parcel tracking.
21. **`BUNDLES`**: Saree bundle / box grouping before bale packing.
22. **`pack_cons`**: Packing material (box, polybag, Patti, bardana) consumption per bill/pack.
23. **`BILLSLET`**: Bill dispatch covering letter / courier slip metadata.

### D. Production, Saree Costing, BOM & Fiscal Stock Rollover (`13 Tables`)
Crucial context for **Design Orders**, **Costing Sheets**, **Recipe/BOM**, and **April 1 Fiscal Year Rollover**:
24. **`SAREEDESORD`**: Design-wise Sales/Production Orders (`SAREEDES` order book).
25. **`COSTING`**: Saree costing breakdown (Grey + Mill Dyeing/Printing + Embroidery/Jobwork + Packing + Margin).
26. **`ITEMCONS`**: Item / BOM consumption norms (e.g., meters of grey/border/lace per saree).
27. **`ITEMCONS_MFR`**: Manufacturing / Jobwork consumption norms.
28. **`GREYRET`**: Grey fabric return to weaver/supplier.
29. **`QOPSTOCK`**: Quality Opening Stock (populated during April 1 Financial Year creation!).
30. **`CLOSSTOCK`**: Closing Stock valuation snapshot.
31. **`DESSTOCK`**: Design-wise stock summary.
32. **`CATALOGS`**: Saree catalog / collection book master.
33. **`CATEGORY`**: Product / Party category master.
34. **`MARKET`**: Textile market / textile hub master (e.g., Ring Road market buildings).
35. **`LABELS`**: Barcode / Box / Saree sticker label templates.
36. **`APP_IMG`**: Product / Design / App image links.

### E. Tax Adjustments, Maintenance & Dead Pre-GST Legacy (`7 Tables`)
37. **`tds_adjust`**: TDS deduction / adjustment ledger mappings (`194C` jobwork, `194Q` purchase).
38. **`HOLIDAY`**: Factory / Market holiday calendar (useful for due-date calculation).
39. **`MAINT_TYPES`**: Maintenance / Expense head types.
40. **`MAINT_SUBTYPES`**: Maintenance sub-categories.
41. **`TAXFORMS`**: Legacy Sales Tax C-Form / F-Form / H-Form header *(Pre-GST — Ignore)*.
42. **`TAXFORMDET`**: Legacy Sales Tax Form detail *(Pre-GST — Ignore)*.
43. **`RG1_REG`**: Legacy Central Excise RG-1 Daily Stock Account *(Pre-GST — Ignore)*.

