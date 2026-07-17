# Graph Report - frontend  (2026-07-17)

## Corpus Check
- 211 files · ~169,202 words
- Verdict: corpus is large enough that graph structure adds value.

## Summary
- 2982 nodes · 4127 edges · 170 communities (154 shown, 16 thin omitted)
- Extraction: 100% EXTRACTED · 0% INFERRED · 0% AMBIGUOUS · INFERRED: 14 edges (avg confidence: 0.8)
- Token cost: 0 input · 0 output

## Graph Freshness
- Built from commit: `cd4333dd`
- Run `git rev-parse HEAD` and compare to check if the graph is stale.
- Run `graphify update .` after code changes (no API cost).

## Community Hubs (Navigation)
- theme.dart
- media_screen.dart
- model_grey.dart
- model_cutting.dart
- colors.dart
- metrics.dart
- cutting_form_state.dart
- box.dart
- input.dart
- tissues_view.dart
- cutting_screen.dart
- package:flutter/material.dart
- tissues.dart
- StatelessWidget
- grey_screen.dart
- model_media.dart
- cells.dart
- ../theme.dart
- service_media.dart
- sync_dashboard_screen.dart
- package:lucide_icons_flutter/lucide_icons.dart
- grey_deal_dialog.dart
- job_work_tab.dart
- model_party.dart
- IconData?
- deals_tab.dart
- command_palette.dart
- inward_tab.dart
- Widget
- autocomplete.dart
- domain.dart
- model_jobwork.dart
- model_sync.dart
- cutting_form_overlay.dart
- popover.dart
- combobox.dart
- hover_card.dart
- pane_list.dart
- workspace_controller.dart
- cells_view.dart
- three_pane_canvas.dart
- topbar.dart
- ../cells.dart
- typography.dart
- time_picker.dart
- button.dart
- pane_header.dart
- login_screen.dart
- date_picker.dart
- input_number.dart
- parties_screen.dart
- FlutterWindow
- model_media_suggestion.dart
- home.dart
- party_card.dart
- status_dot.dart
- model_quality.dart
- pipeline_screen.dart
- service_supabase.dart
- State
- dropdown.dart
- wizard.dart
- win32_window.cpp
- z_stack.dart
- skeleton.dart
- library_shell.dart
- select.dart
- DateTime
- items_screen.dart
- focus.dart
- currency_display.dart
- inline_edit.dart
- service_cutting.dart
- service_grey.dart
- section_canvas.dart
- tooltip.dart
- spatial.dart
- image_gallery.dart
- list_card.dart
- cutting_detail_canvas.dart
- service_sync.dart
- card.dart
- organs_view.dart
- barcode_scanner.dart
- legacy_constants.dart
- ValueChanged
- nav_boat.dart
- summary.dart
- calendar.dart
- nav_item.dart
- domain_view.dart
- plasma_view.dart
- file_upload.dart
- dialog.dart
- library_section.dart
- double?
- document.dart
- wWinMain
- icon.dart
- menu_item.dart
- spatial.dart
- amounts.dart
- meta.dart
- results.dart
- context_menu.dart
- tabs.dart
- locale_utils.dart
- service_auth.dart
- Win32Window
- accordion_group.dart
- date_field.dart
- filter_bar.dart
- pagination.dart
- main.dart
- challan_card.dart
- physics.dart
- toast.dart
- master_layout.dart
- timeline.dart
- service_jobwork.dart
- manifest.json
- image.dart
- checkbox.dart
- sync_monitor.dart
- avatar.dart
- tag.dart
- tokens.dart
- kpi_tile.dart
- add_canvas.dart
- MessageHandler
- multi_button.dart
- tab_item.dart
- badge.dart
- switch.dart
- ledger.dart
- production_timeline.dart
- theme_view.dart
- plasma.dart
- comments.dart
- kanban.dart
- kpi_card.dart
- service_masters.dart
- breadcrumb.dart
- @immutable
- package:supabase_flutter/supabase_flutter.dart
- kpi_strip.dart
- stage_badge.dart
- status.dart
- types.dart
- toggle_group.dart
- stage_icon.dart
- supabase_config.dart
- label.dart
- empty_value.dart
- RegisterPlugins
- model_bill.dart
- model_purchase_order.dart
- model_recipe.dart
- model_report.dart
- textile_erp
- KineticWorkspaceController
- model_program.dart
- README.md
- OrganTopbar
- README.md
- service_bills.dart
- service_recipe.dart
- service_reports.dart
- README.md
- String?

## God Nodes (most connected - your core abstractions)
1. `Win32Window` - 19 edges
2. `MessageHandler` - 12 edges
3. `OrganismColors` - 10 edges
4. `FlutterWindow` - 10 edges
5. `Create` - 10 edges
6. `WndProc` - 10 edges
7. `MessageHandler` - 8 edges
8. `KineticWorkspaceController` - 7 edges
9. `PlasmaPopoverState` - 7 edges
10. `WindowClassRegistrar` - 7 edges

## Surprising Connections (you probably didn't know these)
- `OnCreate` --calls--> `RegisterPlugins()`  [INFERRED]
  windows/runner/flutter_window.h → windows/flutter/generated_plugin_registrant.cc
- `wWinMain()` --calls--> `CreateAndAttachConsole()`  [INFERRED]
  windows/runner/main.cpp → windows/runner/utils.cpp
- `Win32Window::Win32Window()` --calls--> `Destroy`  [INFERRED]
  windows/runner/win32_window.cpp → windows/runner/win32_window.h
- `FlutterWindow` --inherits--> `Win32Window`  [EXTRACTED]
  windows/runner/flutter_window.h → windows/runner/win32_window.h
- `OnCreate` --calls--> `GetClientArea`  [INFERRED]
  windows/runner/flutter_window.h → windows/runner/win32_window.h

## Import Cycles
- None detected.

## Communities (170 total, 16 thin omitted)

### Community 0 - "theme.dart"
Cohesion: 0.02
Nodes (99): bodyLarge, bodyMedium, bodySmall, borderLg, borderMd, borderPill, borderSm, borderXl (+91 more)

### Community 1 - "media_screen.dart"
Cohesion: 0.03
Nodes (72): _archiveSingle, _autocompleteResults, bucket, _bucketCounts, build, _buildBucketItem, _buildBulkActionBar, _buildGridArea (+64 more)

### Community 2 - "model_grey.dart"
Cohesion: 0.03
Nodes (62): dart:convert, amt, bcode, bill, billAmt, billDate, brokerCode, cardNo (+54 more)

### Community 3 - "model_cutting.dart"
Cohesion: 0.03
Nodes (61): 0, avgWt, cardNo, ccCode, ccNo, ccut, costPerPc, createTime (+53 more)

### Community 4 - "colors.dart"
Cohesion: 0.03
Nodes (61): background, border, borderSubtle, chart1, chart10, chart11, chart12, chart2 (+53 more)

### Community 5 - "metrics.dart"
Cohesion: 0.04
Nodes (52): borderLg, borderMd, borderPill, borderSm, borderXl, breakpointLg, breakpointMd, breakpointSm (+44 more)

### Community 6 - "cutting_form_state.dart"
Cohesion: 0.04
Nodes (49): availableTakas, avgWtGrams, batchDate, calculatedFentMts, calculatedFreshMts, calculatedSecondMts, cutLength, dispose (+41 more)

### Community 7 - "box.dart"
Cohesion: 0.05
Nodes (40): Border?, Color, backgroundColor, border, borderRadius, build, CellBox, child (+32 more)

### Community 8 - "input.dart"
Cohesion: 0.05
Nodes (44): FocusNode get, build, CellInput, _CellInputState, controller, createState, didUpdateWidget, dispose (+36 more)

### Community 9 - "tissues_view.dart"
Cohesion: 0.05
Nodes (41): DateTimeRange?, _activeTabIndex, build, _buildActionGroupingSection, _buildAdvancedWorkflowsSection, _buildContextDecoratorsSection, _buildDashboardSection, _buildDataMoleculesSection (+33 more)

### Community 10 - "cutting_screen.dart"
Cohesion: 0.05
Nodes (42): _batchMedia, _batchSummary, build, _buildFilterPopover, _buildSortPopover, _cards, createState, _currentPage (+34 more)

### Community 11 - "package:flutter/material.dart"
Cohesion: 0.05
Nodes (28): build, CellCountBadge, count, maxCount, build, CellKbd, keyString, build (+20 more)

### Community 12 - "tissues.dart"
Cohesion: 0.05
Nodes (37): tissues/accordion.dart, tissues/accordion_group.dart, tissues/alert.dart, tissues/barcode_scanner.dart, tissues/breadcrumb.dart, tissues/bulk_action_bar.dart, tissues/button_bar.dart, tissues/card_content.dart (+29 more)

### Community 13 - "StatelessWidget"
Cohesion: 0.07
Nodes (33): build, color, designNo, DomainDesignID, DomainQualityBadge, DomainShadeBadge, quality, shadeNo (+25 more)

### Community 14 - "grey_screen.dart"
Cohesion: 0.06
Nodes (33): GreyPurchaseModel, MillInwardModel, build, _buildMetric, _buildSectionCanvas, createState, _currentPage, _dealReceipts (+25 more)

### Community 15 - "model_media.dart"
Cohesion: 0.06
Nodes (33): 0, bucket, bucketLabel, compressedPath, copyWith, createdAt, displayName, entityId (+25 more)

### Community 16 - "cells.dart"
Cohesion: 0.06
Nodes (30): cells/autocomplete.dart, cells/avatar.dart, cells/card_avatar.dart, cells/checkbox.dart, cells/combobox.dart, cells/count_badge.dart, cells/currency_display.dart, cells/date_picker.dart (+22 more)

### Community 17 - "../theme.dart"
Cohesion: 0.07
Nodes (26): ../cells/tab_item.dart, alignment, build, children, TissueButtonBar, build, children, showDivider (+18 more)

### Community 18 - "service_media.dart"
Cohesion: 0.06
Nodes (30): dart:typed_data, archiveMedia, bulkArchive, bulkLinkSuggestions, bulkLinkToEntity, compressAndThumbnail, CompressedMediaResult, _db (+22 more)

### Community 19 - "sync_dashboard_screen.dart"
Cohesion: 0.07
Nodes (30): _activeTab, build, _buildAggregationTabsSection, _buildDailyList, _buildGridSection, _buildGroupCard, _buildHeaderSection, _buildHistoryContent (+22 more)

### Community 20 - "package:lucide_icons_flutter/lucide_icons.dart"
Cohesion: 0.07
Nodes (26): build, CellFilterChip, isSelected, label, onDeleted, onSelected, build, CellInputChip (+18 more)

### Community 21 - "grey_deal_dialog.dart"
Cohesion: 0.07
Nodes (29): _brokers, build, createState, _dealDate, _disc, dispose, _firmsUnderWeaver, _graceDays (+21 more)

### Community 22 - "job_work_tab.dart"
Cohesion: 0.07
Nodes (28): _attachChallanScan, _attachedMedia, build, _buildMediaAttachmentsSection, _buildMetric, _buildSectionCanvas, createState, _currentPage (+20 more)

### Community 23 - "model_party.dart"
Cohesion: 0.07
Nodes (27): accountType, adatiya, address1, address2, brokerage, city, code, companyType (+19 more)

### Community 24 - "IconData?"
Cohesion: 0.08
Nodes (24): badge.dart, box.dart, ../cells/alert.dart, ../cells/badge.dart, IconData?, build, CellAlert, icon (+16 more)

### Community 25 - "deals_tab.dart"
Cohesion: 0.08
Nodes (26): grey_deal_dialog.dart, GreyDealModel, build, _buildMetric, _buildSectionCanvas, createState, _currentPage, _dealReceipts (+18 more)

### Community 26 - "command_palette.dart"
Cohesion: 0.08
Nodes (26): actions, build, CommandPaletteAction, createState, dispose, _executeSelected, _filter, _filteredActions (+18 more)

### Community 27 - "inward_tab.dart"
Cohesion: 0.08
Nodes (26): _attachChallanScan, _attachedMedia, build, _buildMediaAttachmentsSection, _buildMetric, _buildSectionCanvas, createState, _currentPage (+18 more)

### Community 28 - "Widget"
Cohesion: 0.09
Nodes (22): ../cells/spatial.dart, build, content, createState, initiallyExpanded, initState, _isExpanded, title (+14 more)

### Community 29 - "autocomplete.dart"
Cohesion: 0.08
Nodes (25): input_chip.dart, build, controller, createState, didUpdateWidget, dispose, _effectiveController, _effectiveFocusNode (+17 more)

### Community 30 - "domain.dart"
Cohesion: 0.08
Nodes (24): domain/amounts.dart, domain/documents/document.dart, domain/financial/account.dart, domain/financial/identity_badges.dart, domain/financial/indicators.dart, domain/financial/ledger.dart, domain/financial/party_card.dart, domain/financial/tokens.dart (+16 more)

### Community 31 - "model_jobwork.dart"
Cohesion: 0.08
Nodes (24): amt, billNo, challanNo, cno, cuttingCardNo, date, finalAmt, fromJson (+16 more)

### Community 32 - "model_sync.dart"
Cohesion: 0.08
Nodes (23): activeTables, capturedAt, delta, delta24h, description, fromJson, id, isStagnant (+15 more)

### Community 33 - "cutting_form_overlay.dart"
Cohesion: 0.09
Nodes (21): cutting_form_state.dart, cutting_lot_group.dart, InheritedNotifier, build, _buildPaneHeader, _buildProgressBarRow, createState, CuttingFormOverlay (+13 more)

### Community 34 - "popover.dart"
Cohesion: 0.10
Nodes (21): Alignment, build, close, content, _createOverlayEntry, createState, explicitWidth, followerAnchor (+13 more)

### Community 35 - "combobox.dart"
Cohesion: 0.10
Nodes (21): divider.dart, build, CellCombobox, _CellComboboxState, createState, didUpdateWidget, dispose, _filteredItems (+13 more)

### Community 36 - "hover_card.dart"
Cohesion: 0.10
Nodes (21): Duration, build, closeDelay, _closeTimer, content, createState, dispose, _hide (+13 more)

### Community 37 - "pane_list.dart"
Cohesion: 0.09
Nodes (21): IndexedWidgetBuilder, build, _buildContent, _buildSkeleton, currentPage, emptyIcon, emptyMessage, emptyState (+13 more)

### Community 38 - "workspace_controller.dart"
Cohesion: 0.09
Nodes (21): InheritedWidget, _activeModuleIndex, activeModuleName, controller, hideOverlay, _isOverlayVisible, _isSidebarCollapsed, KineticWorkspaceProvider (+13 more)

### Community 39 - "cells_view.dart"
Cohesion: 0.10
Nodes (21): build, _buildButtonsSection, _buildDataEntrySection, _buildDisplaySection, _buildFormattingAtomsSection, _buildInputsSection, _buildNavigationSection, _buildSelectionControlsSection (+13 more)

### Community 40 - "three_pane_canvas.dart"
Cohesion: 0.09
Nodes (21): build, centerPane, centerPaneWidth, child, colors, isComplete, label, leftPane (+13 more)

### Community 41 - "topbar.dart"
Cohesion: 0.10
Nodes (21): _AnimatedMenuIcon, _AnimatedMenuIconState, _animationController, build, controller, createState, didUpdateWidget, dispose (+13 more)

### Community 42 - "../cells.dart"
Cohesion: 0.10
Nodes (18): ../cells.dart, accountType, amount, build, DomainAccountBadge, DomainBalanceDisplay, isCompact, build (+10 more)

### Community 43 - "typography.dart"
Cohesion: 0.10
Nodes (20): dart:ui, bodyLarge, bodyMedium, bodySmall, codeTabular, displayLarge, labelLarge, labelMedium (+12 more)

### Community 44 - "time_picker.dart"
Cohesion: 0.10
Nodes (20): DayPeriod, build, _buildInput, _buildPeriodButton, _buildPeriodToggle, CellTimePicker, _CellTimePickerState, _commit (+12 more)

### Community 45 - "button.dart"
Cohesion: 0.10
Nodes (20): build, CellButtonVariant, createState, _getBackgroundColor, _getBorder, _getForegroundColor, _handleHover, _handleTapCancel (+12 more)

### Community 46 - "pane_header.dart"
Cohesion: 0.10
Nodes (20): addIcon, addLabel, build, createState, filterContent, _filterPopoverKey, filterWidth, onAddPressed (+12 more)

### Community 47 - "login_screen.dart"
Cohesion: 0.10
Nodes (20): build, createState, _debounce, dispose, _emailController, _emailExists, _emailFocusNode, _errorMessage (+12 more)

### Community 48 - "date_picker.dart"
Cohesion: 0.11
Nodes (19): calendar.dart, build, CellDatePicker, _CellDatePickerState, createState, _dayController, _dayFocusNode, didUpdateWidget (+11 more)

### Community 49 - "input_number.dart"
Cohesion: 0.11
Nodes (19): input.dart, build, CellInputNumber, _CellInputNumberState, _controller, createState, _currentValue, decimals (+11 more)

### Community 50 - "parties_screen.dart"
Cohesion: 0.11
Nodes (18): ../../constants/legacy_constants.dart, int?, PartyModel, _activeAType, build, createState, _currentPage, initState (+10 more)

### Community 51 - "FlutterWindow"
Cohesion: 0.12
Nodes (16): FlutterViewController, unique_ptr, DartProject, HWND, LPARAM, LRESULT, UINT, WPARAM (+8 more)

### Community 52 - "model_media_suggestion.dart"
Cohesion: 0.11
Nodes (18): int get, entityId, entityLabel, entityType, folderContext, hashCode, hasMatches, isChecked (+10 more)

### Community 53 - "home.dart"
Cohesion: 0.12
Nodes (17): admin/sync_dashboard_screen.dart, items/items_screen.dart, build, _buildBody, _controller, createState, dispose, _getCommandPaletteActions (+9 more)

### Community 54 - "party_card.dart"
Cohesion: 0.11
Nodes (16): ../amounts.dart, identity_badges.dart, build, DomainGstBadge, DomainPartyType, DomainPartyTypeBadge, gstin, type (+8 more)

### Community 55 - "status_dot.dart"
Cohesion: 0.12
Nodes (17): Animation, bool?, build, CellStatusDot, _CellStatusDotState, CellStatusVariant, color, _controller (+9 more)

### Community 56 - "model_quality.dart"
Cohesion: 0.11
Nodes (17): bool get, baseQualityCode, category, clothType, fromJson, gstRate, hsnCode, isBaseQual (+9 more)

### Community 57 - "pipeline_screen.dart"
Cohesion: 0.12
Nodes (17): cutting/cutting_screen.dart, deals/deals_tab.dart, inward/inward_tab.dart, job_work/job_work_tab.dart, build, _buildActiveTab, createState, defaultTabIndex (+9 more)

### Community 58 - "service_supabase.dart"
Cohesion: 0.11
Nodes (17): dart:async, client, data, DbResponse, error, handleDbError, hasError, hasMore (+9 more)

### Community 59 - "State"
Cohesion: 0.16
Nodes (18): CellAutocomplete, _CellAutocompleteState, CellButton, _CellButtonState, NavRail, _NavRailState, PlasmaContextMenu, _PlasmaContextMenuState (+10 more)

### Community 60 - "dropdown.dart"
Cohesion: 0.12
Nodes (17): build, createState, dispose, _filteredItems, hasError, initState, isDisabled, _isHovered (+9 more)

### Community 61 - "wizard.dart"
Cohesion: 0.12
Nodes (17): build, _buildStepper, content, createState, _currentIndex, _isLoading, _nextStep, onCancel (+9 more)

### Community 62 - "win32_window.cpp"
Cohesion: 0.18
Nodes (14): Point, Size, wchar_t, Scale(), Create, Destroy, UpdateTheme, Win32Window::Win32Window() (+6 more)

### Community 63 - "z_stack.dart"
Cohesion: 0.12
Nodes (16): AlignmentGeometry, alignment, bottom, build, child, children, fit, height (+8 more)

### Community 64 - "skeleton.dart"
Cohesion: 0.12
Nodes (16): AnimationController, GradientTransform, borderRadius, build, CellSkeleton, _CellSkeletonState, _controller, createState (+8 more)

### Community 65 - "library_shell.dart"
Cohesion: 0.12
Nodes (16): Brightness, brightness, build, createState, label, _LibraryContent, OrganismLibraryScreen, _OrganismLibraryScreenState (+8 more)

### Community 66 - "select.dart"
Cohesion: 0.12
Nodes (15): ../cells/label.dart, build, errorText, inputCell, isRequired, label, TissueFormField, build (+7 more)

### Community 67 - "DateTime"
Cohesion: 0.12
Nodes (15): DateTime, build, CellCardAvatar, date, _getMonthColor, _months, size, build (+7 more)

### Community 68 - "items_screen.dart"
Cohesion: 0.12
Nodes (16): QualityModel, build, createState, _currentPage, initState, _isLoading, _items, ItemsScreen (+8 more)

### Community 69 - "focus.dart"
Cohesion: 0.12
Nodes (16): autofocus, borderRadius, build, child, createState, didUpdateWidget, dispose, focusNode (+8 more)

### Community 70 - "currency_display.dart"
Cohesion: 0.12
Nodes (14): amount, build, CellCurrencyDisplay, CellCurrencyVariant, _determineColor, _formatter, showSymbol, variant (+6 more)

### Community 71 - "inline_edit.dart"
Cohesion: 0.13
Nodes (15): build, _controller, createState, dispose, _focusNode, initialValue, initState, _isEditing (+7 more)

### Community 72 - "service_cutting.dart"
Cohesion: 0.12
Nodes (15): CuttingService, _db, getAvailableTakas, getBatchSummary, getBatchTimeline, getCardByNo, getCuttingBatches, getNextMultiVno (+7 more)

### Community 73 - "service_grey.dart"
Cohesion: 0.12
Nodes (15): _db, getBillDetails, getBrokers, getDispatchRegistry, getFirmsForWeaverGroup, getGreyDeals, getMillInwardBills, getPurchaseBills (+7 more)

### Community 74 - "section_canvas.dart"
Cohesion: 0.13
Nodes (14): double get, actions, build, children, colors, maxExtent, minExtent, OrganSectionCanvas (+6 more)

### Community 75 - "tooltip.dart"
Cohesion: 0.14
Nodes (14): LayerLink, build, CellTooltip, _CellTooltipState, child, _createOverlayEntry, createState, dispose (+6 more)

### Community 76 - "spatial.dart"
Cohesion: 0.13
Nodes (13): build, CellListTile, isCompact, leading, onTap, subtitle, title, trailing (+5 more)

### Community 77 - "image_gallery.dart"
Cohesion: 0.14
Nodes (14): build, createState, _currentIndex, fit, imageUrls, initialIndex, initState, _LightboxView (+6 more)

### Community 78 - "list_card.dart"
Cohesion: 0.14
Nodes (14): build, createState, footer, isCompact, _isHovered, isSelected, leading, onTap (+6 more)

### Community 79 - "cutting_detail_canvas.dart"
Cohesion: 0.13
Nodes (14): batchMedia, build, _buildScanThumbnail, _buildSectionLotCard, CuttingDetailCanvas, loadingBatchDetail, loadingTimeline, onEdit (+6 more)

### Community 80 - "service_sync.dart"
Cohesion: 0.13
Nodes (14): _db, getDashboardSummaries, _getDefaultGroupRowCount, _getDefaultRowCount, _getFallbackSummaries, _getMonthName, getRecentLogs, groupDescriptions (+6 more)

### Community 81 - "card.dart"
Cohesion: 0.14
Nodes (12): ../cells/box.dart, ../cells/button.dart, EdgeInsetsGeometry, build, children, hasShadow, padding, TissueCard (+4 more)

### Community 82 - "organs_view.dart"
Cohesion: 0.16
Nodes (12): ../domain.dart, build, _buildMasterDetailSection, _buildOrgansSection, _buildOverlaysSection, OrgansView, library/library_shell.dart, ../../organs.dart (+4 more)

### Community 83 - "barcode_scanner.dart"
Cohesion: 0.15
Nodes (13): FocusNode, build, _controller, createState, dispose, _focusNode, _handleSubmitted, label (+5 more)

### Community 84 - "legacy_constants.dart"
Cohesion: 0.14
Nodes (13): accountTypes, banks, companies, getAccountTypeColor, getAccountTypeName, getSeriesName, isProductionProcess, LegacyConstants (+5 more)

### Community 85 - "ValueChanged"
Cohesion: 0.14
Nodes (12): build, CellRadio, groupValue, onChanged, value, build, CellSlider, max (+4 more)

### Community 86 - "nav_boat.dart"
Cohesion: 0.15
Nodes (13): build, controller, createState, forceCollapsed, isCollapsed, _isHovered, label, NavBoat (+5 more)

### Community 87 - "summary.dart"
Cohesion: 0.15
Nodes (12): identity.dart, build, designNo, DomainInventorySummary, DomainItemMasterCard, maxStock, mts, onTap (+4 more)

### Community 88 - "calendar.dart"
Cohesion: 0.17
Nodes (12): build, CellCalendar, _CellCalendarState, createState, didUpdateWidget, initialViewMonth, initState, _nextMonth (+4 more)

### Community 89 - "nav_item.dart"
Cohesion: 0.15
Nodes (12): build, CellNavItem, CellNavItemVariant, icon, isCollapsed, isSelected, label, leading (+4 more)

### Community 90 - "domain_view.dart"
Cohesion: 0.15
Nodes (12): build, _buildFinancialSection, _buildInventorySection, _buildProductionSection, _buildRegistrySection, _doc, DomainView, package:textile_erp/organism_design/cells.dart (+4 more)

### Community 91 - "plasma_view.dart"
Cohesion: 0.15
Nodes (12): build, _buildDataVizSections, _buildDepthSection, _buildGeometrySection, _buildOverlaysSection, _buildResponsiveSection, _buildZIndexScaleSection, _colorSwatchCompact (+4 more)

### Community 92 - "file_upload.dart"
Cohesion: 0.17
Nodes (12): allowMultiple, build, createState, _isDragging, isUploading, label, _pickFiles, subtitle (+4 more)

### Community 93 - "dialog.dart"
Cohesion: 0.21
Nodes (10): ../cells/divider.dart, PlasmaAlertDialog, PlasmaDialog, show, PlasmaDrawer, OrganismColors, Offset, physics.dart (+2 more)

### Community 94 - "library_section.dart"
Cohesion: 0.17
Nodes (11): CrossAxisAlignment, build, child, crossAxisAlignment, description, filePath, LibraryComponentDoc, LibrarySection (+3 more)

### Community 95 - "double?"
Cohesion: 0.17
Nodes (10): double?, build, CellDivider, isVertical, length, build, CellPlaceholder, height (+2 more)

### Community 96 - "document.dart"
Cohesion: 0.17
Nodes (11): ../financial/tokens.dart, build, date, description, DomainDocumentHeader, DomainDocumentRow, id, partyName (+3 more)

### Community 97 - "wWinMain"
Cohesion: 0.24
Nodes (9): _In_, _In_opt_, vector, wWinMain(), string, wchar_t, CreateAndAttachConsole(), GetCommandLineArguments() (+1 more)

### Community 98 - "icon.dart"
Cohesion: 0.17
Nodes (11): build, CellIcon, CellIconSize, CellIconVariant, _getColor, _getSize, huge, icon (+3 more)

### Community 99 - "menu_item.dart"
Cohesion: 0.18
Nodes (11): build, CellMenuItem, _CellMenuItemState, createState, icon, isDestructive, isDisabled, _isHovered (+3 more)

### Community 100 - "spatial.dart"
Cohesion: 0.17
Nodes (11): build, CellGap, CellPad, child, horizontalMultiplier, large, multiplier, small (+3 more)

### Community 101 - "amounts.dart"
Cohesion: 0.17
Nodes (11): build, DomainAmount, DomainQuantity, isCompact, isCredit, showSymbol, style, unit (+3 more)

### Community 102 - "meta.dart"
Cohesion: 0.17
Nodes (11): build, DomainAuditLabel, DomainPrintButton, DomainSyncStatus, hasError, isSynced, isThermal, lastSync (+3 more)

### Community 103 - "results.dart"
Cohesion: 0.17
Nodes (11): build, category, DomainFilterPill, DomainSearchOverlay, icon, metric, onRemove, onTap (+3 more)

### Community 104 - "context_menu.dart"
Cohesion: 0.17
Nodes (11): build, child, _closeMenu, _ContextMenuOverlay, createState, items, onClose, _overlayEntry (+3 more)

### Community 105 - "tabs.dart"
Cohesion: 0.18
Nodes (11): build, createState, _currentIndex, initialIndex, initState, onChanged, tabs, TissueTabs (+3 more)

### Community 106 - "locale_utils.dart"
Cohesion: 0.17
Nodes (11): compactCurrency, currency, date, dateLong, dateTime, financialYear, financialYearRange, meters (+3 more)

### Community 107 - "service_auth.dart"
Cohesion: 0.17
Nodes (11): AuthService, checkEmailExists, currentUser, _db, getUserProfile, _instance, signIn, signOut (+3 more)

### Community 108 - "Win32Window"
Cohesion: 0.21
Nodes (12): RECT, OnCreate, HWND, Win32Window, child_content_, GetClientArea, OnCreate, quit_on_close_ (+4 more)

### Community 109 - "accordion_group.dart"
Cohesion: 0.20
Nodes (10): accordion.dart, build, children, createState, defaultOpenId, _handleToggle, initState, _openId (+2 more)

### Community 110 - "date_field.dart"
Cohesion: 0.20
Nodes (10): ../cells/calendar.dart, GlobalKey, build, createState, label, onChanged, _popoverKey, TissueDateField (+2 more)

### Community 111 - "filter_bar.dart"
Cohesion: 0.18
Nodes (10): ../cells/filter_chip.dart, build, filters, id, label, onAddFilter, onClearAll, onFilterRemoved (+2 more)

### Community 112 - "pagination.dart"
Cohesion: 0.18
Nodes (10): ../cells/input.dart, ../cells/multi_button.dart, dart:math, build, currentPage, limit, onPageChanged, TissuePagination (+2 more)

### Community 113 - "main.dart"
Cohesion: 0.18
Nodes (10): config/supabase_config.dart, dart:io, build, initialize, main, TextileERPMain, package:flutter/foundation.dart, package:window_manager/window_manager.dart (+2 more)

### Community 114 - "challan_card.dart"
Cohesion: 0.18
Nodes (10): build, date, DomainChallanCard, isSelected, mts, onTap, partyName, pcs (+2 more)

### Community 115 - "physics.dart"
Cohesion: 0.18
Nodes (10): curve, fade, fast, PlasmaPhysics, scaleIn, slideUp, slow, standard (+2 more)

### Community 116 - "toast.dart"
Cohesion: 0.18
Nodes (10): build, _currentToast, instance, message, onClose, PlasmaToastManager, _PlasmaToastWidget, show (+2 more)

### Community 117 - "master_layout.dart"
Cohesion: 0.18
Nodes (10): build, emptyIcon, emptyMessage, emptyTitle, isDetailVisible, paneHeader, paneList, sectionCanvas (+2 more)

### Community 118 - "timeline.dart"
Cohesion: 0.18
Nodes (10): build, _buildNode, description, isCompleted, isLast, nodes, TimelineNodeData, timestamp (+2 more)

### Community 119 - "service_jobwork.dart"
Cohesion: 0.18
Nodes (10): _db, getDispatchesForCuttingCard, getJobDispatches, getJobReceives, getJobWorkLines, getReceivesForDispatch, _instance, JobWorkService (+2 more)

### Community 120 - "manifest.json"
Cohesion: 0.18
Nodes (10): background_color, description, display, icons, name, orientation, prefer_related_applications, short_name (+2 more)

### Community 121 - "image.dart"
Cohesion: 0.20
Nodes (9): BoxFit, borderRadius, build, CellImage, fit, height, imageUrl, width (+1 more)

### Community 122 - "checkbox.dart"
Cohesion: 0.22
Nodes (9): focus.dart, build, CellCheckbox, _CellCheckboxState, createState, isDisabled, _isHovered, onChanged (+1 more)

### Community 123 - "sync_monitor.dart"
Cohesion: 0.20
Nodes (9): ../general/meta.dart, build, _buildHeader, _buildTableList, isSyncing, lastSync, onRefresh, OrganSyncMonitor (+1 more)

### Community 124 - "avatar.dart"
Cohesion: 0.20
Nodes (9): ImageProvider?, build, CellAvatar, fallbackIcon, image, name, onTap, size (+1 more)

### Community 125 - "tag.dart"
Cohesion: 0.20
Nodes (9): build, CellTag, CellTagVariant, icon, label, onRemove, onTap, _resolveColors (+1 more)

### Community 126 - "tokens.dart"
Cohesion: 0.20
Nodes (9): build, DomainPaymentMode, DomainRateTag, DomainVoucherID, id, mode, prefix, rate (+1 more)

### Community 127 - "kpi_tile.dart"
Cohesion: 0.20
Nodes (9): build, _buildDelta, delta, DomainKpiTile, DomainKpiTrend, label, trend, unit (+1 more)

### Community 128 - "add_canvas.dart"
Cohesion: 0.20
Nodes (9): build, children, footer, headerActions, onClose, OrganAddCanvas, subHeader, title (+1 more)

### Community 129 - "MessageHandler"
Cohesion: 0.36
Nodes (10): HWND, LPARAM, LRESULT, UINT, WPARAM, EnableFullDpiSupportIfAvailable(), GetHandle, GetThisFromHandle (+2 more)

### Community 130 - "multi_button.dart"
Cohesion: 0.22
Nodes (8): BorderRadius?, button.dart, borderRadius, build, CellMultiButton, child, children, _MultiWidgetWrapper

### Community 131 - "tab_item.dart"
Cohesion: 0.22
Nodes (8): kbd.dart, build, CellTabItem, icon, isSelected, kbdShortcut, onTap, title

### Community 132 - "badge.dart"
Cohesion: 0.22
Nodes (8): build, CellBadge, customColor, icon, onDismiss, onTap, text, variant

### Community 133 - "switch.dart"
Cohesion: 0.25
Nodes (8): build, CellSwitch, _CellSwitchState, createState, isDisabled, _isHovered, onChanged, value

### Community 134 - "ledger.dart"
Cohesion: 0.22
Nodes (8): amount, build, date, DomainGSTBreakdown, DomainLedgerEntry, isDr, particulars, taxMap

### Community 135 - "production_timeline.dart"
Cohesion: 0.22
Nodes (8): build, _buildConnector, _buildStageNode, completedStages, currentStage, DomainProductionTimeline, stage_badge.dart, stage_icon.dart

### Community 136 - "theme_view.dart"
Cohesion: 0.22
Nodes (8): build, _buildColorsSection, _buildMetricsSection, _buildTypographySection, _colorChip, _metricBox, ThemeView, ../widgets/library_section.dart

### Community 137 - "plasma.dart"
Cohesion: 0.22
Nodes (8): plasma/context_menu.dart, plasma/dialog.dart, plasma/drawer.dart, plasma/hover_card.dart, plasma/physics.dart, ../plasma/popover.dart, plasma/toast.dart, plasma/z_stack.dart

### Community 138 - "comments.dart"
Cohesion: 0.22
Nodes (8): authorName, build, CommentData, comments, content, initial, timestamp, TissueComments

### Community 139 - "kanban.dart"
Cohesion: 0.22
Nodes (8): build, columns, columnWidth, headerExtra, items, TissueKanbanBoard, TissueKanbanColumnData, title

### Community 140 - "kpi_card.dart"
Cohesion: 0.22
Nodes (8): build, deltaText, isPositive, label, sparklineData, TissueKpiCard, value, package:fl_chart/fl_chart.dart

### Community 141 - "service_masters.dart"
Cohesion: 0.25
Nodes (7): ../core/service_supabase.dart, _db, getParties, getQualities, MastersService, ../../models/masters/model_party.dart, ../../models/masters/model_quality.dart

### Community 142 - "breadcrumb.dart"
Cohesion: 0.25
Nodes (7): build, label, maxVisibleNodes, nodes, onTap, TissueBreadcrumb, TissueBreadcrumbNode

### Community 143 - "@immutable"
Cohesion: 0.29
Nodes (7): @immutable, CuttingBatchSummaryModel, CuttingCardModel, JobDispatchModel, JobReceiveModel, JobWorkDetailLineModel, MediaModel

### Community 144 - "package:supabase_flutter/supabase_flutter.dart"
Cohesion: 0.29
Nodes (6): AuthState, ../home.dart, AuthGate, build, login_screen.dart, package:supabase_flutter/supabase_flutter.dart

### Community 145 - "kpi_strip.dart"
Cohesion: 0.29
Nodes (6): kpi_tile.dart, build, _buildSkeletonRow, isLoading, items, OrganKpiStrip

### Community 146 - "stage_badge.dart"
Cohesion: 0.29
Nodes (6): build, DomainStageBadge, isCompact, isCompleted, stage, ../types.dart

### Community 147 - "status.dart"
Cohesion: 0.29
Nodes (6): build, DomainMendingBadge, DomainSlipStatus, hasMending, isCancelled, isCompleted

### Community 148 - "types.dart"
Cohesion: 0.29
Nodes (6): code, DomainDocumentType, DomainLedgerType, DomainProductionStage, DomainTaxType, fromCode

### Community 149 - "toggle_group.dart"
Cohesion: 0.33
Nodes (5): build, CellToggleGroup, items, onChanged, value

### Community 150 - "stage_icon.dart"
Cohesion: 0.33
Nodes (5): build, color, DomainStageIcon, size, stage

### Community 151 - "supabase_config.dart"
Cohesion: 0.40
Nodes (4): anonKey, SupabaseConfig, url, static const String

### Community 152 - "label.dart"
Cohesion: 0.40
Nodes (4): build, CellLabel, isRequired, text

### Community 153 - "empty_value.dart"
Cohesion: 0.50
Nodes (3): build, CellEmptyValue, fallbackText

## Knowledge Gaps
- **2094 isolated node(s):** `SupabaseConfig`, `url`, `anonKey`, `LegacyConstants`, `companies` (+2089 more)
  These have ≤1 connection - possible missing edges or undocumented components.
- **16 thin communities (<3 nodes) omitted from report** — run `graphify query` to explore isolated nodes.

## Suggested Questions
_Questions this graph is uniquely positioned to answer:_

- **Why does `CuttingService` connect `service_cutting.dart` to `media_screen.dart`, `cutting_screen.dart`, `cutting_form_state.dart`?**
  _High betweenness centrality (0.007) - this node is a cross-community bridge._
- **Why does `QualityModel` connect `items_screen.dart` to `model_quality.dart`?**
  _High betweenness centrality (0.005) - this node is a cross-community bridge._
- **Why does `OrganismColors` connect `dialog.dart` to `theme.dart`, `popover.dart`, `colors.dart`, `three_pane_canvas.dart`, `section_canvas.dart`?**
  _High betweenness centrality (0.002) - this node is a cross-community bridge._
- **What connects `SupabaseConfig`, `url`, `anonKey` to the rest of the system?**
  _2094 weakly-connected nodes found - possible documentation gaps or missing edges._
- **Should `theme.dart` be split into smaller, more focused modules?**
  _Cohesion score 0.02 - nodes in this community are weakly interconnected._
- **Should `media_screen.dart` be split into smaller, more focused modules?**
  _Cohesion score 0.0273972602739726 - nodes in this community are weakly interconnected._
- **Should `model_grey.dart` be split into smaller, more focused modules?**
  _Cohesion score 0.031746031746031744 - nodes in this community are weakly interconnected._