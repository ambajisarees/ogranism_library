import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/services.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart' as shad;
import 'package:webview_windows/webview_windows.dart';
import '../../services/service_crm_webview.dart';

/// Pipeline stage enum for CRM ticket lifecycle
enum CrmPipelineStage {
  discovery('Incoming Discovery', shad.LucideIcons.sparkles),
  intent('Intent Understanding', shad.LucideIcons.brainCircuit),
  staged('Task Staged', shad.LucideIcons.packageCheck),
  completed('Completed', shad.LucideIcons.circleCheck);

  final String label;
  final IconData icon;

  const CrmPipelineStage(this.label, this.icon);
}

/// CRM Ticket Data Model
class CrmTicket {
  final String ticketId; // e.g. AAA-00001
  final String headerCode; // e.g. AAA
  final String customerName;
  final String phone;
  final String city;
  final CrmPipelineStage stage;
  final String designCode;
  final int itemQty;
  final String cutLength;
  final int stockQty;
  final String lastMsgTime;
  final bool isIncoming;

  const CrmTicket({
    required this.ticketId,
    required this.headerCode,
    required this.customerName,
    required this.phone,
    required this.city,
    required this.stage,
    required this.designCode,
    required this.itemQty,
    required this.cutLength,
    required this.stockQty,
    required this.lastMsgTime,
    required this.isIncoming,
  });
}

/// CRM Chat Message Model
class CrmChatMessage {
  final String id;
  final String ticketId;
  final String senderName;
  final bool isFromCustomer;
  final String text;
  final String time;

  const CrmChatMessage({
    required this.id,
    required this.ticketId,
    required this.senderName,
    required this.isFromCustomer,
    required this.text,
    required this.time,
  });
}

/// [CrmWorkspacePage] — 100%-Width Native CRM Workspace with 65% WebView2 Side Sheet Drawer & Live Image Staging.
class CrmWorkspacePage extends StatefulWidget {
  const CrmWorkspacePage({super.key});

  @override
  State<CrmWorkspacePage> createState() => _CrmWorkspacePageState();
}

class _CrmWorkspacePageState extends State<CrmWorkspacePage>
    with AutomaticKeepAliveClientMixin {
  int _activeTabWorkspaceIndex = 0; // 0: Incoming, 1: Outgoing
  String _selectedTicketId = 'AAA-00001';
  String _searchQuery = '';
  bool _isNavigatingWebview = false;
  bool _isWebviewDrawerOpen = false;
  bool _isStagingImages = false;
  String? _stagedDesignCode;

  WebviewController get _controller => CrmWebviewService.instance.controller;

  final Map<String, List<String>> _sampleSareeImages = const {
    'ALISHA-09': [
      'https://images.unsplash.com/photo-1610030469983-98e550d6193c?w=600&auto=format&fit=crop',
      'https://images.unsplash.com/photo-1583391733956-3750e0ff4e8b?w=600&auto=format&fit=crop',
      'https://images.unsplash.com/photo-1617627143750-d86bc21e42bb?w=600&auto=format&fit=crop',
    ],
    'GEORGETTE-12': [
      'https://images.unsplash.com/photo-1609357605129-26f69add5d6e?w=600&auto=format&fit=crop',
      'https://images.unsplash.com/photo-1610030469983-98e550d6193c?w=600&auto=format&fit=crop',
      'https://images.unsplash.com/photo-1583391733956-3750e0ff4e8b?w=600&auto=format&fit=crop',
    ],
    'BANDHANI-01': [
      'https://images.unsplash.com/photo-1617627143750-d86bc21e42bb?w=600&auto=format&fit=crop',
      'https://images.unsplash.com/photo-1609357605129-26f69add5d6e?w=600&auto=format&fit=crop',
    ],
    'SILK-ROYAL-04': [
      'https://images.unsplash.com/photo-1583391733956-3750e0ff4e8b?w=600&auto=format&fit=crop',
      'https://images.unsplash.com/photo-1610030469983-98e550d6193c?w=600&auto=format&fit=crop',
      'https://images.unsplash.com/photo-1617627143750-d86bc21e42bb?w=600&auto=format&fit=crop',
    ],
    'KANJIVARAM-02': [
      'https://images.unsplash.com/photo-1609357605129-26f69add5d6e?w=600&auto=format&fit=crop',
      'https://images.unsplash.com/photo-1617627143750-d86bc21e42bb?w=600&auto=format&fit=crop',
    ],
  };

  final List<CrmTicket> _sampleTickets = const [
    CrmTicket(
      ticketId: 'AAA-00001',
      headerCode: 'AAA',
      customerName: 'Shree Ambaji Textiles',
      phone: '+91 98250 12345',
      city: 'Surat',
      stage: CrmPipelineStage.discovery,
      designCode: 'ALISHA-09',
      itemQty: 24,
      cutLength: '6.3m',
      stockQty: 142,
      lastMsgTime: '10:42 AM',
      isIncoming: true,
    ),
    CrmTicket(
      ticketId: 'AAX-00042',
      headerCode: 'AAX',
      customerName: 'Vijay Fabric Traders',
      phone: '+91 98980 67890',
      city: 'Ahmedabad',
      stage: CrmPipelineStage.intent,
      designCode: 'GEORGETTE-12',
      itemQty: 50,
      cutLength: '5.5m',
      stockQty: 88,
      lastMsgTime: '11:15 AM',
      isIncoming: true,
    ),
    CrmTicket(
      ticketId: 'BBA-00109',
      headerCode: 'BBA',
      customerName: 'Kalyan Collections',
      phone: '+91 98241 11223',
      city: 'Rajkot',
      stage: CrmPipelineStage.staged,
      designCode: 'BANDHANI-01',
      itemQty: 12,
      cutLength: '6.3m',
      stockQty: 30,
      lastMsgTime: '09:05 AM',
      isIncoming: true,
    ),
    CrmTicket(
      ticketId: 'MBB-00890',
      headerCode: 'MBB',
      customerName: 'Mahavir Saree Depot',
      phone: '+91 97240 54321',
      city: 'Mumbai',
      stage: CrmPipelineStage.completed,
      designCode: 'SILK-ROYAL-04',
      itemQty: 100,
      cutLength: '6.3m',
      stockQty: 210,
      lastMsgTime: 'Yesterday',
      isIncoming: false,
    ),
    CrmTicket(
      ticketId: 'SRT-00412',
      headerCode: 'SRT',
      customerName: 'Riddhi Sarees Wholesale',
      phone: '+91 98790 33445',
      city: 'Surat',
      stage: CrmPipelineStage.completed,
      designCode: 'KANJIVARAM-02',
      itemQty: 36,
      cutLength: '6.3m',
      stockQty: 95,
      lastMsgTime: 'Jul 22',
      isIncoming: false,
    ),
  ];

  final List<CrmChatMessage> _sampleMessages = const [
    CrmChatMessage(
      id: 'm1',
      ticketId: 'AAA-00001',
      senderName: 'Shree Ambaji Textiles',
      isFromCustomer: true,
      text:
          'Namaste! Need 24 pcs of design code ALISHA-09 in Georgette 6.3m cut length for Surat delivery.',
      time: '10:40 AM',
    ),
    CrmChatMessage(
      id: 'm2',
      ticketId: 'AAA-00001',
      senderName: 'System Bot (Intent)',
      isFromCustomer: false,
      text:
          'Intent parsed: Wholesale Purchase Inquiry • Design SKU: ALISHA-09 • Stock Available: 142 Pcs.',
      time: '10:41 AM',
    ),
    CrmChatMessage(
      id: 'm3',
      ticketId: 'AAX-00042',
      senderName: 'Vijay Fabric Traders',
      isFromCustomer: true,
      text: 'Please send latest price catalog for GEORGETTE-12 sarees.',
      time: '11:15 AM',
    ),
    CrmChatMessage(
      id: 'm4',
      ticketId: 'BBA-00109',
      senderName: 'Kalyan Collections',
      isFromCustomer: true,
      text: 'Order status update for Bandhani saree lot #12.',
      time: '09:05 AM',
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
    try {
      await CrmWebviewService.instance.ensureInitialized();
      if (mounted) setState(() {});
    } catch (e) {
      debugPrint('[CrmWorkspacePage] WebView initialization error: $e');
    }
  }

  /// Deep-links WhatsApp Web and opens 65% slide-out Sheet Drawer (100% Pure Meta Compliant)
  Future<void> _fulfillOrderAndOpenWebview(CrmTicket ticket) async {
    if (_isNavigatingWebview) return;
    setState(() => _isNavigatingWebview = true);

    final cleanPhone = ticket.phone.replaceAll(RegExp(r'\D'), '');
    final greeting = Uri.encodeComponent('Namaste ji');

    try {
      // Step 1: Stage native JPG files to Windows System Clipboard using super_clipboard
      final imageUrls = _sampleSareeImages[ticket.designCode] ?? [];
      final localFiles = await CrmWebviewService.instance
          .stageLocalSareeImageFiles(imageUrls, ticket.designCode);

      if (localFiles.isNotEmpty) {
        await CrmWebviewService.instance
            .writeImageFilesToWindowsClipboard(localFiles);
        setState(() => _stagedDesignCode = ticket.designCode);
      }

      // Step 2: Load official deep-link URL (text pre-filled natively by WhatsApp Web)
      await CrmWebviewService.instance
          .loadUrl('https://web.whatsapp.com/send?phone=$cleanPhone&text=$greeting');

      if (!mounted) return;
      setState(() => _isNavigatingWebview = false);

      // Step 3: Open 65% width slide-out Sheet Drawer
      _openWebviewSheetDrawer(context);
    } catch (e) {
      debugPrint('[CrmWorkspacePage] Deep link error: $e');
      if (mounted) setState(() => _isNavigatingWebview = false);
    }
  }

  /// Downloads local JPG files & stages binary image files to Windows Clipboard
  Future<void> _stageSareeImages(CrmTicket ticket) async {
    if (_isStagingImages) return;
    setState(() => _isStagingImages = true);

    final imageUrls = _sampleSareeImages[ticket.designCode] ?? [];
    try {
      final localFiles = await CrmWebviewService.instance
          .stageLocalSareeImageFiles(imageUrls, ticket.designCode);

      if (localFiles.isNotEmpty) {
        await CrmWebviewService.instance
            .writeImageFilesToWindowsClipboard(localFiles);
      } else {
        await Clipboard.setData(ClipboardData(text: imageUrls.join('\n')));
      }

      if (!mounted) return;
      setState(() {
        _isStagingImages = false;
        _stagedDesignCode = ticket.designCode;
      });

      shad.showToast(
        context: context,
        builder: (context, show) => shad.Card(
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(shad.LucideIcons.circleCheck,
                    color: Color(0xFF25D366), size: 18),
                const SizedBox(width: 8),
                Text(
                  localFiles.isNotEmpty
                      ? '${localFiles.length} Native JPG Saree Files (${ticket.designCode}) saved to local disk & staged to Windows Clipboard! Press Ctrl+V in WhatsApp Web.'
                      : 'Image Links (${ticket.designCode}) copied to Clipboard! Press Ctrl+V in WhatsApp Web.',
                ),
              ],
            ),
          ),
        ),
      );
    } catch (e) {
      debugPrint('[CrmWorkspacePage] Image staging error: $e');
      if (mounted) setState(() => _isStagingImages = false);
    }
  }

  /// Opens the 65% width slide-out Sheet Drawer embedding WebView2
  void _openWebviewSheetDrawer(BuildContext context) {
    if (_isWebviewDrawerOpen) return;
    _isWebviewDrawerOpen = true;

    shad.openSheetOverlay(
      context: context,
      position: shad.OverlayPosition.right,
      builder: (context) {
        final theme = shad.Theme.of(context);
        final colors = theme.colorScheme;
        final screenWidth = MediaQuery.of(context).size.width;
        final drawerWidth = screenWidth * 0.65; // 65% of available width

        return SizedBox(
          width: drawerWidth,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Drawer Header Bar
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
                decoration: BoxDecoration(
                  color: colors.card,
                  border: Border(bottom: BorderSide(color: colors.border)),
                ),
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
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                'WhatsApp Web Execution Engine',
                                style: theme.typography.textSmall.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: colors.foreground,
                                ),
                              ),
                              const SizedBox(width: 8),
                              const shad.PrimaryBadge(
                                child: Text('Connected'),
                              ),
                            ],
                          ),
                          Text(
                            'Human-in-the-loop send & media staging',
                            style: theme.typography.xSmall.copyWith(
                              color: colors.mutedForeground,
                            ),
                          ),
                        ],
                      ),
                    ),
                    shad.OutlineButton(
                      size: shad.ButtonSize.small,
                      onPressed: () => CrmWebviewService.instance.reload(),
                      child: const Icon(shad.LucideIcons.refreshCw, size: 14),
                    ),
                    const SizedBox(width: 8),
                    shad.IconButton.ghost(
                      icon: const Icon(shad.LucideIcons.x, size: 18),
                      onPressed: () => shad.closeSheet(context),
                    ),
                  ],
                ),
              ),

              // Embedded Webview Canvas
              Expanded(
                child: Listener(
                  behavior: HitTestBehavior.translucent,
                  onPointerSignal: (signal) {
                    if (signal is PointerScrollEvent &&
                        CrmWebviewService.instance.isInitialized) {
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
                ),
              ),
            ],
          ),
        );
      },
    );
    _isWebviewDrawerOpen = false;
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final theme = shad.Theme.of(context);
    final colors = theme.colorScheme;

    final isIncomingMode = _activeTabWorkspaceIndex == 0;
    final filteredTickets = _sampleTickets.where((t) {
      if (t.isIncoming != isIncomingMode) return false;
      if (_searchQuery.isEmpty) return true;
      final q = _searchQuery.toLowerCase();
      return t.ticketId.toLowerCase().contains(q) ||
          t.customerName.toLowerCase().contains(q) ||
          t.phone.contains(q) ||
          t.city.toLowerCase().contains(q) ||
          t.designCode.toLowerCase().contains(q);
    }).toList();

    final selectedTicket = _sampleTickets.firstWhere(
      (t) => t.ticketId == _selectedTicketId,
      orElse: () => _sampleTickets.first,
    );

    final selectedThreadMessages =
        _sampleMessages.where((m) => m.ticketId == selectedTicket.ticketId).toList();

    final currentSareeImages = _sampleSareeImages[selectedTicket.designCode] ??
        [
          'https://images.unsplash.com/photo-1610030469983-98e550d6193c?w=600&auto=format&fit=crop',
          'https://images.unsplash.com/photo-1583391733956-3750e0ff4e8b?w=600&auto=format&fit=crop',
        ];

    final isStaged = _stagedDesignCode == selectedTicket.designCode;

    return Scaffold(
      backgroundColor: colors.background,
      body: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          children: [
            // TOP HEADER CONTROL BAR
            shad.Card(
              padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 8.0),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(3),
                    decoration: BoxDecoration(
                      color: colors.muted,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _activeTabWorkspaceIndex == 0
                            ? shad.PrimaryButton(
                                size: shad.ButtonSize.small,
                                onPressed: () =>
                                    setState(() => _activeTabWorkspaceIndex = 0),
                                child: const Row(
                                  children: [
                                    Icon(shad.LucideIcons.inbox, size: 14),
                                    SizedBox(width: 6),
                                    Text('Incoming Tasks (3)'),
                                  ],
                                ),
                              )
                            : shad.OutlineButton(
                                size: shad.ButtonSize.small,
                                onPressed: () =>
                                    setState(() => _activeTabWorkspaceIndex = 0),
                                child: const Row(
                                  children: [
                                    Icon(shad.LucideIcons.inbox, size: 14),
                                    SizedBox(width: 6),
                                    Text('Incoming Tasks (3)'),
                                  ],
                                ),
                              ),
                        const SizedBox(width: 4),
                        _activeTabWorkspaceIndex == 1
                            ? shad.PrimaryButton(
                                size: shad.ButtonSize.small,
                                onPressed: () =>
                                    setState(() => _activeTabWorkspaceIndex = 1),
                                child: const Row(
                                  children: [
                                    Icon(shad.LucideIcons.send, size: 14),
                                    SizedBox(width: 6),
                                    Text('Outgoing History'),
                                  ],
                                ),
                              )
                            : shad.OutlineButton(
                                size: shad.ButtonSize.small,
                                onPressed: () =>
                                    setState(() => _activeTabWorkspaceIndex = 1),
                                child: const Row(
                                  children: [
                                    Icon(shad.LucideIcons.send, size: 14),
                                    SizedBox(width: 6),
                                    Text('Outgoing History'),
                                  ],
                                ),
                              ),
                      ],
                    ),
                  ),

                  const SizedBox(width: 14),

                  Expanded(
                    child: shad.TextField(
                      placeholder: const Text(
                          'Search by Ticket ID (AAA-00001), Customer, Phone, SKU...'),
                      onChanged: (val) => setState(() => _searchQuery = val),
                      features: [
                        shad.InputFeature.leading(
                          Icon(shad.LucideIcons.search,
                              size: 16, color: colors.mutedForeground),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(width: 14),

                  shad.OutlineButton(
                    onPressed: () => _openWebviewSheetDrawer(context),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(shad.LucideIcons.panelRightOpen, size: 15),
                        const SizedBox(width: 6),
                        const Text('WhatsApp Webview Drawer'),
                        const SizedBox(width: 8),
                        Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            color: Color(0xFF25D366),
                            shape: BoxShape.circle,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 10),

            // 100%-WIDTH NATIVE CRM WORKSPACE CANVAS
            Expanded(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // LEFT TICKET LIST (30% WIDTH)
                  Expanded(
                    flex: 30,
                    child: shad.Card(
                      padding: const EdgeInsets.all(10.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Row(
                            children: [
                              Text(
                                isIncomingMode ? 'Discovery Queue' : 'Completed Archive',
                                style: theme.typography.h4.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: colors.foreground,
                                ),
                              ),
                              const Spacer(),
                              shad.SecondaryBadge(
                                child: Text('${filteredTickets.length} Tickets'),
                              ),
                            ],
                          ),
                          const shad.DensityGap(shad.gapSm),

                          Expanded(
                            child: ListView.separated(
                              itemCount: filteredTickets.length,
                              separatorBuilder: (_, __) => const SizedBox(height: 6),
                              itemBuilder: (context, index) {
                                final ticket = filteredTickets[index];
                                final isSelected =
                                    ticket.ticketId == selectedTicket.ticketId;

                                return GestureDetector(
                                  onTap: () => setState(
                                      () => _selectedTicketId = ticket.ticketId),
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: isSelected
                                          ? colors.primary.withAlpha(20)
                                          : colors.card,
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(
                                        color: isSelected
                                            ? colors.primary
                                            : colors.border,
                                        width: isSelected ? 1.5 : 1.0,
                                      ),
                                    ),
                                    padding: const EdgeInsets.all(10.0),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Container(
                                              padding: const EdgeInsets.symmetric(
                                                  horizontal: 6, vertical: 2),
                                              decoration: BoxDecoration(
                                                color: colors.primary.withAlpha(30),
                                                borderRadius:
                                                    BorderRadius.circular(4),
                                              ),
                                              child: Text(
                                                ticket.ticketId,
                                                style: theme.typography.mono.copyWith(
                                                  fontSize: 11,
                                                  fontWeight: FontWeight.bold,
                                                  color: colors.primary,
                                                ),
                                              ),
                                            ),
                                            const SizedBox(width: 8),
                                            Expanded(
                                              child: Text(
                                                ticket.customerName,
                                                style: theme.typography.textSmall
                                                    .copyWith(
                                                  fontWeight: FontWeight.bold,
                                                  color: colors.foreground,
                                                ),
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 4),
                                        Row(
                                          children: [
                                            Icon(shad.LucideIcons.phone,
                                                size: 12,
                                                color: colors.mutedForeground),
                                            const SizedBox(width: 4),
                                            Text(
                                              '${ticket.phone} • ${ticket.city}',
                                              style: theme.typography.xSmall.copyWith(
                                                color: colors.mutedForeground,
                                              ),
                                            ),
                                            const Spacer(),
                                            Text(
                                              ticket.lastMsgTime,
                                              style: theme.typography.xSmall.copyWith(
                                                fontSize: 10,
                                                color: colors.mutedForeground,
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 6),
                                        Row(
                                          children: [
                                            Icon(ticket.stage.icon,
                                                size: 13, color: colors.foreground),
                                            const SizedBox(width: 4),
                                            Text(
                                              ticket.stage.label,
                                              style: theme.typography.xSmall.copyWith(
                                                fontWeight: FontWeight.bold,
                                                color: colors.foreground,
                                              ),
                                            ),
                                            const Spacer(),
                                            shad.SecondaryBadge(
                                              child: Text(ticket.designCode),
                                            ),
                                          ],
                                        ),
                                      ],
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

                  const SizedBox(width: 10),

                  // RIGHT CHAT REPLAY & TASK COMMAND PANE (70% WIDTH)
                  Expanded(
                    flex: 70,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Selected Ticket Header Banner
                        shad.Card(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 14.0, vertical: 8.0),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: colors.primary.withAlpha(30),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  selectedTicket.ticketId,
                                  style: theme.typography.mono.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: colors.primary,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      selectedTicket.customerName,
                                      style: theme.typography.h4.copyWith(
                                        fontWeight: FontWeight.bold,
                                        color: colors.foreground,
                                      ),
                                    ),
                                    Text(
                                      '${selectedTicket.phone} • ${selectedTicket.city} • Header Line Code: [${selectedTicket.headerCode}]',
                                      style: theme.typography.xSmall.copyWith(
                                        color: colors.mutedForeground,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              shad.SecondaryBadge(
                                child: Row(
                                  children: [
                                    Icon(selectedTicket.stage.icon, size: 13),
                                    const SizedBox(width: 4),
                                    Text(selectedTicket.stage.label),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 8),

                        // Native shadcn Chat Bubbles Replay Thread
                        Expanded(
                          child: shad.Card(
                            padding: const EdgeInsets.all(12.0),
                            child: Column(
                              children: [
                                Expanded(
                                  child: selectedThreadMessages.isEmpty
                                      ? Center(
                                          child: Text(
                                            'No active messages in thread ${selectedTicket.ticketId}.',
                                            style: theme.typography.textMuted,
                                          ),
                                        )
                                      : ListView.separated(
                                          itemCount: selectedThreadMessages.length,
                                          separatorBuilder: (_, __) =>
                                              const SizedBox(height: 10),
                                          itemBuilder: (context, index) {
                                            final msg = selectedThreadMessages[index];
                                            return _buildNativeChatBubble(
                                                context, theme, colors, msg);
                                          },
                                        ),
                                ),

                                const SizedBox(height: 10),

                                // TASK ACTION COMMAND CARD WITH LIVE IMAGE GALLERY
                                Container(
                                  padding: const EdgeInsets.all(12.0),
                                  decoration: BoxDecoration(
                                    color: colors.card,
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(color: colors.border),
                                  ),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Icon(shad.LucideIcons.package,
                                              size: 16, color: colors.primary),
                                          const SizedBox(width: 8),
                                          Text(
                                            'Task Staging Command: SKU ${selectedTicket.designCode}',
                                            style: theme.typography.textSmall.copyWith(
                                              fontWeight: FontWeight.bold,
                                              color: colors.foreground,
                                            ),
                                          ),
                                          const Spacer(),
                                          if (isStaged)
                                            const shad.PrimaryBadge(
                                              child: Row(
                                                children: [
                                                  Icon(shad.LucideIcons.circleCheck,
                                                      size: 12),
                                                  SizedBox(width: 4),
                                                  Text('Images Staged'),
                                                ],
                                              ),
                                            )
                                          else
                                            Text(
                                              'In Stock: ${selectedTicket.stockQty} Pcs',
                                              style: theme.typography.xSmall.copyWith(
                                                fontWeight: FontWeight.bold,
                                                color: colors.primary,
                                              ),
                                            ),
                                        ],
                                      ),
                                      const SizedBox(height: 6),
                                      Text(
                                        'Order Details: ${selectedTicket.itemQty} Pcs • ${selectedTicket.cutLength} Cut Length • City: ${selectedTicket.city}',
                                        style: theme.typography.xSmall.copyWith(
                                          color: colors.mutedForeground,
                                        ),
                                      ),
                                      const SizedBox(height: 8),

                                      // LIVE OPEN-SOURCE SAREE IMAGE PREVIEW GALLERY
                                      SizedBox(
                                        height: 64,
                                        child: Row(
                                          children: currentSareeImages
                                              .asMap()
                                              .entries
                                              .map((entry) {
                                            final imgIndex = entry.key + 1;
                                            final imgUrl = entry.value;

                                            return Padding(
                                              padding:
                                                  const EdgeInsets.only(right: 8.0),
                                              child: Container(
                                                width: 64,
                                                height: 64,
                                                decoration: BoxDecoration(
                                                  borderRadius:
                                                      BorderRadius.circular(6),
                                                  border: Border.all(
                                                      color: colors.border),
                                                ),
                                                child: ClipRRect(
                                                  borderRadius:
                                                      BorderRadius.circular(5),
                                                  child: Stack(
                                                    fit: StackFit.expand,
                                                    children: [
                                                      Image.network(
                                                        imgUrl,
                                                        fit: BoxFit.cover,
                                                        errorBuilder:
                                                            (_, __, ___) =>
                                                                Container(
                                                          color: colors.muted,
                                                          child: const Icon(
                                                              shad.LucideIcons
                                                                  .image,
                                                              size: 20),
                                                        ),
                                                      ),
                                                      Positioned(
                                                        bottom: 2,
                                                        right: 2,
                                                        child: Container(
                                                          padding: const EdgeInsets
                                                              .symmetric(
                                                              horizontal: 4,
                                                              vertical: 1),
                                                          decoration: BoxDecoration(
                                                            color: Colors.black
                                                                .withAlpha(160),
                                                            borderRadius:
                                                                BorderRadius.circular(
                                                                    3),
                                                          ),
                                                          child: Text(
                                                            '#$imgIndex',
                                                            style: const TextStyle(
                                                              fontSize: 9,
                                                              color: Colors.white,
                                                              fontWeight:
                                                                  FontWeight.bold,
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            );
                                          }).toList(),
                                        ),
                                      ),

                                      const SizedBox(height: 10),

                                      Row(
                                        children: [
                                          Expanded(
                                            child: shad.PrimaryButton(
                                              onPressed: _isNavigatingWebview
                                                  ? null
                                                  : () => _fulfillOrderAndOpenWebview(
                                                      selectedTicket),
                                              child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: [
                                                  if (_isNavigatingWebview) ...[
                                                    const SizedBox(
                                                      width: 14,
                                                      height: 14,
                                                      child:
                                                          shad.CircularProgressIndicator(
                                                        strokeWidth: 2,
                                                      ),
                                                    ),
                                                    const SizedBox(width: 8),
                                                    const Text(
                                                        'Navigating WhatsApp Web...'),
                                                  ] else ...[
                                                    const Icon(
                                                        shad.LucideIcons.externalLink,
                                                        size: 15),
                                                    const SizedBox(width: 8),
                                                    Text(
                                                        'Fulfill Order & Open Webview (65% Drawer)'),
                                                  ],
                                                ],
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          shad.OutlineButton(
                                            onPressed: _isStagingImages
                                                ? null
                                                : () => _stageSareeImages(
                                                    selectedTicket),
                                            child: Row(
                                              children: [
                                                if (_isStagingImages) ...[
                                                  const SizedBox(
                                                    width: 12,
                                                    height: 12,
                                                    child:
                                                        shad.CircularProgressIndicator(
                                                      strokeWidth: 2,
                                                    ),
                                                  ),
                                                  const SizedBox(width: 6),
                                                  const Text('Staging...'),
                                                ] else ...[
                                                  const Icon(shad.LucideIcons.copy,
                                                      size: 14),
                                                  const SizedBox(width: 6),
                                                  Text(isStaged
                                                      ? 'Re-Stage Images'
                                                      : 'Stage Images'),
                                                ],
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
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

  /// Builds native shadcn styled chat bubbles
  Widget _buildNativeChatBubble(
    BuildContext context,
    shad.ThemeData theme,
    shad.ColorScheme colors,
    CrmChatMessage msg,
  ) {
    final isCustomer = msg.isFromCustomer;

    return Align(
      alignment: isCustomer ? Alignment.centerLeft : Alignment.centerRight,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 520),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isCustomer ? colors.muted : colors.primary.withAlpha(25),
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(10),
            topRight: const Radius.circular(10),
            bottomLeft: Radius.circular(isCustomer ? 2 : 10),
            bottomRight: Radius.circular(isCustomer ? 10 : 2),
          ),
          border: Border.all(
            color: isCustomer ? colors.border : colors.primary.withAlpha(60),
          ),
        ),
        child: Column(
          crossAxisAlignment:
              isCustomer ? CrossAxisAlignment.start : CrossAxisAlignment.end,
          children: [
            Text(
              msg.senderName,
              style: theme.typography.xSmall.copyWith(
                fontWeight: FontWeight.bold,
                color: isCustomer ? colors.foreground : colors.primary,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              msg.text,
              style: theme.typography.textSmall.copyWith(
                color: colors.foreground,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              msg.time,
              style: theme.typography.xSmall.copyWith(
                fontSize: 10,
                color: colors.mutedForeground,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
