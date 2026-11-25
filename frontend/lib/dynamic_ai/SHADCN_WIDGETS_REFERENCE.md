# `shadcn_flutter` (`v0.0.55`) — Complete Categorized Widget & Token Reference

> **Purpose**: Single-source architectural reference at workspace root listing **every widget, theme class, controller, utility, and extension** exported by `package:shadcn_flutter/shadcn_flutter.dart` (`0.0.55`) alongside live usage telemetry inside `frontend/lib/` (`dynamic_ai/` + modules).
> **Import Convention**: Always alias as `import 'package:shadcn_flutter/shadcn_flutter.dart' as shad;` (or avoid `dart:ui` / Material conflicts) per `GEMINI.md`.
> **Pub Cache Source**: `C:\Users\smitt\AppData\Local\Pub\Cache\hosted\pub.dev\shadcn_flutter-0.0.55\lib\shadcn_flutter.dart`
> **Local Skill Docs**: [.agents/skills/shadcn-flutter/SKILL.md](file:///c:/Users/smitt/.gemini/antigravity/scratch/textile_erp/.agents/skills/shadcn-flutter/SKILL.md)

> [!IMPORTANT]
> **`0.0.55` Architecture Notes vs Older Docs**:
> 1. **Zero Material/Cupertino Core Dependency**: Since `0.0.54+`, `shadcn_flutter` exports patched `package:flutter/widgets.dart` (`Row`, `Column`, `Flex`, `Stack`, `Positioned` with `paintOrder`) cleanly with zero hard dependency on Material or Cupertino.
> 2. **Unified Overlay API**: Legacy `showDialog` / `showPopover` / `openDrawer` / `openSheet` helpers from older docs are unified under `showOverlay<T>(context, config, builder: ...)` (`DialogConfiguration`, `PopoverConfiguration`, `DrawerConfiguration`, `SheetConfiguration`, `MenuConfiguration`, `TooltipConfiguration`) + `closeOverlay(context)`, alongside `openDrawerOverlay`, `openSheetOverlay`, `closeDrawer`, `closeSheet`, and `showDropdown`.
> 3. **No `.asSkeleton()` in `0.0.55`**: `.agents/skills/shadcn-flutter/components/feedback/skeleton.md` documents `.asSkeleton()` from an earlier build; `0.0.55` does **not** export `SkeletonTheme` or `.asSkeleton()` (use `Progress`, `Spinner`, or native shaded placeholder containers as in `DyTable`).

---

## 1. App Root, Theme, Colors, Typography & Density

**Source Files**: `src/shadcn_app.dart`, `src/theme/{theme.dart, color_scheme.dart, generated_colors.dart, generated_themes.dart, legacy_generated_themes.dart, typography.dart, density.dart, theme_extension.dart}`

| Symbol / API | Purpose & Tokens | Theme / Companion Classes | ERP Usage (`frontend/lib/`) | Local Doc / Source |
| :--- | :--- | :--- | :--- | :--- |
| `ShadcnApp` | Root app widget (`theme`, `darkTheme`, `themeMode`, `surfaceOpacity`, `surfaceBlur`) | `ShadcnLayer`, `ShadcnUI`, `ShadcnScrollBehavior`, `ShadcnAnimatedTheme` | **1** (`main.dart`) | `src/shadcn_app.dart` |
| `Theme`, `ThemeData` | Inherited theme scope (`shad.Theme.of(context)`), `radiusMd`, `scaling`, `brightness` | `ThemeDataTween`, `AnimatedTheme`, `AdaptiveScaling`, `AdaptiveScaler`, `ThemeMode` | **155** `Theme` / **126** `ThemeData` | [theming.md](file:///c:/Users/smitt/.gemini/antigravity/scratch/textile_erp/.agents/skills/shadcn-flutter/guides/theming.md) |
| `ComponentTheme<T>` | Scoped theme override wrapper (`shad.ComponentTheme<shad.TabPaneTheme>(...)`) | `ComponentThemeData` | **5** | [theming.md](file:///c:/Users/smitt/.gemini/antigravity/scratch/textile_erp/.agents/skills/shadcn-flutter/guides/theming.md) |
| `ColorScheme`, `ColorSchemes` | Semantic palette (`background`, `card`, `border`, `primary`, `muted`, `destructive`, etc.) + presets (`lightSlate.teal`, `darkStone.amber`) | `ColorShades`, `Colors` (Tailwind scales), `ChartColorScheme`, `SingleChartColorScheme`, `LegacyColorSchemes` | **122** `ColorScheme` / **30** `Colors` | [colors.md](file:///c:/Users/smitt/.gemini/antigravity/scratch/textile_erp/.agents/skills/shadcn-flutter/guides/colors.md) |
| `Typography` | `Typography.geist(...)` scale: `sans`, `mono`, `xSmall`..`x9Large`, `h1`..`h4`, `p`, `lead`, `large`, `small`, `muted` | `IconThemeProperties` | **20** | [typography.md](file:///c:/Users/smitt/.gemini/antigravity/scratch/textile_erp/.agents/skills/shadcn-flutter/guides/typography.md) |
| `Density` | Presets: `defaultDensity` (16/8/16), `reducedDensity` (12/6/12), `compactDensity` (8/4/8), `spaciousDensity` (20/10/20) | Constants: `padX2s`..`pad4xl`, `gapXs`..`gap4xl`, `EdgeInsetsDensity`, `DirectionalEdgeInsetsDensity` | Used via `theme.density` & `shad.gap*` (**730+**) | `src/theme/density.dart` |
| `DensityGap` | Scaled spacing gap inside Flex/Column/Row (`DensityGap(shad.gapSm)`) | `DensityContainerPadding`, `DensityContentPadding`, `DensityRow`, `DensityColumn`, `DensityFlex`, `DensityWrap` | **805** (`DensityGap`) | `src/theme/density.dart` |

---

## 2. Buttons, Toggles & Interactive Controls

**Source Files**: `src/components/control/{button.dart, clickable.dart, command.dart, hover.dart, scrollbar.dart, scrollview.dart}`

| Widget / Symbol | Description & Variants | Theme / Controller / Helpers | ERP Usage (`frontend/lib/`) | Local Doc / Source |
| :--- | :--- | :--- | :--- | :--- |
| `PrimaryButton`, `SecondaryButton`, `OutlineButton`, `GhostButton`, `DestructiveButton`, `LinkButton`, `TextButton` | Semantic styled action buttons supporting `size: ButtonSize`, `density: ButtonDensity` | `Button`, `CardButton`, `TabButton`, `IconButton`, `ButtonStyle`, `AbstractButtonStyle`, `ButtonVariance`, `ButtonStyleOverride`, `FocusToFront`, `*ButtonTheme` | `OutlineButton` **127**, `PrimaryButton` **85**, `IconButton` **44**, `GhostButton` **38**, `Button` **19**, `SecondaryButton` **12**, `DestructiveButton` **5** | [button.md](file:///c:/Users/smitt/.gemini/antigravity/scratch/textile_erp/.agents/skills/shadcn-flutter/components/control/button.md) |
| `ButtonGroup` | Joins child buttons seamlessly with shared outer radius & inner dividers | `ButtonGroupFlexible`, `ButtonGroupItem`, `ButtonGroupData` | **3** (`dy_action_bar`, `dy_page_header`, `dab_group_switcher`) | [button.md](file:///c:/Users/smitt/.gemini/antigravity/scratch/textile_erp/.agents/skills/shadcn-flutter/components/control/button.md) |
| `SelectedButton`, `Toggle` | Stateful/controlled toggleable selection buttons | `ControlledToggle`, `ToggleController`, `ToggleState`, `SelectedButtonState` | `SelectedButton` **3** (`Toggle`: **0**) | `src/components/control/button.dart` |
| `Clickable`, `Hover` | Low-level hover/focus/press interaction surface & visual feedback wrapper | `WidgetStatesProvider`, `WidgetStatesData`, `StatedWidget`, `HoverTheme`, `HoverActivity`, `OverflowDecoratedBox` | **0** *(Custom `MouseRegion`+`GestureDetector` used in `dy_*` cards)* | `src/components/control/clickable.dart` |
| `Command`, `showCommandDialog` | Built-in `Ctrl+K` searchable command palette list & dialog launcher | `CommandCategory`, `CommandItem`, `CommandEmpty` | **0** *(App uses custom command palette in workspace)* | [command.md](file:///c:/Users/smitt/.gemini/antigravity/scratch/textile_erp/.agents/skills/shadcn-flutter/components/utility/command.md) |
| `Scrollbar`, `ScrollViewInterceptor` | Styled desktop scrollbars & wheel-scroll pointer interceptors | `ScrollbarTheme`, `DesktopPointerScrollEvent` | **0** | `src/components/control/scrollbar.dart` |

---

## 3. Layout, Containers, Splitters & Desktop Windows

**Source Files**: `src/components/layout/{scaffold.dart, card.dart, card_image.dart, outlined_container.dart, resizable.dart, flex.dart, stage_container.dart, media_query.dart, hidden.dart, group.dart, basic.dart, icon.dart, focus_outline.dart, scrollable.dart, scrollable_client.dart, overflow_marquee.dart, window.dart}`

| Widget / Symbol | Description & Role | Theme / Controller / Helpers | ERP Usage (`frontend/lib/`) | Local Doc / Source |
| :--- | :--- | :--- | :--- | :--- |
| `Scaffold`, `AppBar` | Structural header/body/footer shell with loading & resize support | `ScaffoldTheme`, `ScaffoldBarData`, `ScaffoldHeaderPadding`, `ScaffoldFooterPadding` | **4** (`home.dart`, mobile prototypes) | [scaffold.md](file:///c:/Users/smitt/.gemini/antigravity/scratch/textile_erp/.agents/skills/shadcn-flutter/components/layout/scaffold.md) |
| `Card`, `SurfaceCard` | Elevated bordered panel (`Card`) and frosted/translucent surface (`SurfaceCard`) | `CardTheme` | `Card` **82**, `SurfaceCard` **7** | [card.md](file:///c:/Users/smitt/.gemini/antigravity/scratch/textile_erp/.agents/skills/shadcn-flutter/components/layout/card.md) |
| `CardImage` | Media preview card with aspect container & hover/overlay affordance | `CardImageTheme` | **0** *(Candidate for `DyGridCard` / `Masters -> Designs`)* | [card_image.md](file:///c:/Users/smitt/.gemini/antigravity/scratch/textile_erp/.agents/skills/shadcn-flutter/components/layout/card_image.md) |
| `OutlinedContainer` | Styled box surface with `backgroundColor`, `borderColor`, `borderRadius`, `SurfaceBlur` | `OutlinedContainerTheme`, `DashedContainer`, `DashedLine` | **147** (`OutlinedContainer`), **17** (`OutlinedContainerTheme`) | `src/components/layout/outlined_container.dart` |
| `ResizablePane`, `ResizablePanel` | Split multi-pane layouts with interactive draggable dividers | `HorizontalResizableDragger`, `VerticalResizableDragger`, `AbsoluteResizablePaneController`, `FlexibleResizablePaneController`, `ResizableDraggerTheme` | **0** *(High-value candidate for `DyListPane` / `DyCardPane` splits)* | [resizable.md](file:///c:/Users/smitt/.gemini/antigravity/scratch/textile_erp/.agents/skills/shadcn-flutter/components/layout/resizable.md) |
| `Row`, `Column`, `Flex`, `Stack`, `Positioned` | Patched Flutter flex/stack adding `PaintOrder` control | `Flexible`, `Expanded`, `PaintOrder` | Exported everywhere via `shad.*` | [layout.md](file:///c:/Users/smitt/.gemini/antigravity/scratch/textile_erp/.agents/skills/shadcn-flutter/guides/layout.md) |
| `StageContainer`, `MediaQueryVisibility`, `Hidden` | Breakpoint-responsive max-width container & conditional breakpoint visibility | `StageBreakpoint`, `ConstantBreakpoint`, `StagedBreakpoint`, `StageContainerTheme`, `MediaQueryVisibilityTheme`, `HiddenTheme` | **0** *(Candidate for Desktop/Tablet/Mobile layout engine)* | `src/components/layout/stage_container.dart` |
| `Basic`, `Label`, `IconContainer` | Standard Leading / Title / Subtitle / Content / Trailing layout primitive + form label | `BasicTheme`, `BasicLayout`, `IconContainerTheme` | `Label` **1** (`Basic`: **0**) | `src/components/layout/basic.dart` |
| `FocusOutline` | Local focus ring painter anchored cleanly during animations/overlays | `FocusOutlineTheme` | **1** (`main.dart` theme contract) | `src/components/layout/focus_outline.dart` |
| `GroupWidget`, `GroupPositioned` | Relative coordinate group container | `RenderGroup`, `GroupParentData` | **0** | `src/components/layout/group.dart` |
| `ScrollableClient`, `FadedScrollableViewport`, `OverflowMarquee` | Viewport with edge fade gradients & auto-scrolling ticker text for tight labels | `ScrollableClientTheme`, `OverflowMarqueeTheme` | **0** | [overflow_marquee.md](file:///c:/Users/smitt/.gemini/antigravity/scratch/textile_erp/.agents/skills/shadcn-flutter/components/utility/overflow_marquee.md) |
| `Window`, `WindowNavigator`, `WindowViewport` | Draggable/snappable MDI floating sub-windows inside desktop workspace | `WindowController`, `WindowWidget`, `WindowActions`, `WindowSnapStrategy`, `WindowTheme` | **0** | [window.md](file:///c:/Users/smitt/.gemini/antigravity/scratch/textile_erp/.agents/skills/shadcn-flutter/components/overlay/window.md) |

---

## 4. Disclosure, Trees, Steppers, Sortables & Timelines

**Source Files**: `src/components/layout/{accordion.dart, collapsible.dart, tree.dart, stepper.dart, steps.dart, timeline.dart, sortable.dart}` + `src/components/form/sortable.dart`

| Widget / Symbol | Description & Role | Supporting Types & Theme | ERP Usage (`frontend/lib/`) | Local Doc / Source |
| :--- | :--- | :--- | :--- | :--- |
| `Accordion`, `AccordionItem`, `AccordionTrigger` | Vertically expandable multi-section disclosure groups | `AccordionState`, `AccordionTheme` | **0** *(Candidate for Inspector / GST detail drawers)* | [accordion.md](file:///c:/Users/smitt/.gemini/antigravity/scratch/textile_erp/.agents/skills/shadcn-flutter/components/disclosure/accordion.md) |
| `Collapsible`, `CollapsibleTrigger`, `CollapsibleContent` | Single expand/collapse disclosure container | `CollapsibleState`, `CollapsibleStateData`, `CollapsibleTheme` | **0** | [collapsible.md](file:///c:/Users/smitt/.gemini/antigravity/scratch/textile_erp/.agents/skills/shadcn-flutter/components/disclosure/collapsible.md) |
| `Tree`, `TreeItem` | Hierarchical expandable node tree with keyboard selection & indent lines | `TreeNode`, `TreeItemNode`, `TreeRootNode`, `BranchLine`, `IndentGuideLine`, `IndentGuidePath`, `TreeTheme` | **0** *(Candidate for `Masters -> Groups`, Account Chart, Multi-level Categories)* | [tree.md](file:///c:/Users/smitt/.gemini/antigravity/scratch/textile_erp/.agents/skills/shadcn-flutter/components/navigation/tree.md) |
| `Stepper`, `Steps` | Guided multi-step workflows (`Stepper`) and static numbered step lists (`Steps`) | `StepperController`, `StepperValue`, `Step`, `StepNumber`, `StepTitle`, `StepContainer`, `StepItem`, `StepperTheme`, `StepsTheme` | **0** *(Candidate for GSTIN Onboarding & Textile Production Stage tracking)* | [stepper.md](file:///c:/Users/smitt/.gemini/antigravity/scratch/textile_erp/.agents/skills/shadcn-flutter/components/layout/stepper.md) |
| `Timeline` | Vertical chronological event/audit trail with semantic step dots | `TimelineData`, `TimelineTheme` | **0** *(Candidate for Dispatch / Voucher / Taka Pipeline History)* | [timeline.md](file:///c:/Users/smitt/.gemini/antigravity/scratch/textile_erp/.agents/skills/shadcn-flutter/components/layout/timeline.md) |
| `Sortable`, `SortableLayer`, `RawSortableList` | Drag-and-drop item reordering with drag handles and fallback drop zones | `ScrollableSortableLayer`, `SortableDragHandle`, `SortableDropFallback`, `SortableData`, `ListChanges` | **0** *(Candidate for Kanban board dragging & Group Level ordering)* | [sortable.md](file:///c:/Users/smitt/.gemini/antigravity/scratch/textile_erp/.agents/skills/shadcn-flutter/components/layout/sortable.md) |

---

## 5. Tables & Data Grids

**Source File**: `src/components/layout/table.dart`

| Widget / Symbol | Description & Role | Supporting Types & Theme | ERP Usage (`frontend/lib/`) | Local Doc / Source |
| :--- | :--- | :--- | :--- | :--- |
| `Table` | High-control grid layout with `TableHeader`, `TableRow`, `TableFooter`, `TableCell`, frozen cells | `TableRef`, `FrozenTableData`, `ConstrainedTableSize`, `TableTheme`, `TableCellTheme` | **0** *(Currently `dynamic_ai/page/dy_table.dart` uses custom `Row`+`ListView.builder`)* | [table.md](file:///c:/Users/smitt/.gemini/antigravity/scratch/textile_erp/.agents/skills/shadcn-flutter/components/display/table.md) |
| `ResizableTable` | Native interactive column-resizable & row-resizable table backed by controller | `ResizableTableController`, `ResizableTableTheme` | **0** *(Major candidate to evaluate for `DyTable` column resize support)* | [table.md](file:///c:/Users/smitt/.gemini/antigravity/scratch/textile_erp/.agents/skills/shadcn-flutter/components/display/table.md) |

---

## 6. Navigation, Tabs, Sidebars & Pagination

**Source Files**: `src/components/navigation/` (`navigation_bar/`, `tabs/`, `pagination.dart`, `switcher.dart`, `subfocus.dart`, `page_route.dart`) + `src/components/layout/breadcrumb.dart`

| Widget / Symbol | Description & Role | Supporting Types & Theme | ERP Usage (`frontend/lib/`) | Local Doc / Source |
| :--- | :--- | :--- | :--- | :--- |
| `NavigationSidebar`, `NavigationRail`, `NavigationBar` | Responsive vertical collapsible sidebar (`240px`), icon rail (`56px`), and bottom bar (mobile) | `NavigationItem`, `NavigationButton`, `AbstractNavigationButton`, `NavigationCollapsible`, `NavigationGroup`, `NavigationLabeled`, `NavigationDivider`, `NavigationGap`, `NavigationSlot`, `NavigationBarTheme`, `NavigationLabelType/Size/Position` | `NavigationItem` **4**, `NavigationRail` **3**, `NavigationDivider` **1** | `src/components/navigation/navigation_bar/` |
| `TabPane`, `Tabs`, `TabList`, `TabContainer` | Browser-style closable/reorderable workspace tabs (`TabPane`) & pill tab strip (`Tabs`) | `TabPaneData`, `TabItem`, `KeyedTabItem`, `TabChildWidget`, `TabPaneTheme`, `TabsTheme`, `TabListTheme`, `TabContainerTheme` | `TabItem` **7**, `TabPane` **4**, `Tabs` **2**, `TabPaneData` **2** | [tab_pane.md](file:///c:/Users/smitt/.gemini/antigravity/scratch/textile_erp/.agents/skills/shadcn-flutter/components/navigation/tab_pane.md) |
| `Breadcrumb` | Hierarchical path trail (`Masters / Parties / Detail`) | `BreadcrumbTheme` | **0** *(Currently `PageHeader` implements custom breadcrumb row)* | [breadcrumb.md](file:///c:/Users/smitt/.gemini/antigravity/scratch/textile_erp/.agents/skills/shadcn-flutter/components/navigation/breadcrumb.md) |
| `Pagination` | Page index buttons with prev/next/ellipsis truncation | `PaginationTheme` | **2** (`dy_pagination_row.dart`) | [pagination.md](file:///c:/Users/smitt/.gemini/antigravity/scratch/textile_erp/.agents/skills/shadcn-flutter/components/navigation/pagination.md) |
| `Switcher`, `SubFocusScope`, `ShadcnPageRoute` | Animated directional content switcher, roving keyboard sub-focus, and page routes | `SubFocus`, `ShadcnPageTransition`, `ShadcnPage` | **0** | [switcher.md](file:///c:/Users/smitt/.gemini/antigravity/scratch/textile_erp/.agents/skills/shadcn-flutter/components/navigation/switcher.md) |

---

## 7. Menus, Context Menus & Menubars

**Source Files**: `src/components/menu/{menu.dart, popup.dart, dropdown_menu.dart, context_menu.dart, menubar.dart, navigation_menu.dart, spell_check_suggestions_toolbar.dart}`

| Widget / Symbol | Description & Role | Supporting Types & Theme | ERP Usage (`frontend/lib/`) | Local Doc / Source |
| :--- | :--- | :--- | :--- | :--- |
| `MenuPopup` | Floating styled menu surface for items, checkboxes, radio groups, and submenus | `MenuPopupTheme`, `MenuGroup`, `MenuButton`, `MenuCheckbox`, `MenuRadioGroup`, `MenuRadio`, `MenuDivider`, `MenuLabel`, `MenuShortcut`, `MenuGap`, `MenuTheme` | **3** (`sidebar_nav_flyout.dart`, `home_popovers.dart`) | `src/components/menu/popup.dart` |
| `DropdownMenu`, `showDropdown` | Triggered dropdown action menu with keyboard focus intents (`CloseMenuIntent`, `OpenSubMenuIntent`) | `DropdownMenuTheme`, `DropdownMenuData` | **0** | [dropdown_menu.md](file:///c:/Users/smitt/.gemini/antigravity/scratch/textile_erp/.agents/skills/shadcn-flutter/components/utility/dropdown_menu.md) |
| `ContextMenu`, `ContextMenuPopup` | Right-click / long-press desktop & mobile context menu wrapper | `ContextMenuTheme`, `DesktopEditableTextContextMenu`, `MobileEditableTextContextMenu`, `SpellCheckSuggestionsToolbar` | **0** *(High-value candidate for `DyTableDefRow` & Kanban right-click menus)* | [context_menu.md](file:///c:/Users/smitt/.gemini/antigravity/scratch/textile_erp/.agents/skills/shadcn-flutter/components/utility/context_menu.md) |
| `Menubar`, `NavigationMenu` | Desktop File/Edit/View top menubar (`Menubar`) & multi-panel hover dropdown nav (`NavigationMenu`) | `MenubarTheme`, `NavigationMenuTheme`, `NavigationMenuItem`, `NavigationMenuContent` | **0** | [menubar.md](file:///c:/Users/smitt/.gemini/antigravity/scratch/textile_erp/.agents/skills/shadcn-flutter/components/navigation/menubar.md) |

---

## 8. Form Controls, Inputs, Validation & Pickers

**Source Files**: `src/components/form/` (`form.dart`, `form_field.dart`, `validated.dart`, `control.dart`, `text_field.dart`, `text_area.dart`, `input.dart`, `formatted_input.dart`, `formatter.dart`, `autocomplete.dart`, `select.dart`, `checkbox.dart`, `switch.dart`, `radio_group.dart`, `slider.dart`, `chip_input.dart`, `input_otp.dart`, `date_picker.dart`, `time_picker.dart`, `object_input.dart`, `phone_input.dart`, `item_picker.dart`, `multiple_choice.dart`, `star_rating.dart`, `file_picker.dart`, `file_input.dart`, `color/`)

| Widget / Symbol | Description & Role | Controllers, Features & Validators | ERP Usage (`frontend/lib/`) | Local Doc / Source |
| :--- | :--- | :--- | :--- | :--- |
| `Form`, `FormField`, `SubmitButton` | Typed reactive form container with inline/table layouts & declarative validators | `FormController`, `FormKey`, `FormInline`, `FormTableLayout`, `ObjectFormField`, `Validated`, `Validator` (`NotEmpty`, `Length`, `Range`, `Regex`, `Email`, `URL`, `CompareWith`, `Composite`, `SafePassword`) | `Form` **1** | [form.md](file:///c:/Users/smitt/.gemini/antigravity/scratch/textile_erp/.agents/skills/shadcn-flutter/components/form/form.md) |
| `TextField`, `TextArea`, `InputFeature` | Single & multi-line text inputs with pluggable features (`leading`, `trailing`, `clear`, `hint`, `passwordToggle`, `copy`, `paste`, `spinner`, `stepperButton`, `autoComplete`, `revalidate`, `above`, `below`) | `TextFieldTheme`, `InputFeatureVisibility`, `TextInputStatefulWidget` | `TextField` **103**, `InputFeature` **20** | [input.md](file:///c:/Users/smitt/.gemini/antigravity/scratch/textile_erp/.agents/skills/shadcn-flutter/components/form/input.md) |
| `FormattedInput`, `FormattedObjectInput` | Structured segmented inputs (GSTIN, HSN, Date, Pincode masks) | `FormattedInputController`, `EditablePart`, `StaticPart`, `TextInputFormatters`, `FormattedInputTheme` | **0** *(Strong candidate for 15-char GSTIN & 6-digit Pincode entry)* | [formatted_input.md](file:///c:/Users/smitt/.gemini/antigravity/scratch/textile_erp/.agents/skills/shadcn-flutter/components/form/formatted_input.md) |
| `AutoComplete` | Keyboard-navigable suggestion popup bound directly to text input | `AutoCompleteTheme`, `AutoCompleteIntent`, `NavigateSuggestionIntent`, `AcceptSuggestionIntent` | **0** *(Currently modules implement custom overlays for Mill/Party lookup)* | [autocomplete.md](file:///c:/Users/smitt/.gemini/antigravity/scratch/textile_erp/.agents/skills/shadcn-flutter/components/form/autocomplete.md) |
| `Select`, `MultiSelect` | Searchable single-select & multi-chip dropdown selectors | `ControlledSelect`, `SelectController`, `ControlledMultiSelect`, `MultiSelectController`, `SelectPopup`, `SelectItemList`, `SelectItemButton`, `SelectGroup`, `SelectLabel`, `MultiSelectChip`, `SelectTheme` | `Select` **12**, `SelectPopup` **10**, `SelectItemList` **10**, `SelectItemButton` **12** | [select.md](file:///c:/Users/smitt/.gemini/antigravity/scratch/textile_erp/.agents/skills/shadcn-flutter/components/form/select.md) |
| `Checkbox`, `Switch`, `RadioGroup`, `RadioCard` | Boolean, tri-state, and exclusive choice controls (including card-style radios) | `ControlledCheckbox`, `CheckboxState`, `ControlledSwitch`, `ControlledRadioGroup`, `Radio`, `RadioItem`, `RadioCardTheme`, `*Theme` | `Checkbox` **24**, `CheckboxState` **62** | [checkbox.md](file:///c:/Users/smitt/.gemini/antigravity/scratch/textile_erp/.agents/skills/shadcn-flutter/components/form/checkbox.md) |
| `Slider` | Continuous & range value slider (`SliderValue`) | `ControlledSlider`, `SliderController`, `SliderTheme` | `Slider` **2** (`dab_slider_pop.dart`) | [slider.md](file:///c:/Users/smitt/.gemini/antigravity/scratch/textile_erp/.agents/skills/shadcn-flutter/components/form/slider.md) |
| `ChipInput<T>` | Tag/token pill input box with suggestion support & clipboard serialization | `ChipEditingController`, `ChipSpan`, `ChipInputTheme` | **0** *(Candidate for multi-HSN / design color tag inputs)* | [chip_input.md](file:///c:/Users/smitt/.gemini/antigravity/scratch/textile_erp/.agents/skills/shadcn-flutter/components/form/chip_input.md) |
| `InputOTP` | Multi-box verification code input | `InputOTPTheme`, `CharacterInputOTPChild`, `OTPSeparator` | **0** | [input_otp.md](file:///c:/Users/smitt/.gemini/antigravity/scratch/textile_erp/.agents/skills/shadcn-flutter/components/form/input_otp.md) |
| `DatePicker`, `DateRangePicker`, `TimePicker`, `DurationPicker` | Full date/range/time/duration input buttons backed by `Calendar` & `object_input.dart` | `ControlledDatePicker`, `DateInput`, `TimeInput`, `DurationInput`, `DateTimeRange`, `TimeRange` | **0** *(Currently using custom `dab_date_pop` / `Calendar`)* | [date_picker.md](file:///c:/Users/smitt/.gemini/antigravity/scratch/textile_erp/.agents/skills/shadcn-flutter/components/form/date_picker.md) |
| `PhoneInput` | Country-code selector + phone mask backed by bundled `Countries` data | `PhoneNumber`, `PhoneInputTheme` | **0** *(Candidate for `Masters -> Contacts` mobile entry)* | [phone_input.md](file:///c:/Users/smitt/.gemini/antigravity/scratch/textile_erp/.agents/skills/shadcn-flutter/components/form/phone_input.md) |
| `ItemPicker`, `showItemPicker` | Modal/grid/list arbitrary object picker dialog | `ListItemPickerLayout`, `GridItemPickerLayout`, `ItemPickerDialog`, `ItemPickerOption` | **0** | [item_picker.md](file:///c:/Users/smitt/.gemini/antigravity/scratch/textile_erp/.agents/skills/shadcn-flutter/components/form/item_picker.md) |
| `MultipleChoice`, `MultipleAnswer`, `StarRating` | Exclusive/multi-choice chip selectors & 5-star ratings | `ControlledMultipleChoice`, `ControlledMultipleAnswer`, `ControlledStarRating`, `StarRatingTheme` | **0** | [star_rating.md](file:///c:/Users/smitt/.gemini/antigravity/scratch/textile_erp/.agents/skills/shadcn-flutter/components/form/star_rating.md) |
| `ColorPicker`, `ColorInput`, `EyeDropperLayer` | Full HSV/HSL/Alpha picker, swatch history grid & screen eyedropper | `ControlledColorInput`, `ColorHistoryGrid`, `HSLColorSlider`, `HSVColorSlider`, `pickColorFromScreen` | **0** *(Candidate for Saree Dyeing Shade Master)* | [color_picker.md](file:///c:/Users/smitt/.gemini/antigravity/scratch/textile_erp/.agents/skills/shadcn-flutter/components/form/color_picker.md) |
| `FilePicker` *(shadcn)*, `FileItem` | UI dropzone/item list widget *(distinct from native OS `file_picker` plugin)* | `FileIconProvider`, `FileIconProviderData` | **0** | `src/components/form/file_picker.dart` |

---

## 9. Display, Badges, Calendars, Media & Status Visuals

**Source Files**: `src/components/display/` (`badge.dart`, `chip.dart`, `avatar.dart`, `calendar.dart`, `carousel.dart`, `dot_indicator.dart`, `divider.dart`, `code_snippet.dart`, `keyboard_shortcut.dart`, `number_ticker.dart`, `chat.dart`, `pinned_sheet.dart`, `country_flag.dart`, `fade_scroll.dart`) + `src/components/chart/tracker.dart`

| Widget / Symbol | Description & Role | Supporting Types & Theme | ERP Usage (`frontend/lib/`) | Local Doc / Source |
| :--- | :--- | :--- | :--- | :--- |
| `PrimaryBadge`, `SecondaryBadge`, `OutlineBadge`, `DestructiveBadge` | Compact status/metric pills *(wrap in focus isolation inside interactive cards per Rule 8)* | `BadgeTheme` | `SecondaryBadge` **74**, `PrimaryBadge` **58**, `OutlineBadge` **34**, `DestructiveBadge` **7** | [badge.md](file:///c:/Users/smitt/.gemini/antigravity/scratch/textile_erp/.agents/skills/shadcn-flutter/components/utility/badge.md) |
| `Chip`, `ChipButton` | Interactive tag chips with leading/trailing close icons | `ChipTheme` | `Chip` **1** | [chip.md](file:///c:/Users/smitt/.gemini/antigravity/scratch/textile_erp/.agents/skills/shadcn-flutter/components/utility/chip.md) |
| `Avatar`, `AvatarGroup`, `AvatarBadge` | Monogram initials / image user avatars & stacked overlaps | `AvatarTheme`, `AvatarWidget`, `AvatarGroupClipper` | **0** *(Currently header/party initials use custom containers)* | [avatar.md](file:///c:/Users/smitt/.gemini/antigravity/scratch/textile_erp/.agents/skills/shadcn-flutter/components/display/avatar.md) |
| `Calendar`, `MonthCalendar`, `YearCalendar` | Interactive single/range/multi-date calendar grid & dialog | `CalendarValue` (`Single/Range/Multi`), `CalendarView`, `DatePickerDialog`, `CalendarTheme` | `Calendar` **4**, `CalendarValue` **16**, `CalendarView` **3** | [calendar.md](file:///c:/Users/smitt/.gemini/antigravity/scratch/textile_erp/.agents/skills/shadcn-flutter/components/utility/calendar.md) |
| `Carousel`, `DotIndicator` | Animated sliding/fading multi-item showcase + dot pagination | `CarouselController`, `CarouselDotIndicator`, `CarouselSizeConstraint`, `CarouselTheme`, `DotIndicatorTheme` | **0** *(Could power `Masters -> Media` & Saree Design galleries)* | [carousel.md](file:///c:/Users/smitt/.gemini/antigravity/scratch/textile_erp/.agents/skills/shadcn-flutter/components/layout/carousel.md) |
| `Divider`, `VerticalDivider` | Tokenized horizontal & vertical hairlines (`colors.border`) | `DividerTheme`, `DividerProperties` | **45** (`Divider`) | [divider.md](file:///c:/Users/smitt/.gemini/antigravity/scratch/textile_erp/.agents/skills/shadcn-flutter/components/layout/divider.md) |
| `CodeSnippet` | Syntax-box container with built-in copy button | `CodeSnippetTheme` | **0** *(Candidate for Raw GSTIN JSON inspector & `Demo [D]` spec snippets)* | [code_snippet.md](file:///c:/Users/smitt/.gemini/antigravity/scratch/textile_erp/.agents/skills/shadcn-flutter/components/display/code_snippet.md) |
| `KeyboardDisplay`, `KeyboardKeyDisplay` | Renders OS-styled shortcut keycaps (`Ctrl` + `K`, `Alt` + `1`) from `LogicalKeyboardKey` / `ShortcutActivator` | `KeyboardShortcutTheme`, `KeyboardShortcutDisplayHandle`, `KeyboardShortcutDisplayMapper` | **0** *(Major candidate to replace manual shortcut keycap badges)* | `src/components/display/keyboard_shortcut.dart` |
| `NumberTicker`, `TextFlipper` | Rolling odometer numeric flip animation for live KPI updates | `NumberTickerTheme`, `FlipperCharset`, `FlipperCharacter` | **0** *(Strong candidate for `DyKpiMetricCard` live totals)* | [number_ticker.md](file:///c:/Users/smitt/.gemini/antigravity/scratch/textile_erp/.agents/skills/shadcn-flutter/components/animation/number_ticker.md) |
| `Tracker` | Color-coded SLA / uptime / daily dispatch segmented status strip | `TrackerData`, `TrackerLevel`, `TrackerTheme` | **0** *(Ideal for Mill SLA / 30-day dispatch health bars)* | [tracker.md](file:///c:/Users/smitt/.gemini/antigravity/scratch/textile_erp/.agents/skills/shadcn-flutter/components/display/tracker.md) |
| `ChatGroup`, `ChatBubble`, `ChatReaction` | Native threaded message bubbles & emoji reactions | `ChatConstrainedBox`, `ChatBubbleType`, `ChatCollapsible`, `ChatTheme` | **0** | [chat.md](file:///c:/Users/smitt/.gemini/antigravity/scratch/textile_erp/.agents/skills/shadcn-flutter/components/display/chat.md) |
| `PinnedSheet`, `CountryFlag`, `FadeScroll` | Persistent multi-stage peek/expand bottom sheet (`PinnedSheet`), SVG/flag helper, & edge fade scroller | `SheetController`, `SheetStage` (`Closed`, `Expanded`, `Fixed`, `Fraction`, `PeekDragHandle`), `CountryFlagTheme`, `FadeScrollTheme` | **0** *(Mobile floor upload/inspector candidate)* | `src/components/display/pinned_sheet.dart` |

---

## 10. Feedback, Alerts & Progress

**Source Files**: `src/components/layout/{alert.dart, dialog/alert_dialog.dart}` + `src/components/display/{progress.dart, linear_progress_indicator.dart, circular_progress_indicator.dart, spinner.dart}` + `src/components/overlay/toast.dart`

| Widget / Symbol | Description & Role | Supporting Types & Theme | ERP Usage (`frontend/lib/`) | Local Doc / Source |
| :--- | :--- | :--- | :--- | :--- |
| `Alert`, `AlertDialog` | Inline callout banners (`destructive: false/true`, leading/title/content) & modal confirmations | `AlertTheme` | `Alert` **4**, `AlertDialog` **3** | [alert.md](file:///c:/Users/smitt/.gemini/antigravity/scratch/textile_erp/.agents/skills/shadcn-flutter/components/feedback/alert.md) |
| `Progress`, `LinearProgressIndicator`, `CircularProgressIndicator`, `Spinner` | Determinate & indeterminate progress bars/rings + subtle rotating spinner | `ProgressTheme`, `LinearProgressIndicatorTheme`, `CircularProgressIndicatorTheme`, `SpinnerTheme` | `CircularProgressIndicator` **27**, `LinearProgressIndicator` **12**, `Progress` **2** | [progress.md](file:///c:/Users/smitt/.gemini/antigravity/scratch/textile_erp/.agents/skills/shadcn-flutter/components/feedback/progress.md) |
| `showToast`, `ToastLayer` | Non-blocking stacked notification toasts (`ToastLocation.bottomRight`, etc.) | `ToastTheme`, `ToastOverlay`, `ToastEntry` | `showToast` **32** | [toast.md](file:///c:/Users/smitt/.gemini/antigravity/scratch/textile_erp/.agents/skills/shadcn-flutter/components/feedback/toast.md) |

---

## 11. Overlays, Modals, Sheets, Drawers, Popovers & Tooltips

**Source Files**: `src/components/overlay/{overlay.dart, overlay_configuration.dart, dialog.dart, drawer.dart, drawer_container.dart, popover.dart, hover_card.dart, tooltip.dart, swiper.dart, refresh_trigger.dart, anchor.dart, backdrop_transform.dart}`

| API / Widget | Description & Role | Configuration / Helpers | ERP Usage (`frontend/lib/`) | Local Doc / Source |
| :--- | :--- | :--- | :--- | :--- |
| `showOverlay<T>`, `closeOverlay` | Unified overlay launcher taking typed `OverlayConfiguration` | `PopoverConfiguration`, `DialogConfiguration`, `DrawerConfiguration`, `SheetConfiguration`, `MenuConfiguration`, `TooltipConfiguration`, `OverlayController`, `OverlayCompleter` | `showOverlay` **40**, `closeOverlay` **33**, `PopoverConfiguration` **23**, `DialogConfiguration` **12** | `src/components/overlay/overlay_configuration.dart` |
| `ModalBackdrop`, `ModalContainer` | Modal backdrop dim/blur & framed dialog content container | `DialogRoute`, `SurfaceBarrierPainter`, `ModalBackdropTheme` | `ModalContainer` **8** | [dialog.md](file:///c:/Users/smitt/.gemini/antigravity/scratch/textile_erp/.agents/skills/shadcn-flutter/components/overlay/dialog.md) |
| `openDrawerOverlay`, `openSheetOverlay`, `closeDrawer`, `closeSheet` | Slide-in side drawers & mobile bottom sheets with drag/backdrop transform | `DrawerOverlay`, `DrawerContainer`, `SheetContainer`, `DrawerWrapper`, `SheetWrapper`, `AxisSize` (`Fixed`, `Fraction`, etc.), `BackdropTransform`, `DrawerTheme` | `openSheetOverlay` **1**, `closeSheet` **1** | [drawer.md](file:///c:/Users/smitt/.gemini/antigravity/scratch/textile_erp/.agents/skills/shadcn-flutter/components/overlay/drawer.md) |
| `HoverCard` | Rich preview card shown smoothly on pointer hover | `HoverCardTheme` | **0** *(Strong candidate for quick Party/Design/Bill hover previews in `DyTable`)* | [hover_card.md](file:///c:/Users/smitt/.gemini/antigravity/scratch/textile_erp/.agents/skills/shadcn-flutter/components/overlay/hover_card.md) |
| `Tooltip`, `InstantTooltip`, `TooltipContainer` | Delayed or instant hover hint overlay | `TooltipTheme` | `Tooltip` **3**, `TooltipContainer` **3**, `TooltipTheme` **2** | [tooltip.md](file:///c:/Users/smitt/.gemini/antigravity/scratch/textile_erp/.agents/skills/shadcn-flutter/components/overlay/tooltip.md) |
| `Swiper`, `RefreshTrigger` | Touch edge-swipe drawer/sheet gesture opener (`Swiper`) + pull-to-refresh (`RefreshTrigger`) | `DrawerSwiperHandler`, `SheetSwiperHandler`, `SwiperTheme`, `DefaultRefreshIndicator`, `RefreshTriggerTheme` | **0** *(Essential for `Samsung S26 Ultra` Mobile Floor gestures)* | [swiper.md](file:///c:/Users/smitt/.gemini/antigravity/scratch/textile_erp/.agents/skills/shadcn-flutter/components/overlay/swiper.md) |
| `Anchor`, `ContextAnchor`, `LinkedAnchor`, `OverlayAnchor` | Coordinate/widget-linked overlay positioning primitives | `OverlayAnchorRegistry`, `OverlayAnchorScope`, `OverlayBarrier` | **0** | `src/components/overlay/anchor.dart` |

---

## 12. Typography Modifiers & Selectable Text

**Source Files**: `src/components/text/{text.dart, selectable.dart, selection_controls.dart}`

| Symbol / Extension | Description & Chainable Modifiers | Notes & Usage | Local Doc / Source |
| :--- | :--- | :--- | :--- |
| `TextExtension` (on `Widget`) | Fluent chainable style getters: `.sans`, `.mono`, `.xSmall`, `.small`, `.base`, `.large`, `.xLarge`..`.x9Large`, `.thin`..`.black`, `.italic`, `.underline`, `.muted`, `.primaryForeground`, `.secondaryForeground`, `.h1`..`.h4`, `.p`, `.firstP`, `.blockQuote`, `.li`, `.inlineCode` | Returns a `TextModifier` (`WrappedText`). **Warning (Rule 2)**: `NavigationItem` / `NavigationButton` require plain `Text(...)` in `label:` because `shadcn_flutter` invokes `.xSmall` on `label!`. | [typography.md](file:///c:/Users/smitt/.gemini/antigravity/scratch/textile_erp/.agents/skills/shadcn-flutter/guides/typography.md) |
| `Text` builder helpers (`then*`) | Rich inline text & inline clickable button composition (`then()`, `thenText()`, `thenInlineCode()`, `thenButton()`) | Great for inline clickable links without manual `RichText` `TextSpan` boilerplate. | `src/components/text/text.dart` |
| `SelectableText` | Selectable read-only text styled with active `shadcn_flutter` theme | Use for GSTINs, voucher codes, phone numbers, and error diagnostics. | `src/components/text/selectable.dart` |

---

## 13. Bundled Icon Sets

**Source Files**: `src/icons/{lucide_icons.dart, radix_icons.dart, bootstrap_icons.dart}`, `src/components/icon/{icon.dart, triple_dots.dart}`

| Symbol | Coverage | ERP Usage (`frontend/lib/`) | Notes |
| :--- | :--- | :--- | :--- |
| `shad.LucideIcons` | Primary crisp stroke icons | **584** | Standard icon set across the entire ERP (`lucide_icons_flutter` standalone removed in Stage 12.1). |
| `shad.RadixIcons` | Compact Radix UI geometric glyphs | **0** | Useful for ultra-dense table indicators / sort arrows if needed. |
| `shad.BootstrapIcons` | Extended utility/business glyphs | **0** | Available as fallback without extra packages. |
| `WrappedIcon`, `MoreDots` | Theme-scaled icon wrapper (`WrappedIcon`) & 3-dot indicator (`MoreDots`) | **0** | Supports `.iconSmall()`, etc. via `IconExtension`. |

---

## 14. Exported Companion Helpers, Validation, Localization & Animations

**Source Files**: `lib/shadcn_flutter.dart`, `src/animation.dart`, `src/components/async.dart`, `src/components/wrapper.dart`, `src/components/patch.dart`, `src/components/locale/`, `src/util.dart`

| Exported Helper / Package | Description & Role | Key Classes / Functions | ERP Usage |
| :--- | :--- | :--- | :--- |
| **State & Data Binding** (`package:data_widget`) | Scoped reactive state & model inheritance | `Data<T>`, `Model<T>`, `MultiData` | **0** *(Option to simplify `dynamic_ai` state scoping vs callbacks)* |
| **Animations** (`package:animation_kit`) | Declarative value & timeline animation builders | `AnimatedValueBuilder`, `ControlledAnimation`, `Keyframe`, `TimelineAnimation`, `kDefaultDuration` | `AnimatedValueBuilder` **1**, `kDefaultDuration` **2** |
| **Spacing** (`package:gap` + `util.dart`) | Flex spacing & list joining extensions | `Gap`, `sliverGap`, `List<Widget>.joinable` / `separated` | Uses `DensityGap` predominantly |
| **Async & Flow** | Future handling & gesture patches | `FutureOrBuilder`, `Wrapper`, `ClickDetector`, `clearActiveTextInput()`, `WidgetTreeChangeDetector` | **0** |
| **Vendor & Locale** | Built-in localization (40+ languages incl. `ShadcnLocalizationsEn`, `ShadcnLocalizationsHi`), expression parser, email validator, country codes | `ShadcnLocalizations`, `SizeUnitLocale`, `EmailValidator`, `ExpressionEvaluator`, `Countries`, `TimeOfDay` | Used implicitly by `ShadcnApp` |

---

## 15. Strategic `dynamic_ai/` Refinement Opportunities (Unused High-Value Widgets)

When refining `frontend/lib/dynamic_ai/` and preparing **Phase B (Desktop & Mobile Home Landing)** and **Phase C (Masters)**:

1. **Interactive Split Views (`DyListPane` & `DyCardPane`)**: Adopt **`ResizablePane` / `ResizablePanel`** instead of hardcoded fixed `360px` / `9+3` static columns so desktop users can drag-resize master lists and inspect wide voucher tables comfortably.
2. **Column Resizing in `DyTable`**: Benchmark **`ResizableTable` / `ResizableTableController`** (with `FrozenTableData`) to replace manual fixed/flex column math in `dy_table_header.dart` & `dy_table_def_row.dart` with interactive drag-to-resize columns.
3. **Desktop Productivity & Right-Click UX**: Wire **`ContextMenu`** on `DyTableDefRow` & `DyKanbanCard` for instant right-click actions (`Edit`, `Print PDF`, `Copy GSTIN`, `Mark Closed`) and **`HoverCard`** for instant Party / Design thumbnails on hover.
4. **Native Shortcut Badges & Live Counters**: Swap custom manual keycap pills for **`KeyboardDisplay`** (`Ctrl+K`, `Alt+1..9`, `N`) and use **`NumberTicker`** + **`Tracker`** in Bento KPI / Mill SLA strips.
5. **High-Integrity Forms (`Masters` & `Sales`)**: Standardize on native **`AutoComplete`**, **`FormattedInput`** (15-char GSTIN / 6-digit Pincode), **`PhoneInput`**, **`ChipInput`**, **`CodeSnippet`** (Raw GSTIN JSON audit), and **`Stepper` / `Timeline`** (Production & Dispatch Tracking).
6. **True Desktop vs Mobile (`<768px`) Responsiveness**: Bind **`Density`** (`reducedDensity`/`compactDensity` on Windows vs `defaultDensity`/`spaciousDensity` on Mobile) + **`StageContainer` / `NavigationBar` / `openSheetOverlay` / `RefreshTrigger` / `Swiper`** across shared shells.
