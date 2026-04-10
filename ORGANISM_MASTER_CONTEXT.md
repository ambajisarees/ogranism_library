# Organism Design System - Master Technical Context

## 1. Core Philosophy: The Biological Hierarchy
The system is built on a strict bottom-up biological hierarchy. Every UI element must belong to one of these five layers:

1.  **🩸 PLASMA (Foundations)**: Mathematical constants. Colors, typography, shadows, spacing, and iconography tokens. (Stored in `theme.dart` and `plasma.dart`).
2.  **🦠 CELLS (Atomic Mechanics)**: The smallest interactable pieces. Headless, state-aware, and stripped of Material design bloat. (e.g., `CellButton`, `CellInput`).
3.  **🧬 TISSUES (Molecular Layouts)**: Combinations of Cells with specialized functional boundaries. (e.g., `TissueDatePicker`, `TissueListCard`).
4.  **🫀 ORGANS (Structural App Shells)**: Complex structural blocks that manage global app behavior. (e.g., `NavBoat` navigation rail).
5.  **🧠 SYSTEMS (Page Master Layouts)**: High-level page orchestrators and master-detail patterns.

---

## 2. Plasma Specifications (Tokens)
All designs MUST derive from `OrganismTheme` tokens. Hardcoding of values is strictly forbidden.

### Color Palette (Red Wine & Stone)
- **Primary**: `#800020` (Bordeaux/Burgundy)
- **Success/Warning/Error**: Standard semantic flags.
- **Surface Layering**: Uses the "Stone" scale from `stone50` (backgrounds) to `stone900` (primary text).

### Iconography Rules
- **Library**: `LucideIcons` only.
- **Sizes**: Must use semantic tokens:
    - `iconSizeXs` (12px): Micro indicators.
    - `iconSizeSm` (16px): Inputs, secondary buttons.
    - `iconSizeMd` (20px): Primary nav, standard buttons.
    - `iconSizeLg` (28px): Empty states, hero sections.

### Geometry (Membranes)
- **Standard Radius**: `radiusMd` (8.0px).
- **ERP Density**: `VisualDensity(horizontal: -2, vertical: -2)` enforced for high-information density.

---

## 3. Implementation Code Patterns

### Component Pattern (A "Cell" or "Tissue")
```dart
class CellExample extends StatefulWidget {
  final bool value;
  final ValueChanged<bool>? onChanged;

  const CellExample({super.key, required this.value, this.onChanged});

  @override
  State<CellExample> createState() => _CellExampleState();
}

class _CellExampleState extends State<CellExample> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedContainer(
        duration: OrganismTheme.durationFast,
        decoration: BoxDecoration(
          color: widget.value ? OrganismTheme.primary : OrganismTheme.surface,
          border: Border.all(
            color: _isHovered ? OrganismTheme.primaryLight : OrganismTheme.border,
          ),
          borderRadius: OrganismTheme.borderMd,
          boxShadow: _isHovered ? OrganismTheme.shadowSm : null,
        ),
        // Child logic here...
      ),
    );
  }
}
```

### The NavBoat Layout (Organ)
The `NavBoat` uses a kinetic state switch (`_isCollapsed`).
- **Collapsed (84px)**: Selected items show a vertical stack: `Column([labelMicro], [icon])`.
- **Expanded (240px)**: Items show horizontal `Row([icon], [spacing], [label])`.

---

## 4. Work in Progress & Future Roadmap
- **Stabilized**: All Cells and Tissues are tokenized and using Lucide icons.
- **NavBoat**: Fully functional binary rail/sidebar.
- **Next Up**: `Systems` layer. We need to build the **Master-Detail Master Page** that handles search on top, list on the left (Tissues), and detailed forms on the right.

## 5. Key File Registry
- `theme.dart`: The single source of truth for "Plasma."
- `cells.dart`: Indivisible atoms.
- `tissues.dart`: Molecular functional blocks.
- `organs.dart`: Structural shells.
- `index.dart`: Central export registry and component documentation.

---

## 6. Component Registry Summary (from index.dart)

### 🦠 CELLS (Atomic)
- **Inputs**: `CellInput`, `CellCheckbox`, `CellSwitch`, `CellRadio`, `CellSlider`.
- **Interactions**: `CellButton`, `CellFilterChip`, `CellTooltip`.
- **Visuals**: `CellBadge`, `CellAvatar`, `CellSkeleton`, `CellDivider`, `CellProgressBar`, `CellKbd`.
- **Framework**: `CellLabel`.

### 🧬 TISSUES (Molecular)
- **Data Display**: `TissueCard`, `TissueListCard`, `TissuePipeline`.
- **Forms & Inputs**: `TissueFormField`, `TissueDropdown`, `TissueDatePicker`, `TissueStepper`, `TissueReadOnlyField`.
- **Navigation/Control**: `TissueTabs`, `TissuePagination`, `TissueAccordion`, `TissueMenu`.
- **Feedback**: `TissueAlert`, `TissueEmptyState`.
