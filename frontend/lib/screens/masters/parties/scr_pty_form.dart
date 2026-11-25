/*
================================================================================
LLM CONTEXT & QUERY SPACE — PARTIES FORM WORKSPACE (scr_pty_form.dart)
================================================================================
1. DOMAIN & PURPOSE:
   - Modular Base-12 Add/Edit form (`ScrPtyForm`) for `IMMBE2627.sb_parties`,
     built on top of `DyFormCanvas` (`9 : 3` Bento column split matching the
     4-card KPI grid) + `DyFormSection` + `DyFormLabeledField`.
   - Captures complete normalized Party Master data across 4 left sections
     (Tax & GSTIN Verification, Party Identity & Classification, Contact &
     Registered Address, Commercial & Logistics Terms) and 2 right inspector
     sections (Live KYC Readiness Checklist & Legacy Migration Reference).

2. BUSINESS LOGIC & DATA CONTRACTS:
   - Auto-extracts `pan_number` (chars 3..12) and `gst_state_code` (chars 1..2)
     plus state name from valid 15-character GSTIN strings cleanly.
   - Zero Material chrome or hardcoded hex values; uses strictly native
     `shadcn_flutter` (`shad.TextField`, `shad.Select`, `shad.OutlineButton`,
     `shad.LinearProgressIndicator`, `shad.SecondaryBadge`) & `DyColorSystem`.

3. DATA AUDIT / NULL RATES / GOTCHAS:
   - `sb_parties` mandatory database NOT NULL columns: `party_code`,
     `party_role`, `trade_name`, `gst_status`, `taxpayer_type`, `credit_days`,
     `credit_limit`, `verification_status`.
   - Badge chips inside rows stay wrapped cleanly per `GEMINI.md` Rule 8.

4. OPEN QUESTIONS & CLARIFICATIONS:
   - Phase 2 will bind `adatiya_name` (`sb_sources`), `preferred_transport`
     (`sb_transports`), and `gstin` live API lookup (`sb_gstin_cache`) via `SrvPty`.
================================================================================
*/

library;

import 'package:flutter/widgets.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart' as shad;

import '../../../dynamic_ai/page/dy_form_section.dart';
import '../../../dynamic_ai/shells/dy_form_canvas.dart';
import '../../../dynamic_ai/specs/dy_color_system.dart';
import '../../../services/service_header_toast.dart';

/// `[N]` Add / Edit Form workspace for `IMMBE2627.sb_parties`.
class ScrPtyForm extends StatefulWidget {
  const ScrPtyForm({super.key});

  @override
  State<ScrPtyForm> createState() => ScrPtyFormState();
}

class ScrPtyFormState extends State<ScrPtyForm> {
  static const Map<String, String> _gstStateMap = {
    '06': 'Haryana',
    '07': 'Delhi',
    '08': 'Rajasthan',
    '09': 'Uttar Pradesh',
    '19': 'West Bengal',
    '23': 'Madhya Pradesh',
    '24': 'Gujarat',
    '27': 'Maharashtra',
    '29': 'Karnataka',
    '33': 'Tamil Nadu',
  };

  // Section 1: Tax & GSTIN Controllers
  final TextEditingController _gstinCtrl = TextEditingController();
  final TextEditingController _panCtrl = TextEditingController();
  final TextEditingController _msmeCtrl = TextEditingController();
  String _taxpayerType = 'Regular';
  String _constitution = 'Proprietorship';
  String _gstStatus = 'Active';

  // Section 2: Party Identity Controllers
  final TextEditingController _partyCodeCtrl = TextEditingController(
    text: 'PTY-NEW',
  );
  final TextEditingController _tradeNameCtrl = TextEditingController();
  final TextEditingController _legalNameCtrl = TextEditingController();
  String _partyRole = 'CUSTOMER';
  String _ledgerGroup = 'Sundry Debtors';
  String _verificationStatus = 'HUMAN_VERIFIED';

  // Section 3: Contact & Address Controllers
  final TextEditingController _contactPersonCtrl = TextEditingController();
  final TextEditingController _mobileCtrl = TextEditingController();
  final TextEditingController _phoneCtrl = TextEditingController();
  final TextEditingController _emailCtrl = TextEditingController();
  final TextEditingController _addr1Ctrl = TextEditingController();
  final TextEditingController _addr2Ctrl = TextEditingController();
  final TextEditingController _pincodeCtrl = TextEditingController();
  final TextEditingController _cityCtrl = TextEditingController();
  final TextEditingController _districtCtrl = TextEditingController();
  final TextEditingController _stateCtrl = TextEditingController();
  final TextEditingController _gstStateCodeCtrl = TextEditingController();
  String _zoneCode = 'WEST-GJ';

  // Section 4: Commercial & Logistics Controllers
  final TextEditingController _adatiyaCtrl = TextEditingController();
  final TextEditingController _transportCtrl = TextEditingController();
  final TextEditingController _stationCtrl = TextEditingController();
  final TextEditingController _distanceKmCtrl = TextEditingController();
  final TextEditingController _creditDaysCtrl = TextEditingController(
    text: '30',
  );
  final TextEditingController _creditLimitCtrl = TextEditingController(
    text: '0',
  );

  // Side Context: Legacy Migration Reference Controllers
  final TextEditingController _legacyMasterCodeCtrl = TextEditingController();
  final TextEditingController _legacyHasteCtrl = TextEditingController();

  @override
  void dispose() {
    for (final c in [
      _gstinCtrl,
      _panCtrl,
      _msmeCtrl,
      _partyCodeCtrl,
      _tradeNameCtrl,
      _legalNameCtrl,
      _contactPersonCtrl,
      _mobileCtrl,
      _phoneCtrl,
      _emailCtrl,
      _addr1Ctrl,
      _addr2Ctrl,
      _pincodeCtrl,
      _cityCtrl,
      _districtCtrl,
      _stateCtrl,
      _gstStateCodeCtrl,
      _adatiyaCtrl,
      _transportCtrl,
      _stationCtrl,
      _distanceKmCtrl,
      _creditDaysCtrl,
      _creditLimitCtrl,
      _legacyMasterCodeCtrl,
      _legacyHasteCtrl,
    ]) {
      c.dispose();
    }
    super.dispose();
  }

  /// Validates mandatory `sb_parties` inputs before staging.
  ({bool ok, String message}) validateForStage() {
    final trade = _tradeNameCtrl.text.trim();
    if (trade.isEmpty) {
      return (ok: false, message: 'Trade Name is required for sb_parties.');
    }
    final code = _partyCodeCtrl.text.trim();
    if (code.isEmpty) {
      return (ok: false, message: 'Party Code is required.');
    }
    final gstin = _gstinCtrl.text.trim().toUpperCase();
    if (_taxpayerType != 'Unregistered' &&
        gstin.isNotEmpty &&
        gstin.length != 15) {
      return (ok: false, message: 'GSTIN must be 15 characters when provided.');
    }
    return (
      ok: true,
      message: 'Staged $trade ($code • $_partyRole) for sb_parties.',
    );
  }

  void _onGstinChanged(String raw) {
    final clean = raw.trim().toUpperCase();
    setState(() {
      if (clean.length >= 2) {
        final stateCode = clean.substring(0, 2);
        _gstStateCodeCtrl.text = stateCode;
        final mappedState = _gstStateMap[stateCode];
        if (mappedState != null && _stateCtrl.text.trim().isEmpty) {
          _stateCtrl.text = mappedState;
        }
      }
      if (clean.length >= 12) {
        _panCtrl.text = clean.substring(2, 12);
      }
    });
  }

  void _verifyGstinFormat() {
    final clean = _gstinCtrl.text.trim().toUpperCase();
    if (clean.length != 15) {
      ServiceHeaderToast.instance.show(
        'Enter a valid 15-digit GSTIN to inspect PAN & State Code.',
        tone: HeaderToastTone.warning,
      );
      return;
    }
    _onGstinChanged(clean);
    final stateName = _gstStateMap[clean.substring(0, 2)] ?? 'India';
    ServiceHeaderToast.instance.show(
      'GSTIN format verified ($stateName • PAN ${clean.substring(2, 12)}). Live portal sync connects in Phase 2.',
      tone: HeaderToastTone.success,
    );
  }

  Widget _buildSelect({
    required String value,
    required List<String> options,
    required ValueChanged<String> onChanged,
  }) {
    return shad.Select<String>(
      value: value,
      onChanged: (val) {
        if (val != null) onChanged(val);
      },
      itemBuilder: (_, val) => Text(val),
      popup: (_) => shad.SelectPopup<String>(
        items: shad.SelectItemList(
          children: [
            for (final opt in options)
              shad.SelectItemButton<String>(
                value: opt,
                child: Text(opt),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildCheckRow(
    shad.ThemeData theme,
    String label,
    bool done,
  ) {
    final colors = theme.colorScheme;
    final toneColor =
        done ? DyColorSystem.emerald500 : colors.mutedForeground;

    return Row(
      children: [
        Icon(
          done ? shad.LucideIcons.circleCheck : shad.LucideIcons.circleDashed,
          size: 14 * theme.scaling,
          color: toneColor,
        ),
        const shad.DensityGap(shad.gapSm),
        Expanded(
          child: Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: theme.typography.xSmall.copyWith(
              color: done ? colors.foreground : colors.mutedForeground,
              fontWeight: done ? FontWeight.w600 : FontWeight.w400,
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = shad.Theme.of(context);
    final colors = theme.colorScheme;

    final checks = <(String, bool)>[
      ('Trade Name & Party Code', _tradeNameCtrl.text.trim().isNotEmpty),
      (
        'GSTIN (15-char) or Unregistered',
        _taxpayerType == 'Unregistered' ||
            _gstinCtrl.text.trim().length == 15,
      ),
      ('Primary WhatsApp / Mobile', _mobileCtrl.text.trim().length >= 10),
      (
        'City & State Address',
        _cityCtrl.text.trim().isNotEmpty && _stateCtrl.text.trim().isNotEmpty,
      ),
      ('Credit Days Defined', _creditDaysCtrl.text.trim().isNotEmpty),
    ];
    final completedCount = checks.where((c) => c.$2).length;
    final readinessPct = completedCount / checks.length;

    return DyFormCanvas(
      mainSections: [
        // 1. TAX & GSTIN VERIFICATION
        DyFormSection(
          title: 'Tax & GSTIN Verification',
          leadingIcon: shad.LucideIcons.shieldCheck,
          trailing: shad.OutlineButton(
            size: shad.ButtonSize.small,
            onPressed: _verifyGstinFormat,
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(shad.LucideIcons.scanSearch, size: 13),
                shad.DensityGap(shad.gapXs),
                Text('Verify GSTIN'),
              ],
            ),
          ),
          fields: [
            DyFormField(
              colSpan: 4,
              child: DyFormLabeledField(
                label: 'GSTIN (15-Digit)',
                helperText: 'Auto-fills PAN & State Code',
                child: shad.TextField(
                  controller: _gstinCtrl,
                  placeholder: const Text('24AABCU9603R1ZM'),
                  onChanged: _onGstinChanged,
                ),
              ),
            ),
            DyFormField(
              colSpan: 4,
              child: DyFormLabeledField(
                label: 'PAN Number',
                child: shad.TextField(
                  controller: _panCtrl,
                  placeholder: const Text('AABCU9603R'),
                  onChanged: (_) => setState(() {}),
                ),
              ),
            ),
            DyFormField(
              colSpan: 4,
              child: DyFormLabeledField(
                label: 'MSME / Udyam #',
                child: shad.TextField(
                  controller: _msmeCtrl,
                  placeholder: const Text('UDYAM-GJ-22-0000000'),
                ),
              ),
            ),
            DyFormField(
              colSpan: 4,
              child: DyFormLabeledField(
                label: 'Taxpayer Type',
                isRequired: true,
                child: _buildSelect(
                  value: _taxpayerType,
                  options: const ['Regular', 'Composition', 'Unregistered'],
                  onChanged: (v) => setState(() => _taxpayerType = v),
                ),
              ),
            ),
            DyFormField(
              colSpan: 4,
              child: DyFormLabeledField(
                label: 'Constitution',
                child: _buildSelect(
                  value: _constitution,
                  options: const [
                    'Proprietorship',
                    'Partnership',
                    'Private Limited',
                    'LLP',
                    'HUF',
                  ],
                  onChanged: (v) => setState(() => _constitution = v),
                ),
              ),
            ),
            DyFormField(
              colSpan: 4,
              child: DyFormLabeledField(
                label: 'GST Status',
                isRequired: true,
                child: _buildSelect(
                  value: _gstStatus,
                  options: const ['Active', 'Suspended', 'Unregistered'],
                  onChanged: (v) => setState(() => _gstStatus = v),
                ),
              ),
            ),
          ],
        ),

        // 2. PARTY IDENTITY & CLASSIFICATION
        DyFormSection(
          title: 'Party Identity & Classification',
          leadingIcon: shad.LucideIcons.users,
          fields: [
            DyFormField(
              colSpan: 3,
              child: DyFormLabeledField(
                label: 'Party Code',
                isRequired: true,
                child: shad.TextField(
                  controller: _partyCodeCtrl,
                  placeholder: const Text('PTY-0001'),
                  onChanged: (_) => setState(() {}),
                ),
              ),
            ),
            DyFormField(
              colSpan: 3,
              child: DyFormLabeledField(
                label: 'Party Role',
                isRequired: true,
                child: _buildSelect(
                  value: _partyRole,
                  options: const [
                    'CUSTOMER',
                    'SUPPLIER',
                    'MILL_PROCESSOR',
                    'KARIGAR_JOBBER',
                    'BROKER_ADATIYA',
                  ],
                  onChanged: (v) => setState(() => _partyRole = v),
                ),
              ),
            ),
            DyFormField(
              colSpan: 3,
              child: DyFormLabeledField(
                label: 'Ledger Group (sb_groups)',
                child: _buildSelect(
                  value: _ledgerGroup,
                  options: const [
                    'Sundry Debtors',
                    'Sundry Creditors',
                    'Process & Mill Houses',
                    'Karigar & Job Workers',
                    'Brokers / Adatiyas',
                  ],
                  onChanged: (v) => setState(() => _ledgerGroup = v),
                ),
              ),
            ),
            DyFormField(
              colSpan: 3,
              child: DyFormLabeledField(
                label: 'Verification Status',
                isRequired: true,
                child: _buildSelect(
                  value: _verificationStatus,
                  options: const ['HUMAN_VERIFIED', 'KYC_PENDING', 'ON_HOLD'],
                  onChanged: (v) => setState(() => _verificationStatus = v),
                ),
              ),
            ),
            DyFormField(
              colSpan: 6,
              child: DyFormLabeledField(
                label: 'Trade Name',
                isRequired: true,
                child: shad.TextField(
                  controller: _tradeNameCtrl,
                  placeholder: const Text('Ambaji Silk Creation'),
                  onChanged: (_) => setState(() {}),
                ),
              ),
            ),
            DyFormField(
              colSpan: 6,
              child: DyFormLabeledField(
                label: 'Registered Legal Name',
                child: shad.TextField(
                  controller: _legalNameCtrl,
                  placeholder: const Text('As per GST / PAN certificate'),
                ),
              ),
            ),
          ],
        ),

        // 3. CONTACT & REGISTERED ADDRESS
        DyFormSection(
          title: 'Contact & Registered Address',
          leadingIcon: shad.LucideIcons.mapPin,
          fields: [
            DyFormField(
              colSpan: 3,
              child: DyFormLabeledField(
                label: 'Contact Person',
                child: shad.TextField(
                  controller: _contactPersonCtrl,
                  placeholder: const Text('Proprietor / Buyer Name'),
                ),
              ),
            ),
            DyFormField(
              colSpan: 3,
              child: DyFormLabeledField(
                label: 'WhatsApp / Mobile',
                child: shad.TextField(
                  controller: _mobileCtrl,
                  placeholder: const Text('+91 98250 00000'),
                  onChanged: (_) => setState(() {}),
                ),
              ),
            ),
            DyFormField(
              colSpan: 3,
              child: DyFormLabeledField(
                label: 'Alternate Phone',
                child: shad.TextField(
                  controller: _phoneCtrl,
                  placeholder: const Text('Office / Landline'),
                ),
              ),
            ),
            DyFormField(
              colSpan: 3,
              child: DyFormLabeledField(
                label: 'Email',
                child: shad.TextField(
                  controller: _emailCtrl,
                  placeholder: const Text('accounts@party.in'),
                ),
              ),
            ),
            DyFormField(
              colSpan: 6,
              child: DyFormLabeledField(
                label: 'Address Line 1',
                child: shad.TextField(
                  controller: _addr1Ctrl,
                  placeholder: const Text('Shop / Gala / Textile Market Name'),
                ),
              ),
            ),
            DyFormField(
              colSpan: 6,
              child: DyFormLabeledField(
                label: 'Address Line 2',
                child: shad.TextField(
                  controller: _addr2Ctrl,
                  placeholder: const Text('Ring Road / Area / Landmark'),
                ),
              ),
            ),
            DyFormField(
              colSpan: 2,
              child: DyFormLabeledField(
                label: 'Pincode',
                child: shad.TextField(
                  controller: _pincodeCtrl,
                  placeholder: const Text('395002'),
                ),
              ),
            ),
            DyFormField(
              colSpan: 3,
              child: DyFormLabeledField(
                label: 'City / Town',
                child: shad.TextField(
                  controller: _cityCtrl,
                  placeholder: const Text('Surat'),
                  onChanged: (_) => setState(() {}),
                ),
              ),
            ),
            DyFormField(
              colSpan: 3,
              child: DyFormLabeledField(
                label: 'District',
                child: shad.TextField(
                  controller: _districtCtrl,
                  placeholder: const Text('Surat'),
                ),
              ),
            ),
            DyFormField(
              colSpan: 2,
              child: DyFormLabeledField(
                label: 'State',
                child: shad.TextField(
                  controller: _stateCtrl,
                  placeholder: const Text('Gujarat'),
                  onChanged: (_) => setState(() {}),
                ),
              ),
            ),
            DyFormField(
              colSpan: 2,
              child: DyFormLabeledField(
                label: 'Territory Zone',
                child: _buildSelect(
                  value: _zoneCode,
                  options: const [
                    'WEST-GJ',
                    'WEST-MH',
                    'NORTH-DL',
                    'NORTH-UP',
                    'CENTRAL-MP',
                    'EAST-WB',
                    'SOUTH-TN',
                  ],
                  onChanged: (v) => setState(() => _zoneCode = v),
                ),
              ),
            ),
          ],
        ),

        // 4. COMMERCIAL, BROKER & LOGISTICS TERMS
        DyFormSection(
          title: 'Commercial, Broker & Logistics Terms',
          leadingIcon: shad.LucideIcons.truck,
          fields: [
            DyFormField(
              colSpan: 4,
              child: DyFormLabeledField(
                label: 'Source / Adatiya (sb_sources)',
                child: shad.TextField(
                  controller: _adatiyaCtrl,
                  placeholder: const Text('Broker or Direct'),
                ),
              ),
            ),
            DyFormField(
              colSpan: 4,
              child: DyFormLabeledField(
                label: 'Preferred Transport (sb_transports)',
                child: shad.TextField(
                  controller: _transportCtrl,
                  placeholder: const Text('Shree Maruti / VRL / etc.'),
                ),
              ),
            ),
            DyFormField(
              colSpan: 4,
              child: DyFormLabeledField(
                label: 'Nearest Booking Station',
                child: shad.TextField(
                  controller: _stationCtrl,
                  placeholder: const Text('Station / Mandi'),
                ),
              ),
            ),
            DyFormField(
              colSpan: 4,
              child: DyFormLabeledField(
                label: 'Distance from Surat (Km)',
                child: shad.TextField(
                  controller: _distanceKmCtrl,
                  placeholder: const Text('0'),
                ),
              ),
            ),
            DyFormField(
              colSpan: 4,
              child: DyFormLabeledField(
                label: 'Credit Days',
                isRequired: true,
                child: shad.TextField(
                  controller: _creditDaysCtrl,
                  placeholder: const Text('30'),
                  onChanged: (_) => setState(() {}),
                ),
              ),
            ),
            DyFormField(
              colSpan: 4,
              child: DyFormLabeledField(
                label: 'Credit Limit (₹)',
                isRequired: true,
                child: shad.TextField(
                  controller: _creditLimitCtrl,
                  placeholder: const Text('0.00'),
                ),
              ),
            ),
          ],
        ),
      ],
      sideSections: [
        // SIDE 1: LIVE KYC & READINESS CHECKLIST
        DyFormSection(
          title: 'KYC & Onboarding Readiness',
          leadingIcon: shad.LucideIcons.listChecks,
          trailing: Focus(
            canRequestFocus: false,
            skipTraversal: true,
            descendantsAreFocusable: false,
            child: shad.SecondaryBadge(
              child: Text('$completedCount/${checks.length}'),
            ),
          ),
          fields: [
            DyFormField(
              colSpan: 12,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisSize: MainAxisSize.min,
                children: [
                  shad.LinearProgressIndicator(
                    value: readinessPct,
                    theme: shad.LinearProgressIndicatorTheme(
                      color: readinessPct >= 1.0
                          ? DyColorSystem.emerald500
                          : colors.primary,
                      backgroundColor: colors.muted,
                      minHeight: 6 * theme.scaling,
                      borderRadius: BorderRadius.circular(99),
                    ),
                  ),
                  const shad.DensityGap(shad.gapMd),
                  for (int i = 0; i < checks.length; i++) ...[
                    if (i > 0) const shad.DensityGap(shad.gapSm),
                    _buildCheckRow(theme, checks[i].$1, checks[i].$2),
                  ],
                  const shad.DensityGap(shad.gapMd),
                  Text(
                    'Derived State Code: ${_gstStateCodeCtrl.text.isEmpty ? '--' : _gstStateCodeCtrl.text} • PAN: ${_panCtrl.text.isEmpty ? '--' : _panCtrl.text}',
                    style: theme.typography.xSmall
                        .merge(theme.typography.mono)
                        .copyWith(color: colors.mutedForeground),
                  ),
                ],
              ),
            ),
          ],
        ),

        // SIDE 2: LEGACY MIGRATION REFERENCE
        DyFormSection(
          title: 'Legacy Migration Reference',
          leadingIcon: shad.LucideIcons.history,
          fields: [
            DyFormField(
              colSpan: 12,
              child: DyFormLabeledField(
                label: 'Legacy Master Code (sq_MASTER)',
                helperText: 'Optional link to AMAZEv1 CODE',
                child: shad.TextField(
                  controller: _legacyMasterCodeCtrl,
                  placeholder: const Text('e.g. C0421'),
                ),
              ),
            ),
            DyFormField(
              colSpan: 12,
              child: DyFormLabeledField(
                label: 'Legacy Haste Name (sq_HASTE)',
                helperText: 'Optional link to Haste consignee',
                child: shad.TextField(
                  controller: _legacyHasteCtrl,
                  placeholder: const Text('e.g. AMBIKA SAREE DEPOT'),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
