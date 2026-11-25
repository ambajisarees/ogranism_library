/*
================================================================================
LLM CONTEXT & QUERY SPACE
================================================================================
1. DOMAIN & PURPOSE:
   - Region [5] Owned Account Group & Sister-Firm Rollup (`ContactOwnedGroupEmpireBentoCard`)
     and the M:N ERP Party & Account Group Link Picker Modal
     (`showContactsErpLinkPickerModal`) for Stage 9.3 Contacts Workspace.
   - Displays each linked `sq_ACGROUP` parent banner (`GCODE`, Name, City, Contact)
     and every sister `sq_MASTER` firm sharing that `GCODE` (Firm Name, `code`,
     City/Station, `ADATIYA` broker, `crdays`, `MOBILE`, `Direct` vs `Sister` badge).

2. BUSINESS LOGIC & DATA CONTRACTS:
   - Strictly uses native `shadcn_flutter` widgets, `theme.density.*`,
     `theme.typography.*`, `colors.*`, and `DyColorSystem`.
   - Relationship role selector inside the ERP picker defaults to `PROPRIETOR`
     for `sq_MASTER` and `GROUP_OWNER` for `sq_ACGROUP`, supporting `ACCOUNTS`,
     `BUYER`, `DISPATCH`, and `BROKER`.
   - Wraps all badges in `Focus(canRequestFocus: false, skipTraversal: true,
     descendantsAreFocusable: false)` per `GEMINI.md` Rule 8.

3. DATA AUDIT / NULL RATES / GOTCHAS:
   - `sq_MASTER` and `sq_ACGROUP` are strictly read-only Airbyte mirrors.
   - Always checks `if (!mounted) return;` after awaits.

4. OPEN QUESTIONS & CLARIFICATIONS:
   - Stage 9.4 S24 Call Log intelligence will render below this rollup card.
================================================================================
*/

import 'package:flutter/widgets.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart' as shad;

import '../../../../dynamic_ai/shells/dy_landing_canvas.dart';
import '../../../../dynamic_ai/specs/dy_color_system.dart';
import '../../../../models/masters/model_google_contacts.dart';
import '../../../../services/masters/service_google_contacts.dart';
import 'scr_contacts_bento_cards.dart';

/// Opens the M:N ERP Party & Account Group Link Picker modal with role tagging.
Future<ErpContactLink?> showContactsErpLinkPickerModal({
  required BuildContext context,
  required String contactName,
  required ServiceGoogleContacts service,
}) async {
  ErpContactLink? chosen;
  await shad.showOverlay<void>(
    context,
    const shad.DialogConfiguration(barrierDismissible: true),
    builder: (overlayCtx) => Center(
      child: _ErpEntityPickerModal(
        contactName: contactName,
        service: service,
        onSelectLink: (link) {
          chosen = link;
          shad.closeOverlay(overlayCtx);
        },
        onCancel: () => shad.closeOverlay(overlayCtx),
      ),
    ),
  ).future;
  return chosen;
}

/// Region [5] (`Flex 4`): Owned Account Group (`sq_ACGROUP`) & Sister Firms Rollup.
class ContactOwnedGroupEmpireBentoCard extends StatelessWidget {
  final GoogleContact? contact;
  final ContactGroupEmpireRollup rollup;
  final bool isLoading;
  final VoidCallback onLinkErp;
  final bool isZoomed;
  final VoidCallback onToggleZoom;

  const ContactOwnedGroupEmpireBentoCard({
    super.key,
    required this.contact,
    required this.rollup,
    required this.isLoading,
    required this.onLinkErp,
    this.isZoomed = false,
    required this.onToggleZoom,
  });

  @override
  Widget build(BuildContext context) {
    final theme = shad.Theme.of(context);
    final colors = theme.colorScheme;
    final pad = theme.density.baseContainerPadding * theme.scaling;
    final isDark = theme.brightness == Brightness.dark;

    return DyBentoCard(
      title: 'Owned Account Group & Sister Firms',
      subtitle: rollup.sisterParties.isNotEmpty
          ? '${rollup.groups.length} groups • ${rollup.sisterParties.length} sister firms'
          : 'sq_ACGROUP -> sq_MASTER GCODE rollup',
      icon: shad.LucideIcons.layers,
      regionNumber: 5,
      isZoomed: isZoomed,
      onToggleZoom: onToggleZoom,
      expandBody: true,
      child: SingleChildScrollView(
        padding: EdgeInsets.all(pad),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (isLoading)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 28),
                child: Center(child: shad.CircularProgressIndicator()),
              )
            else if (contact == null || rollup.isEmpty)
              shad.OutlinedContainer(
                backgroundColor: colors.card,
                borderColor: colors.border,
                borderRadius: BorderRadius.circular(theme.radiusSm),
                padding: EdgeInsets.all(pad),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Multi-Firm Group Empire View',
                      style: theme.typography.textSmall
                          .copyWith(fontWeight: FontWeight.w600),
                    ),
                    const shad.DensityGap(shad.gapXs),
                    Text(
                      'Link an Account Group (sq_ACGROUP) or any Party (sq_MASTER) to automatically resolve all sister firms sharing that GCODE.',
                      style: theme.typography.xSmall
                          .copyWith(color: colors.mutedForeground),
                    ),
                    if (contact != null) ...[
                      const shad.DensityGap(shad.gapMd),
                      shad.OutlineButton(
                        size: shad.ButtonSize.small,
                        onPressed: onLinkErp,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: const [
                            ContactsShiftKeyCap(letter: 'L'),
                            Icon(shad.LucideIcons.link, size: 12),
                            shad.DensityGap(shad.gapXs),
                            Text('Link Party / Group'),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              )
            else ...[
              for (final grp in rollup.groups) ...[
                shad.OutlinedContainer(
                  backgroundColor:
                      DyColorSystem.resolveSurface(DyColorSystem.indigo500, isDark),
                  borderColor:
                      DyColorSystem.resolveBorder(DyColorSystem.indigo500, isDark),
                  borderRadius: BorderRadius.circular(theme.radiusSm),
                  padding: EdgeInsets.all(pad * 0.85),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Focus(
                            canRequestFocus: false,
                            skipTraversal: true,
                            descendantsAreFocusable: false,
                            child: shad.PrimaryBadge(
                              child: Text('GCODE ${grp.gcode}'),
                            ),
                          ),
                          const shad.DensityGap(shad.gapSm),
                          Expanded(
                            child: Text(
                              grp.name,
                              style: theme.typography.textSmall
                                  .copyWith(fontWeight: FontWeight.w700),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      if (grp.city.isNotEmpty || grp.contact.isNotEmpty) ...[
                        const shad.DensityGap(shad.gapXs),
                        Text(
                          [grp.city, grp.contact, grp.mobile]
                              .where((s) => s.isNotEmpty)
                              .join(' • '),
                          style: theme.typography.xSmall
                              .copyWith(color: colors.mutedForeground),
                        ),
                      ],
                    ],
                  ),
                ),
                const shad.DensityGap(shad.gapSm),
              ],
              Text(
                'SISTER FIRMS (${rollup.sisterParties.length})',
                style: theme.typography.xSmall.copyWith(
                  fontWeight: FontWeight.w700,
                  color: colors.mutedForeground,
                ),
              ),
              const shad.DensityGap(shad.gapXs),
              for (final sp in rollup.sisterParties) ...[
                shad.OutlinedContainer(
                  backgroundColor: colors.card,
                  borderColor: sp.isDirectlyLinked ? colors.primary : colors.border,
                  borderRadius: BorderRadius.circular(theme.radiusSm),
                  padding: EdgeInsets.all(pad * 0.8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              sp.name,
                              style: theme.typography.xSmall
                                  .copyWith(fontWeight: FontWeight.w700),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const shad.DensityGap(shad.gapXs),
                          Focus(
                            canRequestFocus: false,
                            skipTraversal: true,
                            descendantsAreFocusable: false,
                            child: sp.isDirectlyLinked
                                ? const shad.PrimaryBadge(child: Text('Direct'))
                                : const shad.OutlineBadge(child: Text('Sister')),
                          ),
                        ],
                      ),
                      const shad.DensityGap(shad.gapXs),
                      Text(
                        '${sp.code} • ${sp.city.isNotEmpty ? sp.city : sp.station} • Agent: ${sp.adatiya}',
                        style: theme.typography.xSmall
                            .copyWith(color: colors.mutedForeground),
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        'Cr: ${sp.creditDays}d${sp.mobile.isNotEmpty ? ' • ${sp.mobile}' : ''}',
                        style: theme.typography.mono.copyWith(
                          fontSize: 11 * theme.scaling,
                          color: colors.mutedForeground,
                        ),
                      ),
                    ],
                  ),
                ),
                const shad.DensityGap(shad.gapXs),
              ],
            ],
            const shad.DensityGap(shad.gapMd),
            shad.OutlinedContainer(
              backgroundColor:
                  DyColorSystem.resolveSurface(DyColorSystem.cyan500, isDark),
              borderColor:
                  DyColorSystem.resolveBorder(DyColorSystem.cyan500, isDark),
              borderRadius: BorderRadius.circular(theme.radiusSm),
              padding: EdgeInsets.all(pad * 0.85),
              child: Row(
                children: [
                  Icon(shad.LucideIcons.phone,
                      size: 15 * theme.scaling, color: DyColorSystem.cyan500),
                  const shad.DensityGap(shad.gapSm),
                  Expanded(
                    child: Text(
                      'Stage 9.4 Ready: GIN phone_norms[] indexed for Galaxy S24 call & WhatsApp resolution.',
                      style: theme.typography.xSmall
                          .copyWith(color: colors.mutedForeground),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ErpEntityPickerModal extends StatefulWidget {
  final String contactName;
  final ServiceGoogleContacts service;
  final ValueChanged<ErpContactLink> onSelectLink;
  final VoidCallback onCancel;

  const _ErpEntityPickerModal({
    required this.contactName,
    required this.service,
    required this.onSelectLink,
    required this.onCancel,
  });

  @override
  State<_ErpEntityPickerModal> createState() => _ErpEntityPickerModalState();
}

class _ErpEntityPickerModalState extends State<_ErpEntityPickerModal> {
  static const List<String> _roles = [
    'GROUP_OWNER',
    'PROPRIETOR',
    'ACCOUNTS',
    'BUYER',
    'DISPATCH',
    'BROKER',
  ];

  final TextEditingController _searchCtrl = TextEditingController();
  bool _isGroupTab = false;
  bool _isLoading = true;
  String _selectedRole = 'PROPRIETOR';
  List<MasterPartyOption> _parties = const [];
  List<AccountGroupOption> _groups = const [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() => _isLoading = true);
    final q = _searchCtrl.text.trim();
    if (_isGroupTab) {
      final res =
          await widget.service.searchAccountGroups(searchQuery: q, limit: 40);
      if (!mounted) return;
      setState(() {
        _groups = res;
        _isLoading = false;
      });
    } else {
      final res =
          await widget.service.searchMasterParties(searchQuery: q, limit: 40);
      if (!mounted) return;
      setState(() {
        _parties = res;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = shad.Theme.of(context);
    final colors = theme.colorScheme;
    final pad = theme.density.baseContainerPadding * theme.scaling;

    return shad.ModalContainer(
      child: shad.OutlinedContainer(
        backgroundColor: colors.card,
        borderColor: colors.card,
        borderRadius: BorderRadius.circular(theme.radiusLg),
        child: SizedBox(
          width: 540 * theme.scaling,
          height: 540 * theme.scaling,
          child: Padding(
            padding: EdgeInsets.all(pad * 1.4),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Link "${widget.contactName}" to ERP',
                        style: theme.typography.h4,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    shad.GhostButton(
                      onPressed: widget.onCancel,
                      child: const Icon(shad.LucideIcons.x, size: 16),
                    ),
                  ],
                ),
                const shad.DensityGap(shad.gapSm),
                Row(
                  children: [
                    _tabBtn('Master Parties (sq_MASTER)', !_isGroupTab, () {
                      setState(() {
                        _isGroupTab = false;
                        _selectedRole = 'PROPRIETOR';
                      });
                      _load();
                    }),
                    const shad.DensityGap(shad.gapSm),
                    _tabBtn('Account Groups (sq_ACGROUP)', _isGroupTab, () {
                      setState(() {
                        _isGroupTab = true;
                        _selectedRole = 'GROUP_OWNER';
                      });
                      _load();
                    }),
                    const Spacer(),
                    SizedBox(
                      width: 150 * theme.scaling,
                      child: shad.Select<String>(
                        value: _selectedRole,
                        onChanged: (val) {
                          if (val != null) setState(() => _selectedRole = val);
                        },
                        itemBuilder: (ctx, v) => Text(v),
                        popup: shad.SelectPopup(
                          items: shad.SelectItemList(
                            children: [
                              for (final r in _roles)
                                shad.SelectItemButton(value: r, child: Text(r)),
                            ],
                          ),
                        ).call,
                      ),
                    ),
                  ],
                ),
                const shad.DensityGap(shad.gapSm),
                shad.TextField(
                  controller: _searchCtrl,
                  placeholder: Text(_isGroupTab
                      ? 'Search group name or gcode...'
                      : 'Search party name, code, city, or phone...'),
                  onChanged: (_) => _load(),
                ),
                const shad.DensityGap(shad.gapMd),
                Expanded(
                  child: _isLoading
                      ? const Center(child: shad.CircularProgressIndicator())
                      : ListView.separated(
                          itemCount:
                              _isGroupTab ? _groups.length : _parties.length,
                          separatorBuilder: (_, __) =>
                              const shad.DensityGap(shad.gapXs),
                          itemBuilder: (context, index) {
                            if (_isGroupTab) {
                              final g = _groups[index];
                              return _pickerRow(
                                title: g.name,
                                meta: '${g.gcode} • ${g.city}',
                                theme: theme,
                                colors: colors,
                                onTap: () => widget.onSelectLink(
                                  ErpContactLink(
                                    kind: 'GROUP',
                                    code: g.gcode,
                                    name: g.name,
                                    city: g.city,
                                    role: _selectedRole,
                                  ),
                                ),
                              );
                            }
                            final p = _parties[index];
                            return _pickerRow(
                              title: p.name,
                              meta: '${p.code} • ${p.city}',
                              theme: theme,
                              colors: colors,
                              onTap: () => widget.onSelectLink(
                                ErpContactLink(
                                  kind: 'PARTY',
                                  code: p.code,
                                  name: p.name,
                                  city: p.city,
                                  role: _selectedRole,
                                ),
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _pickerRow({
    required String title,
    required String meta,
    required shad.ThemeData theme,
    required shad.ColorScheme colors,
    required VoidCallback onTap,
  }) =>
      shad.OutlineButton(
        onPressed: onTap,
        child: Row(
          children: [
            Expanded(
              child: Text(title,
                  style: theme.typography.textSmall,
                  overflow: TextOverflow.ellipsis),
            ),
            Text(meta,
                style: theme.typography.xSmall
                    .copyWith(color: colors.mutedForeground)),
          ],
        ),
      );

  Widget _tabBtn(String label, bool active, VoidCallback onPressed) => active
      ? shad.PrimaryButton(
          size: shad.ButtonSize.small, onPressed: onPressed, child: Text(label))
      : shad.OutlineButton(
          size: shad.ButtonSize.small,
          onPressed: onPressed,
          child: Text(label),
        );
}
