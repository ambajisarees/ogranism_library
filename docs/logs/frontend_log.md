# Frontend Design Log — Ambaji ERP

## 2026-04-05: Emerald Refresh Phase 1
- [x] **Theme Foundations**: Defined `AppColors` (Emerald/Slate) and `AppTheme` (VisualDensity.compact, JetBrains Mono).
- [x] **Core UI**: Replaced Material icons with `LucideIcons` in `Sidebar` and `TopAppBar`.
- [x] **Production Module — Grey Inward**:
    - [x] `GreyInwardScreen`: Updated icons/colors.
    - [x] `GreyInwardListPanel`: High-density layout + Lucide icons.
    - [x] `GreyInwardVnoCard`: Mono font for numbers + 8px padding.
    - [x] `GreyInwardDetailPanel`: Streamlined table + Lucide icons.
- [/] **Production Module — Mill Receive**:
    - [ ] Update `MillReceiveScreen` icons/density.
    - [ ] Refactor `MillReceiveListPanel` / `VnoCard`.
    - [ ] Refactor `MillReceiveDetailPanel`.
- [ ] **Production Module — Cutting Cards**:
    - [ ] Update `CuttingCardsScreen`.
- [ ] **Masters Module**:
    - [ ] Update `MastersScreen` & `PartyMasterV3`.
- [ ] **Quality Control**: Clean up unused imports/lints globally.

## 2026-04-09: Unified Iconography & Organism Refinement
- [x] **Plasm (Architecture)**: 
    - [x] Defined semantic iconography tokens (`iconSizeXs` to `iconSizeLg`).
    - [x] Tokenized icon colors for consistency across Atoms/Molecules.
- [x] **Atoms & Molecules (Cells/Tissues)**:
    - [x] Refactored all components (`CellButton`, `TissueDatePicker`, etc.) to use theme tokens.
    - [x] Full migration from Material Icons to `LucideIcons`.
- [x] **Organs (App Shell)**:
    - [x] Implemented `NavBoat` organ with binary Sidebar/Rail states.
    - [x] Refined Rail (84px) with vertical "Selected" labels (Name over Icon).
    - [x] Resolved header overflows (116px width collision fixed).
- [x] **Documentation**:
    - [x] Cleaned up `LibraryPreview` redundancy.
    - [x] Registered `NavBoat` in central `index.dart`.
- [x] **Safety**:
    - [x] Created `backup_erp.ps1` PowerShell script for timestamped project snapshots.
    - [x] Verified backup integrity (verified 240MB lean snapshots).
