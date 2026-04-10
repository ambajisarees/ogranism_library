import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../organism_design/index.dart';

/// OrganismUI — The Biological ERP design system.
///
/// PHILOSOPHY (The Hierarchy of Complexity):
/// 1. CELLS      - Particles & Atoms.
/// 2. TISSUES    - Molecules. Functional groups of cells.
/// 3. ORGANS     - Organisms. Complex interactive blocks.
/// 4. SYSTEMS    - Templates. Layout types and page structures.
/// 5. ORGANELLES - Smart Controllers. Functional logic & state wrappers.
///
/// PERFORMANCE PROTOCOL:
/// - STATIC FIRST: Use static methods and 'const' constructors.
/// - NO RUNTIME COST: Style tokens are hardcoded/precalculated.

class OrganismUI {
  // --- CELLS (Particles: The Foundation) ---

  static Widget cellBox({
    required Widget child,
    EdgeInsets? padding,
    Color? backgroundColor,
    Color? borderColor,
    double? borderRadius,
    bool showShadow = false,
  }) {
    return Container(
      padding: padding ?? const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: backgroundColor ?? Colors.transparent,
        borderRadius: BorderRadius.circular(borderRadius ?? 8),
        border: Border.all(color: borderColor ?? Colors.transparent),
        boxShadow: showShadow
            ? [
                BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4))
              ]
            : null,
      ),
      child: child,
    );
  }

  static Widget cellText(
    String text, {
    double fontSize = 14,
    FontWeight fontWeight = FontWeight.normal,
    Color? color,
    bool isMono = false,
    TextAlign? textAlign,
    int? maxLines,
    TextOverflow? overflow,
  }) {
    final style = (isMono ? OrganismTheme.textStyleMono : OrganismTheme.textStylePrimary)
        .copyWith(fontSize: fontSize, fontWeight: fontWeight, color: color);

    return Text(
      text,
      style: style,
      textAlign: textAlign,
      maxLines: maxLines,
      overflow: overflow,
    );
  }

  static Widget cellIcon(
    IconData icon, {
    double size = 20,
    Color? color,
  }) {
    return Icon(icon, size: size, color: color);
  }

  /// Page Title: 40px, regular spacing, now with optional weight control.
  static Widget pageTitle(String text, {FontWeight? fontWeight}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 24),
      child: Text(
        text,
        style: OrganismTheme.textStylePageTitle.copyWith(
          fontWeight: fontWeight,
        ),
      ),
    );
  }

  // --- ICONS (Particles: Atoms) ---

  // --- BUTTONS (Cells: Atoms) ---

  static Widget primaryButton({
    required String label,
    required VoidCallback? onPressed,
    IconData? prefixIcon,
    IconData? suffixIcon,
    bool isLoading = false,
    bool isCompact = false,
    double? width,
    Color? backgroundColor,
    Color? foregroundColor,
  }) {
    final themeColor = backgroundColor ?? OrganismTheme.primary;
    final onColor = foregroundColor ?? Colors.white;

    return SizedBox(
      width: width,
      height: isCompact ? 36 : 48,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: themeColor,
          foregroundColor: onColor,
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          padding: EdgeInsets.symmetric(horizontal: isCompact ? 12 : 24),
        ),
        child: isLoading
            ? SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(onColor)),
              )
            : Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (prefixIcon != null) ...[
                    Icon(prefixIcon, size: isCompact ? 16 : 20),
                    const SizedBox(width: 8),
                  ],
                  Text(
                    label,
                    style: OrganismTheme.textStylePrimary.copyWith(
                        fontWeight: FontWeight.w600,
                        fontSize: isCompact ? 13 : 15,
                        color: onColor),
                  ),
                  if (suffixIcon != null) ...[
                    const SizedBox(width: 8),
                    Icon(suffixIcon, size: isCompact ? 16 : 20),
                  ],
                ],
              ),
      ),
    );
  }

  static Widget successButton({
    required String label,
    required VoidCallback? onPressed,
    IconData? prefixIcon,
    double? width,
    bool isCompact = false,
  }) =>
      primaryButton(
        label: label,
        onPressed: onPressed,
        prefixIcon: prefixIcon,
        width: width,
        isCompact: isCompact,
        backgroundColor: OrganismTheme.success,
      );

  static Widget dangerButton({
    required String label,
    required VoidCallback? onPressed,
    IconData? prefixIcon,
    double? width,
    bool isCompact = false,
  }) =>
      primaryButton(
        label: label,
        onPressed: onPressed,
        prefixIcon: prefixIcon,
        width: width,
        isCompact: isCompact,
        backgroundColor: OrganismTheme.error,
      );

  static Widget warningButton({
    required String label,
    required VoidCallback? onPressed,
    IconData? prefixIcon,
    double? width,
    bool isCompact = false,
  }) =>
      primaryButton(
        label: label,
        onPressed: onPressed,
        prefixIcon: prefixIcon,
        width: width,
        isCompact: isCompact,
        backgroundColor: OrganismTheme.warning,
        foregroundColor: Colors.black,
      );

  static Widget secondaryButton({
    required String label,
    required VoidCallback? onPressed,
    IconData? prefixIcon,
    double? width,
    bool isCompact = false,
  }) =>
      primaryButton(
        label: label,
        onPressed: onPressed,
        prefixIcon: prefixIcon,
        width: width,
        isCompact: isCompact,
        backgroundColor: OrganismTheme.slate100,
        foregroundColor: OrganismTheme.textPrimary,
      );

  static Widget outlineButton({
    required String label,
    required VoidCallback? onPressed,
    IconData? prefixIcon,
    double? width,
    bool isCompact = false,
  }) {
    return SizedBox(
      width: width,
      height: isCompact ? 36 : 48,
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          side: const BorderSide(color: OrganismTheme.border),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          padding: EdgeInsets.symmetric(horizontal: isCompact ? 12 : 24),
          foregroundColor: OrganismTheme.textPrimary,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (prefixIcon != null) ...[
              Icon(prefixIcon, size: isCompact ? 16 : 20),
              const SizedBox(width: 8),
            ],
            Text(
              label,
              style: OrganismTheme.textStylePrimary.copyWith(
                  fontWeight: FontWeight.w600,
                  fontSize: isCompact ? 13 : 15,
                  color: OrganismTheme.textPrimary),
            ),
          ],
        ),
      ),
    );
  }

  static Widget ghostButton({
    required String label,
    required VoidCallback? onPressed,
    IconData? prefixIcon,
    bool isCompact = false,
    double? width,
    Color? color,
  }) {
    return SizedBox(
      width: width,
      child: TextButton(
        onPressed: onPressed,
        style: TextButton.styleFrom(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          padding: EdgeInsets.symmetric(horizontal: isCompact ? 12 : 16),
          foregroundColor: color ?? OrganismTheme.textSecondary,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (prefixIcon != null) ...[
              Icon(prefixIcon, size: isCompact ? 16 : 20),
              const SizedBox(width: 8),
            ],
            Text(
              label,
              style: OrganismTheme.textStylePrimary.copyWith(
                  fontWeight: FontWeight.w600,
                  fontSize: isCompact ? 13 : 15,
                  color: color ?? OrganismTheme.textSecondary),
            ),
          ],
        ),
      ),
    );
  }

  static Widget iconButton({
    required IconData icon,
    required VoidCallback? onPressed,
    double size = 42,
    Color? color,
    Color? iconColor,
    bool showBorder = true,
  }) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color ?? Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: showBorder ? Border.all(color: OrganismTheme.border) : null,
      ),
      child: IconButton(
        icon: Icon(icon,
            size: size * 0.45, color: iconColor ?? OrganismTheme.textPrimary),
        onPressed: onPressed,
        padding: EdgeInsets.zero,
        splashRadius: size * 0.4,
      ),
    );
  }

  // --- DATA ENTRY & CONTROLS (Cells: Atoms) ---

  static Widget inputField({
    required String label,
    required TextEditingController controller,
    String? hintText,
    bool isMono = false,
    bool isPassword = false,
    String? prefixText,
    Widget? prefixIcon,
    Widget? suffixIcon,
    TextInputType? keyboardType,
    ValueChanged<String>? onChanged,
    Color? activeColor,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label.toUpperCase(),
          style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: OrganismTheme.textSecondary,
              letterSpacing: 0.5),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          obscureText: isPassword,
          keyboardType: keyboardType,
          onChanged: onChanged,
          style: isMono
              ? OrganismTheme.textStyleMono.copyWith(fontSize: 15)
              : OrganismTheme.textStylePrimary.copyWith(fontSize: 15),
          decoration: InputDecoration(
            hintText: hintText,
            prefixText: prefixText,
            prefixIcon: prefixIcon,
            suffixIcon: suffixIcon,
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide:
                  BorderSide(color: activeColor ?? OrganismTheme.primary, width: 2),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: OrganismTheme.border),
            ),
          ),
        ),
      ],
    );
  }

  /// The compact search bar used in list headers (Fixed 40px, Minimalist).
  static Widget headerSearchField({
    required TextEditingController controller,
    String hintText = 'Search...',
    ValueChanged<String>? onChanged,
    Color? activeColor,
  }) {
    return _SearchField(
      controller: controller,
      hintText: hintText,
      onChanged: onChanged,
      accentColor: activeColor,
      isFormStyle: false,
    );
  }

  /// A search bar that follows the standard form field pattern (Top Label + Standard Border).
  static Widget formSearchField({
    required String label,
    required TextEditingController controller,
    String hintText = 'Search...',
    ValueChanged<String>? onChanged,
    Color? activeColor,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label.toUpperCase(),
          style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: OrganismTheme.textSecondary,
              letterSpacing: 0.5),
        ),
        const SizedBox(height: 8),
        _SearchField(
          controller: controller,
          hintText: hintText,
          onChanged: onChanged,
          accentColor: activeColor,
          isFormStyle: true,
        ),
      ],
    );
  }

  static Widget qtyStepper({
    required double value,
    required ValueChanged<double> onChanged,
    double step = 1.0,
    String unit = 'Pcs',
    Color? activeColor,
  }) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        iconButton(
          icon: LucideIcons.minus,
          onPressed: () => onChanged(value - step),
          size: 48,
          color: OrganismTheme.background,
        ),
        const SizedBox(width: 8),
        Container(
          width: 80,
          height: 48,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: OrganismTheme.background,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: OrganismTheme.border),
          ),
          child: Text(
            '${value.toInt()} $unit',
            style: OrganismTheme.textStyleMono
                .copyWith(fontSize: 15, fontWeight: FontWeight.bold),
          ),
        ),
        const SizedBox(width: 8),
        iconButton(
          icon: LucideIcons.plus,
          onPressed: () => onChanged(value + step),
          size: 48,
          color: OrganismTheme.background,
        ),
      ],
    );
  }

  static Widget toggle({
    required bool value,
    required ValueChanged<bool> onChanged,
    Color? activeColor,
  }) {
    return Switch(
      value: value,
      onChanged: onChanged,
      activeThumbColor: activeColor ?? OrganismTheme.primary,
      activeTrackColor: (activeColor ?? OrganismTheme.primary).withOpacity(0.3),
      inactiveThumbColor: OrganismTheme.slate400,
      inactiveTrackColor: OrganismTheme.slate200,
    );
  }

  // --- MARKERS & STATUS (Cells: Atoms) ---

  static Widget badge({
    required String label,
    required BadgeType type,
    Color? customBg,
    Color? customText,
    bool showDot = false,
  }) {
    Color bgColor;
    Color textColor;

    if (customBg != null && customText != null) {
      bgColor = customBg;
      textColor = customText;
    } else {
      switch (type) {
        case BadgeType.success:
          bgColor = const Color(0xFFF0FDF4);
          textColor = const Color(0xFF166534);
          break;
        case BadgeType.warning:
          bgColor = const Color(0xFFFFFBEB);
          textColor = const Color(0xFF92400E);
          break;
        case BadgeType.error:
          bgColor = const Color(0xFFFEF2F2);
          textColor = const Color(0xFF991B1B);
          break;
        case BadgeType.info:
          bgColor = const Color(0xFFEFF6FF);
          textColor = const Color(0xFF1E40AF);
          break;
        case BadgeType.neutral:
          bgColor = OrganismTheme.slate100;
          textColor = OrganismTheme.slate600;
          break;
        case BadgeType.accent:
          bgColor = OrganismTheme.primary.withOpacity(0.1);
          textColor = OrganismTheme.primaryDark;
          break;
      }
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(99),
        border: Border.all(color: textColor.withOpacity(0.15)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (showDot) ...[
            Container(
                width: 6,
                height: 6,
                decoration:
                    BoxDecoration(color: textColor, shape: BoxShape.circle)),
            const SizedBox(width: 8),
          ],
          Text(
            label.toUpperCase(),
            style: OrganismTheme.textStyleLabel.copyWith(
                color: textColor,
                fontSize: 10,
              ),
          ),
        ],
      ),
    );
  }

  static Widget pagination({
    required String contextLabel,
    required VoidCallback onPrev,
    required VoidCallback onNext,
    ListViewLoadingType loadingType = ListViewLoadingType.none,
    Color? accentColor,
    bool isExpanded = false,
  }) {
    final bool isSkeleton = loadingType == ListViewLoadingType.full || loadingType == ListViewLoadingType.paging;
    final accent = accentColor ?? OrganismTheme.primary;
    return Container(
      height: 36,
      padding: const EdgeInsets.symmetric(horizontal: 4),
      decoration: BoxDecoration(
        color: OrganismTheme.surface,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: OrganismTheme.borderSubtle),
      ),
      child: Row(
        mainAxisSize: isExpanded ? MainAxisSize.max : MainAxisSize.min,
        mainAxisAlignment: isExpanded ? MainAxisAlignment.spaceBetween : MainAxisAlignment.start,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: Icon(LucideIcons.chevronLeft, size: 16, color: accent),
                onPressed: onPrev,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                splashRadius: 16,
              ),
              const VerticalDivider(width: 1, indent: 8, endIndent: 8),
              IconButton(
                icon: Icon(LucideIcons.chevronRight, size: 16, color: accent),
                onPressed: onNext,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                splashRadius: 16,
              ),
            ],
          ),
          if (!isExpanded) const SizedBox(width: 16),
          if (isSkeleton)
            skeleton(width: 80, height: 12, radius: 4)
          else
            Text(
              contextLabel.toUpperCase(),
              style: OrganismTheme.textStyleLabel.copyWith(
                color: OrganismTheme.textSecondary,
              ),
            ),
          const SizedBox(width: 12),
        ],
      ),
    );
  }

  /// A high-density picker/dropdown wrapper designed to match the pagination widget.
  /// Used for filters and sort controls in list headers.
  static Widget dropdownControl({
    String? label,
    required IconData icon,
    VoidCallback? onTap,
    Color? accentColor,
    bool isActive = false,
  }) {
    final accent = accentColor ?? OrganismTheme.primary;

    final content = Container(
      height: 36,
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color: isActive ? accent.withOpacity(0.05) : OrganismTheme.surface,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: isActive ? accent.withOpacity(0.3) : OrganismTheme.borderSubtle,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: 14,
            color: accent,
          ),
          if (label != null && label.isNotEmpty) ...[
            const SizedBox(width: 8),
            Text(
              label.toUpperCase(),
              style: OrganismTheme.textStyleLabel.copyWith(
                color: accent,
                fontWeight: FontWeight.w700,
                fontSize: 10,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ],
      ),
    );

    if (onTap == null) return content;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(6),
      child: content,
    );
  }

  static Widget tag({
    required String label,
    bool isAccent = false,
    VoidCallback? onRemove,
    Color? customColor,
  }) {
    final color =
        customColor ?? (isAccent ? OrganismTheme.primary : OrganismTheme.textSecondary);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: isAccent ? color.withOpacity(0.08) : Colors.white,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
            color: isAccent ? color.withOpacity(0.3) : OrganismTheme.border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(label,
              style: OrganismTheme.textStyleSecondary.copyWith(
                  fontSize: 12,
                  color: isAccent ? color : OrganismTheme.textPrimary)),
          if (onRemove != null) ...[
            const SizedBox(width: 6),
            GestureDetector(
              onTap: onRemove,
              child: Icon(LucideIcons.x,
                  size: 14, color: isAccent ? color : OrganismTheme.textMuted),
            ),
          ],
        ],
      ),
    );
  }

  static Widget avatar({
    required String initials,
    double size = 36,
    Color? backgroundColor,
    Color? textColor,
  }) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: backgroundColor ?? OrganismTheme.primary.withOpacity(0.1),
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: 2),
      ),
      alignment: Alignment.center,
      child: Text(
        initials.toUpperCase(),
        style: TextStyle(
            color: textColor ?? OrganismTheme.primaryDark,
            fontWeight: FontWeight.bold,
            fontSize: size * 0.4),
      ),
    );
  }

  // --- NAVIGATION (Tissues: Molecules) ---

  static Widget pillTabs({
    required List<String> tabs,
    required int selectedIndex,
    required Function(int) onTabChanged,
    List<IconData>? icons,
    Color? activeColor,
    Color? inactiveTextColor,
    Color? backgroundColor,
    Color? borderColor,
    IconData? icon,
  }) {
    final Color accent = activeColor ?? OrganismTheme.primary;

    return Container(
      height: OrganismTheme.tabHeightPill,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: backgroundColor ?? Colors.white,
        borderRadius: BorderRadius.circular(OrganismTheme.tabHeightPill / 2),
        border: Border.all(color: borderColor ?? OrganismTheme.border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: List.generate(tabs.length, (index) {
          final bool isSelected = index == selectedIndex;
          final IconData? itemIcon = (icons != null && icons.length > index)
              ? icons[index]
              : (index == 0 ? icon : null);

          return GestureDetector(
            onTap: () => onTabChanged(index),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 16),
              margin: const EdgeInsets.symmetric(horizontal: 2),
              decoration: BoxDecoration(
                color: isSelected
                    ? accent.withOpacity(0.12)
                    : Colors.transparent,
                borderRadius:
                    BorderRadius.circular((OrganismTheme.tabHeightPill - 8) / 2),
                border: Border.all(
                  color: isSelected ? accent : Colors.transparent,
                  width: 1.5,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (itemIcon != null) ...[
                    Icon(
                      itemIcon,
                      size: 14,
                      color: isSelected
                          ? accent
                          : (inactiveTextColor ?? OrganismTheme.textSecondary),
                    ),
                    const SizedBox(width: 8),
                  ],
                  Text(
                    tabs[index],
                    style: (isSelected
                            ? OrganismTheme.textStyleAccent
                            : OrganismTheme.textStyleSecondary)
                        .copyWith(
                      fontSize: 13,
                      fontWeight:
                          isSelected ? FontWeight.w600 : FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }

  static Widget underlineTabs({
    required List<String> tabs,
    required int selectedIndex,
    required Function(int) onTabChanged,
    Color? activeColor,
    Color? inactiveTextColor,
    bool isFullWidth = false,
  }) {
    final Color accent = activeColor ?? OrganismTheme.primary;

    final items = List.generate(tabs.length, (index) {
      final bool isSelected = index == selectedIndex;

      final tab = GestureDetector(
        onTap: () => onTabChanged(index),
        child: Container(
          height: OrganismTheme.tabHeightUnderline,
          padding: const EdgeInsets.symmetric(horizontal: 8),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: isSelected ? accent : Colors.transparent,
                width: 2,
              ),
            ),
          ),
          child: Center(
            child: Text(
              tabs[index],
              style: (isSelected
                      ? OrganismTheme.textStyleAccent
                      : OrganismTheme.textStyleSecondary)
                  .copyWith(
                fontSize: 13,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
              ),
              maxLines: 1,
              overflow: TextOverflow.fade,
              softWrap: false,
            ),
          ),
        ),
      );

      return isFullWidth ? Expanded(child: tab) : tab;
    });

    return Row(
      mainAxisSize: isFullWidth ? MainAxisSize.max : MainAxisSize.min,
      mainAxisAlignment: isFullWidth
          ? MainAxisAlignment.spaceEvenly
          : MainAxisAlignment.start,
      children: items,
    );
  }

  // --- HEADERS (Tissues: Molecules) ---

  static Widget brandIcon(IconData icon, Color accent) {
    return Icon(icon, color: accent, size: 20);
  }

  static Widget pageHeader({
    required String title,
    required IconData icon,
    List<Widget>? leadingActions,
    List<Widget>? trailingActions,
    List<String>? tabs,
    int? selectedTabIndex,
    Function(int)? onTabChanged,
    Color? accentColor,
  }) {
    final bool hasTabs = tabs != null && tabs.isNotEmpty;
    final Color accent = accentColor ?? OrganismTheme.primary;

    return Container(
      decoration: const BoxDecoration(
        color: OrganismTheme.surface,
        border: Border(bottom: BorderSide(color: OrganismTheme.border, width: 1)),
      ),
      child: Column(
        children: [
          Container(
            height: 64,
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Row(
              children: [
                Icon(icon, color: accent, size: 20),
                const SizedBox(width: 12),
                Text(
                  title, // Removed toUpperCase() for Sentence Case
                  style: OrganismTheme.textStylePrimary.copyWith(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                if (leadingActions != null && leadingActions.isNotEmpty) ...[
                  const SizedBox(width: 24),
                  ...leadingActions,
                ],
                const Spacer(),
                if (trailingActions != null && trailingActions.isNotEmpty)
                  ...trailingActions,
              ],
            ),
          ),
          if (hasTabs)
            Container(
              height: 48,
              alignment: Alignment.centerLeft,
              padding: const EdgeInsets.only(left: 16, bottom: 8),
              child: pillTabs(
                tabs: tabs,
                selectedIndex: selectedTabIndex ?? 0,
                onTabChanged: onTabChanged ?? (_) {},
                activeColor: accent,
              ),
            ),
        ],
      ),
    );
  }

  static Widget listHeaderSection({
    required String title,
    IconData? icon,
    required String primaryActionLabel,
    required VoidCallback onPrimaryAction,
    List<String>? tabs,
    int? selectedTabIndex,
    Function(int)? onTabChanged,
    required TextEditingController searchController,
    required String searchHint,
    Function(String)? onSearchChanged,
    required Widget filterButton,
    required Widget sortButton,
    required Widget pagination,
    bool isPaginationLoading = false,
    Color? accentColor,
  }) {
    final accent = accentColor ?? OrganismTheme.primary;
    final bool hasTabs = tabs != null && tabs.isNotEmpty;
    return Container(
      decoration: const BoxDecoration(
        color: OrganismTheme.surface,
        border: Border(bottom: BorderSide(color: OrganismTheme.border, width: 1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Row 1: Identity & Primary Action
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
            child: Row(
              children: [
                if (icon != null) ...[
                  brandIcon(icon, accent),
                  const SizedBox(width: 12),
                ],
                Expanded(
                  child: Text(
                    title,
                    style: OrganismTheme.textStylePrimary.copyWith(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.2,
                      color: OrganismTheme.textPrimary,
                    ),
                  ),
                ),
                primaryButton(
                  label: primaryActionLabel,
                  onPressed: onPrimaryAction,
                  prefixIcon: LucideIcons.plus,
                  isCompact: true,
                  backgroundColor: accent,
                ),
              ],
            ),
          ),

          // Row 2: Search Section (Full Width)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: headerSearchField(
              controller: searchController,
              onChanged: onSearchChanged,
              hintText: searchHint,
              activeColor: accent,
            ),
          ),

          // Row 3: Controls Row (Pagination Expanded, Filter/Sort Pinned Right)
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
            child: Row(
              children: [
                Expanded(
                  child: pagination,
                ),
                const SizedBox(width: 12),
                filterButton,
                const SizedBox(width: 8),
                sortButton,
              ],
            ),
          ),
          
          if (hasTabs)
            Padding(
              padding: const EdgeInsets.only(bottom: 0),
              child: underlineTabs(
                tabs: tabs,
                selectedIndex: selectedTabIndex ?? 0,
                onTabChanged: onTabChanged ?? (_) {},
                activeColor: accent,
                isFullWidth: true,
              ),
            ),
        ],
      ),
    );
  }

  // --- LISTS (Tissues: Molecules) ---

  // BIOLOGICAL_ERP: Tiered Loading System
  static Widget scrollableList({
    required int itemCount,
    required Widget Function(BuildContext, int) itemBuilder,
    EdgeInsets? padding,
    double separatorHeight = 16,
    ListViewLoadingType loadingType = ListViewLoadingType.none,
    int skeletonCount = 8,
  }) {
    final bool isFullLoad = loadingType == ListViewLoadingType.full || loadingType == ListViewLoadingType.paging;
    final bool isSubtleLoad = loadingType == ListViewLoadingType.subtle;

    return Stack(
      children: [
        AnimatedOpacity(
          duration: const Duration(milliseconds: 300),
          opacity: isSubtleLoad ? 0.6 : 1.0,
          child: ListView.separated(
            padding: padding ?? const EdgeInsets.all(24),
            itemCount: isFullLoad ? skeletonCount : itemCount,
            separatorBuilder: (context, index) => SizedBox(height: separatorHeight),
            itemBuilder: isFullLoad ? (context, index) => listCardSkeleton() : itemBuilder,
          ),
        ),
        if (isSubtleLoad)
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: PreferredSize(
              preferredSize: const Size.fromHeight(2),
              child: LinearProgressIndicator(
                minHeight: 2,
                backgroundColor: Colors.transparent,
                valueColor: AlwaysStoppedAnimation<Color>(OrganismTheme.primary.withOpacity(0.5)),
              ),
            ),
          ),
      ],
    );
  }

  // --- CARDS (Organs: Organisms) ---

  static Widget card({
    required Widget child,
    Color? backgroundColor,
    Color? borderColor,
    double borderWidth = 1.0,
    bool showGlow = false,
    bool isSelected = false,
    EdgeInsets? padding,
    VoidCallback? onTap,
    BorderRadius? borderRadius,
  }) {
    // If borderWidth is 0, we use transparent as the fallback color
    final effectiveBorderColor = borderWidth == 0 ? Colors.transparent : (borderColor ?? OrganismTheme.border);

    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: backgroundColor ?? OrganismTheme.surface,
        borderRadius: borderRadius ?? BorderRadius.zero,
        border: borderWidth > 0 
          ? Border.all(color: effectiveBorderColor, width: borderWidth)
          : null,
        boxShadow: showGlow
            ? [
                BoxShadow(
                  color: (borderColor ?? OrganismTheme.primary).withOpacity(0.1),
                  blurRadius: 10,
                  spreadRadius: 2,
                )
              ]
            : null,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: padding ?? EdgeInsets.zero,
            child: child,
          ),
        ),
      ),
    );
  }

  static Widget list_card_1({
    required String title,
    String? station,
    String? phone,
    String? typeLabel,
    bool isSelected = false,
    VoidCallback? onTap,
  }) {
    // Truncate type label to first 4 chars for extreme density (e.g. CUSTOMER -> CUST)
    final shortType = (typeLabel != null && typeLabel.isNotEmpty)
        ? typeLabel.split(' ').first.substring(0, typeLabel.length > 4 ? 4 : typeLabel.length).toUpperCase()
        : '';

    return card(
      onTap: onTap,
      isSelected: isSelected,
      backgroundColor: isSelected ? OrganismTheme.primary.withOpacity(0.08) : Colors.transparent,
      borderWidth: 0,
      showGlow: false,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Row(
        children: [
          // Empty Thumbnail Placeholder
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: OrganismTheme.background,
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: OrganismTheme.borderSubtle),
            ),
            child: const Icon(LucideIcons.image, size: 16, color: OrganismTheme.textMuted),
          ),
          const SizedBox(width: 12),
          // Content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: OrganismTheme.textStylePrimary.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    if (shortType.isNotEmpty)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: OrganismTheme.primary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          shortType,
                          style: OrganismTheme.textStyleLabel.copyWith(
                            color: OrganismTheme.primary,
                            fontSize: 9,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    if (station != null) ...[
                      const Icon(LucideIcons.mapPin, size: 12, color: OrganismTheme.textMuted),
                      const SizedBox(width: 4),
                      Text(
                        station,
                        style: OrganismTheme.textStyleSecondary.copyWith(fontSize: 12),
                      ),
                    ],
                    const Spacer(),
                    if (phone != null) ...[
                      const Icon(LucideIcons.phone, size: 12, color: OrganismTheme.textMuted),
                      const SizedBox(width: 4),
                      Text(
                        phone,
                        style: OrganismTheme.textStyleSecondary.copyWith(fontSize: 12),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  static Widget list_card_2({
    required String title,
    String? subtitle, // QCode / Category
    String? line3,    // Rates / Commercials
    String? line4,    // Technical Specs (Cut / Packing)
    String? typeLabel,
    bool isSelected = false,
    VoidCallback? onTap,
    IconData icon = LucideIcons.package,
  }) {
    final shortType = (typeLabel != null && typeLabel.isNotEmpty)
        ? typeLabel.split(' ').first.substring(0, typeLabel.length > 4 ? 4 : typeLabel.length).toUpperCase()
        : '';

    return card(
      onTap: onTap,
      isSelected: isSelected,
      backgroundColor: isSelected ? OrganismTheme.primary.withOpacity(0.08) : Colors.transparent,
      borderWidth: 0,
      showGlow: false,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Standardized 42px Thumbnail
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: OrganismTheme.background,
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: OrganismTheme.borderSubtle),
            ),
            child: Icon(icon, size: 18, color: OrganismTheme.textMuted),
          ),
          const SizedBox(width: 12),
          // Content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: OrganismTheme.textStylePrimary.copyWith(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                    ),
                    if (shortType.isNotEmpty)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                        decoration: BoxDecoration(
                          color: OrganismTheme.primary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          shortType,
                          style: OrganismTheme.textStyleLabel.copyWith(
                            color: OrganismTheme.primary,
                            fontSize: 8,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                  ],
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: 1),
                  Text(
                    subtitle,
                    style: OrganismTheme.textStyleSecondary.copyWith(
                      fontSize: 11,
                      color: OrganismTheme.textMuted,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
                if (line3 != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    line3,
                    style: OrganismTheme.textStyleAccent.copyWith(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
                if (line4 != null) ...[
                  const SizedBox(height: 1),
                  Text(
                    line4,
                    style: OrganismTheme.textStyleSecondary.copyWith(
                      fontSize: 10,
                      fontWeight: FontWeight.w500,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Standard high-density card without thumbnails. 
  /// Best for document-like records (VNOs, Cutting Cards) where visual status badge is enough.
  static Widget list_card_3({
    required String title,
    String? subtitle,
    String? line3,
    String? line4,
    String? typeLabel,
    bool isSelected = false,
    VoidCallback? onTap,
    IconData? icon, // Optional trailing/leading icon
  }) {
    final shortType = (typeLabel != null && typeLabel.isNotEmpty)
        ? typeLabel.split(' ').first.substring(0, typeLabel.length > 4 ? 4 : typeLabel.length).toUpperCase()
        : '';

    return card(
      onTap: onTap,
      isSelected: isSelected,
      backgroundColor: isSelected ? OrganismTheme.primary.withOpacity(0.08) : Colors.transparent,
      borderWidth: 0,
      showGlow: false,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: OrganismTheme.textStylePrimary.copyWith(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
              ),
              if (shortType.isNotEmpty)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                  decoration: BoxDecoration(
                    color: OrganismTheme.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    shortType,
                    style: OrganismTheme.textStyleLabel.copyWith(
                      color: OrganismTheme.primary,
                      fontSize: 8,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
            ],
          ),
          if (subtitle != null) ...[
            const SizedBox(height: 1),
            Text(
              subtitle,
              style: OrganismTheme.textStyleSecondary.copyWith(
                fontSize: 11,
                color: OrganismTheme.textMuted,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
          if (line3 != null) ...[
            const SizedBox(height: 4),
            Text(
              line3,
              style: OrganismTheme.textStyleAccent.copyWith(
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
          if (line4 != null) ...[
            const SizedBox(height: 1),
            Text(
              line4,
              style: OrganismTheme.textStyleSecondary.copyWith(
                fontSize: 10,
                fontWeight: FontWeight.w500,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ],
      ),
    );
  }

  static Widget featureCard({
    required IconData icon,
    required String title,
    required String description,
    Color? iconColor,
    Color? iconBgColor,
    Color? backgroundColor,
    Color? borderColor,
    VoidCallback? onTap,
  }) {
    return card(
      onTap: onTap,
      backgroundColor: backgroundColor,
      borderColor: borderColor,
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: iconBgColor ?? OrganismTheme.slate50,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: OrganismTheme.borderSubtle),
            ),
            child: Icon(icon, size: 20, color: iconColor ?? OrganismTheme.primary),
          ),
          const SizedBox(height: 16),
          Text(
            title,
            style: OrganismTheme.textStylePrimary.copyWith(
              fontSize: 15,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            description,
            style: OrganismTheme.textStyleSecondary.copyWith(
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  static Widget metricCard({
    required String label,
    required String value,
    required String trendText,
    required bool isTrendUp,
    Color? backgroundColor,
    Color? borderColor,
    VoidCallback? onTap,
  }) {
    final trendColor = isTrendUp ? OrganismTheme.success : OrganismTheme.error;
    final trendIcon = isTrendUp ? LucideIcons.arrowUp : LucideIcons.arrowDown;

    return card(
      onTap: onTap,
      backgroundColor: backgroundColor,
      borderColor: borderColor,
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label.toUpperCase(),
            style: OrganismTheme.textStyleLabel,
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: OrganismTheme.textStylePrimary.copyWith(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              letterSpacing: -1,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(trendIcon, size: 14, color: trendColor),
              const SizedBox(width: 4),
              Text(
                trendText,
                style: OrganismTheme.textStyleSecondary.copyWith(
                  fontSize: 12,
                  color: trendColor,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  static Widget contentCard({
    required String title,
    required String description,
    String? badgeText,
    Color? badgeColor,
    Color? badgeTextColor,
    Widget? footerLeading,
    Widget? footerTrailing,
    Color? backgroundColor,
    Color? borderColor,
    VoidCallback? onTap,
  }) {
    return card(
      onTap: onTap,
      backgroundColor: backgroundColor,
      borderColor: borderColor,
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      title,
                      style: OrganismTheme.textStylePrimary.copyWith(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (badgeText != null)
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color:
                              badgeColor ?? OrganismTheme.success.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          badgeText,
                          style: OrganismTheme.textStylePrimary.copyWith(
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                              color: badgeTextColor ?? OrganismTheme.success),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  description,
                  style: OrganismTheme.textStylePrimary.copyWith(
                      fontSize: 14,
                      color: OrganismTheme.textSecondary,
                      height: 1.5),
                ),
              ],
            ),
          ),
          if (footerLeading != null || footerTrailing != null) ...[
            Divider(height: 1, color: borderColor ?? OrganismTheme.borderSubtle),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  footerLeading ?? const SizedBox.shrink(),
                  footerTrailing ?? const SizedBox.shrink(),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  static Widget mediaCard({
    required String imageUrl,
    required String title,
    required String description,
    bool isNetwork = true,
    Color? backgroundColor,
    Color? borderColor,
    VoidCallback? onTap,
  }) {
    return card(
      onTap: onTap,
      backgroundColor: backgroundColor,
      borderColor: borderColor,
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            height: 140,
            width: double.infinity,
            child: isNetwork
                ? Image.network(imageUrl, fit: BoxFit.cover, errorBuilder:
                    (context, error, stackTrace) {
                    return Container(color: OrganismTheme.borderSubtle);
                  })
                : Image.asset(imageUrl, fit: BoxFit.cover),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: OrganismTheme.textStylePrimary.copyWith(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                ),
                const SizedBox(height: 8),
                Text(
                  description,
                  style: OrganismTheme.textStylePrimary.copyWith(
                      fontSize: 14,
                      color: OrganismTheme.textSecondary,
                      height: 1.5),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  // --- UTILITIES (Organelles: Machinery) ---

  static Widget spinner({double size = 20, Color? color}) {
    return SizedBox(
      width: size,
      height: size,
      child: CircularProgressIndicator(
        strokeWidth: 2,
        valueColor: AlwaysStoppedAnimation<Color>(color ?? OrganismTheme.primary),
      ),
    );
  }

  static Widget skeleton({
    double? width,
    double height = 20,
    double radius = 8,
    Color? color,
  }) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: color ?? OrganismTheme.borderSubtle.withOpacity(0.5),
        borderRadius: BorderRadius.circular(radius),
      ),
    );
  }

  /// A high-density card skeleton that matches the layout of detailedCard.
  static Widget listCardSkeleton() {
    return card(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      borderWidth: 0,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              skeleton(width: 140, height: 16, radius: 4),
              skeleton(width: 40, height: 12, radius: 4),
            ],
          ),
          const SizedBox(height: 8),
          skeleton(width: 220, height: 12, radius: 4),
          const SizedBox(height: 12),
          skeleton(width: 130, height: 14, radius: 4),
          const SizedBox(height: 8),
          skeleton(width: 170, height: 10, radius: 4),
        ],
      ),
    );
  }

  static Widget dataField({
    required String label,
    required String value,
    bool isMono = true,
    Color? labelColor,
    Color? valueColor,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label.toUpperCase(),
          style: OrganismTheme.textStyleLabel.copyWith(
              color: labelColor ?? OrganismTheme.textMuted),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: (isMono
                  ? OrganismTheme.textStyleMono
                  : OrganismTheme.textStylePrimary.copyWith(
                      fontSize: 14,
                    ))
              .copyWith(color: valueColor ?? OrganismTheme.textPrimary),
        ),
      ],
    );
  }

  /// A compact, high-density KPI label used in card vitals trays.
  static Widget vitalsLabel({
    required String label,
    required String value,
    Color? color,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label.toUpperCase(),
          style: OrganismTheme.textStyleLabel.copyWith(
            fontSize: 9,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: OrganismTheme.textStyleMono.copyWith(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: color ?? OrganismTheme.textPrimary,
          ),
        ),
      ],
    );
  }

  // --- KEYBOARD (Organelles) ---

  /// A dense, flat container representing a keyboard shortcut (e.g. [Ctrl N])
  /// Designed to be used inline as trailing icons in buttons or form inputs.
  static Widget kbdShortcut(List<dynamic> keys, {Color? backgroundColor, Color? textColor, Color? borderColor}) {
    final bg = backgroundColor ?? OrganismTheme.surface;
    final textCol = textColor ?? OrganismTheme.textSecondary;
    final bColor = borderColor ?? OrganismTheme.border;

    return Container(
      height: 22,
      padding: const EdgeInsets.symmetric(horizontal: 6),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: bColor, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            offset: const Offset(0, 1.5),
            blurRadius: 2,
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: List.generate(keys.length * 2 - 1, (index) {
          if (index.isOdd) {
            return const SizedBox(width: 4); // Tight spacing between keys, no '+'
          }
          
          final keyBlock = keys[index ~/ 2];
          if (keyBlock is Widget) return keyBlock;
          if (keyBlock is String) {
            String label = keyBlock;
            IconData? icon;
            
            if (keyBlock.toLowerCase() == 'win' || keyBlock.toLowerCase() == 'windows') {
              icon = LucideIcons.layoutGrid;
              label = '';
            } else if (keyBlock.toLowerCase() == 'cmd' || keyBlock.toLowerCase() == 'command') {
              icon = LucideIcons.command;
              label = '';
            } else if (keyBlock.toLowerCase() == 'space') {
              label = 'Space';
            }

            return Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (icon != null) ...[
                  Padding(
                    padding: const EdgeInsets.only(bottom: 1), // Align icon with text
                    child: Icon(icon, size: 10, color: textCol),
                  ),
                  if (label.isNotEmpty) const SizedBox(width: 2),
                ],
                if (label.isNotEmpty)
                  Text(
                    label,
                    style: OrganismTheme.textStylePrimary.copyWith(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: textCol,
                    ),
                  ),
              ],
            );
          }
          return const SizedBox.shrink();
        }),
      ),
    );
  }


  // ─── STEP 1: FEEDBACK (Organelles: New) ─────────────────────────────────────

  /// Empty state placeholder shown when a list has no records.
  static Widget emptyState({
    required IconData icon,
    required String title,
    String? subtitle,
    String? actionLabel,
    VoidCallback? onAction,
    Color? accentColor,
  }) {
    final accent = accentColor ?? OrganismTheme.primary;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: accent.withOpacity(0.08),
                shape: BoxShape.circle,
                border: Border.all(color: accent.withOpacity(0.2)),
              ),
              child: Icon(icon, size: 28, color: accent.withOpacity(0.6)),
            ),
            const SizedBox(height: 20),
            Text(
              title,
              style: OrganismTheme.textStylePrimary.copyWith(
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
            if (subtitle != null) ...[
              const SizedBox(height: 8),
              Text(
                subtitle,
                style: OrganismTheme.textStyleMuted.copyWith(
                  fontSize: 13,
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
            ],
            if (actionLabel != null && onAction != null) ...[
              const SizedBox(height: 24),
              outlineButton(
                label: actionLabel,
                onPressed: onAction,
                isCompact: true,
              ),
            ],
          ],
        ),
      ),
    );
  }

  /// A small pulsing dot + label for showing connection/sync status.
  static Widget statusDot({
    required String label,
    required bool isActive,
    Color? color,
  }) {
    final dotColor =
        color ?? (isActive ? OrganismTheme.success : OrganismTheme.textMuted);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: dotColor,
            shape: BoxShape.circle,
            boxShadow: isActive
                ? [
                    BoxShadow(
                        color: dotColor.withOpacity(0.45),
                        blurRadius: 6,
                        spreadRadius: 1)
                  ]
                : null,
          ),
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: OrganismTheme.textStylePrimary.copyWith(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: OrganismTheme.textSecondary,
          ),
        ),
      ],
    );
  }

  /// Inline alert banner for form validation or page-level notices.
  static Widget alertBanner({
    required String message,
    required AlertType type,
    String? title,
    VoidCallback? onDismiss,
  }) {
    late Color bgColor;
    late Color borderColor;
    late Color tintColor;
    late IconData iconData;

    switch (type) {
      case AlertType.success:
        bgColor = OrganismTheme.success.withOpacity(0.08);
        borderColor = OrganismTheme.success.withOpacity(0.3);
        tintColor = OrganismTheme.success;
        iconData = LucideIcons.checkCircle2;
        break;
      case AlertType.warning:
        bgColor = OrganismTheme.warning.withOpacity(0.08);
        borderColor = OrganismTheme.warning.withOpacity(0.3);
        tintColor = OrganismTheme.warning;
        iconData = LucideIcons.alertTriangle;
        break;
      case AlertType.error:
        bgColor = OrganismTheme.error.withOpacity(0.08);
        borderColor = OrganismTheme.error.withOpacity(0.3);
        tintColor = OrganismTheme.error;
        iconData = LucideIcons.alertCircle;
        break;
      case AlertType.info:
        bgColor = OrganismTheme.info.withOpacity(0.08);
        borderColor = OrganismTheme.info.withOpacity(0.3);
        tintColor = OrganismTheme.info;
        iconData = LucideIcons.info;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: borderColor),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 1),
            child: Icon(iconData, size: 15, color: tintColor),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (title != null) ...[
                  Text(
                    title,
                    style: OrganismTheme.textStylePrimary.copyWith(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: tintColor,
                    ),
                  ),
                  const SizedBox(height: 2),
                ],
                Text(
                  message,
                  style: OrganismTheme.textStylePrimary.copyWith(
                    fontSize: 13,
                    color: tintColor,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
          if (onDismiss != null) ...[
            const SizedBox(width: 8),
            GestureDetector(
              onTap: onDismiss,
              child: Icon(LucideIcons.x,
                  size: 14, color: tintColor.withOpacity(0.7)),
            ),
          ],
        ],
      ),
    );
  }

  /// Horizontal progress bar with optional label and percentage.
  static Widget progressBar({
    required double value,
    String? label,
    String? valueLabel,
    Color? accentColor,
    double height = 6,
  }) {
    final accent = accentColor ?? OrganismTheme.primary;
    final clamped = value.clamp(0.0, 1.0);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label != null || valueLabel != null)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                if (label != null)
                  Text(label,
                      style: OrganismTheme.textStylePrimary.copyWith(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: OrganismTheme.textSecondary)),
                if (valueLabel != null)
                  Text(valueLabel,
                      style: OrganismTheme.textStyleMono.copyWith(
                          fontSize: 11, color: accent)),
              ],
            ),
          ),
        Container(
          height: height,
          decoration: BoxDecoration(
            color: OrganismTheme.borderSubtle,
            borderRadius: BorderRadius.circular(99),
          ),
          child: FractionallySizedBox(
            alignment: Alignment.centerLeft,
            widthFactor: clamped,
            child: Container(
              decoration: BoxDecoration(
                color: accent,
                borderRadius: BorderRadius.circular(99),
              ),
            ),
          ),
        ),
      ],
    );
  }

  /// Circular count badge — for notification counts on nav items.
  static Widget countBadge({
    required int count,
    Color? backgroundColor,
    Color? textColor,
    double size = 20,
  }) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: backgroundColor ?? OrganismTheme.primary,
        shape: BoxShape.circle,
      ),
      alignment: Alignment.center,
      child: Text(
        count > 99 ? '99+' : '$count',
        style: OrganismTheme.textStylePrimary.copyWith(
          fontSize: size * 0.50,
          fontWeight: FontWeight.bold,
          color: textColor ?? Colors.white,
        ),
      ),
    );
  }

  // ─── STEP 2: OVERLAYS (Organelles: New) ─────────────────────────────────────

  /// Shows a styled SnackBar toast using ScaffoldMessenger.
  static void showToast({
    required BuildContext context,
    required String message,
    ToastType type = ToastType.success,
    Duration duration = const Duration(seconds: 3),
  }) {
    late Color bgColor;
    late IconData iconData;

    switch (type) {
      case ToastType.success:
        bgColor = OrganismTheme.success;
        iconData = LucideIcons.checkCircle2;
        break;
      case ToastType.warning:
        bgColor = OrganismTheme.warning;
        iconData = LucideIcons.alertTriangle;
        break;
      case ToastType.error:
        bgColor = OrganismTheme.error;
        iconData = LucideIcons.alertCircle;
        break;
      case ToastType.info:
        bgColor = OrganismTheme.info;
        iconData = LucideIcons.info;
        break;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        duration: duration,
        backgroundColor: Colors.transparent,
        elevation: 0,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 24),
        content: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.white.withOpacity(0.15)),
          ),
          child: Row(
            children: [
              Icon(iconData, size: 16, color: Colors.white),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  message,
                  style: OrganismTheme.textStylePrimary.copyWith(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Shows a confirm/danger dialog. Returns true if confirmed, false/null if cancelled.
  static Future<bool?> showConfirmDialog({
    required BuildContext context,
    required String title,
    required String message,
    String confirmLabel = 'Confirm',
    String cancelLabel = 'Cancel',
    bool isDanger = false,
    IconData? icon,
  }) {
    final accentColor = isDanger ? OrganismTheme.error : OrganismTheme.primary;
    return showDialog<bool>(
      context: context,
      barrierColor: Colors.black.withOpacity(0.4),
      builder: (ctx) => Dialog(
        backgroundColor: OrganismTheme.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: OrganismTheme.border),
        ),
        elevation: 0,
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: SizedBox(
            width: 400,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: accentColor.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                            color: accentColor.withOpacity(0.2)),
                      ),
                      child: Icon(
                        icon ??
                            (isDanger
                                ? LucideIcons.alertTriangle
                                : LucideIcons.shieldCheck),
                        size: 16,
                        color: accentColor,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        title,
                        style: OrganismTheme.textStylePrimary.copyWith(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: OrganismTheme.textPrimary,
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: () => Navigator.of(ctx).pop(false),
                      child: const Icon(LucideIcons.x,
                          size: 16, color: OrganismTheme.textMuted),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                const Divider(color: OrganismTheme.borderSubtle, height: 1),
                const SizedBox(height: 16),
                Text(
                  message,
                  style: OrganismTheme.textStylePrimary.copyWith(
                    fontSize: 14,
                    color: OrganismTheme.textSecondary,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    outlineButton(
                      label: cancelLabel,
                      onPressed: () => Navigator.of(ctx).pop(false),
                      isCompact: true,
                    ),
                    const SizedBox(width: 12),
                    isDanger
                        ? dangerButton(
                            label: confirmLabel,
                            onPressed: () => Navigator.of(ctx).pop(true),
                            isCompact: true,
                          )
                        : primaryButton(
                            label: confirmLabel,
                            onPressed: () => Navigator.of(ctx).pop(true),
                            isCompact: true,
                          ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// A right-side slide-in drawer shell with a fixed header + close button.
  /// Wrap in a Stack/Overlay to use as a true drawer; or inline for preview.
  static Widget drawerShell({
    required String title,
    required Widget child,
    required VoidCallback onClose,
    List<Widget>? actions,
    double width = 380,
  }) {
    return Container(
      width: width,
      decoration: const BoxDecoration(
        color: OrganismTheme.surface,
        border: Border(left: BorderSide(color: OrganismTheme.border)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Container(
            height: 56,
            padding: const EdgeInsets.symmetric(horizontal: 24),
            decoration: const BoxDecoration(
              color: OrganismTheme.surface,
              border: Border(bottom: BorderSide(color: OrganismTheme.border)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    title,
                    style: OrganismTheme.textStylePrimary.copyWith(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                if (actions != null) ...actions,
                if (actions != null) const SizedBox(width: 8),
                iconButton(
                  icon: LucideIcons.x,
                  onPressed: onClose,
                  size: OrganismTheme.buttonHeightCompact,
                  showBorder: false,
                ),
              ],
            ),
          ),
          // Content
          Expanded(child: child),
        ],
      ),
    );
  }

  // ─── STEP 3: DATA DISPLAY ────────────────────────────────────────────────────

  /// Dense ERP data table with optional row selection and sort indicators.
  static Widget dataTable({
    required List<String> columns,
    required List<List<String>> rows,
    List<TextAlign>? columnAligns,
    List<double>? columnFlex,
    int? selectedIndex,
    Function(int)? onRowTap,
    Color? accentColor,
    int? sortColumnIndex,
    bool sortAscending = true,
    Function(int)? onSort,
  }) {
    final accent = accentColor ?? OrganismTheme.primary;
    final n = columns.length;
    final aligns = columnAligns ?? List.filled(n, TextAlign.left);
    final flexes =
        columnFlex?.map((f) => (f * 10).round()).toList() ?? List.filled(n, 10);

    return Container(
      decoration: BoxDecoration(
        color: OrganismTheme.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: OrganismTheme.border),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header row
          Container(
            height: 34,
            color: OrganismTheme.borderSubtle,
            child: Row(
              children: [
                for (int i = 0; i < n; i++)
                  Expanded(
                    flex: flexes[i],
                    child: InkWell(
                      onTap: onSort != null ? () => onSort(i) : null,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        child: Row(
                          mainAxisAlignment: aligns[i] == TextAlign.right
                              ? MainAxisAlignment.end
                              : aligns[i] == TextAlign.center
                                  ? MainAxisAlignment.center
                                  : MainAxisAlignment.start,
                          children: [
                            Flexible(
                              child: Text(
                                columns[i].toUpperCase(),
                                style: OrganismTheme.textStyleLabel.copyWith(
                                  color: OrganismTheme.textMuted,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            if (sortColumnIndex == i && onSort != null) ...[
                              const SizedBox(width: 3),
                              Icon(
                                sortAscending
                                    ? LucideIcons.chevronUp
                                    : LucideIcons.chevronDown,
                                size: 10,
                                color: accent,
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          // Data rows
          ...rows.asMap().entries.map((entry) {
            final rowIdx = entry.key;
            final rowData = entry.value;
            final isSelected = selectedIndex == rowIdx;
            final isLast = rowIdx == rows.length - 1;
            return InkWell(
              onTap: onRowTap != null ? () => onRowTap(rowIdx) : null,
              child: Container(
                height: 36,
                decoration: BoxDecoration(
                  color: isSelected
                      ? accent.withOpacity(0.06)
                      : rowIdx.isEven
                          ? OrganismTheme.surface
                          : OrganismTheme.background,
                  border: isLast
                      ? null
                      : const Border(
                          bottom: BorderSide(color: OrganismTheme.borderSubtle)),
                ),
                child: Row(
                  children: [
                    for (int i = 0;
                        i < rowData.length && i < n;
                        i++)
                      Expanded(
                        flex: flexes[i],
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                          child: Text(
                            rowData[i],
                            textAlign: aligns[i],
                            style: OrganismTheme.textStyleMono.copyWith(
                              fontSize: 12,
                              color: isSelected ? accent : OrganismTheme.textPrimary,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  /// Horizontal step-progress indicator for multi-stage workflows.
  static Widget stepIndicator({
    required List<String> steps,
    required int currentStep,
    Color? accentColor,
  }) {
    final accent = accentColor ?? OrganismTheme.primary;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (int i = 0; i < steps.length; i++) ...[
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: i <= currentStep ? accent : OrganismTheme.surface,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: i <= currentStep ? accent : OrganismTheme.border,
                    width: 2,
                  ),
                ),
                child: i < currentStep
                    ? const Icon(LucideIcons.check, size: 13, color: Colors.white)
                    : Center(
                        child: Text(
                          '${i + 1}',
                          style: OrganismTheme.textStylePrimary.copyWith(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: i == currentStep
                                ? Colors.white
                                : OrganismTheme.textMuted,
                          ),
                        ),
                      ),
              ),
              const SizedBox(height: 6),
              SizedBox(
                width: 64,
                child: Text(
                  steps[i],
                  style: OrganismTheme.textStylePrimary.copyWith(
                    fontSize: 10,
                    fontWeight: i == currentStep
                        ? FontWeight.w600
                        : FontWeight.w400,
                    color: i == currentStep
                        ? accent
                        : i < currentStep
                            ? OrganismTheme.textSecondary
                            : OrganismTheme.textMuted,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                ),
              ),
            ],
          ),
          if (i < steps.length - 1)
            Expanded(
              child: Container(
                height: 2,
                margin: const EdgeInsets.only(top: 13),
                color: i < currentStep ? accent : OrganismTheme.borderSubtle,
              ),
            ),
        ],
      ],
    );
  }

  /// Production pipeline stage tracker — for the O3→O4→O5 dispatch chain.
  static Widget pipelineStage({
    required List<PipelineStageData> stages,
    Color? accentColor,
  }) {
    final accent = accentColor ?? OrganismTheme.primary;
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (int i = 0; i < stages.length; i++) ...[
            _buildPipelineChip(stages[i], accent),
            if (i < stages.length - 1)
              Padding(
                padding: const EdgeInsets.only(top: 12, left: 4, right: 4),
                child: Icon(
                  LucideIcons.chevronRight,
                  size: 16,
                  color: stages[i].status == PipelineStatus.done
                      ? accent
                      : OrganismTheme.textMuted,
                ),
              ),
          ],
        ],
      ),
    );
  }

  static Widget _buildPipelineChip(PipelineStageData stage, Color accent) {
    late Color borderColor;
    late Color bgColor;
    late Color labelColor;
    late Color countBg;
    late Color countFg;

    switch (stage.status) {
      case PipelineStatus.done:
        borderColor = OrganismTheme.success.withOpacity(0.4);
        bgColor = OrganismTheme.success.withOpacity(0.06);
        labelColor = OrganismTheme.success;
        countBg = OrganismTheme.success;
        countFg = Colors.white;
        break;
      case PipelineStatus.active:
        borderColor = accent.withOpacity(0.5);
        bgColor = accent.withOpacity(0.06);
        labelColor = accent;
        countBg = accent;
        countFg = Colors.white;
        break;
      case PipelineStatus.pending:
        borderColor = OrganismTheme.border;
        bgColor = OrganismTheme.surface;
        labelColor = OrganismTheme.textMuted;
        countBg = OrganismTheme.borderSubtle;
        countFg = OrganismTheme.textMuted;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                stage.seriesCode,
                style: OrganismTheme.textStyleMono.copyWith(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: labelColor,
                ),
              ),
              const SizedBox(width: 6),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: countBg,
                  borderRadius: BorderRadius.circular(99),
                ),
                child: Text(
                  '${stage.count}',
                  style: OrganismTheme.textStylePrimary.copyWith(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: countFg,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            stage.label,
            style: OrganismTheme.textStylePrimary.copyWith(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: labelColor,
            ),
          ),
        ],
      ),
    );
  }

  /// Groups a list of row widgets under a labelled section header.
  static Widget groupedRows({
    required String groupLabel,
    required List<Widget> rows,
    int? count,
    Color? accentColor,
  }) {
    final accent = accentColor ?? OrganismTheme.primary;
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: OrganismTheme.border),
        borderRadius: BorderRadius.circular(8),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            height: 32,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            color: OrganismTheme.borderSubtle,
            child: Row(
              children: [
                Text(
                  groupLabel.toUpperCase(),
                  style: OrganismTheme.textStylePrimary.copyWith(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: OrganismTheme.textMuted,
                    letterSpacing: 0.8,
                  ),
                ),
                const Spacer(),
                if (count != null)
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: accent.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(99),
                      border: Border.all(color: accent.withOpacity(0.2)),
                    ),
                    child: Text(
                      '$count',
                      style: OrganismTheme.textStylePrimary.copyWith(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: accent,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const Divider(height: 1, color: OrganismTheme.border),
          ...rows,
        ],
      ),
    );
  }

  // ─── STEP 4: FORMS & LAYOUT ──────────────────────────────────────────────────

  /// Two-column form row: label on the left, child widget on the right.
  /// Used in slip entry, party master, and detail drawer forms.
  static Widget formRow({
    required String label,
    required Widget child,
    bool isRequired = false,
    String? hint,
    double labelFlex = 1.0,
    double fieldFlex = 2.0,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Label column
          SizedBox(
            width: 120,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    label,
                    style: OrganismTheme.textStylePrimary.copyWith(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: OrganismTheme.textSecondary,
                    ),
                  ),
                ),
                if (isRequired)
                  Text(
                    ' *',
                    style: OrganismTheme.textStylePrimary.copyWith(
                      fontSize: 13,
                      color: OrganismTheme.error,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          // Field column
          Expanded(child: child),
        ],
      ),
    );
  }

  /// Date range display widget — shows From/To dates with a calendar icon tap.
  static Widget dateRangePicker({
    required String fromDate,
    required String toDate,
    VoidCallback? onTap,
    Color? accentColor,
    String label = 'Date Range',
  }) {
    final accent = accentColor ?? OrganismTheme.primary;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: OrganismTheme.surface,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: OrganismTheme.border),
        ),
        child: Row(
          children: [
            Icon(LucideIcons.calendarDays, size: 16, color: accent),
            const SizedBox(width: 10),
            Flexible(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    label.toUpperCase(),
                    style: OrganismTheme.textStyleLabel.copyWith(
                      fontSize: 9,
                      letterSpacing: 0.6,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Flexible(
                        child: Text(
                          fromDate,
                          style: OrganismTheme.textStyleMono.copyWith(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: OrganismTheme.textPrimary,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 6),
                        child: Icon(
                          LucideIcons.arrowRight,
                          size: 12,
                          color: OrganismTheme.textMuted,
                        ),
                      ),
                      Flexible(
                        child: Text(
                          toDate,
                          style: OrganismTheme.textStyleMono.copyWith(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: OrganismTheme.textPrimary,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            const Icon(LucideIcons.chevronDown, size: 14, color: OrganismTheme.textMuted),
          ],
        ),
      ),
    );
  }

  /// Bulk action bar — appears when 1+ rows are selected in a table.
  static Widget bulkActionBar({
    required int selectedCount,
    required List<Widget> actions,
    VoidCallback? onClearSelection,
    Color? accentColor,
  }) {
    final accent = accentColor ?? OrganismTheme.primary;
    return Container(
      height: 48,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: accent.withOpacity(0.08),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: accent.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          // Selection count chip
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: accent,
              borderRadius: BorderRadius.circular(99),
            ),
            child: Text(
              '$selectedCount selected',
              style: OrganismTheme.textStylePrimary.copyWith(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(width: 12),
          // Action buttons
          ...actions,
          const Spacer(),
          // Clear selection
          if (onClearSelection != null)
            InkWell(
              onTap: onClearSelection,
              borderRadius: BorderRadius.circular(6),
              child: Padding(
                padding: const EdgeInsets.all(6),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(LucideIcons.x, size: 14, color: OrganismTheme.textMuted),
                    const SizedBox(width: 4),
                    Text(
                      'Clear',
                      style: OrganismTheme.textStylePrimary.copyWith(
                        fontSize: 12,
                        color: OrganismTheme.textMuted,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  /// Toggleable filter chip for filter bars and tag selectors.
  static Widget filterChip({
    required String label,
    required bool isActive,
    required VoidCallback onTap,
    IconData? icon,
    Color? accentColor,
    int? count,
  }) {
    final accent = accentColor ?? OrganismTheme.primary;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: EdgeInsets.symmetric(
          horizontal: count != null ? 8 : 12,
          vertical: 6,
        ),
        decoration: BoxDecoration(
          color: isActive ? accent.withOpacity(0.1) : OrganismTheme.surface,
          borderRadius: BorderRadius.circular(99),
          border: Border.all(
            color: isActive ? accent.withOpacity(0.5) : OrganismTheme.border,
            width: isActive ? 1.5 : 1.0,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(
                icon,
                size: 13,
                color: isActive ? accent : OrganismTheme.textMuted,
              ),
              const SizedBox(width: 5),
            ],
            Text(
              label,
              style: (isActive
                      ? OrganismTheme.textStyleAccent
                      : OrganismTheme.textStyleSecondary)
                  .copyWith(
                fontSize: 12,
                fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
              ),
            ),
            if (count != null) ...[
              const SizedBox(width: 5),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                decoration: BoxDecoration(
                  color: isActive ? accent : OrganismTheme.borderSubtle,
                  borderRadius: BorderRadius.circular(99),
                ),
                child: Text(
                  '$count',
                  style: OrganismTheme.textStyleSecondary.copyWith(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: isActive ? Colors.white : OrganismTheme.textMuted,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  // ─── STEP 5: SYSTEMS (Layouts) ──────────────────────────────────────────────

  /// The standard split-pane layout for Master data & Transactions.
  static Widget layoutSplitPane({
    required Widget leftPane,
    required Widget rightPane,
    double leftWidth = OrganismTheme.masterPaneWidth,
    Color? backgroundColor,
  }) {
    return Container(
      color: backgroundColor ?? OrganismTheme.background,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: leftWidth,
            decoration: const BoxDecoration(
              color: OrganismTheme.surface,
              border: Border(right: BorderSide(color: OrganismTheme.border)),
            ),
            child: leftPane,
          ),
          Expanded(child: rightPane),
        ],
      ),
    );
  }

  /// Standard single focus page (e.g., Settings, Auth, Isolated reports).
  static Widget layoutCardPage({
    required Widget header,
    required Widget body,
    Color? backgroundColor,
    double maxWidth = 1000,
  }) {
    return Container(
      color: backgroundColor ?? OrganismTheme.background,
      child: Column(
        children: [
          header,
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Center(
                child: ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: maxWidth),
                  child: body,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// KPI and Summary Grids. Responsive wrap layout natively padding cards.
  static Widget layoutDashboard({
    required Widget header,
    required List<Widget> cards,
    Color? backgroundColor,
  }) {
    return Container(
      color: backgroundColor ?? OrganismTheme.background,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          header,
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Wrap(
                spacing: 24,
                runSpacing: 24,
                children: cards,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Full-width, margin-less data tables spanning edge-to-edge.
  static Widget layoutDataGrid({
    required Widget header,
    required Widget gridView, // Typically a DataTable or custom grid
    Widget? footer,
  }) {
    return Container(
      color: OrganismTheme.surface,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          header,
          Expanded(child: gridView),
          if (footer != null) footer,
        ],
      ),
    );
  }

  /// Visual tracking of workflow pipelines.
  static Widget layoutKanban({
    required Widget header,
    required List<Widget> columns, // Each column is a vertical fixed width list
    Color? backgroundColor,
  }) {
    return Container(
      color: backgroundColor ?? OrganismTheme.background,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          header,
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.all(24),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: columns.map((col) => Padding(
                  padding: const EdgeInsets.only(right: 24),
                  child: col,
                )).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Complex, guided linear processes.
  static Widget layoutWizard({
    required Widget header,
    required Widget stepTracker,
    required Widget currentStepContent,
    required Widget footerActions,
    double maxWidth = 800,
  }) {
    return Container(
      color: OrganismTheme.background,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          header,
          Container(
            padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 24),
            decoration: const BoxDecoration(
              color: OrganismTheme.surface,
              border: Border(bottom: BorderSide(color: OrganismTheme.border)),
            ),
            child: Center(
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: maxWidth),
                child: stepTracker,
              ),
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(32),
              child: Center(
                child: ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: maxWidth),
                  child: card(child: currentStepContent),
                ),
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
            decoration: const BoxDecoration(
              color: OrganismTheme.surface,
              border: Border(top: BorderSide(color: OrganismTheme.border)),
            ),
            child: Center(
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: maxWidth),
                child: footerActions,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─── STEP 6: FORM STATES (Read Only) ────────────────────────────────────────

  /// A field designed for viewing records before entering "Edit" mode.
  /// Blends directly into the background without borders, using typography for hierarchy.
  /// Mimics the size footprint of `inputField` to prevent layout jumps.
  static Widget readOnlyField({
    required String label,
    required String value,
    bool isMono = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label.toUpperCase(),
          style: OrganismTheme.textStylePrimary.copyWith(
            fontSize: 11,
            fontWeight: FontWeight.bold,
            color: OrganismTheme.textMuted,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
          decoration: BoxDecoration(
            color: OrganismTheme.slate50, // very light background to distinguish bounding box subtly
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.transparent), // maintains identical dimension logic
          ),
          child: Text(
            value,
            style: isMono ? 
              OrganismTheme.textStyleMono.copyWith(fontSize: 15, color: OrganismTheme.textPrimary) :
              OrganismTheme.textStylePrimary.copyWith(fontSize: 15, fontWeight: FontWeight.w500, color: OrganismTheme.textPrimary),
          ),
        ),
      ],
    );
  }
}

enum BadgeType { success, warning, error, info, neutral, accent }

enum AlertType { success, warning, error, info }

class _SearchField extends StatefulWidget {
  final TextEditingController controller;
  final String hintText;
  final ValueChanged<String>? onChanged;
  final Color? accentColor;
  final bool isFormStyle;

  const _SearchField({
    required this.controller,
    required this.hintText,
    this.onChanged,
    this.accentColor,
    this.isFormStyle = false,
  });

  @override
  _SearchFieldState createState() => _SearchFieldState();
}

class _SearchFieldState extends State<_SearchField> {
  final FocusNode _focusNode = FocusNode();
  bool _isHovered = false;
  bool _isFocused = false;

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(_onFocusChange);
  }

  @override
  void dispose() {
    _focusNode.removeListener(_onFocusChange);
    _focusNode.dispose();
    super.dispose();
  }

  void _onFocusChange() {
    setState(() {
      _isFocused = _focusNode.hasFocus;
    });
  }

  @override
  Widget build(BuildContext context) {
    final accent = widget.accentColor ?? OrganismTheme.primary;

    final isForm = widget.isFormStyle;

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      cursor: SystemMouseCursors.text,
      child: SizedBox(
        height: isForm ? 56 : 40,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          decoration: BoxDecoration(
            color: OrganismTheme.surface,
            borderRadius: BorderRadius.circular(6),
            border: Border.all(
              color: _isFocused
                  ? accent
                  : (_isHovered
                      ? OrganismTheme.textSecondary.withOpacity(0.5)
                      : OrganismTheme.borderSubtle),
              width: _isFocused ? 1.5 : 1.0,
            ),
          ),
          alignment: Alignment.center,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(6), // Synchronize with container
            child: TextField(
              controller: widget.controller,
              focusNode: _focusNode,
              onChanged: (val) {
                setState(() {});
                widget.onChanged?.call(val);
              },
              cursorColor: accent,
              textAlignVertical: TextAlignVertical.center,
              style: OrganismTheme.textStylePrimary.copyWith(
                fontSize: 14,
                color: OrganismTheme.textPrimary,
                decoration: TextDecoration.none,
                height: 1.0,
              ),
              decoration: InputDecoration(
                isDense: true,
                hintText: widget.hintText,
                hintStyle: const TextStyle(
                  color: OrganismTheme.textMuted,
                  fontSize: 13,
                ),
                prefixIcon: Icon(
                  LucideIcons.search,
                  size: 16,
                  color: (_isFocused || _isHovered) ? accent : OrganismTheme.textMuted,
                ),
                prefixIconConstraints: const BoxConstraints(minWidth: 38, minHeight: 38),
                suffixIcon: widget.controller.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(LucideIcons.xCircle, size: 14),
                        color: OrganismTheme.textMuted,
                        onPressed: () {
                          widget.controller.clear();
                          setState(() {});
                          widget.onChanged?.call('');
                        },
                        splashRadius: 18,
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(minWidth: 38, minHeight: 38),
                      )
                    : null,
                suffixIconConstraints: const BoxConstraints(minWidth: 38, minHeight: 38),
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                contentPadding: EdgeInsets.zero,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

enum ToastType { success, warning, error, info }

enum PipelineStatus { pending, active, done }

// BIOLOGICAL_ERP: Loading States
enum ListViewLoadingType { none, full, paging, subtle }


/// Data model for a single stage in the production pipeline.
class PipelineStageData {
  final String seriesCode; // e.g. 'O4'
  final String label;      // e.g. 'Work In House'
  final int count;
  final PipelineStatus status;

  const PipelineStageData({
    required this.seriesCode,
    required this.label,
    required this.count,
    required this.status,
  });
}
