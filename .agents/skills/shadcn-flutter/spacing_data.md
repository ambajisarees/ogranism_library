# Shadcn Flutter Spacing & Component Dimensions Reference

A complete spacing and size reference for all core widgets in the `shadcn_flutter` library. Use this to maintain pixel-perfect sizing, consistent grid alignment, and responsive density scaling.

---

## 1. Density Spacing & Gap Multipliers
All dynamic spacing is calculated relative to `theme.density.baseGap` (defaults to **`8.0px`**) and computed via the `DensityGap` widget:

```dart
const shad.DensityGap(shad.gapSm)
```

| Constant Name | Multiplier Value | Computed Spacing (Base 8px) | Usage Guidelines |
| :--- | :--- | :--- | :--- |
| **`gap2Xs`** (Custom) | `0.25` | **`2.0px`** | Precise vertical overlay offsets, micro-margins |
| **`gapXs`** | `0.5` | **`4.0px`** | Small items separation, label-to-input gap |
| **`gapSm`** | `1.0` | **`8.0px`** | Sibling controls spacing, chip horizontal gap |
| **`gapMd`** | `1.5` | **`12.0px`** | Content sections, menu list padding |
| **`gapLg`** | `2.0` | **`16.0px`** | Default toolbar separation, general grid gap |
| **`gapXl`** | `2.5` | **`20.0px`** | Broad component layouts |
| **`gap2xl`** | `3.0` | **`24.0px`** | Section container vertical margins |
| **`gap3xl`** | `3.5` | **`28.0px`** | Massive layout separations |
| **`gap4xl`** | `4.0` | **`32.0px`** | Page margins and large dividers |

---

## 2. Container & Content Padding Multipliers
Padding scales using multipliers of the theme's base padding:
* **Container Padding base**: `theme.density.baseContainerPadding` (defaults to **`16.0px`**)
* **Content Padding base**: `theme.density.baseContentPadding` (defaults to **`16.0px`**)

```dart
EdgeInsets.symmetric(
  horizontal: theme.density.baseContainerPadding * shad.padXs, // 8.0px
  vertical: theme.density.baseContainerPadding * shad.padX2s,  // 4.0px
)
```

| Constant Name | Multiplier Value | Computed Padding (Base 16px) | Description / Common Usage |
| :--- | :--- | :--- | :--- |
| `padX2s` | `0.25` | **`4.0px`** | Fine content padding |
| `padXs` | `0.5` | **`8.0px`** | Tight container edges |
| `padSm` | `0.75` | **`12.0px`** | Standard list row padding |
| `padMd` | `1.0` | **`16.0px`** | Base Container Padding (Card, panel walls) |
| `padLg` | `1.5` | **`24.0px`** | Cozy/spacious borders |
| `padXl` | `2.0` | **`32.0px`** | Screen-level margins |
| `pad2xl` | `2.5` | **`40.0px`** | Major section buffers |

---

## 3. Button Sizing & Densities
Buttons scale their padding, text size, and icon size via `ButtonSize` and `ButtonDensity`.

### A. Size Scaling Factors (`ButtonSize.scale`)
* **`xSmall`**: `0.5` scale
* **`small`**: `0.75` scale (used for **`Badge`** controls)
* **`normal`**: `1.0` scale (default)
* **`large`**: `2.0` scale
* **`xLarge`**: `3.0` scale

### B. Density Padding Modifiers
* **`normal`**: `100%` padding. Default padding is `horizontal: baseContentPadding` (**`16px`**), `vertical: baseGap` (**`8px`**).
* **`dense`**: `50%` padding (`horizontal: 8px`, `vertical: 4px`).
* **`compact`**: `0%` padding (`EdgeInsets.zero`).
* **`comfortable`**: `200%` padding (`horizontal: 32px`, `vertical: 16px`).
* **`icon`**: Equal padding on all sides based on the minimum padding dimension (perfect square).
* **`iconDense`**: Dense square padding (50% of the minimum side).

---

## 4. Input & Form Component Sizing

| Component Name | Default Height / Size | Property Name | Behavior / Scaling |
| :--- | :--- | :--- | :--- |
| **`shad.TextField`** | **`34.0px`** | `kTextFieldHeight` | Governed by hardcoded layout constant `kTextFieldHeight` |
| **`shad.Select`** | **`34.0px`** | Height matched | Automatically matches standard `TextField` height |
| **`shad.OutlineButton`** | **`34.0px`** | Height matched | Standard text buttons align with input height |
| **`shad.Chip`** | **`34.0px`** | Height matched | Sized to match typical text input levels |
| **`shad.Switch`** | **`36.0px`** (W) x **`20.0px`** (H) | Track sizes | Computed as `width: (32+4)*scaling`, `height: (16+4)*scaling` |
| **`shad.Checkbox`** | **`16.0px`** x **`16.0px`** | Default size | Scaled by `16 * theme.scaling` |
| **`shad.Radio`** | **`16.0px`** x **`16.0px`** | Default size | Scaled by `16 * theme.scaling`. Inner dot is `size - 8 * theme.scaling` |
| **`shad.Slider`** | **`16.0px`** (H) | Track height / Thumb | Track container is `16px` tall. Trackbar line is `6px`. Thumb size is `16px`. |

---

## 5. Overlay, Layout, & Visual Components

| Component Name | Dimension | Default Value | Scaling / Layout Details |
| :--- | :--- | :--- | :--- |
| **`shad.Card`** | Padding | **`16.0px`** | Evaluates to `EdgeInsets.all(baseContainerPadding)` |
| **`shad.Avatar`** | Diameter | **`40.0px`** | Evaluates to `40 * theme.scaling` |
| **`shad.AvatarBadge`** | Diameter | **`12.0px`** | Evaluates to `12 * theme.scaling`, offset automatically |
| **`shad.CircularProgress`** | Diameter | **`16.0px`** | Calculated as `(iconThemeData.size ?? 24) - 8 * theme.scaling` |
| **`shad.Progress`** (Linear) | Height | **`8.0px`** | Track height is `8.0 * theme.scaling` |
| **`shad.Resizable`** | Handle | **`16.0px`** (L) x **`10.0px`** (T) | Thickness is `4 * 2.5 * scaling`, length is `4 * 4 * scaling` |
| **`shad.Tooltip`** | Border Radius | `theme.radiusSm` | Rounded corners are `radiusSm` (usually `4px`) |
| **`shad.Toast`** | Constraints | Width **`320.0px`** | Constraints are fixed width of `320px`. Stacking gap is `12px` (`baseGap * 1.5`). Spacing is `8px`. |
| **`Popover Menu`** | y-Offset | **`2.0px`** | Customized relative to anchor using `baseGap * 0.25` |

---

## 6. Layout Principles
1. **Vertical Alignments**: Ensure components inside the same horizontal Row (such as Search, Select Filters, and Buttons) use standard densities to maintain uniform **`34px`** heights.
2. **Dynamic Offsets**: When launching menus/popovers, configure `alignment: Alignment.topRight` and `anchorAlignment: Alignment.bottomRight` with an offset of `Offset(0, theme.density.baseGap * 0.25)` to stack perfectly `2.0px` below components.
