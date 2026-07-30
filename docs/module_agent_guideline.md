# Module Agent Master Contextualization SOP & Initial Prompt Template

This document defines the **Master Guidelines and Initial System Prompt Template** for launching dedicated, domain-bounded Chat Windows (Tabs) in Antigravity 2.0.

---

## 🏛️ System Architecture & Role Boundaries

```
┌─────────────────────────────────────────────────────────────────────────┐
│                       MASTER CHAT WINDOW (Parent)                       │
│ Conversation ID: def5a9d9-ee76-4d30-be57-1551666ddd2e                 │
│ Role: Core Architect, System Guardian & Git Release Controller          │
│ Allowed Paths: lib/models/core/, lib/services/core/, lib/dynamic_ai/  │
└────────────────────────────────────┬────────────────────────────────────┘
                                     │
           ┌─────────────────────────┼─────────────────────────┐
           ▼                         ▼                         ▼
┌────────────────────┐    ┌────────────────────┐    ┌────────────────────┐
│    CHAT TAB: PO    │    │    CHAT TAB: CC    │    │    CHAT TAB: PB    │
│ Purchase Orders    │    │ Cutting Cards      │    │ Purchase Bills     │
│ Domain: `scr_po_*` │    │ Domain: `scr_cc_*` │    │ Domain: `scr_pb_*` │
└────────────────────┘    └────────────────────┘    └────────────────────┘
```

---

## 📋 What Every New Chat Session Needs (Key References)

When opening any new Chat Window in Antigravity 2.0 for a specific module, the agent **MUST** be contextualized with the following 4 core references:

1. **Master AI Developer Rules**: [GEMINI.md](file:///Users/smittal/Developer/ogranism_library/textile_erp/GEMINI.md) (Strict native `shadcn_flutter` tokens, 34px DAB height, Section 9 `mns` naming conventions).
2. **Canonical Core Layer**:
   - Models: [lib/models/core/sq/](file:///Users/smittal/Developer/ogranism_library/textile_erp/frontend/lib/models/core/sq/) & [lib/models/core/sb/](file:///Users/smittal/Developer/ogranism_library/textile_erp/frontend/lib/models/core/sb/)
   - Services: [lib/services/core/sq/](file:///Users/smittal/Developer/ogranism_library/textile_erp/frontend/lib/services/core/sq/) & [lib/services/core/sb/](file:///Users/smittal/Developer/ogranism_library/textile_erp/frontend/lib/services/core/sb/)
3. **Dynamic AI Reusable UI Engine**: [lib/dynamic_ai/components/page_level/](file:///Users/smittal/Developer/ogranism_library/textile_erp/frontend/lib/dynamic_ai/components/page_level/) (`PageHeader`, `DynamicActionBar`, `DabSubmodulePopover`, `DynamicDenseTable`, `DynamicList`, `MicroButton`).
4. **Master Chat Channel**: Target `Conversation ID`: **`def5a9d9-ee76-4d30-be57-1551666ddd2e`**.

---

## 🔴 Directives & Allowed File Boundaries

| Action | Allowed Path | Policy |
| :--- | :--- | :--- |
| 🟢 **Full Write Access** | `frontend/lib/screens/production/<module>/scr_<mns>_*.dart` | Module UI screens, canvases, modals |
| 🟢 **Full Write Access** | `frontend/lib/models/production/mdl_<mns>.dart` | Module specific view models / wrappers |
| 🟢 **Full Write Access** | `frontend/lib/services/production/srv_<mns>.dart` | Module specific service logic |
| 🔴 **Read-Only (Escalate)** | `frontend/lib/models/core/*` & `services/core/*` | Master Chat handles core schema changes |
| 🔴 **Read-Only (Escalate)** | `frontend/lib/dynamic_ai/*` | Master Chat handles shared UI components |

---

## 📤 Core Mutation Escalation Protocol

If your module agent requires a change to a shared Core Service (`sq_bills_service`, `sq_series_service`, etc.) or a shared `dynamic_ai` component:

1. **DO NOT edit the core file directly.**
2. Send a message to Master Chat using the `send_message` tool:
   - **Recipient**: `def5a9d9-ee76-4d30-be57-1551666ddd2e`
   - **Message**:
     ```markdown
     [CORE_MUTATION_REQUEST]
     Module: <mns>
     File Target: lib/services/core/sq/sq_bills_service.dart
     Requested Addition: Add broker filter method getBillsByBroker(...)
     Rationale: Required for Sales Orders broker reconciliation.
     ```

---

## 📋 Copy-Paste Prompt Template for Launching a New Chat Tab

Copy and paste the template below into any new Antigravity 2.0 Chat Window when starting work on a module:

```markdown
Hello Agent! You are the dedicated Module Developer for the **[MODULE NAME] ([mns])** module in Ambaji Sarees ERP.

### 🏛️ Domain Context & Rules
- **Target Module Abbreviation (`mns`)**: `[e.g. po / cc / pb / so / jw]`
- **Allowed Working Files**:
  - `frontend/lib/screens/production/[MODULE]/scr_[mns]_landing.dart`
  - `frontend/lib/screens/production/[MODULE]/scr_[mns]_detail_canvas.dart`
  - `frontend/lib/screens/production/[MODULE]/scr_[mns]_form_dialog.dart`
  - `frontend/lib/models/production/mdl_[mns].dart`
  - `frontend/lib/services/production/srv_[mns].dart`
- **Master Rules**: Read and obey `GEMINI.md` (native shadcn_flutter tokens, 34px DAB height, zero container wrappers).

### 🔒 Core Layer Contract
- Shared core models (`lib/models/core/`), services (`lib/services/core/`), and UI components (`lib/dynamic_ai/`) are **READ-ONLY**.
- If you need a core file updated, send a message to Master Chat using `send_message`:
  - Recipient: `def5a9d9-ee76-4d30-be57-1551666ddd2e`

### 🚀 Task Objective
[DESCRIBE YOUR TASK FOR THIS MODULE HERE]
```
