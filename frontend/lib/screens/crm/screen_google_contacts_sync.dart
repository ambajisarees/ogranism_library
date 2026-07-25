import 'package:flutter/material.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart' as shad;
import '../../models/model_google_contacts.dart';
import '../../services/service_google_contacts.dart';

/// ScreenGoogleContactsSync — Desktop Management Screen for Google Contacts & Master Party Linker
class ScreenGoogleContactsSync extends StatefulWidget {
  const ScreenGoogleContactsSync({super.key});

  @override
  State<ScreenGoogleContactsSync> createState() => _ScreenGoogleContactsSyncState();
}

class _ScreenGoogleContactsSyncState extends State<ScreenGoogleContactsSync> {
  final ServiceGoogleContacts _contactsService = ServiceGoogleContacts();

  List<GoogleContact> _contacts = [];
  List<MasterPartyOption> _masterOptions = [];
  final Set<String> _selectedContactIds = {};

  bool _isLoading = true;
  bool _isProcessingAction = false;
  String _searchQuery = '';
  int _filterTab = 0; // 0: All, 1: Unlinked, 2: Linked

  GoogleAuthStatus _authStatus = const GoogleAuthStatus(isConnected: false);
  GoogleContact? _selectedContact;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final auth = await _contactsService.getAuthStatus();
      final unlinkedOnly = _filterTab == 1;
      final linkedOnly = _filterTab == 2;
      final contacts = await _contactsService.fetchContacts(
        searchQuery: _searchQuery,
        unlinkedOnly: unlinkedOnly,
        linkedOnly: linkedOnly,
      );
      final masters = await _contactsService.searchMasterParties(limit: 100);

      if (!mounted) return;
      setState(() {
        _authStatus = auth;
        _contacts = contacts;
        _masterOptions = masters;
        _isLoading = false;
        if (_contacts.isNotEmpty && _selectedContact == null) {
          _selectedContact = _contacts.first;
        }
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
    }
  }

  Future<void> _handleConnectAccount() async {
    setState(() => _isProcessingAction = true);
    final ok = await _contactsService.signInWithSupabaseGoogle();
    if (!ok && mounted) {
      _showOAuthModal();
    }
    if (!mounted) return;
    setState(() => _isProcessingAction = false);
    _loadData();
  }

  void _showOAuthModal() {
    showDialog(
      context: context,
      builder: (context) {
        String email = _authStatus.email ?? 'sub.ambaji@gmail.com';
        String accessToken = '';

        return shad.ModalContainer(
          child: Container(
            width: 520,
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Connect Google Account', style: shad.Theme.of(context).typography.h4),
                const SizedBox(height: 6),
                Text(
                  'Authorize your single Google Account to pull & sync contacts into ERP Master Parties.',
                  style: shad.Theme.of(context).typography.xSmall,
                ),
                const SizedBox(height: 16),
                shad.TextField(
                  initialValue: email,
                  placeholder: const Text('Google Account Email...'),
                  features: const [
                    shad.InputFeature.leading(
                      Padding(
                        padding: EdgeInsets.only(left: 8, right: 6),
                        child: Icon(shad.LucideIcons.mail, size: 16),
                      ),
                    ),
                  ],
                  onChanged: (val) => email = val,
                ),
                const SizedBox(height: 12),
                shad.PrimaryButton(
                  onPressed: () async {
                    await _contactsService.signInWithSupabaseGoogle();
                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Icon(shad.LucideIcons.chrome, size: 14),
                      SizedBox(width: 6),
                      Text('Sign In with Google (OAuth)'),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                const Divider(),
                const SizedBox(height: 8),
                Text('Or Paste Google Access Token Directly:', style: shad.Theme.of(context).typography.xSmall.copyWith(fontWeight: FontWeight.bold)),
                const SizedBox(height: 6),
                shad.TextField(
                  placeholder: const Text('Google OAuth Access Token (ya29.a0...)...'),
                  features: const [
                    shad.InputFeature.leading(
                      Padding(
                        padding: EdgeInsets.only(left: 8, right: 6),
                        child: Icon(shad.LucideIcons.key, size: 16),
                      ),
                    ),
                  ],
                  onChanged: (val) => accessToken = val,
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    shad.OutlineButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('Cancel'),
                    ),
                    const SizedBox(width: 8),
                    shad.SecondaryButton(
                      onPressed: () async {
                        Navigator.of(context).pop();
                        if (accessToken.isNotEmpty) {
                          _contactsService.setManualAccessToken(accessToken);
                        }
                        await _contactsService.connectGoogleAccount(userEmail: email);
                        if (!mounted) return;
                        _loadData();
                      },
                      child: const Text('Save & Fetch Contacts'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _handlePullFromGoogle() async {
    double currentProgress = 0.10;
    String currentStep = 'Checking Google OAuth Session...';
    PullResult? pullResult;
    StateSetter? updateModalState;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (modalContext, setModalState) {
            updateModalState = setModalState;
            return shad.ModalContainer(
              child: Container(
                width: 500,
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(shad.LucideIcons.refreshCw, size: 20, color: shad.Theme.of(modalContext).colorScheme.primary),
                        const SizedBox(width: 10),
                        Text('Syncing Google Contacts...', style: shad.Theme.of(modalContext).typography.h4),
                      ],
                    ),
                    const SizedBox(height: 16),
                    // Progress Indicator Bar
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: currentProgress,
                        backgroundColor: shad.Theme.of(modalContext).colorScheme.muted.withAlpha(50),
                        valueColor: AlwaysStoppedAnimation<Color>(shad.Theme.of(modalContext).colorScheme.primary),
                        minHeight: 8,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '${(currentProgress * 100).toInt()}% Complete',
                          style: shad.Theme.of(modalContext).typography.xSmall.copyWith(fontWeight: FontWeight.bold),
                        ),
                        Text(
                          currentProgress < 1.0 ? 'Est. remaining: ~2s' : 'Done',
                          style: shad.Theme.of(modalContext).typography.xSmall.copyWith(color: shad.Theme.of(modalContext).colorScheme.mutedForeground),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      currentStep,
                      style: shad.Theme.of(modalContext).typography.xSmall.copyWith(color: shad.Theme.of(modalContext).colorScheme.mutedForeground),
                    ),
                    if (pullResult != null) ...[
                      const SizedBox(height: 16),
                      shad.OutlinedContainer(
                        borderColor: pullResult!.isSuccess ? Colors.green : Colors.amber.shade700,
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                pullResult!.message,
                                style: shad.Theme.of(modalContext).typography.textSmall.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: pullResult!.isSuccess ? Colors.green : Colors.amber.shade700,
                                    ),
                              ),
                              if (pullResult!.detail != null) ...[
                                const SizedBox(height: 4),
                                Text(pullResult!.detail!, style: shad.Theme.of(modalContext).typography.xSmall),
                              ],
                            ],
                          ),
                        ),
                      ),
                    ],
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        if (pullResult != null && !pullResult!.isSuccess) ...[
                          shad.PrimaryButton(
                            onPressed: () {
                              Navigator.of(dialogContext).pop();
                              _handleConnectAccount();
                            },
                            child: const Text('Connect Google Account'),
                          ),
                          const SizedBox(width: 8),
                        ],
                        shad.OutlineButton(
                          onPressed: pullResult == null ? null : () => Navigator.of(dialogContext).pop(),
                          child: Text(pullResult == null ? 'Syncing...' : 'Close'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );

    final res = await _contactsService.pullFromGoogleWithProgress(
      onProgress: (progress, message) {
        if (updateModalState != null) {
          updateModalState!(() {
            currentProgress = progress;
            currentStep = message;
          });
        }
      },
    );

    if (updateModalState != null) {
      updateModalState!(() {
        pullResult = res;
        currentProgress = 1.0;
        currentStep = res.isSuccess ? 'Sync Completed!' : 'Sync Notice';
      });
    }

    if (!mounted) return;
    _loadData();
  }

  Future<void> _handleImportCsv() async {
    showDialog(
      context: context,
      builder: (context) {
        String rawCsv = '';
        return shad.ModalContainer(
          child: Container(
            width: 520,
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Import Google Contacts CSV', style: shad.Theme.of(context).typography.h4),
                const SizedBox(height: 6),
                Text(
                  'Paste CSV exported from contacts.google.com to instantly load contacts into ERP.',
                  style: shad.Theme.of(context).typography.xSmall,
                ),
                const SizedBox(height: 16),
                shad.TextField(
                  maxLines: 8,
                  placeholder: const Text('Paste Google Contacts CSV content here...\nName,Phone,Organization\nRamesh Patel,+919825144321,ABC Fabrics'),
                  onChanged: (val) => rawCsv = val,
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    shad.OutlineButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('Cancel'),
                    ),
                    const SizedBox(width: 8),
                    shad.PrimaryButton(
                      onPressed: () async {
                        Navigator.of(context).pop();
                        setState(() => _isProcessingAction = true);
                        await _contactsService.importGoogleContactsFromCsv(rawCsv);
                        if (!mounted) return;
                        setState(() => _isProcessingAction = false);
                        _loadData();
                      },
                      child: const Text('Import Contacts'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _handleAutoMatch() async {
    setState(() => _isProcessingAction = true);
    await _contactsService.autoMatchContactsWithMasters();
    if (!mounted) return;
    setState(() => _isProcessingAction = false);
    _loadData();
  }

  Future<void> _handlePushToGoogle() async {
    setState(() => _isProcessingAction = true);
    await _contactsService.pushToGoogle();
    if (!mounted) return;
    setState(() => _isProcessingAction = false);
    _loadData();
  }

  Future<void> _handleLinkToMaster(String contactId, String masterCode) async {
    await _contactsService.linkContactToMaster(contactId: contactId, masterCode: masterCode);
    _loadData();
  }

  Future<void> _handleUnlink(String contactId) async {
    await _contactsService.unlinkContact(contactId);
    _loadData();
  }

  Future<void> _handleBulkLink(String masterCode) async {
    if (_selectedContactIds.isEmpty) return;
    setState(() => _isProcessingAction = true);
    await _contactsService.bulkLinkContacts(
      contactIds: _selectedContactIds.toList(),
      masterCode: masterCode,
    );
    if (!mounted) return;
    setState(() {
      _selectedContactIds.clear();
      _isProcessingAction = false;
    });
    _loadData();
  }

  @override
  Widget build(BuildContext context) {
    final theme = shad.Theme.of(context);
    final colors = theme.colorScheme;

    return Scaffold(
      backgroundColor: colors.background,
      body: Column(
        children: [
          _buildTopBar(theme, colors),
          const Divider(height: 1),
          _buildFilterBar(theme, colors),
          const Divider(height: 1),
          Expanded(
            child: _isLoading
                ? const Center(child: shad.CircularProgressIndicator())
                : _buildMainContent(theme, colors),
          ),
        ],
      ),
    );
  }

  Widget _buildTopBar(shad.ThemeData theme, shad.ColorScheme colors) {
    final linkedCount = _contacts.where((c) => c.isLinked).length;
    final unlinkedCount = _contacts.where((c) => !c.isLinked).length;

    return Padding(
      padding: EdgeInsets.all(theme.density.baseContainerPadding * theme.scaling * 1.5),
      child: Row(
        children: [
          Icon(shad.LucideIcons.contact, size: 22, color: colors.primary),
          SizedBox(width: theme.density.baseContainerPadding * theme.scaling),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Google Contacts Sync & People Linker', style: theme.typography.h4),
              Text(
                'Connect individual contacts to ERP Master Organizations (1 Party : N People)',
                style: theme.typography.xSmall.copyWith(color: colors.mutedForeground),
              ),
            ],
          ),
          const Spacer(),
          // Google Auth Status Button
          GestureDetector(
            onTap: _showOAuthModal,
            child: Focus(
              canRequestFocus: false,
              skipTraversal: true,
              descendantsAreFocusable: false,
              child: _authStatus.isConnected
                  ? shad.PrimaryBadge(
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(shad.LucideIcons.circleCheck, size: 12, color: Colors.white),
                          const SizedBox(width: 4),
                          Text(_authStatus.email ?? 'Google Connected'),
                        ],
                      ),
                    )
                  : shad.SecondaryBadge(
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: const [
                          Icon(shad.LucideIcons.keyRound, size: 12),
                          SizedBox(width: 4),
                          Text('Connect Google Account'),
                        ],
                      ),
                    ),
            ),
          ),
          SizedBox(width: theme.density.baseContainerPadding * theme.scaling * 1.5),
          Focus(
            canRequestFocus: false,
            skipTraversal: true,
            descendantsAreFocusable: false,
            child: shad.SecondaryBadge(
              child: Text('Linked: $linkedCount | Unlinked: $unlinkedCount'),
            ),
          ),
          SizedBox(width: theme.density.baseContainerPadding * theme.scaling * 1.5),
          shad.OutlineButton(
            onPressed: _isProcessingAction ? null : _handleImportCsv,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: const [
                Icon(shad.LucideIcons.fileSpreadsheet, size: 14),
                SizedBox(width: 6),
                Text('Import CSV'),
              ],
            ),
          ),
          SizedBox(width: theme.density.baseContainerPadding * theme.scaling),
          shad.OutlineButton(
            onPressed: _isProcessingAction ? null : _handlePullFromGoogle,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: const [
                Icon(shad.LucideIcons.arrowDownLeft, size: 14),
                SizedBox(width: 6),
                Text('Pull from Google'),
              ],
            ),
          ),
          SizedBox(width: theme.density.baseContainerPadding * theme.scaling),
          shad.OutlineButton(
            onPressed: _isProcessingAction ? null : _handlePushToGoogle,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: const [
                Icon(shad.LucideIcons.arrowUpRight, size: 14),
                SizedBox(width: 6),
                Text('Push to Google'),
              ],
            ),
          ),
          SizedBox(width: theme.density.baseContainerPadding * theme.scaling),
          shad.PrimaryButton(
            onPressed: _isProcessingAction ? null : _handleAutoMatch,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: const [
                Icon(shad.LucideIcons.sparkles, size: 14),
                SizedBox(width: 6),
                Text('Auto-Match Masters'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterBar(shad.ThemeData theme, shad.ColorScheme colors) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: theme.density.baseContainerPadding * theme.scaling * 1.5,
        vertical: theme.density.baseContainerPadding * theme.scaling,
      ),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: shad.TextField(
              placeholder: const Text('Search by contact name, phone, company, or master org...'),
              features: const [
                shad.InputFeature.leading(
                  Padding(
                    padding: EdgeInsets.only(left: 8, right: 6),
                    child: Icon(shad.LucideIcons.search, size: 16),
                  ),
                ),
              ],
              onChanged: (val) {
                _searchQuery = val;
                _loadData();
              },
            ),
          ),
          SizedBox(width: theme.density.baseContainerPadding * theme.scaling * 1.5),
          shad.OutlineButton(
            onPressed: () {
              setState(() {
                _filterTab = 0;
              });
              _loadData();
            },
            child: Text(
              'All (${_contacts.length})',
              style: TextStyle(fontWeight: _filterTab == 0 ? FontWeight.bold : FontWeight.normal),
            ),
          ),
          SizedBox(width: theme.density.baseContainerPadding * theme.scaling * 0.5),
          shad.OutlineButton(
            onPressed: () {
              setState(() {
                _filterTab = 1;
              });
              _loadData();
            },
            child: Text(
              'Unlinked',
              style: TextStyle(fontWeight: _filterTab == 1 ? FontWeight.bold : FontWeight.normal),
            ),
          ),
          SizedBox(width: theme.density.baseContainerPadding * theme.scaling * 0.5),
          shad.OutlineButton(
            onPressed: () {
              setState(() {
                _filterTab = 2;
              });
              _loadData();
            },
            child: Text(
              'Linked',
              style: TextStyle(fontWeight: _filterTab == 2 ? FontWeight.bold : FontWeight.normal),
            ),
          ),
          if (_selectedContactIds.isNotEmpty) ...[
            const Spacer(),
            shad.SecondaryButton(
              onPressed: () => _showBulkLinkDialog(context),
              child: Text('Bulk Link Selected (${_selectedContactIds.length})'),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildMainContent(shad.ThemeData theme, shad.ColorScheme colors) {
    if (_contacts.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(shad.LucideIcons.users, size: 48, color: colors.mutedForeground),
            const SizedBox(height: 12),
            Text('No Google Contacts Found in IMMBE2627.sb_google_contacts', style: theme.typography.h3),
            const SizedBox(height: 6),
            Text('Click "Import CSV" or "Connect Google Account" to load your contacts.', style: theme.typography.textSmall.copyWith(color: colors.mutedForeground)),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                shad.PrimaryButton(
                  onPressed: _handleImportCsv,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: const [
                      Icon(shad.LucideIcons.fileSpreadsheet, size: 14),
                      SizedBox(width: 6),
                      Text('1-Click Import Google CSV'),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                shad.OutlineButton(
                  onPressed: _showOAuthModal,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: const [
                      Icon(shad.LucideIcons.keyRound, size: 14),
                      SizedBox(width: 6),
                      Text('Connect Google OAuth'),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      );
    }

    return Row(
      children: [
        // Left Column: Native Shadcn Table View
        Expanded(
          flex: 7,
          child: Column(
            children: [
              _buildTableHeader(theme, colors),
              Expanded(
                child: ListView.separated(
                  padding: EdgeInsets.all(theme.density.baseContainerPadding * theme.scaling * 1.2),
                  itemCount: _contacts.length,
                  separatorBuilder: (_, __) => SizedBox(height: theme.density.baseContainerPadding * theme.scaling * 0.5),
                  itemBuilder: (context, index) {
                    final contact = _contacts[index];
                    final isSelected = _selectedContact?.id == contact.id;
                    final isChecked = _selectedContactIds.contains(contact.id);

                    return _buildTableRow(context, contact, isSelected, isChecked, theme, colors);
                  },
                ),
              ),
            ],
          ),
        ),
        const VerticalDivider(width: 1),
        // Right Column: Master Party Intelligence & Multi-Contact Roster
        Expanded(
          flex: 4,
          child: _buildRightPanel(theme, colors),
        ),
      ],
    );
  }

  Widget _buildTableHeader(shad.ThemeData theme, shad.ColorScheme colors) {
    final allSelected = _contacts.isNotEmpty && _selectedContactIds.length == _contacts.length;

    return shad.OutlinedContainer(
      borderColor: colors.border,
      child: Container(
        color: colors.muted.withAlpha(40),
        padding: EdgeInsets.symmetric(
          horizontal: theme.density.baseContainerPadding * theme.scaling * 1.2,
          vertical: theme.density.baseContainerPadding * theme.scaling * 0.8,
        ),
        child: Row(
          children: [
            SizedBox(
              width: 32,
              child: shad.Checkbox(
                state: allSelected ? shad.CheckboxState.checked : shad.CheckboxState.unchecked,
                onChanged: (val) {
                  setState(() {
                    if (val == shad.CheckboxState.checked) {
                      _selectedContactIds.addAll(_contacts.map((c) => c.id));
                    } else {
                      _selectedContactIds.clear();
                    }
                  });
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              flex: 3,
              child: Text('Contact Name', style: theme.typography.xSmall.copyWith(fontWeight: FontWeight.bold, color: colors.mutedForeground)),
            ),
            Expanded(
              flex: 2,
              child: Text('Phone Number', style: theme.typography.xSmall.copyWith(fontWeight: FontWeight.bold, color: colors.mutedForeground)),
            ),
            Expanded(
              flex: 2,
              child: Text('Company / Org', style: theme.typography.xSmall.copyWith(fontWeight: FontWeight.bold, color: colors.mutedForeground)),
            ),
            Expanded(
              flex: 3,
              child: Text('Linked Master Party', style: theme.typography.xSmall.copyWith(fontWeight: FontWeight.bold, color: colors.mutedForeground)),
            ),
            Expanded(
              flex: 2,
              child: Text('Station / Hub', style: theme.typography.xSmall.copyWith(fontWeight: FontWeight.bold, color: colors.mutedForeground)),
            ),
            Expanded(
              flex: 2,
              child: Text('Sync Status', style: theme.typography.xSmall.copyWith(fontWeight: FontWeight.bold, color: colors.mutedForeground)),
            ),
            SizedBox(
              width: 100,
              child: Text('Actions', style: theme.typography.xSmall.copyWith(fontWeight: FontWeight.bold, color: colors.mutedForeground), textAlign: TextAlign.right),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTableRow(
    BuildContext context,
    GoogleContact contact,
    bool isSelected,
    bool isChecked,
    shad.ThemeData theme,
    shad.ColorScheme colors,
  ) {
    return GestureDetector(
      onTap: () {
        setState(() => _selectedContact = contact);
      },
      child: shad.OutlinedContainer(
        borderColor: isSelected ? colors.primary : colors.border,
        child: Container(
          color: isSelected ? colors.primary.withAlpha(12) : colors.card,
          padding: EdgeInsets.symmetric(
            horizontal: theme.density.baseContainerPadding * theme.scaling * 1.2,
            vertical: theme.density.baseContainerPadding * theme.scaling * 0.8,
          ),
          child: Row(
            children: [
              SizedBox(
                width: 32,
                child: shad.Checkbox(
                  state: isChecked ? shad.CheckboxState.checked : shad.CheckboxState.unchecked,
                  onChanged: (val) {
                    setState(() {
                      if (val == shad.CheckboxState.checked) {
                        _selectedContactIds.add(contact.id);
                      } else {
                        _selectedContactIds.remove(contact.id);
                      }
                    });
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 3,
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 14,
                      backgroundColor: colors.primary.withAlpha(25),
                      backgroundImage: contact.photoUrl != null ? NetworkImage(contact.photoUrl!) : null,
                      child: contact.photoUrl == null
                          ? Text(
                              contact.displayName.isNotEmpty ? contact.displayName[0].toUpperCase() : 'C',
                              style: TextStyle(color: colors.primary, fontWeight: FontWeight.bold, fontSize: 11),
                            )
                          : null,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(contact.displayName, style: theme.typography.textSmall.copyWith(fontWeight: FontWeight.bold), overflow: TextOverflow.ellipsis),
                          if (contact.jobTitle != null)
                            Text(contact.jobTitle!, style: theme.typography.xSmall.copyWith(color: colors.mutedForeground), overflow: TextOverflow.ellipsis),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                flex: 2,
                child: Text(contact.primaryPhone, style: theme.typography.mono.copyWith(fontSize: 12), overflow: TextOverflow.ellipsis),
              ),
              Expanded(
                flex: 2,
                child: Text(contact.companyName ?? '—', style: theme.typography.xSmall, overflow: TextOverflow.ellipsis),
              ),
              Expanded(
                flex: 3,
                child: contact.isLinked
                    ? Row(
                        children: [
                          Flexible(
                            child: Text(
                              contact.masterName ?? contact.masterCode ?? '',
                              style: theme.typography.textSmall.copyWith(fontWeight: FontWeight.bold, color: colors.primary),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Focus(
                            canRequestFocus: false,
                            skipTraversal: true,
                            descendantsAreFocusable: false,
                            child: shad.SecondaryBadge(
                              child: Text(contact.masterCode ?? ''),
                            ),
                          ),
                        ],
                      )
                    : Text('Unlinked', style: theme.typography.xSmall.copyWith(color: colors.mutedForeground)),
              ),
              Expanded(
                flex: 2,
                child: Text(contact.masterStation ?? '—', style: theme.typography.xSmall, overflow: TextOverflow.ellipsis),
              ),
              Expanded(
                flex: 2,
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Focus(
                    canRequestFocus: false,
                    skipTraversal: true,
                    descendantsAreFocusable: false,
                    child: contact.isLinked
                        ? shad.PrimaryBadge(child: Text(contact.syncStatus.toUpperCase()))
                        : shad.SecondaryBadge(child: Text(contact.syncStatus.toUpperCase())),
                  ),
                ),
              ),
              SizedBox(
                width: 100,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    if (contact.isLinked) ...[
                      shad.GhostButton(
                        onPressed: () => _handleUnlink(contact.id),
                        child: const Icon(shad.LucideIcons.unlink, size: 14),
                      ),
                    ] else ...[
                      shad.OutlineButton(
                        onPressed: () => _showPickerForContact(context, contact),
                        child: const Icon(shad.LucideIcons.link, size: 14),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRightPanel(shad.ThemeData theme, shad.ColorScheme colors) {
    if (_selectedContact == null) {
      return Center(
        child: Text('Select a contact from the table to view master details', style: theme.typography.textSmall.copyWith(color: colors.mutedForeground)),
      );
    }

    final contact = _selectedContact!;
    final linkedPeers = _contacts.where((c) => c.masterCode != null && c.masterCode == contact.masterCode).toList();

    return SingleChildScrollView(
      padding: EdgeInsets.all(theme.density.baseContainerPadding * theme.scaling * 1.5),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Selected Contact Detail', style: theme.typography.h4),
          SizedBox(height: theme.density.baseContainerPadding * theme.scaling),
          shad.OutlinedContainer(
            child: Padding(
              padding: EdgeInsets.all(theme.density.baseContainerPadding * theme.scaling * 1.2),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(contact.displayName, style: theme.typography.h3),
                  if (contact.jobTitle != null) Text(contact.jobTitle!, style: theme.typography.textSmall.copyWith(color: colors.mutedForeground)),
                  const SizedBox(height: 12),
                  _detailRow('Primary Phone', contact.primaryPhone, theme, colors),
                  _detailRow('Emails', contact.emails.isNotEmpty ? contact.emails.join(', ') : 'N/A', theme, colors),
                  _detailRow('Company Name', contact.companyName ?? 'N/A', theme, colors),
                  _detailRow('Google Resource', contact.googleResourceName, theme, colors),
                  _detailRow('Sync Status', contact.syncStatus.toUpperCase(), theme, colors),
                  _detailRow('Raw Data Captured', contact.rawData != null ? 'YES (100% JSON)' : 'YES (Uncompressed)', theme, colors),
                ],
              ),
            ),
          ),
          SizedBox(height: theme.density.baseContainerPadding * theme.scaling * 2),
          Text('Parent Master Organization (sq_MASTER)', style: theme.typography.h4),
          SizedBox(height: theme.density.baseContainerPadding * theme.scaling),
          if (contact.isLinked) ...[
            shad.Card(
              child: Padding(
                padding: EdgeInsets.all(theme.density.baseContainerPadding * theme.scaling * 1.2),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(contact.masterName ?? 'Linked Master', style: theme.typography.h3.copyWith(color: colors.primary)),
                        const Spacer(),
                        Focus(
                          canRequestFocus: false,
                          skipTraversal: true,
                          descendantsAreFocusable: false,
                          child: shad.SecondaryBadge(
                            child: Text(contact.masterCode ?? ''),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    _detailRow('Station Hub', contact.masterStation ?? 'SURAT', theme, colors),
                    _detailRow('City', contact.masterCity ?? 'SURAT', theme, colors),
                    _detailRow('Broker (Adatiya)', contact.masterAdatiya ?? 'SELF', theme, colors),
                    _detailRow('Credit Terms', '${contact.masterCrdays ?? 30} Days', theme, colors),
                  ],
                ),
              ),
            ),
            SizedBox(height: theme.density.baseContainerPadding * theme.scaling * 2),
            Text('Associated People for this Master Party (${linkedPeers.length})', style: theme.typography.h4),
            SizedBox(height: theme.density.baseContainerPadding * theme.scaling),
            Column(
              children: linkedPeers.map((peer) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: shad.OutlinedContainer(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                      child: Row(
                        children: [
                          const Icon(shad.LucideIcons.user, size: 14),
                          const SizedBox(width: 8),
                          Text(peer.displayName, style: theme.typography.textSmall.copyWith(fontWeight: FontWeight.bold)),
                          if (peer.jobTitle != null) Text(' (${peer.jobTitle})', style: theme.typography.xSmall),
                          const Spacer(),
                          Text(peer.primaryPhone, style: theme.typography.mono.copyWith(fontSize: 11)),
                        ],
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ] else ...[
            shad.OutlinedContainer(
              child: Padding(
                padding: EdgeInsets.all(theme.density.baseContainerPadding * theme.scaling * 1.5),
                child: Column(
                  children: [
                    Icon(shad.LucideIcons.unlink, size: 32, color: colors.mutedForeground),
                    const SizedBox(height: 8),
                    Text('Unlinked Google Contact', style: theme.typography.h4),
                    const SizedBox(height: 4),
                    Text('Link this contact to an ERP Party to enable WhatsApp CRM auto-resolution.', style: theme.typography.xSmall, textAlign: TextAlign.center),
                    const SizedBox(height: 12),
                    shad.PrimaryButton(
                      onPressed: () => _showPickerForContact(context, contact),
                      child: const Text('Search & Link Master Party'),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _detailRow(String label, String value, shad.ThemeData theme, shad.ColorScheme colors) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: theme.typography.xSmall.copyWith(color: colors.mutedForeground)),
          Text(value, style: theme.typography.xSmall.copyWith(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  void _showPickerForContact(BuildContext context, GoogleContact contact) {
    showDialog(
      context: context,
      builder: (context) {
        return _MasterPartyPickerModal(
          contactName: contact.displayName,
          masterOptions: _masterOptions,
          onSelect: (master) {
            Navigator.of(context).pop();
            _handleLinkToMaster(contact.id, master.code);
          },
        );
      },
    );
  }

  void _showBulkLinkDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return _MasterPartyPickerModal(
          contactName: '${_selectedContactIds.length} Selected Contacts',
          masterOptions: _masterOptions,
          onSelect: (master) {
            Navigator.of(context).pop();
            _handleBulkLink(master.code);
          },
        );
      },
    );
  }
}

class _MasterPartyPickerModal extends StatefulWidget {
  final String contactName;
  final List<MasterPartyOption> masterOptions;
  final ValueChanged<MasterPartyOption> onSelect;

  const _MasterPartyPickerModal({
    required this.contactName,
    required this.masterOptions,
    required this.onSelect,
  });

  @override
  State<_MasterPartyPickerModal> createState() => _MasterPartyPickerModalState();
}

class _MasterPartyPickerModalState extends State<_MasterPartyPickerModal> {
  String _filter = '';

  @override
  Widget build(BuildContext context) {
    final theme = shad.Theme.of(context);
    final colors = theme.colorScheme;

    final filtered = widget.masterOptions.where((m) {
      if (_filter.isEmpty) return true;
      final f = _filter.toLowerCase();
      return m.name.toLowerCase().contains(f) || m.code.toLowerCase().contains(f) || m.city.toLowerCase().contains(f);
    }).toList();

    return shad.ModalContainer(
      child: Container(
        width: 500,
        height: 500,
        padding: EdgeInsets.all(theme.density.baseContainerPadding * theme.scaling * 1.5),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Link Party for: ${widget.contactName}', style: theme.typography.h4),
            const SizedBox(height: 8),
            shad.TextField(
              placeholder: const Text('Search Master Party name or code...'),
              features: const [
                shad.InputFeature.leading(
                  Padding(
                    padding: EdgeInsets.only(left: 8, right: 6),
                    child: Icon(shad.LucideIcons.search, size: 16),
                  ),
                ),
              ],
              onChanged: (val) => setState(() => _filter = val),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: ListView.builder(
                itemCount: filtered.length,
                itemBuilder: (context, index) {
                  final item = filtered[index];
                  return ListTile(
                    title: Text(item.name, style: theme.typography.textSmall.copyWith(fontWeight: FontWeight.bold)),
                    subtitle: Text('${item.code} • ${item.city} • ${item.station}', style: theme.typography.xSmall.copyWith(color: colors.mutedForeground)),
                    trailing: const Icon(shad.LucideIcons.chevronRight, size: 14),
                    onTap: () => widget.onSelect(item),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
