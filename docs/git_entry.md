# Git Operations & Cross-Machine Workflow Registry

> **Project**: Ambaji Sarees ERP
> **Primary Workstations**:
> - 💻 **`[Windows Workstation]`**: Windows Desktop Primary Engine (`flutter run -d windows`)
> - 🍏 **`[MacBook Workstation]`**: macOS & iOS Secondary Engine (`flutter run -d macos`)
> **Default Branch**: `master` · Remote Origin: `origin/master`

---

## 🔀 Branch Topology & Git History

```mermaid
gitGraph
   commit id: "8cd5594 (Win)" tag: "Shortcut Resilience"
   commit id: "b770663 (Win)" tag: "Merge purorders"
   commit id: "23c2aa8 (Win)" tag: "Widget test fix"
   commit id: "2026-07-25 (Mac)" tag: "DynamicDenseTable"
   commit id: "2026-07-26 (Win)" tag: "Slate10 HeaderTabs"
   commit id: "2026-07-27 (Win)" tag: "Table Footer & Stone 980"
```

---

## 📊 Cross-Machine Operations Log

| Date | Machine Agent | Action | Target Branch / Hash | Key Changes & Objectives |
| :--- | :--- | :--- | :--- | :--- |
| **2026-07-30** | 💻 `[Windows Workstation]` | **Commit & Push** | `master` (`origin/master`) | MNS architecture overhaul for Cutting Cards (`cc`) and Purchase Bills (`pb`), line item source routing (`sq_PINVTRN` for Grey, `sq_MILLREC` for Mill, `sq_BILLDET` for others), MicroButton overflow fix, & retired 11 legacy production files. |
| **2026-07-29** | 🍏 `[MacBook Workstation]` | **Commit & Push** | `master` (`origin/master`) | Shipped 7 canonical core data models (`sq_bills`, `sq_pinvtrn`, `sq_millrec`, `sq_chaltrn`, `sq_billdet`, `sb_cutdet`, `sb_cutdet_summary`), 7 core services, 3-way card linkage engine, Mill Programs module, `GEMINI.md` Section 9, & legacy reference cleanup. |
| **2026-07-29** | 💻 `[Windows Workstation]` | **Commit & Push** | `master` (`origin/master`) | Standardized 12px/8px/8px vertical gap tokens, DAB 34px height alignment, crisp white autocompletes, tooltipped grouping switcher, and DDT row grouping column-aligned summary view. |
| **2026-07-28** | 🍏 `[MacBook Workstation]` | **Commit & Merge & Push** | `master` (`origin/master`) | Shipped 3-state `PageHeader` (`standard`, `adding`, `editing`), zero-overhead `PageFormCanvas` with pixel-perfect 1200px max-width alignment, dedicated 2-column form layout (`CreatePageLayout`), dynamic list/content pane skeletons, and symmetric 12px (`shad.padMd`) `HeaderTabs` child padding. |
| **2026-07-27** | 💻 `[Windows Workstation]` | **Commit & Push** | `master` (`origin/master`) | Shipped 3-area Table Footer, dynamic `Stone 980` (2% dark tint) surface tokens, fabric thumbnails + gallery overlay, updated dev_log & git_entry. |
| **2026-07-26** | 💻 `[Windows Workstation]` | **Commit** | `master` | Standardized `header_tabs.dart` Slate 10 token, Sidenav Slate 50 palette, and global keyboard state machine. |
| **2026-07-25** | 🍏💻 `[MacBook & Windows]` | **Commit & Merge** | `master` (`purorders`, `recipes`, `crm`) | Merged Multi-Module SOP (`docs/workflow_multi_branch_guide.md`), Purchase Orders 5-module workflow (`purorders`), Mill Printing Recipes (`sb_recipe_mill`), Google Contacts Sync Engine, DynamicDenseTable, & native `shadcn_flutter` rules. |
| **2026-07-20** | 💻 `[Windows Workstation]` | **Commit & Push** | `master` | Refactored accordion sidebar, generic child layout sizing engine, and 12-item quick action wrap grid. |
| **2026-07-19** | 💻 `[Windows Workstation]` | **Commit & Push** | `master` | Built reusable `PageHeader` component (`page_header.dart`) and launched background Levitation management client. |
| **2026-07-18** | 🍏 `[MacBook Workstation]` | **Commit & Merge** | `master` | Resolved cutting card total investment calculation bug (`CC-0290`), updated Edge Function `create-cutting-batch` v13. |
| **2026-07-17** | 💻 `[Windows Workstation]` | **Commit & Push** | `master` | Built Stitching tasks reconciliation view, Designs SKU catalog dashboard (`sb_designs`), and denormalized `sb_cutdet_summary`. |
| **2026-07-16** | 💻 `[Windows Workstation]` | **Commit & Push** | `master` | Shipped central Media Library Explorer (`media_screen.dart`), inline scan attachments, and single-step auto-rename. |
| **2026-07-15** | 💻 `[Windows Workstation]` | **Commit & Merge** | `master` (`whatsapp`, `purorders`) | Merged WhatsApp CRM companion workstation & Purchase Orders 5-module workflow into `master`. |

---

## 🚀 Mac Handoff Checklist (Next Steps)

1. **On your MacBook Workstation**:
   ```bash
   cd ~/path/to/textile_erp
   git checkout master
   git pull origin master
   flutter pub get
   flutter run -d macos
   ```
2. Both `docs/dev_log.md` and `docs/git_entry.md` are synchronized with `origin/master`.
