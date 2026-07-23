import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart' as shad;
import 'package:webview_windows/webview_windows.dart';
import 'package:flutter/services.dart';
import '../../services/service_crm_webview.dart';

/// Sample Task Item model for CRM task forwarding queue
class CrmCustomerTask {
  final String id;
  final String customerName;
  final String phone;
  final String city;
  final String designCode;
  final String status;
  final int itemQty;
  final String lastMessageTime;

  const CrmCustomerTask({
    required this.id,
    required this.customerName,
    required this.phone,
    required this.city,
    required this.designCode,
    required this.status,
    required this.itemQty,
    required this.lastMessageTime,
  });
}

/// [WhatsAppWebviewPage] — Optimized CRM Workstation Workspace.
/// Child 1 (35% Width): Customer Task Queue & Search.
/// Child 2 (65% Width): Full-height WhatsApp Web companion with zero padding & wide chat canvas.
class WhatsAppWebviewPage extends StatefulWidget {
  const WhatsAppWebviewPage({super.key});

  @override
  State<WhatsAppWebviewPage> createState() => _WhatsAppWebviewPageState();
}

class _WhatsAppWebviewPageState extends State<WhatsAppWebviewPage>
    with AutomaticKeepAliveClientMixin {
  bool _isInitializing = false;
  bool _isInitialized = false;
  String? _errorMessage;

  String _selectedTaskId = '1';
  String _searchQuery = '';

  WebviewController get _controller => CrmWebviewService.instance.controller;

  final List<CrmCustomerTask> _sampleTasks = const [
    CrmCustomerTask(
      id: '1',
      customerName: 'Shree Ambaji Textiles',
      phone: '+91 98250 12345',
      city: 'Surat',
      designCode: 'ALISHA-09',
      status: 'Pending Send',
      itemQty: 24,
      lastMessageTime: '10:42 AM',
    ),
    CrmCustomerTask(
      id: '2',
      customerName: 'Vijay Fabric Traders',
      phone: '+91 98980 67890',
      city: 'Ahmedabad',
      designCode: 'GEORGETTE-12',
      status: 'Inquiry',
      itemQty: 50,
      lastMessageTime: '11:15 AM',
    ),
    CrmCustomerTask(
      id: '3',
      customerName: 'Mahavir Saree Depot',
      phone: '+91 97240 54321',
      city: 'Mumbai',
      designCode: 'SILK-ROYAL-04',
      status: 'Quotation',
      itemQty: 100,
      lastMessageTime: 'Yesterday',
    ),
    CrmCustomerTask(
      id: '4',
      customerName: 'Kalyan Collections',
      phone: '+91 98241 11223',
      city: 'Rajkot',
      designCode: 'BANDHANI-01',
      status: 'Pending Send',
      itemQty: 12,
      lastMessageTime: 'Jul 22',
    ),
  ];

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _initWebview();
  }

  Future<void> _initWebview() async {
    if (CrmWebviewService.instance.isInitialized) {
      setState(() {
        _isInitializing = false;
        _isInitialized = true;
        _errorMessage = null;
      });
      return;
    }

    setState(() {
      _isInitializing = true;
      _errorMessage = null;
    });

    try {
      await CrmWebviewService.instance.ensureInitialized();

      if (!mounted) return;
      setState(() {
        _isInitializing = false;
        _isInitialized = CrmWebviewService.instance.isInitialized;
      });
    } on PlatformException catch (e) {
      debugPrint('[WhatsAppWebviewPage] PlatformException initializing webview: $e');
      if (!mounted) return;
      setState(() {
        _isInitializing = false;
        _isInitialized = false;
        _errorMessage = (e.message?.contains('WebView2') == true || e.code.contains('WebView2'))
            ? 'Microsoft Edge WebView2 Runtime is not installed on this system. Please install WebView2 Runtime to load WhatsApp Web.'
            : 'WebView initialization failed (${e.code}): ${e.message}';
      });
    } catch (e, stack) {
      debugPrint('[WhatsAppWebviewPage] Failed to initialize webview_windows: $e\n$stack');
      if (!mounted) return;
      setState(() {
        _isInitializing = false;
        _isInitialized = false;
        _errorMessage = 'Failed to initialize WhatsApp Webview: $e';
      });
    }
  }

  /// Pure Official WhatsApp Deep-Link Navigation with pre-filled greeting text
  Future<void> _navigateToCustomerChat(String rawPhone) async {
    final cleanPhone = rawPhone.replaceAll(RegExp(r'\D'), '');
    final greeting = Uri.encodeComponent('Namaste ji');
    try {
      await CrmWebviewService.instance
          .loadUrl('https://web.whatsapp.com/send?phone=$cleanPhone&text=$greeting');

      if (!mounted) return;
      shad.showToast(
        context: context,
        builder: (context, show) => shad.Card(
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Text('Navigating to chat +$cleanPhone...'),
          ),
        ),
      );
    } catch (e) {
      debugPrint('[WhatsAppWebviewPage] Navigation error: $e');
    }
  }

  Future<void> _reloadWebview() async {
    try {
      await CrmWebviewService.instance.reload();
      if (!mounted) return;
      setState(() {
        _isInitialized = CrmWebviewService.instance.isInitialized;
      });
    } catch (e) {
      debugPrint('[WhatsAppWebviewPage] Reload error: $e');
      _initWebview();
    }
  }

  Future<void> _confirmClearCache() async {
    const shad.DialogOverlayHandler().show(
      context: context,
      alignment: Alignment.center,
      builder: (context) {
        return SizedBox(
          width: 440,
          child: shad.AlertDialog(
            title: const Text('Clear WhatsApp Session & Cache?'),
            content: const Text(
              'This will purge all local cookies, cache, and active WhatsApp login sessions stored in %LOCALAPPDATA%\\textile_erp\\whatsapp_profile. You will need to scan the QR code again.',
            ),
            actions: [
              shad.OutlineButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Cancel'),
              ),
              shad.DestructiveButton(
                onPressed: () async {
                  Navigator.of(context).pop();
                  await _clearCacheAndReset();
                },
                child: const Text('Clear & Sign Out'),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _clearCacheAndReset() async {
    try {
      await CrmWebviewService.instance.clearCacheAndReset();
      if (!mounted) return;
      shad.showToast(
        context: context,
        builder: (context, show) => const shad.Card(
          child: Padding(
            padding: EdgeInsets.all(12.0),
            child: Text('Webview session cache cleared successfully.'),
          ),
        ),
      );
    } catch (e) {
      debugPrint('[WhatsAppWebviewPage] Clear cache error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final theme = shad.Theme.of(context);
    final colors = theme.colorScheme;

    final filteredTasks = _sampleTasks.where((t) {
      if (_searchQuery.isEmpty) return true;
      final q = _searchQuery.toLowerCase();
      return t.customerName.toLowerCase().contains(q) ||
          t.phone.contains(q) ||
          t.designCode.toLowerCase().contains(q) ||
          t.city.toLowerCase().contains(q);
    }).toList();

    return Scaffold(
      backgroundColor: colors.background,
      body: Padding(
        padding: const EdgeInsets.only(left: 8.0, right: 8.0, top: 6.0, bottom: 8.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ==========================================
            // CHILD 1: Left Task Queue Pane (35% Width)
            // ==========================================
            Expanded(
              flex: 35,
              child: shad.Card(
                padding: const EdgeInsets.all(10.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            color: colors.primary.withAlpha(30),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Center(
                            child: Icon(
                              shad.LucideIcons.users,
                              color: colors.primary,
                              size: 18,
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'CRM Task Queue',
                                style: theme.typography.h4.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: colors.foreground,
                                ),
                              ),
                              Text(
                                '${filteredTasks.length} active customer tasks',
                                style: theme.typography.xSmall.copyWith(
                                  color: colors.mutedForeground,
                                ),
                              ),
                            ],
                          ),
                        ),
                        shad.IconButton.ghost(
                          icon: const Icon(shad.LucideIcons.plus, size: 16),
                          onPressed: () {
                            shad.showToast(
                              context: context,
                              builder: (context, show) => const shad.Card(
                                child: Padding(
                                  padding: EdgeInsets.all(12.0),
                                  child: Text('Create new customer forwarding task'),
                                ),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                    const shad.DensityGap(shad.gapSm),

                    shad.TextField(
                      placeholder: const Text('Search customer, phone, design...'),
                      onChanged: (val) => setState(() => _searchQuery = val),
                      features: [
                        shad.InputFeature.leading(
                          Icon(shad.LucideIcons.search,
                              size: 16, color: colors.mutedForeground),
                        ),
                      ],
                    ),
                    const shad.DensityGap(shad.gapSm),

                    Expanded(
                      child: ListView.separated(
                        itemCount: filteredTasks.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 6),
                        itemBuilder: (context, index) {
                          final task = filteredTasks[index];
                          final isSelected = task.id == _selectedTaskId;

                          return Container(
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? colors.primary.withAlpha(20)
                                  : colors.card,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: isSelected ? colors.primary : colors.border,
                                width: isSelected ? 1.5 : 1.0,
                              ),
                            ),
                            padding: const EdgeInsets.all(8.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        task.customerName,
                                        style: theme.typography.textSmall.copyWith(
                                          fontWeight: FontWeight.bold,
                                          color: colors.foreground,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    shad.SecondaryBadge(
                                      child: Text(task.status),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 3),
                                Row(
                                  children: [
                                    Icon(shad.LucideIcons.phone,
                                        size: 12, color: colors.mutedForeground),
                                    const SizedBox(width: 4),
                                    Text(
                                      '${task.phone} • ${task.city}',
                                      style: theme.typography.xSmall.copyWith(
                                        color: colors.mutedForeground,
                                      ),
                                    ),
                                    const Spacer(),
                                    Text(
                                      task.lastMessageTime,
                                      style: theme.typography.xSmall.copyWith(
                                        fontSize: 10,
                                        color: colors.mutedForeground,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 6),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 3),
                                  decoration: BoxDecoration(
                                    color: colors.muted,
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(shad.LucideIcons.package,
                                          size: 12, color: colors.foreground),
                                      const SizedBox(width: 6),
                                      Text(
                                        'SKU: ${task.designCode} (${task.itemQty} Pcs)',
                                        style: theme.typography.xSmall.copyWith(
                                          fontWeight: FontWeight.bold,
                                          color: colors.foreground,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Row(
                                  children: [
                                    Expanded(
                                      child: shad.PrimaryButton(
                                        size: shad.ButtonSize.small,
                                        onPressed: () {
                                          setState(() => _selectedTaskId = task.id);
                                          _navigateToCustomerChat(task.phone);
                                        },
                                        child: const Row(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            Icon(shad.LucideIcons.messageSquare,
                                                size: 12),
                                            SizedBox(width: 6),
                                            Text('Open Chat'),
                                          ],
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 6),
                                    shad.OutlineButton(
                                      size: shad.ButtonSize.small,
                                      onPressed: () {
                                        shad.showToast(
                                          context: context,
                                          builder: (context, show) => shad.Card(
                                            child: Padding(
                                              padding: const EdgeInsets.all(12.0),
                                              child: Text(
                                                  'Images for ${task.designCode} staged to clipboard (Ctrl+V into WhatsApp)'),
                                            ),
                                          ),
                                        );
                                      },
                                      child: const Icon(shad.LucideIcons.copy,
                                          size: 13),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(width: 8),

            // ==========================================
            // CHILD 2: Right Webview Pane (65% Width)
            // ==========================================
            Expanded(
              flex: 65,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Compact Header Card
                  shad.Card(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12.0, vertical: 6.0),
                    child: Row(
                      children: [
                        Container(
                          width: 28,
                          height: 28,
                          decoration: BoxDecoration(
                            color: const Color(0xFF25D366).withAlpha(30),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: const Center(
                            child: Icon(
                              shad.LucideIcons.messageSquare,
                              color: Color(0xFF25D366),
                              size: 16,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Wrap(
                            crossAxisAlignment: WrapCrossAlignment.center,
                            spacing: 8,
                            runSpacing: 2,
                            children: [
                              Text(
                                'WhatsApp Web Companion',
                                style: theme.typography.textSmall.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: colors.foreground,
                                ),
                              ),
                              if (_isInitializing)
                                const shad.SecondaryBadge(
                                  child: Text('Initializing...'),
                                )
                              else if (_isInitialized)
                                const shad.PrimaryBadge(
                                  child: Text('Connected'),
                                )
                              else
                                const shad.DestructiveBadge(
                                  child: Text('Offline'),
                                ),
                            ],
                          ),
                        ),

                        shad.OutlineButton(
                          size: shad.ButtonSize.small,
                          onPressed: _isInitializing ? null : _reloadWebview,
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(shad.LucideIcons.refreshCw,
                                  size: 12, color: colors.foreground),
                              const SizedBox(width: 4),
                              const Text('Reload'),
                            ],
                          ),
                        ),

                        const SizedBox(width: 6),

                        shad.OutlineButton(
                          size: shad.ButtonSize.small,
                          onPressed:
                              _isInitializing ? null : _confirmClearCache,
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(shad.LucideIcons.trash2,
                                  size: 12, color: colors.destructive),
                              const SizedBox(width: 4),
                              Text(
                                'Clear Cache',
                                style: TextStyle(color: colors.destructive),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 6),

                  // Edge-to-Edge Webview Canvas Container (Zero Padding)
                  Expanded(
                    child: shad.Card(
                      padding: EdgeInsets.zero,
                      clipBehavior: Clip.antiAlias,
                      child: _buildWebviewCanvas(context, theme, colors),
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

  Widget _buildWebviewCanvas(
    BuildContext context,
    shad.ThemeData theme,
    shad.ColorScheme colors,
  ) {
    if (_isInitializing) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const shad.CircularProgressIndicator(),
            const shad.DensityGap(shad.gapLg),
            Text(
              'Initializing Windows WebView2 Engine...',
              style: theme.typography.p.copyWith(
                fontWeight: FontWeight.w600,
                color: colors.foreground,
              ),
            ),
            const shad.DensityGap(shad.gapSm),
            Text(
              'Loading web.whatsapp.com',
              style: theme.typography.xSmall.copyWith(
                color: colors.mutedForeground,
              ),
            ),
          ],
        ),
      );
    }

    if (_errorMessage != null) {
      return Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 520),
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                shad.LucideIcons.triangleAlert,
                size: 48,
                color: colors.destructive,
              ),
              const shad.DensityGap(shad.gapLg),
              Text(
                'WebView Initialization Error',
                style: theme.typography.h3.copyWith(
                  fontWeight: FontWeight.bold,
                  color: colors.foreground,
                ),
              ),
              const shad.DensityGap(shad.gapMd),
              shad.Alert.destructive(
                content: Text(
                  _errorMessage!,
                  style: theme.typography.textSmall,
                ),
              ),
              const shad.DensityGap(shad.gapLg),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  shad.PrimaryButton(
                    onPressed: _initWebview,
                    child: const Text('Retry Connection'),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    }

    if (!_isInitialized) {
      return Center(
        child: Text(
          'Webview not initialized.',
          style: theme.typography.textMuted,
        ),
      );
    }

    return Listener(
      behavior: HitTestBehavior.translucent,
      onPointerSignal: (signal) {
        if (signal is PointerScrollEvent && CrmWebviewService.instance.isInitialized) {
          final dy = signal.scrollDelta.dy;
          _controller.executeScript('''
            (function() {
              var x = ${signal.localPosition.dx};
              var y = ${signal.localPosition.dy};
              var el = document.elementFromPoint(x, y);
              while (el && el !== document.body && el !== document.documentElement) {
                var style = window.getComputedStyle(el);
                var overflowY = style.overflowY;
                if ((overflowY === 'auto' || overflowY === 'scroll') && el.scrollHeight > el.clientHeight) {
                  el.scrollTop += $dy;
                  break;
                }
                el = el.parentElement;
              }
            })();
          ''');
        }
      },
      child: Webview(_controller),
    );
  }
}
