import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:async';

/// ============================================================
/// PHASE 0 — Global Supabase Layer
/// ============================================================
/// 
/// Standardized Data Access Layer (DAL) for the Ambaji ERP.
/// Provides centralized:
/// 1. Singleton client management.
/// 2. Error interceptors for UI feedback.
/// 3. Standardized Pagination logic for high-volume Masters.
/// ============================================================

class SupabaseService {
  static final SupabaseService _instance = SupabaseService._internal();
  factory SupabaseService() => _instance;
  SupabaseService._internal();

  /// Shortcut to the active Supabase client
  SupabaseClient get client => Supabase.instance.client;

  /// Centralized error handling for Database operations.
  /// Converts raw PostgrestExceptions into user-friendly messages.
  String handleDbError(dynamic error) {
    if (error is PostgrestException) {
      return 'DB Error [${error.code}]: ${error.message}';
    }
    return 'Connection Error: Unable to reach Ambaji Clouds.';
  }
}

/// A standard container for paginated data responses.
/// Essential for handling the 4,900+ Parties list without memory bloat.
class PaginatedResult<T> {
  final List<T> data;
  final int totalCount;
  final int offset;
  final int limit;
  final String? error;

  PaginatedResult({
    required this.data,
    required this.totalCount,
    required this.offset,
    required this.limit,
    this.error,
  });

  bool get hasMore => offset + data.length < totalCount;
  bool get hasError => error != null;
}

/// Functional Operation Outcome
class DbResponse<T> {
  final T? data;
  final String? error;

  DbResponse({this.data, this.error});

  bool get success => error == null;
}
