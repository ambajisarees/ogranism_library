/*
================================================================================
LLM CONTEXT & QUERY SPACE
================================================================================
1. DOMAIN & PURPOSE:
   - Centralized desktop inline toast service (`ServiceHeaderToast`) feeding the
     permanent center notification pill slot in `PageHeader` (`dy_page_header.dart`).
   - Prevents floating bottom-right overlay toasts from covering pagination
     controls or bottom summary strips while keeping status feedback in view.

2. BUSINESS LOGIC & DATA CONTRACTS:
   - Maintains a reactive `ValueNotifier<HeaderToastMessage?>` (`activeToastNotifier`)
     so any screen action (`Print`, `Export`, `Add`, `Save`, `Refresh`) can
     emit transient status updates cleanly with tone styling (`info`, `success`,
     `warning`, `error`).
   - Automatically clears previous timers when new notifications arrive (`_seq` ID).

3. DATA AUDIT / NULL RATES / GOTCHAS:
   - Zero BuildContext leaks: purely synchronous state holder with auto-dismiss
     `Timer`. Call `clear()` to dismiss early via the inline close icon.

4. OPEN QUESTIONS & CLARIFICATIONS:
   - Can optionally mirror alerts to native `shad.showToast` on `< 1024px` mobile
     viewports when Stage 4 wires the mobile TopBar wrapper.
================================================================================
*/

import 'dart:async';

import 'package:flutter/foundation.dart';

/// Semantic severity tone for inline header status pills.
enum HeaderToastTone {
  info,
  success,
  warning,
  error,
}

/// Immutable payload displayed inside the desktop center slot of `PageHeader`.
@immutable
class HeaderToastMessage {
  final int id;
  final String message;
  final HeaderToastTone tone;

  const HeaderToastMessage({
    required this.id,
    required this.message,
    this.tone = HeaderToastTone.info,
  });
}

/// Singleton inline toast controller bound to `PageHeader` on desktop screens.
class ServiceHeaderToast {
  ServiceHeaderToast._();

  static final ServiceHeaderToast instance = ServiceHeaderToast._();

  final ValueNotifier<HeaderToastMessage?> activeToastNotifier =
      ValueNotifier<HeaderToastMessage?>(null);

  Timer? _dismissTimer;
  int _seq = 0;

  /// Shows a message in the permanent center header slot for [duration].
  void show(
    String message, {
    HeaderToastTone tone = HeaderToastTone.info,
    Duration duration = const Duration(seconds: 4),
  }) {
    final trimmed = message.trim();
    if (trimmed.isEmpty) return;

    _dismissTimer?.cancel();
    _seq += 1;
    final currentId = _seq;

    activeToastNotifier.value = HeaderToastMessage(
      id: currentId,
      message: trimmed,
      tone: tone,
    );

    _dismissTimer = Timer(duration, () {
      if (activeToastNotifier.value?.id == currentId) {
        activeToastNotifier.value = null;
      }
    });
  }

  /// Dismisses the active header toast immediately.
  void clear() {
    _dismissTimer?.cancel();
    _dismissTimer = null;
    if (activeToastNotifier.value != null) {
      activeToastNotifier.value = null;
    }
  }
}
