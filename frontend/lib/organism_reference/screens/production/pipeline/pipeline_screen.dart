import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../organism_design/index.dart';
import 'tasks/tasks_tab.dart';
import 'deals/deals_tab.dart';
import 'programs/programs_tab.dart';
import 'cutting/cutting_screen.dart';
import 'job_work/job_work_tab.dart';
import 'inward/inward_tab.dart';
import 'orders/orders_tab.dart';

/// [PipelineScreen] — The unified production pipeline workspace container.
///
/// Manages tab navigation between the Tasks, Deals, Programs, Cutting, Job Work,
/// Inward, and Orders sub-modules. Supports Alt + [1-7] shortcuts.
class PipelineScreen extends StatefulWidget {
  final int defaultTabIndex;
  
  const PipelineScreen({
    super.key,
    this.defaultTabIndex = 0,
  });

  @override
  State<PipelineScreen> createState() => _PipelineScreenState();
}

class _PipelineScreenState extends State<PipelineScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: 7,
      vsync: this,
      initialIndex: widget.defaultTabIndex,
    );
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        setState(() {});
      }
    });
  }

  @override
  void didUpdateWidget(PipelineScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.defaultTabIndex != widget.defaultTabIndex) {
      _tabController.animateTo(widget.defaultTabIndex);
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CallbackShortcuts(
      bindings: {
        const SingleActivator(LogicalKeyboardKey.digit1, alt: true): () => _tabController.animateTo(0),
        const SingleActivator(LogicalKeyboardKey.digit2, alt: true): () => _tabController.animateTo(1),
        const SingleActivator(LogicalKeyboardKey.digit3, alt: true): () => _tabController.animateTo(2),
        const SingleActivator(LogicalKeyboardKey.digit4, alt: true): () => _tabController.animateTo(3),
        const SingleActivator(LogicalKeyboardKey.digit5, alt: true): () => _tabController.animateTo(4),
        const SingleActivator(LogicalKeyboardKey.digit6, alt: true): () => _tabController.animateTo(5),
        const SingleActivator(LogicalKeyboardKey.digit7, alt: true): () => _tabController.animateTo(6),
      },
      child: Focus(
        autofocus: true,
        debugLabel: 'PipelineScreenFocus',
        child: Column(
          children: [
            TissueTabChrome(
              items: [
                CellTabItem(
                  icon: LucideIcons.checkSquare,
                  title: 'Tasks',
                  kbdShortcut: 'Alt+1',
                  isSelected: _tabController.index == 0,
                  onTap: () => _tabController.animateTo(0),
                ),
                CellTabItem(
                  icon: LucideIcons.handshake,
                  title: 'Deals',
                  kbdShortcut: 'Alt+2',
                  isSelected: _tabController.index == 1,
                  onTap: () => _tabController.animateTo(1),
                ),
                CellTabItem(
                  icon: LucideIcons.calendar,
                  title: 'Programs',
                  kbdShortcut: 'Alt+3',
                  isSelected: _tabController.index == 2,
                  onTap: () => _tabController.animateTo(2),
                ),
                CellTabItem(
                  icon: LucideIcons.scissors,
                  title: 'Cuttings',
                  kbdShortcut: 'Alt+4',
                  isSelected: _tabController.index == 3,
                  onTap: () => _tabController.animateTo(3),
                ),
                CellTabItem(
                  icon: LucideIcons.truck,
                  title: 'Job Work',
                  kbdShortcut: 'Alt+5',
                  isSelected: _tabController.index == 4,
                  onTap: () => _tabController.animateTo(4),
                ),
                CellTabItem(
                  icon: LucideIcons.packageCheck,
                  title: 'Inward',
                  kbdShortcut: 'Alt+6',
                  isSelected: _tabController.index == 5,
                  onTap: () => _tabController.animateTo(5),
                ),
                CellTabItem(
                  icon: LucideIcons.shoppingCart,
                  title: 'Orders',
                  kbdShortcut: 'Alt+7',
                  isSelected: _tabController.index == 6,
                  onTap: () => _tabController.animateTo(6),
                ),
              ],
            ),
            Expanded(
              child: _buildActiveTab(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActiveTab() {
    switch (_tabController.index) {
      case 0:
        return const TasksTab(key: ValueKey('tasks_tab'));
      case 1:
        return const DealsTab(key: ValueKey('deals_tab'));
      case 2:
        return const ProgramsTab(key: ValueKey('programs_tab'));
      case 3:
        return const CuttingScreen(key: ValueKey('cutting_tab'));
      case 4:
        return const JobDispatchTab(key: ValueKey('job_work_tab'));
      case 5:
        return const InwardTab(key: ValueKey('inward_tab'));
      case 6:
        return const OrdersTab(key: ValueKey('orders_tab'));
      default:
        return const SizedBox.shrink();
    }
  }
}
