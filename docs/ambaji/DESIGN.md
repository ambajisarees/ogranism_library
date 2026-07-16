# Ambaji ERP: Technical Design Manual (v220)

This document defines the professional design system for the Ambaji Saree ERP. Influenced by Supabase and Linear, it is optimized for high-density data entry on desktop and high-utility responsiveness on mobile.

## 📐 Responsive Infrastructure

### Breakpoints
- **Mobile** (< 768px): Single-column layouts, Full-screen Modals, Hamburger Drawer navigation.
- **Tablet** (768px - 1024px): 2-column grids, Condensed sidebars, 44px+ touch targets.
- **Desktop** (> 1024px): High-density 3+ column forms, Sticky sidebar, Hover-locked terminals.

---

## 🎨 Design Tokens

### The Emerald Scale (Brand)
Used for success states, active production vouchers, and primary brand presence.
| Token | Hex | Role |
| :--- | :--- | :--- |
| `emerald-50` | `#f0fdf4` | Background tints |
| `emerald-500` | `#3ecf8e` | Primary Buttons / Checkboxes |
| `emerald-700` | `#047857` | Hover / Active borders |

### The Slate Scale (Neutrals)
Used for data-rich interfaces and industrial-grade utility.
| Token | Hex | Role |
| :--- | :--- | :--- |
| `slate-50` | `#f8fafc` | Zebra-striping |
| `slate-400` | `#94a3b8` | Muted metadata |
| `slate-950` | `#020617` | High-contrast headers |

---

## 🔡 Typography: The Functional Hybrid

The system uses a strict 2-font philosophy:
1.  **Inter Variable**: Used for UI labels, titles, and prose. Optimizes for digital clarity and proportional spacing.
2.  **JetBrains Mono**: Mandated for all numerical and technical identifiers (`VNO`, `CNO`, `Mts`, `Pcs`). Ensures perfect vertical alignment in dense lists.

---

## ⚛️ Component Highlights (From the 220 Catalog)

### 1. Data Terminals (Pattern 197)
- **Feature**: Sticky headers with horizontal scrollable tracks.
- **Remix**: 12px padding by default, with an "Extreme" mode for 8px padding on office monitors.

### 2. Side Sheets (Fragment 121)
- **Feature**: Modal-hybrid that slides from the right.
- **Mobile**: Becomes a full-height bottom-sheet with a 56px header handle.

### 3. Production Wizards (Pattern 208)
- **Feature**: Stepper-bridge connecting O1 -> O3 -> O4... -> S1.
- **Logic**: Color-codes steps based on "Truly Pending" (Amber) vs "Closed" (Emerald).

---

## 🛠️ Flutter Implementation Rules

- **Client Icons**: Use Lucide or Phosphor linear icons.
- **Density**: Use `VisualDensity.compact` for all material buttons.
- **Data Tables**: Use `DataTable2` for responsive column sizing and horizontal scroll.
- **Touch**: All interactive elements MUST have a minimum hit region of 44x44 pixels.

---

## 🔗 Resources
- **Component Preview**: [preview.html](file:///c:/Users/smitt/./gemini/antigravity/scratch/textile_erp/design-md/ambaji/preview.html)
- **Supabase Original**: [Browse Documentation](https://supabase.com/design-system)
