# Ambaji Sarees ERP: Model & Service Architecture Guide

This guide defines the standardized structural patterns for writing **Models**, **Services**, and **Database Integrations** in the ERP. Always replicate these patterns when building new modules.

---

## 1. Immutable Model Pattern (`model_*.dart`)

Models must be fully immutable data classes using `final` fields. Always include a `fromJson` constructor with strict numeric safety conversions to prevent runtime type exceptions.

### Model Template
```dart
import 'package:flutter/foundation.dart';

// Helper functions for safe numeric parsing (prevent double/int crashes)
double _parseDouble(dynamic val) {
  if (val == null) return 0.0;
  if (val is num) return val.toDouble();
  if (val is String) return double.tryParse(val) ?? 0.0;
  return 0.0;
}

int _parseInt(dynamic val) {
  if (val == null) return 0;
  if (val is num) return val.toInt();
  if (val is String) return int.tryParse(val) ?? 0;
  return 0;
}

@immutable
class ExampleModel {
  final int id;
  final String code;
  final double amount;
  final DateTime? date;
  final String status;
  final String creator;

  const ExampleModel({
    required this.id,
    required this.code,
    this.amount = 0.0,
    this.date,
    this.status = 'OPEN',
    this.creator = '',
  });

  factory ExampleModel.fromJson(Map<String, dynamic> json) {
    return ExampleModel(
      id: _parseInt(json['id']),
      code: json['code'] as String? ?? 'N/A',
      amount: _parseDouble(json['amount']),
      date: json['date'] != null ? DateTime.tryParse(json['date'].toString()) : null,
      status: json['status'] as String? ?? 'OPEN',
      creator: json['CREATOR'] as String? ?? 'SYSTEM',
    );
  }
}
```

---

## 2. Singleton Service Pattern (`service_*.dart`)

Services manage database fetches and writes. They should be Singletons and utilize `SupabaseService.client` under the target schema (e.g. `IMMBE2627`). Always use `PaginatedResult` for queries returning sets of data.

### Service Template
```dart
import '../models/model_example.dart';
import 'service_supabase.dart';

class ExampleService {
  // Singleton declaration
  static final ExampleService _instance = ExampleService._internal();
  factory ExampleService() => _instance;
  ExampleService._internal();

  final _db = SupabaseService();
  static const String _schema = 'IMMBE2627';

  /// Paginated list fetching
  Future<PaginatedResult<ExampleModel>> getExamples({
    int offset = 0,
    int limit = 50,
    String? searchQuery,
  }) async {
    try {
      var query = _db.client
          .schema(_schema)
          .from('sb_examples')
          .select('*', const GetSizeOptions(count: CountOption.exact));

      // Filtering
      if (searchQuery != null && searchQuery.isNotEmpty) {
        query = query.ilike('code', '%$searchQuery%');
      }

      // Execute range query
      final response = await query
          .order('date', ascending: false)
          .range(offset, offset + limit - 1);

      final List<dynamic> dataList = response.data as List<dynamic>;
      final list = dataList.map((json) => ExampleModel.fromJson(json)).toList();

      return PaginatedResult(
        data: list,
        totalCount: response.count ?? 0,
        offset: offset,
        limit: limit,
      );
    } catch (e) {
      print('Error in getExamples: $e');
      return PaginatedResult(
        data: [],
        totalCount: 0,
        offset: offset,
        limit: limit,
        error: e.toString(),
      );
    }
  }

  /// Single write transaction (Delegated to Edge Functions)
  Future<Map<String, dynamic>?> saveExampleBatch(Map<String, dynamic> payload) async {
    try {
      final response = await _db.client.functions.invoke(
        'create-example-batch',
        body: payload,
      );

      if (response.status != 200) {
        throw Exception(response.data['error'] ?? 'Batch action failed.');
      }

      return Map<String, dynamic>.from(response.data as Map);
    } catch (e) {
      print('Error in saveExampleBatch: $e');
      rethrow;
    }
  }
}
```

---

## 3. Database Join & Filtering Rules (RPC / SQL Functions)

Avoid pulling multiple tables client-side and filtering/joining in-memory (e.g. comparing list exclusions). PostgREST capped limits will silently truncate lists larger than 1,000 items, causing data leakage.

### The Standard Pattern:
For complex multi-table checks (e.g. "Select all items in A that are NOT in B"), write a Postgres SQL function (RPC) and call it directly from the service layer:

#### 1. SQL RPC Definition
```sql
CREATE OR REPLACE FUNCTION "IMMBE2627".get_available_items(
  p_filter_codes text[],
  p_group_id bigint
)
RETURNS SETOF "IMMBE2627"."sq_ITEMS" AS $$
BEGIN
  RETURN QUERY
  SELECT i.*
  FROM "IMMBE2627"."sq_ITEMS" i
  WHERE i."code" = ANY(p_filter_codes)
    AND i."group_id" = p_group_id
    -- Database-level exclusion join (bypasses PostgREST limits)
    AND NOT EXISTS (
      SELECT 1 
      FROM "IMMBE2627"."sb_item_usage" u
      WHERE u.item_id = i.id
        AND u.status = 'USED'
    )
  ORDER BY i."created_at" ASC;
END;
$$ LANGUAGE plpgsql STABLE;
```

#### 2. Service Call Integration
```dart
Future<List<Map<String, dynamic>>> getAvailableItems(List<String> codes, int groupId) async {
  try {
    final response = await _db.client
        .schema('IMMBE2627')
        .rpc('get_available_items', params: {
          'p_filter_codes': codes,
          'p_group_id': groupId,
        });

    return (response as List).map((r) => Map<String, dynamic>.from(r)).toList();
  } catch (e) {
    print('Error getAvailableItems RPC: $e');
    return [];
  }
}
```
