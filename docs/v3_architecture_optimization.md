# Blueprint: ERP V3 Architecture Optimization

## 📅 Status: Deferred (Proposed 2026-04-08)

The following plan outlines the transition from "Scaffold by Copying" to "Scaffold by Configuration" for all V3 modules.

---

## 🔍 Core Problem: Boilerplate Drift
Currently, `PartiesPaneV3` and `ItemsPaneV3` duplicate ~150 lines of "Engine" logic:
- **Search Debouncing**: Manual Timer management.
- **Pagination State**: `currentPage`, `totalCount`, `isLoading`.
- **Skeleton UI**: ~35 lines of identical Row/Skeleton code per file.
- **Event Handlers**: `onSearch`, `nextPage`, `prevPage`.

---

## 🛠️ Phase 1: Design System Hardening
**Target File**: `OrganismUI.dart`

### 1. Unified Skeletons
Implement `OrganismUI.listCardSkeleton({int lines = 3, bool hasThumbnail = true})`.
This replaces the multi-line `_buildSkeletonItem` helper in individual panes.

### 2. Standardized Spacing
Enforce the **42px Thumbnail** and **10px Vertical Padding** as the global density standard for all V3 Explorer cards.

---

## 🛠️ Phase 2: Logic Centralization
**New File**: `lib/widgets/v3_list_controller_mixin.dart`

Create a mixin for `StatefulWidgets` that handles:
1. `TextEditingController` instantiation and disposal.
2. `Timer` management for debouncing.
3. High-density pagination math (`firstItemIndex`, `lastItemIndex`).
4. Loading state toggles.

---

## 🛠️ Phase 3: Screen Refactoring
Refactor existing panes (`Parties`, `Items`) to use the mixin.
- **Expected result**: File size reduction from ~240 lines to **~90 lines**.
- **Impact**: Adding new Masters (Suppliers, Haste, Brokers) becomes a matter of defining the **Service** and the **Cell Card** only.

---

## 🚀 Execution Order
1. Implement `listCardSkeleton` (Immediate visual consistency).
2. Draft the `ListControllerMixin`.
3. Migrate `PartiesPaneV3` (The stable reference).
4. Migrate `ItemsPaneV3`.
