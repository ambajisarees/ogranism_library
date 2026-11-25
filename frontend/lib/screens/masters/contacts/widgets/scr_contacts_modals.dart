/*
================================================================================
LLM CONTEXT & QUERY SPACE
================================================================================
1. DOMAIN & PURPOSE:
   - Modal overlay widgets for the Google Contacts Sync screen (`screen_google_contacts_sync.dart`):
       1) `showContactsOAuthModal`: Connect/refresh `design.ambaji@gmail.com` via
          Option B (Instant OAuth Playground token paste — recommended) or
          Option A (Desktop Loopback OAuth on `http://localhost:8080`).
       2) `showContactsCsvImportModal`: 1-click `FilePicker` (`contacts.csv`)
          and fallback CSV paste importer streaming 400-row batches to RPC.
       3) `showContactsSyncProgressModal`: Live full/delta pull modal for
          Google People API v1.

2. BUSINESS LOGIC & DATA CONTRACTS:
   - Uses `shad.showOverlay` + `shad.ModalContainer` wrapping an opaque
     `shad.OutlinedContainer(backgroundColor: colors.card)` so background text
     never bleeds through the `0.9` surface overlay theme.
   - Separates `_isWaitingForBrowser` (Option A) from `_isSavingToken` (Option B)
     so pasting a token remains unblocked even while waiting for browser OAuth.
   - Always guards `setState` after `await` with `if (!mounted) return;`.

3. DATA AUDIT / NULL RATES / GOTCHAS:
   - Uses `FilePicker.pickFiles` static API matching `file_picker ^11.0.3`.
   - `cancelDesktopLoopbackOAuth()` is invoked on Cancel & `dispose()` so no
     dangling socket stays bound on port `8080`.

4. OPEN QUESTIONS & CLARIFICATIONS:
   - Split cleanly from `scr_contacts_inspector.dart` per `GEMINI.md` Rule 2 (<1000 LOC).
================================================================================
*/

import 'dart:convert';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart' as shad;

import '../../../../dynamic_ai/specs/dy_color_system.dart';
import '../../../../models/masters/model_google_contacts.dart';
import '../../../../services/masters/service_google_contacts.dart';

/// Opens the Google Account OAuth & Access Token Connection Dialog.
Future<bool> showContactsOAuthModal({
  required BuildContext context,
  required GoogleSyncStateModel syncState,
  required ServiceGoogleContacts service,
}) async {
  bool didChange = false;
  final completer = shad.showOverlay<void>(
    context,
    const shad.DialogConfiguration(barrierDismissible: true),
    builder: (overlayCtx) => Center(
      child: _ContactsOAuthModal(
        syncState: syncState,
        service: service,
        onDone: (changed) {
          didChange = changed;
          shad.closeOverlay(overlayCtx);
        },
      ),
    ),
  );
  await completer.future;
  return didChange;
}

/// Opens the Google Contacts CSV File Picker & Batch Uploader Modal.
Future<bool> showContactsCsvImportModal({
  required BuildContext context,
  required String accountEmail,
  required ServiceGoogleContacts service,
}) async {
  bool didImport = false;
  final completer = shad.showOverlay<void>(
    context,
    const shad.DialogConfiguration(barrierDismissible: false),
    builder: (overlayCtx) => Center(
      child: _ContactsCsvImportModal(
        accountEmail: accountEmail,
        service: service,
        onDone: (imported) {
          didImport = imported;
          shad.closeOverlay(overlayCtx);
        },
      ),
    ),
  );
  await completer.future;
  return didImport;
}

/// Opens the Live Google People API Pull / Push Progress Modal.
Future<PullResult?> showContactsSyncProgressModal({
  required BuildContext context,
  required String accountEmail,
  required bool forceFullSync,
  bool isPushMode = false,
  required ServiceGoogleContacts service,
}) async {
  PullResult? result;
  final completer = shad.showOverlay<void>(
    context,
    const shad.DialogConfiguration(barrierDismissible: false),
    builder: (overlayCtx) => Center(
      child: _ContactsSyncProgressModal(
        accountEmail: accountEmail,
        forceFullSync: forceFullSync,
        isPushMode: isPushMode,
        service: service,
        onClose: (res) {
          result = res;
          shad.closeOverlay(overlayCtx);
        },
      ),
    ),
  );
  await completer.future;
  return result;
}

Widget _opaqueModalShell({
  required shad.ThemeData theme,
  required double width,
  required Widget child,
}) {
  final colors = theme.colorScheme;
  final pad = theme.density.baseContainerPadding * theme.scaling;
  return shad.ModalContainer(
    child: shad.OutlinedContainer(
      backgroundColor: colors.card,
      borderColor: colors.card,
      borderRadius: BorderRadius.circular(theme.radiusLg),
      child: SizedBox(
        width: width * theme.scaling,
        child: Padding(padding: EdgeInsets.all(pad * 1.4), child: child),
      ),
    ),
  );
}

class _ContactsOAuthModal extends StatefulWidget {
  final GoogleSyncStateModel syncState;
  final ServiceGoogleContacts service;
  final ValueChanged<bool> onDone;

  const _ContactsOAuthModal({
    required this.syncState,
    required this.service,
    required this.onDone,
  });

  @override
  State<_ContactsOAuthModal> createState() => _ContactsOAuthModalState();
}

class _ContactsOAuthModalState extends State<_ContactsOAuthModal> {
  static const String _contactsScope = 'https://www.googleapis.com/auth/contacts';
  static const String _fixedRedirectUri = 'http://localhost:8080';

  late final TextEditingController _emailCtrl;
  late final TextEditingController _clientIdCtrl;
  final TextEditingController _clientSecretCtrl = TextEditingController();
  final TextEditingController _accessTokenCtrl = TextEditingController();
  final TextEditingController _refreshTokenCtrl = TextEditingController();

  bool _isWaitingForBrowser = false;
  bool _isSavingToken = false;
  String? _statusMessage;
  bool _isError = false;

  @override
  void initState() {
    super.initState();
    _emailCtrl = TextEditingController(text: widget.syncState.email);
    _clientIdCtrl = TextEditingController(text: widget.syncState.oauthClientId);
  }

  @override
  void dispose() {
    widget.service.cancelDesktopLoopbackOAuth();
    _emailCtrl.dispose();
    _clientIdCtrl.dispose();
    _clientSecretCtrl.dispose();
    _accessTokenCtrl.dispose();
    _refreshTokenCtrl.dispose();
    super.dispose();
  }

  Future<void> _copyToClipboard(String text, String feedback) async {
    await Clipboard.setData(ClipboardData(text: text));
    if (!mounted) return;
    setState(() {
      _isError = false;
      _statusMessage = feedback;
    });
  }

  Future<void> _runDesktopOAuth() async {
    final targetEmail = _emailCtrl.text.trim().isEmpty
        ? ServiceGoogleContacts.defaultGoogleEmail
        : _emailCtrl.text.trim();
    setState(() {
      _isWaitingForBrowser = true;
      _isError = false;
      _statusMessage =
          'Listening on $_fixedRedirectUri for $targetEmail... Complete sign-in in browser or click Cancel Browser Wait.';
    });

    final res = await widget.service.startDesktopLoopbackOAuth(
      email: targetEmail,
      clientId: _clientIdCtrl.text.trim(),
      clientSecret: _clientSecretCtrl.text.trim().isEmpty
          ? null
          : _clientSecretCtrl.text.trim(),
    );

    if (!mounted) return;
    setState(() {
      _isWaitingForBrowser = false;
      _isError = !res.isSuccess;
      _statusMessage = res.detail != null && res.detail!.isNotEmpty
          ? '${res.message}\n${res.detail}'
          : res.message;
    });
    if (res.isSuccess) widget.onDone(true);
  }

  Future<void> _cancelBrowserWait() async {
    await widget.service.cancelDesktopLoopbackOAuth();
    if (!mounted) return;
    setState(() {
      _isWaitingForBrowser = false;
      _isError = false;
      _statusMessage = 'Browser OAuth wait cancelled.';
    });
  }

  Future<void> _saveManualTokens() async {
    final access = _accessTokenCtrl.text.trim();
    final refresh = _refreshTokenCtrl.text.trim();
    final secret = _clientSecretCtrl.text.trim();
    final clientId = _clientIdCtrl.text.trim();

    if (access.isEmpty && refresh.isEmpty && secret.isEmpty) {
      setState(() {
        _isError = true;
        _statusMessage =
            'Paste a Google Access Token (ya29...) or Playground JSON response first.';
      });
      return;
    }

    await widget.service.cancelDesktopLoopbackOAuth();
    setState(() {
      _isWaitingForBrowser = false;
      _isSavingToken = true;
      _isError = false;
      _statusMessage = 'Saving credentials to IMMBE2627.sb_google_sync_state...';
    });

    final ok = await widget.service.saveGoogleCredentials(
      email: _emailCtrl.text.trim().isEmpty
          ? ServiceGoogleContacts.defaultGoogleEmail
          : _emailCtrl.text.trim(),
      oauthClientId: clientId.isEmpty ? null : clientId,
      oauthClientSecret: secret.isEmpty ? null : secret,
      accessToken: access.isEmpty ? null : access,
      refreshToken: refresh.isEmpty ? null : refresh,
    );

    if (!mounted) return;
    setState(() => _isSavingToken = false);
    if (ok) {
      widget.onDone(true);
    } else {
      setState(() {
        _isError = true;
        _statusMessage = 'Failed to save credentials to Supabase.';
      });
    }
  }

  Future<void> _disconnect() async {
    await widget.service.cancelDesktopLoopbackOAuth();
    setState(() => _isSavingToken = true);
    final ok =
        await widget.service.disconnectGoogleAccount(email: _emailCtrl.text.trim());
    if (!mounted) return;
    setState(() => _isSavingToken = false);
    if (ok) widget.onDone(true);
  }

  @override
  Widget build(BuildContext context) {
    final theme = shad.Theme.of(context);
    final colors = theme.colorScheme;
    final pad = theme.density.baseContainerPadding * theme.scaling;
    final isDark = theme.brightness == Brightness.dark;

    return shad.ModalContainer(
      child: shad.OutlinedContainer(
        backgroundColor: colors.card,
        borderColor: colors.card,
        borderRadius: BorderRadius.circular(theme.radiusLg),
        child: SizedBox(
          width: 620 * theme.scaling,
          child: Padding(
            padding: EdgeInsets.all(pad * 1.4),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(shad.LucideIcons.keyRound,
                          size: 20 * theme.scaling, color: colors.primary),
                      const shad.DensityGap(shad.gapSm),
                      Expanded(
                        child: Text('Connect Google Contacts Account',
                            style: theme.typography.h4),
                      ),
                      shad.GhostButton(
                        onPressed: _isSavingToken
                            ? null
                            : () async {
                                await widget.service.cancelDesktopLoopbackOAuth();
                                if (mounted) widget.onDone(false);
                              },
                        child: const Icon(shad.LucideIcons.x, size: 16),
                      ),
                    ],
                  ),
                  const shad.DensityGap(shad.gapXs),
                  Text(
                    'Dedicated Google People API sync stored in IMMBE2627.sb_google_sync_state (isolated from ERP staff login).',
                    style: theme.typography.xSmall
                        .copyWith(color: colors.mutedForeground),
                  ),
                  const shad.DensityGap(shad.gapMd),
                  Text('Target Gmail Account',
                      style: theme.typography.xSmall
                          .copyWith(fontWeight: FontWeight.w600)),
                  const shad.DensityGap(shad.gapXs),
                  shad.TextField(
                    controller: _emailCtrl,
                    placeholder: const Text('design.ambaji@gmail.com'),
                  ),
                  const shad.DensityGap(shad.gapMd),

                  // OPTION B — RECOMMENDED INSTANT PLAYGROUND FLOW (AT TOP)
                  shad.OutlinedContainer(
                    backgroundColor: colors.card,
                    borderColor: colors.primary.withAlpha(110),
                    borderRadius: BorderRadius.circular(theme.radiusMd),
                    padding: EdgeInsets.all(pad),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                'Option B — Instant Token Connect via OAuth Playground (Recommended)',
                                style: theme.typography.textSmall
                                    .copyWith(fontWeight: FontWeight.w700),
                              ),
                            ),
                          ],
                        ),
                        const shad.DensityGap(shad.gapXs),
                        Text(
                          '1) Copy Contacts Scope -> 2) Open OAuth Playground, paste scope in "Input your own scopes", click Authorize APIs as design.ambaji@gmail.com -> 3) Click "Exchange authorization code for tokens" and paste the Access Token or JSON below:',
                          style: theme.typography.xSmall
                              .copyWith(color: colors.mutedForeground),
                        ),
                        const shad.DensityGap(shad.gapSm),
                        Wrap(
                          spacing: 8 * theme.scaling,
                          runSpacing: 8 * theme.scaling,
                          children: [
                            shad.OutlineButton(
                              size: shad.ButtonSize.small,
                              onPressed: () => _copyToClipboard(
                                _contactsScope,
                                'Copied "$_contactsScope"! Paste it into OAuth Playground Step 1.',
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: const [
                                  Icon(shad.LucideIcons.copy, size: 12),
                                  shad.DensityGap(shad.gapXs),
                                  Text('1. Copy Contacts Scope'),
                                ],
                              ),
                            ),
                            shad.PrimaryButton(
                              size: shad.ButtonSize.small,
                              onPressed: () => widget.service
                                  .launchOAuthPlaygroundHelper(
                                      email: _emailCtrl.text.trim()),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: const [
                                  Icon(shad.LucideIcons.externalLink, size: 12),
                                  shad.DensityGap(shad.gapXs),
                                  Text('2. Open OAuth Playground'),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const shad.DensityGap(shad.gapSm),
                        shad.TextField(
                          controller: _accessTokenCtrl,
                          placeholder: const Text(
                              'Paste Access Token (ya29.a0...) or Playground JSON response'),
                        ),
                        const shad.DensityGap(shad.gapSm),
                        shad.TextField(
                          controller: _refreshTokenCtrl,
                          placeholder:
                              const Text('Optional Refresh Token (1//0g...)'),
                        ),
                      ],
                    ),
                  ),
                  const shad.DensityGap(shad.gapMd),

                  // OPTION A — DESKTOP LOOPBACK OAUTH
                  shad.OutlinedContainer(
                    backgroundColor: colors.muted.withAlpha(65),
                    borderColor: colors.border,
                    borderRadius: BorderRadius.circular(theme.radiusMd),
                    padding: EdgeInsets.all(pad),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                'Option A — Desktop Browser Loopback OAuth ($_fixedRedirectUri)',
                                style: theme.typography.textSmall
                                    .copyWith(fontWeight: FontWeight.w600),
                              ),
                            ),
                            shad.OutlineButton(
                              size: shad.ButtonSize.small,
                              onPressed: () => _copyToClipboard(
                                _fixedRedirectUri,
                                'Copied "$_fixedRedirectUri"! Add this exact URI under Authorized redirect URIs in Google Cloud Console.',
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: const [
                                  Icon(shad.LucideIcons.copy, size: 11),
                                  shad.DensityGap(shad.gapXs),
                                  Text('Copy Redirect URI'),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const shad.DensityGap(shad.gapXs),
                        Text(
                          'If using Web Client ID 486012291961-..., add $_fixedRedirectUri to Authorized redirect URIs in Google Cloud Console, or use a Desktop App Client ID.',
                          style: theme.typography.xSmall
                              .copyWith(color: colors.mutedForeground),
                        ),
                        const shad.DensityGap(shad.gapSm),
                        shad.TextField(
                          controller: _clientIdCtrl,
                          placeholder: const Text('Google OAuth Client ID...'),
                        ),
                        const shad.DensityGap(shad.gapSm),
                        shad.TextField(
                          controller: _clientSecretCtrl,
                          obscureText: true,
                          placeholder: const Text(
                              'Google OAuth Client Secret (leave blank if unchanged)...'),
                        ),
                        const shad.DensityGap(shad.gapSm),
                        Row(
                          children: [
                            shad.OutlineButton(
                              onPressed: _isSavingToken || _isWaitingForBrowser
                                  ? null
                                  : _runDesktopOAuth,
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(shad.LucideIcons.externalLink,
                                      size: 13),
                                  const shad.DensityGap(shad.gapXs),
                                  Text(_isWaitingForBrowser
                                      ? 'Waiting for Browser...'
                                      : 'Authorize design.ambaji@gmail.com in Browser'),
                                ],
                              ),
                            ),
                            if (_isWaitingForBrowser) ...[
                              const shad.DensityGap(shad.gapSm),
                              shad.DestructiveButton(
                                size: shad.ButtonSize.small,
                                onPressed: _cancelBrowserWait,
                                child: const Text('Cancel Browser Wait'),
                              ),
                            ],
                          ],
                        ),
                      ],
                    ),
                  ),

                  if (_statusMessage != null) ...[
                    const shad.DensityGap(shad.gapMd),
                    shad.OutlinedContainer(
                      backgroundColor: DyColorSystem.resolveSurface(
                        _isError
                            ? DyColorSystem.red500
                            : DyColorSystem.emerald500,
                        isDark,
                      ),
                      borderColor: DyColorSystem.resolveBorder(
                        _isError
                            ? DyColorSystem.red500
                            : DyColorSystem.emerald500,
                        isDark,
                      ),
                      borderRadius: BorderRadius.circular(theme.radiusSm),
                      padding: EdgeInsets.all(pad * 0.8),
                      child: Text(
                        _statusMessage!,
                        style: theme.typography.xSmall.copyWith(
                          color: _isError
                              ? DyColorSystem.red600
                              : DyColorSystem.emerald600,
                        ),
                      ),
                    ),
                  ],
                  const shad.DensityGap(shad.gapLg),
                  Row(
                    children: [
                      if (widget.syncState.isConnected)
                        shad.DestructiveButton(
                          onPressed: _isSavingToken ? null : _disconnect,
                          child: const Text('Disconnect'),
                        ),
                      const Spacer(),
                      shad.OutlineButton(
                        onPressed: _isSavingToken
                            ? null
                            : () async {
                                await widget.service.cancelDesktopLoopbackOAuth();
                                if (mounted) widget.onDone(false);
                              },
                        child: const Text('Cancel'),
                      ),
                      const shad.DensityGap(shad.gapSm),
                      shad.PrimaryButton(
                        onPressed: _isSavingToken ? null : _saveManualTokens,
                        child: _isSavingToken
                            ? const SizedBox(
                                width: 14,
                                height: 14,
                                child: shad.CircularProgressIndicator(
                                    strokeWidth: 2),
                              )
                            : const Text('Save Token & Pull Contacts'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ContactsCsvImportModal extends StatefulWidget {
  final String accountEmail;
  final ServiceGoogleContacts service;
  final ValueChanged<bool> onDone;

  const _ContactsCsvImportModal({
    required this.accountEmail,
    required this.service,
    required this.onDone,
  });

  @override
  State<_ContactsCsvImportModal> createState() =>
      _ContactsCsvImportModalState();
}

class _ContactsCsvImportModalState extends State<_ContactsCsvImportModal> {
  final TextEditingController _pasteCtrl = TextEditingController();
  String? _selectedFileName;
  String? _pickedCsvContent;
  int _estimatedRows = 0;

  bool _isImporting = false;
  double _progress = 0.0;
  String _stepText =
      'Pick the CSV exported from contacts.google.com ("Google CSV" format).';
  PullResult? _result;

  @override
  void dispose() {
    _pasteCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickCsvFile() async {
    try {
      final picked = await FilePicker.pickFiles(
        dialogTitle: 'Select Google Contacts CSV Export (contacts.csv)',
        type: FileType.custom,
        allowedExtensions: const ['csv'],
        withData: true,
      );
      if (!mounted || picked == null || picked.files.isEmpty) return;

      final file = picked.files.first;
      final bytes = file.bytes;
      if (bytes == null || bytes.isEmpty) {
        setState(() {
          _result = const PullResult(
            isSuccess: false,
            count: 0,
            message: 'Unable to read selected file bytes.',
          );
        });
        return;
      }

      final content = utf8.decode(bytes, allowMalformed: true);
      final previewRows = ServiceGoogleContacts.parseRfc4180Csv(content);
      final dataRowCount =
          previewRows.length > 1 ? previewRows.length - 1 : 0;

      if (!mounted) return;
      setState(() {
        _selectedFileName = file.name;
        _pickedCsvContent = content;
        _estimatedRows = dataRowCount;
        _result = null;
        _stepText =
            'Ready to import $dataRowCount contacts from "${file.name}" into IMMBE2627.sb_contacts.';
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _result = PullResult(
            isSuccess: false, count: 0, message: 'File selection failed: $e');
      });
    }
  }

  Future<void> _startImport() async {
    final csvSource =
        (_pickedCsvContent != null && _pickedCsvContent!.trim().isNotEmpty)
            ? _pickedCsvContent!
            : _pasteCtrl.text;

    if (csvSource.trim().isEmpty) {
      setState(() {
        _result = const PullResult(
          isSuccess: false,
          count: 0,
          message: 'Select a contacts.csv file or paste CSV content first.',
        );
      });
      return;
    }

    setState(() {
      _isImporting = true;
      _progress = 0.04;
      _result = null;
      _stepText = 'Starting lossless RFC-4180 CSV import...';
    });

    final outcome = await widget.service.importGoogleContactsCsvWithProgress(
      csvContent: csvSource,
      accountEmail: widget.accountEmail,
      onProgress: (p, msg) {
        if (!mounted) return;
        setState(() {
          _progress = p;
          _stepText = msg;
        });
      },
    );

    if (!mounted) return;
    setState(() {
      _isImporting = false;
      _progress = 1.0;
      _result = outcome;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = shad.Theme.of(context);
    final colors = theme.colorScheme;
    final pad = theme.density.baseContainerPadding * theme.scaling;
    final isDark = theme.brightness == Brightness.dark;

    return _opaqueModalShell(
      theme: theme,
      width: 580,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(shad.LucideIcons.fileSpreadsheet, size: 20 * theme.scaling, color: colors.primary),
              const shad.DensityGap(shad.gapSm),
              Expanded(child: Text('Import Google Contacts CSV (${widget.accountEmail})', style: theme.typography.h4)),
              shad.GhostButton(
                onPressed: _isImporting ? null : () => widget.onDone(_result?.isSuccess == true),
                child: const Icon(shad.LucideIcons.x, size: 16),
              ),
            ],
          ),
          const shad.DensityGap(shad.gapXs),
          Text(
            'Parses 7,000+ rows locally (RFC-4180 multi-phone, addresses, labels & notes) and batch-upserts via 400-row RPC chunks.',
            style: theme.typography.xSmall.copyWith(color: colors.mutedForeground),
          ),
          const shad.DensityGap(shad.gapMd),
          shad.OutlinedContainer(
            backgroundColor: colors.muted.withAlpha(50),
            borderColor: _selectedFileName != null ? colors.primary : colors.border,
            borderRadius: BorderRadius.circular(theme.radiusMd),
            padding: EdgeInsets.all(pad * 1.2),
            child: Row(
              children: [
                Icon(
                  shad.LucideIcons.upload,
                  size: 20 * theme.scaling,
                  color: _selectedFileName != null ? colors.primary : colors.mutedForeground,
                ),
                const shad.DensityGap(shad.gapMd),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(_selectedFileName ?? 'No CSV file chosen yet',
                          style: theme.typography.textSmall.copyWith(fontWeight: FontWeight.w600),
                          overflow: TextOverflow.ellipsis),
                      Text(
                        _selectedFileName != null
                            ? '$_estimatedRows contact rows ready to upload'
                            : 'Export from contacts.google.com -> Export -> Google CSV',
                        style: theme.typography.xSmall.copyWith(color: colors.mutedForeground),
                      ),
                    ],
                  ),
                ),
                const shad.DensityGap(shad.gapSm),
                shad.PrimaryButton(
                  onPressed: _isImporting ? null : _pickCsvFile,
                  child: const Text('Choose contacts.csv'),
                ),
              ],
            ),
          ),
          const shad.DensityGap(shad.gapMd),
          if (_selectedFileName == null) ...[
            Text('Or paste quick CSV sample:',
                style: theme.typography.xSmall.copyWith(color: colors.mutedForeground)),
            const shad.DensityGap(shad.gapXs),
            shad.TextField(
              controller: _pasteCtrl,
              maxLines: 4,
              placeholder: const Text(
                'First Name,Last Name,Organization Name,Phone 1 - Type,Phone 1 - Value\n'
                'Ramesh,Patel,Ambaji Silk Mills,Mobile,+91 98251 44321',
              ),
            ),
            const shad.DensityGap(shad.gapMd),
          ],
          if (_isImporting || _result != null) ...[
            shad.LinearProgressIndicator(
              value: _progress.clamp(0.0, 1.0),
              theme: shad.LinearProgressIndicatorTheme(
                color: _result != null && !_result!.isSuccess ? DyColorSystem.red500 : colors.primary,
                backgroundColor: colors.muted,
                minHeight: 7 * theme.scaling,
                borderRadius: BorderRadius.circular(99),
              ),
            ),
            const shad.DensityGap(shad.gapSm),
            Text(_stepText, style: theme.typography.xSmall.copyWith(color: colors.mutedForeground)),
          ],
          if (_result != null) ...[
            const shad.DensityGap(shad.gapMd),
            shad.OutlinedContainer(
              backgroundColor: DyColorSystem.resolveSurface(
                  _result!.isSuccess ? DyColorSystem.emerald500 : DyColorSystem.red500, isDark),
              borderColor: DyColorSystem.resolveBorder(
                  _result!.isSuccess ? DyColorSystem.emerald500 : DyColorSystem.red500, isDark),
              borderRadius: BorderRadius.circular(theme.radiusSm),
              padding: EdgeInsets.all(pad),
              child: Text(
                _result!.message,
                style: theme.typography.textSmall.copyWith(
                  fontWeight: FontWeight.w600,
                  color: _result!.isSuccess ? DyColorSystem.emerald600 : DyColorSystem.red600,
                ),
              ),
            ),
          ],
          const shad.DensityGap(shad.gapLg),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              shad.OutlineButton(
                onPressed: _isImporting ? null : () => widget.onDone(_result?.isSuccess == true),
                child: Text(_result?.isSuccess == true ? 'Done' : 'Cancel'),
              ),
              if (_result?.isSuccess != true) ...[
                const shad.DensityGap(shad.gapSm),
                shad.PrimaryButton(
                  onPressed: _isImporting ? null : _startImport,
                  child: _isImporting
                      ? const Text('Importing...')
                      : Text(_estimatedRows > 0 ? 'Import $_estimatedRows Contacts' : 'Start CSV Import'),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

class _ContactsSyncProgressModal extends StatefulWidget {
  final String accountEmail;
  final bool forceFullSync;
  final bool isPushMode;
  final ServiceGoogleContacts service;
  final ValueChanged<PullResult?> onClose;

  const _ContactsSyncProgressModal({
    required this.accountEmail,
    required this.forceFullSync,
    required this.isPushMode,
    required this.service,
    required this.onClose,
  });

  @override
  State<_ContactsSyncProgressModal> createState() => _ContactsSyncProgressModalState();
}

class _ContactsSyncProgressModalState extends State<_ContactsSyncProgressModal> {
  double _progress = 0.05;
  String _stepMessage = 'Initializing Google People API v1 sync...';
  PullResult? _result;

  @override
  void initState() {
    super.initState();
    _executePull();
  }

  Future<void> _executePull() async {
    void handleProgress(double p, String msg) {
      if (!mounted) return;
      setState(() {
        _progress = p;
        _stepMessage = msg;
      });
    }

    final res = widget.isPushMode
        ? await widget.service.pushPendingContactsToGoogle(
            email: widget.accountEmail, onProgress: handleProgress)
        : await widget.service.pullFromGoogleWithProgress(
            email: widget.accountEmail,
            forceFullSync: widget.forceFullSync,
            onProgress: handleProgress,
          );
    if (!mounted) return;
    setState(() {
      _progress = 1.0;
      _result = res;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = shad.Theme.of(context);
    final colors = theme.colorScheme;
    final pad = theme.density.baseContainerPadding * theme.scaling;
    final isDark = theme.brightness == Brightness.dark;
    final accent = _result == null
        ? colors.primary
        : (_result!.isSuccess ? DyColorSystem.emerald500 : DyColorSystem.orange500);

    return _opaqueModalShell(
      theme: theme,
      width: 520,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(shad.LucideIcons.refreshCw, size: 20 * theme.scaling, color: colors.primary),
              const shad.DensityGap(shad.gapSm),
              Expanded(
                child: Text(
                  widget.isPushMode
                      ? 'Pushing Pending Contacts to Google'
                      : (widget.forceFullSync
                          ? 'Full Google Contacts Sync'
                          : 'Syncing Google Contacts (Delta Pull)'),
                  style: theme.typography.h4,
                ),
              ),
            ],
          ),
          const shad.DensityGap(shad.gapMd),
          shad.LinearProgressIndicator(
            value: _progress.clamp(0.0, 1.0),
            theme: shad.LinearProgressIndicatorTheme(
              color: accent,
              backgroundColor: colors.muted,
              minHeight: 8 * theme.scaling,
              borderRadius: BorderRadius.circular(99),
            ),
          ),
          const shad.DensityGap(shad.gapSm),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('${(_progress * 100).round()}%',
                  style: theme.typography.xSmall.copyWith(fontWeight: FontWeight.w600)),
              Text(widget.accountEmail,
                  style: theme.typography.mono.copyWith(fontSize: 11, color: colors.mutedForeground)),
            ],
          ),
          const shad.DensityGap(shad.gapXs),
          Text(_stepMessage, style: theme.typography.xSmall.copyWith(color: colors.mutedForeground)),
          if (_result != null) ...[
            const shad.DensityGap(shad.gapMd),
            shad.OutlinedContainer(
              backgroundColor: DyColorSystem.resolveSurface(accent, isDark),
              borderColor: DyColorSystem.resolveBorder(accent, isDark),
              borderRadius: BorderRadius.circular(theme.radiusSm),
              padding: EdgeInsets.all(pad),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(_result!.message,
                      style: theme.typography.textSmall.copyWith(fontWeight: FontWeight.w600)),
                  if (_result!.detail != null && _result!.detail!.isNotEmpty) ...[
                    const shad.DensityGap(shad.gapXs),
                    Text(_result!.detail!,
                        style: theme.typography.xSmall.copyWith(color: colors.mutedForeground)),
                  ],
                ],
              ),
            ),
          ],
          const shad.DensityGap(shad.gapLg),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              shad.PrimaryButton(
                onPressed: _result == null ? null : () => widget.onClose(_result),
                child: Text(_result == null ? 'Syncing...' : 'Close'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
