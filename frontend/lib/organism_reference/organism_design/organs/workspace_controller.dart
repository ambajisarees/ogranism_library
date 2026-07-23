import 'package:flutter/material.dart';

/// [KineticWorkspaceController] — Orchestrates the global state of the application shell.
/// 
/// Manages sidebar collapse state, active module navigation, and global 
/// notification registry.
class KineticWorkspaceController extends ChangeNotifier {
  bool _isSidebarCollapsed = true;
  int _activeModuleIndex = 0;

  // Overlay State (Global Side-sheet / Dialogue)
  Widget? _overlayContent;
  bool _isOverlayVisible = false;
  VoidCallback? _onOverlayCloseRequest;

  bool get isSidebarCollapsed => _isSidebarCollapsed;
  int get activeModuleIndex => _activeModuleIndex;

  Widget? get overlayContent => _overlayContent;
  bool get isOverlayVisible => _isOverlayVisible;
  VoidCallback? get onOverlayCloseRequest => _onOverlayCloseRequest;


  static const Map<int, String> moduleLabels = {
    0: 'Dashboard',
    1: 'Parties',
    2: 'Items',
    3: 'Designs',
    4: 'Transports',
    5: 'Pipeline',
    6: 'Cutting',
    7: 'Job Work',
    8: 'Reports',
    9: 'Library',
  };

  String get activeModuleName => moduleLabels[_activeModuleIndex] ?? 'Module';

  void toggleSidebar() {
    _isSidebarCollapsed = !_isSidebarCollapsed;
    notifyListeners();
  }

  void setSidebarCollapsed(bool value) {
    if (_isSidebarCollapsed == value) return;
    _isSidebarCollapsed = value;
    notifyListeners();
  }

  void setModuleIndex(int index) {
    if (_activeModuleIndex == index) return;
    _activeModuleIndex = index;
    notifyListeners();
  }

  void showOverlay({required Widget content, VoidCallback? onCloseRequest}) {
    _overlayContent = content;
    _onOverlayCloseRequest = onCloseRequest;
    _isOverlayVisible = true;
    notifyListeners();
  }

  void hideOverlay() {
    _isOverlayVisible = false;
    // We don't nullify content immediately to allow for exit animations
    notifyListeners();
  }
}

/// [KineticWorkspaceProvider] — Native state injector for the workspace.
class KineticWorkspaceProvider extends InheritedWidget {
  final KineticWorkspaceController controller;

  const KineticWorkspaceProvider({
    super.key,
    required this.controller,
    required super.child,
  });

  static KineticWorkspaceController? maybeOf(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<KineticWorkspaceProvider>()?.controller;
  }

  static KineticWorkspaceController of(BuildContext context) {
    final controller = maybeOf(context);
    if (controller == null) {
      throw FlutterError('KineticWorkspaceProvider not found in context tree');
    }
    return controller;
  }

  @override
  bool updateShouldNotify(KineticWorkspaceProvider oldWidget) => controller != oldWidget.controller;
}
