/*
================================================================================
LLM CONTEXT & QUERY SPACE
================================================================================
1. DOMAIN & PURPOSE:
   - Admin User & Vendor Onboarding Approval Modal located under
     `lib/screens/admin/auth/widgets/dia_admin_approvals.dart`.
   - Lists pending registration requests from `IMMBE2627.sb_onboarding_requests`
     triggered when new internal users (or future vendors) create a profile.

2. BUSINESS LOGIC & DATA CONTRACTS:
   - Only Admins (`isAdmin == true`) can Approve or Reject requests.
   - Calls `AuthService().reviewOnboardingRequest(requestId, decision, roleId)`.
   - Role options mapped cleanly via `UserRoleModel.assignableRoles`
     (`STAFF = 3`, `MANAGER = 2`, `ADMIN = 1`).

3. UI & SHADCN FLUTTER COMPLIANCE:
   - Strictly uses native `shadcn_flutter` components (`shad.OutlinedContainer`,
     `shad.PrimaryButton`, `shad.OutlineButton`, `shad.PrimaryBadge`,
     `shad.SecondaryBadge`, `shad.DestructiveBadge`, `shad.DensityGap`) and
     native theme tokens.

4. OPEN QUESTIONS & CLARIFICATIONS:
   - Vendor onboarding requests (`requestType == 'VENDOR'`) will surface here
     with a dedicated `VENDOR` badge when external access is enabled.
================================================================================
*/

library;

import 'package:flutter/widgets.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart' as shad;
import '../../../../models/workspace/mdl_auth.dart';
import '../../../../services/workspace/srv_auth.dart';

/// Opens the Admin Onboarding Approval Queue overlay modal.
Future<void> showAdminApprovalsDialog(BuildContext context) async {
  final completer = shad.showOverlay<void>(
    context,
    const shad.DialogConfiguration(barrierDismissible: true),
    builder: (overlayCtx) {
      return Center(
        child: DiaAdminApprovals(
          onClose: () => shad.closeOverlay(overlayCtx),
        ),
      );
    },
  );
  await completer.future;
}

class DiaAdminApprovals extends StatefulWidget {
  final VoidCallback onClose;

  const DiaAdminApprovals({
    super.key,
    required this.onClose,
  });

  @override
  State<DiaAdminApprovals> createState() => _DiaAdminApprovalsState();
}

class _DiaAdminApprovalsState extends State<DiaAdminApprovals> {
  List<OnboardingRequestModel> _requests = [];
  final Map<String, int> _selectedRoles = {};
  bool _isLoading = true;
  String? _processingId;

  @override
  void initState() {
    super.initState();
    _loadRequests();
  }

  Future<void> _loadRequests() async {
    setState(() => _isLoading = true);
    final rows = await AuthService().fetchOnboardingRequests();
    if (!mounted) return;
    setState(() {
      _requests = rows;
      for (final r in rows) {
        _selectedRoles.putIfAbsent(r.id, () => r.requestedRoleId);
      }
      _isLoading = false;
    });
  }

  Future<void> _review(
    OnboardingRequestModel req,
    String decision,
  ) async {
    setState(() => _processingId = req.id);
    final roleId = _selectedRoles[req.id] ?? 3;
    final ok = await AuthService().reviewOnboardingRequest(
      requestId: req.id,
      decision: decision,
      roleId: roleId,
    );
    if (!mounted) return;
    setState(() => _processingId = null);

    if (ok) {
      shad.showToast(
        context: context,
        builder: (ctx, show) => shad.Card(
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Text(
              decision == 'APPROVED'
                  ? 'Approved ${req.username} (${req.fullName}).'
                  : 'Rejected ${req.username}.',
            ),
          ),
        ),
      );
      await _loadRequests();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = shad.Theme.of(context);
    final colors = theme.colorScheme;
    final double scale = theme.scaling;
    final double pad = theme.density.baseContainerPadding * scale;
    final bool isAdmin =
        AuthService().activeProfileNotifier.value?.isAdmin ?? false;

    final pendingList = _requests.where((r) => r.isPending).toList();
    final historyList = _requests.where((r) => !r.isPending).take(8).toList();

    return ConstrainedBox(
      constraints: BoxConstraints(
        maxWidth: 680 * scale,
        maxHeight: 560 * scale,
      ),
      child: shad.OutlinedContainer(
        backgroundColor: colors.card,
        borderColor: colors.border,
        borderRadius: theme.borderRadiusLg,
        padding: EdgeInsets.all(pad * 1.2),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header
            Row(
              children: [
                Icon(
                  shad.LucideIcons.userCheck,
                  size: 18 * scale,
                  color: colors.primary,
                ),
                const shad.DensityGap(shad.gapSm),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Access Approvals & Onboarding',
                        style: theme.typography.h4.copyWith(
                          fontWeight: FontWeight.w700,
                          color: colors.foreground,
                        ),
                      ),
                      Text(
                        'Approve new staff User IDs (and future vendor accounts)',
                        style: theme.typography.xSmall.copyWith(
                          color: colors.mutedForeground,
                        ),
                      ),
                    ],
                  ),
                ),
                shad.SecondaryBadge(
                  child: Text('${pendingList.length} Pending'),
                ),
                const shad.DensityGap(shad.gapSm),
                shad.IconButton.ghost(
                  icon: const Icon(shad.LucideIcons.refreshCw, size: 15),
                  onPressed: _isLoading ? null : _loadRequests,
                ),
                shad.IconButton.ghost(
                  icon: const Icon(shad.LucideIcons.x, size: 16),
                  onPressed: widget.onClose,
                ),
              ],
            ),
            const shad.DensityGap(shad.gapMd),

            if (_isLoading)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 40),
                child: Center(child: shad.CircularProgressIndicator()),
              )
            else if (pendingList.isEmpty && historyList.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 36),
                child: Center(
                  child: Text(
                    'No pending user registration requests.',
                    style: theme.typography.textSmall.copyWith(
                      color: colors.mutedForeground,
                    ),
                  ),
                ),
              )
            else
              Flexible(
                child: ListView(
                  shrinkWrap: true,
                  children: [
                    if (pendingList.isEmpty)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Text(
                          'All caught up — zero pending approvals.',
                          style: theme.typography.textSmall.copyWith(
                            color: colors.mutedForeground,
                          ),
                        ),
                      )
                    else
                      ...pendingList.map(
                        (req) => Padding(
                          padding: EdgeInsets.only(bottom: 8 * scale),
                          child: _buildRequestCard(
                            theme,
                            colors,
                            scale,
                            req,
                            isAdmin,
                          ),
                        ),
                      ),
                    if (historyList.isNotEmpty) ...[
                      const shad.DensityGap(shad.gapSm),
                      Text(
                        'Recent Decisions',
                        style: theme.typography.xSmall.copyWith(
                          color: colors.mutedForeground,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const shad.DensityGap(shad.gapXs),
                      ...historyList.map(
                        (req) => Padding(
                          padding: EdgeInsets.only(bottom: 6 * scale),
                          child: _buildHistoryRow(theme, colors, scale, req),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildRequestCard(
    shad.ThemeData theme,
    shad.ColorScheme colors,
    double scale,
    OnboardingRequestModel req,
    bool isAdmin,
  ) {
    final int selectedRole = _selectedRoles[req.id] ?? 3;
    final bool isBusy = _processingId == req.id;

    return shad.OutlinedContainer(
      backgroundColor: colors.background,
      borderColor: colors.border,
      borderRadius: theme.borderRadiusMd,
      padding: EdgeInsets.all(10 * scale),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              shad.PrimaryBadge(child: Text(req.username)),
              const shad.DensityGap(shad.gapSm),
              shad.SecondaryBadge(
                child: Text(req.isVendor ? 'VENDOR' : 'INTERNAL'),
              ),
              const shad.DensityGap(shad.gapSm),
              Expanded(
                child: Text(
                  req.fullName,
                  style: theme.typography.textSmall.copyWith(
                    fontWeight: FontWeight.w700,
                    color: colors.foreground,
                  ),
                ),
              ),
              Text(
                req.mobileNo,
                style: theme.typography.xSmall.copyWith(
                  fontFamily: 'JetBrains Mono',
                  color: colors.mutedForeground,
                ),
              ),
            ],
          ),
          if (req.email != null && req.email!.isNotEmpty) ...[
            const shad.DensityGap(shad.gapXs),
            Text(
              'Optional email: ${req.email}',
              style: theme.typography.xSmall.copyWith(
                color: colors.mutedForeground,
              ),
            ),
          ],
          const shad.DensityGap(shad.gapSm),
          Row(
            children: [
              Text(
                'Role:',
                style: theme.typography.xSmall.copyWith(
                  color: colors.mutedForeground,
                ),
              ),
              const shad.DensityGap(shad.gapXs),
              ...UserRoleModel.assignableRoles.map((role) {
                final bool isSel = selectedRole == role.id;
                return Padding(
                  padding: EdgeInsets.only(right: 4 * scale),
                  child: isSel
                      ? shad.SecondaryButton(
                          size: shad.ButtonSize.small,
                          onPressed: () {},
                          child: Text(role.name),
                        )
                      : shad.GhostButton(
                          size: shad.ButtonSize.small,
                          onPressed: () {
                            setState(() => _selectedRoles[req.id] = role.id);
                          },
                          child: Text(role.name),
                        ),
                );
              }),
              const Spacer(),
              if (isAdmin) ...[
                shad.OutlineButton(
                  size: shad.ButtonSize.small,
                  onPressed: isBusy ? null : () => _review(req, 'REJECTED'),
                  child: const Text('Reject'),
                ),
                const shad.DensityGap(shad.gapXs),
                shad.PrimaryButton(
                  size: shad.ButtonSize.small,
                  onPressed: isBusy ? null : () => _review(req, 'APPROVED'),
                  child: Text(isBusy ? 'Saving...' : 'Approve'),
                ),
              ] else
                Text(
                  'Admin approval required',
                  style: theme.typography.xSmall.copyWith(
                    color: colors.mutedForeground,
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryRow(
    shad.ThemeData theme,
    shad.ColorScheme colors,
    double scale,
    OnboardingRequestModel req,
  ) {
    final bool approved = req.status == 'APPROVED';
    return shad.OutlinedContainer(
      backgroundColor: colors.muted.withValues(alpha: 0.35),
      borderColor: colors.border,
      borderRadius: theme.borderRadiusSm,
      padding: EdgeInsets.symmetric(
        horizontal: 10 * scale,
        vertical: 6 * scale,
      ),
      child: Row(
        children: [
          Text(
            '${req.username} • ${req.fullName}',
            style: theme.typography.xSmall.copyWith(
              fontWeight: FontWeight.w600,
              color: colors.foreground,
            ),
          ),
          const Spacer(),
          approved
              ? const shad.SecondaryBadge(child: Text('APPROVED'))
              : const shad.DestructiveBadge(child: Text('REJECTED')),
        ],
      ),
    );
  }
}
