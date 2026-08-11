/*
================================================================================
LLM CONTEXT & QUERY SPACE
================================================================================
1. DOMAIN & PURPOSE:
   - Inactivity session tracking service for the Internal Team App.
   - Enforces the 1-hour idle auto-logout requirement for security compliance.

2. BUSINESS LOGIC & DATA CONTRACTS:
   - Timeout period: 60 minutes (3600 seconds).
   - Global Listener wraps active authenticated app scaffold (InactivityWrapper).
   - Resets active timer on mouse movement, click, or keyboard input.
   - Triggers AuthService().signOut() when timer expires.

3. DATA AUDIT / NULL RATES / GOTCHAS:
   - Desktop Windows app can remain open continuously in background; timer ensures safety when user leaves workstation.

4. OPEN QUESTIONS & CLARIFICATIONS:
   - Optional toast notification shown upon automatic session timeout.
================================================================================
*/

import 'dart:async';
import 'package:flutter/material.dart';
import 'srv_auth.dart';

class InactivityTrackerService {
  static final InactivityTrackerService _instance = InactivityTrackerService._internal();
  factory InactivityTrackerService() => _instance;
  InactivityTrackerService._internal();

  Timer? _inactivityTimer;
  Duration _timeout = const Duration(hours: 1);
  VoidCallback? _onTimeoutCallback;

  bool _isTracking = false;

  void startTracking({
    Duration timeout = const Duration(hours: 1),
    VoidCallback? onTimeout,
  }) {
    _timeout = timeout;
    _onTimeoutCallback = onTimeout;
    _isTracking = true;
    resetTimer();
  }

  void stopTracking() {
    _inactivityTimer?.cancel();
    _inactivityTimer = null;
    _isTracking = false;
  }

  void resetTimer() {
    if (!_isTracking) return;
    _inactivityTimer?.cancel();
    _inactivityTimer = Timer(_timeout, _handleTimeout);
  }

  Future<void> _handleTimeout() async {
    debugPrint('[InactivityTracker] 1 Hour Inactivity Timeout Triggered! Auto Logging Out...');
    stopTracking();
    if (_onTimeoutCallback != null) {
      _onTimeoutCallback!();
    }
    await AuthService().signOut();
  }
}

class InactivityWrapper extends StatelessWidget {
  final Widget child;
  final VoidCallback? onTimeout;

  const InactivityWrapper({
    super.key,
    required this.child,
    this.onTimeout,
  });

  @override
  Widget build(BuildContext context) {
    // Ensure tracker is running when widget mounts
    InactivityTrackerService().startTracking(onTimeout: onTimeout);

    return Listener(
      behavior: HitTestBehavior.translucent,
      onPointerDown: (_) => InactivityTrackerService().resetTimer(),
      onPointerMove: (_) => InactivityTrackerService().resetTimer(),
      onPointerHover: (_) => InactivityTrackerService().resetTimer(),
      child: Focus(
        onKeyEvent: (node, event) {
          InactivityTrackerService().resetTimer();
          return KeyEventResult.ignored;
        },
        child: child,
      ),
    );
  }
}
