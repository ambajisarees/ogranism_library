# Dynamic AI Component Review & Presentation Protocol

This document provides explicit instructions for AI Assistants (LLMs) on how to analyze, present, and review `dynamic_ai` components step-by-step with the user in **Ambaji Sarees ERP**.

---

## 📋 LLM Presentation Protocol (Step-by-Step Review Format)

When presenting any component from `frontend/lib/dynamic_ai/` for user review, the LLM **MUST** follow this exact structured markdown layout:

```markdown
### 🔹 Component X of 21: [WidgetName]
📁 **Path**: `frontend/lib/dynamic_ai/components/[path_to_widget].dart`

#### 🎯 Role & Purpose
* High-level architectural role in the ERP design system.

#### 🏗️ Widget Composition Hierarchy
```
OuterContainer / Wrapper
 └── InnerWidget
      └── SubWidgets
```

#### 🎨 Native Theme Tokens & Specifications
* **Surface Background**: `colors.card` / `colors.accent` / transparent
* **Border Outline**: 1.0px `colors.border` / 1.0px `colors.primary.withAlpha(153)`
* **Height & Padding**: Exact pixels with `theme.scaling` density multipliers
* **Typography**: `theme.typography.textSmall`, `theme.typography.h2`, `theme.typography.mono`

#### ⚙️ Parameters & Defaults
| Parameter | Type | Default | Description |

#### ⚡ Behavioral & State Machine
* Details on hover states, focus nullifiers, selection tinting, and zero-shift layout rules.

---

### ❓ Your Review for Component X ([WidgetName])
Are there any changes or parameter updates you would like to make to [WidgetName], or shall we proceed to Component X+1?
```

---

## 🛡️ Master Architectural Contracts to Enforce

1. **Zero-Shift MicroButton Contract**:
   - Filter MicroButtons (`Party`, `Fabric`, `Mill`, `Status`, `Date`) MUST maintain a **fixed, static label**. Labels never change on selection.
   - Badge chip is mandatory: `0` with `SecondaryBadge` and `colors.mutedForeground` text (`FontWeight.w600`) when unselected; count with `PrimaryBadge` and `FontWeight.w600` text when active.

2. **Popover Start-Alignment Contract**:
   - All filter popovers (except trailing 3-dots) align to `anchorAlignment: Alignment.bottomLeft` and `alignment: Alignment.topLeft` flush to the left edge of the trigger.

3. **Pure Native `shadcn_flutter` Strictness**:
   - Color tokens use `shad.Theme.of(context).colorScheme` (`colors.card`, `colors.border`, `colors.primary`, `colors.mutedForeground`).
   - Never wrap `shadcn_flutter` components in custom ad-hoc Material `Container` or `BoxDecoration` wrappers when native theme parameters exist.

4. **Dynamic Table Height Rule**:
   - Tables with `< 10 rows` render at natural compact minimum height (`MainAxisSize.min`).
   - Tables with `10+ rows` expand to full available screen height (`Expanded`) with smooth inner scrolling.

5. **Surface-Less Standalone Pagination**:
   - Pagination sits **outside** the table container surface in a transparent `Padding(horizontal: 12, vertical: 8)` row using native `shad.Pagination`.

6. **Automatic Hot Restart Rule**:
   - Immediately after applying any code change, execute a Hot Restart (`R`) on the active desktop process without blocking or waiting for user prompts.
