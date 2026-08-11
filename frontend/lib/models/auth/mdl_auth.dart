/*
================================================================================
LLM CONTEXT & QUERY SPACE
================================================================================
1. DOMAIN & PURPOSE:
   - Data models for authentication, user profiles (sb_APP_PROFILES), and role definitions (sb_USER_ROLES).
   - Serves as the domain object layer for RBAC security, user session metadata, and permission resolution.

2. BUSINESS LOGIC & DATA CONTRACTS:
   - sb_APP_PROFILES joins 1:1 with auth.users via UUID primary key.
   - Roles: 0 = OWNER, 1 = ADMIN, 2 = MANAGER, 3 = STAFF.
   - appType column defaults to 'INTERNAL' for internal ERP users.
   - permissions is a JSONB map containing module action flags (e.g. {"cuttings": ["read", "write"]}).

3. DATA AUDIT / NULL RATES / GOTCHAS:
   - full_name and username can be null for fresh OAuth sign-ups; defaults provided.
   - permissions defaults to empty JSON map ({}) when null.

4. OPEN QUESTIONS & CLARIFICATIONS:
   - Future granular permission checks will evaluate the jsonb map against active workspace route IDs.
================================================================================
*/

import 'package:flutter/foundation.dart';

@immutable
class UserRoleModel {
  final int id;
  final String name;
  final String description;

  const UserRoleModel({
    required this.id,
    required this.name,
    required this.description,
  });

  factory UserRoleModel.fromJson(Map<String, dynamic> json) {
    return UserRoleModel(
      id: json['id'] as int? ?? 3,
      name: (json['name'] as String?)?.trim() ?? 'STAFF',
      description: (json['description'] as String?)?.trim() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
    };
  }

  static const owner = UserRoleModel(id: 0, name: 'OWNER', description: 'System Owner');
  static const admin = UserRoleModel(id: 1, name: 'ADMIN', description: 'Administrator');
  static const manager = UserRoleModel(id: 2, name: 'MANAGER', description: 'Manager');
  static const staff = UserRoleModel(id: 3, name: 'STAFF', description: 'Staff');
}

@immutable
class AppProfileModel {
  final String id;
  final String fullName;
  final String username;
  final int roleId;
  final String roleName;
  final Map<String, dynamic> permissions;
  final bool isActive;
  final String appType;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const AppProfileModel({
    required this.id,
    required this.fullName,
    required this.username,
    required this.roleId,
    this.roleName = 'STAFF',
    required this.permissions,
    required this.isActive,
    required this.appType,
    this.createdAt,
    this.updatedAt,
  });

  factory AppProfileModel.fromJson(Map<String, dynamic> json, {String? roleNameOverride}) {
    return AppProfileModel(
      id: json['id'] as String? ?? '',
      fullName: (json['full_name'] as String?)?.trim() ?? (json['username'] as String?) ?? 'ERP User',
      username: (json['username'] as String?)?.trim() ?? '',
      roleId: json['role_id'] as int? ?? 3,
      roleName: roleNameOverride ?? _resolveRoleName(json['role_id'] as int? ?? 3),
      permissions: (json['permissions'] is Map)
          ? Map<String, dynamic>.from(json['permissions'] as Map)
          : <String, dynamic>{},
      isActive: json['is_active'] as bool? ?? true,
      appType: (json['app_type'] as String?)?.trim() ?? 'INTERNAL',
      createdAt: json['created_at'] != null ? DateTime.tryParse(json['created_at'].toString()) : null,
      updatedAt: json['updated_at'] != null ? DateTime.tryParse(json['updated_at'].toString()) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'full_name': fullName,
      'username': username,
      'role_id': roleId,
      'permissions': permissions,
      'is_active': isActive,
      'app_type': appType,
      'updated_at': DateTime.now().toIso8601String(),
    };
  }

  static String _resolveRoleName(int roleId) {
    switch (roleId) {
      case 0:
        return 'OWNER';
      case 1:
        return 'ADMIN';
      case 2:
        return 'MANAGER';
      case 3:
      default:
        return 'STAFF';
    }
  }

  bool get isOwner => roleId == 0;
  bool get isAdmin => roleId == 0 || roleId == 1;
  bool get isManager => roleId <= 2;
  bool get isInternal => appType.toUpperCase() == 'INTERNAL';

  bool hasPermission(String moduleKey) {
    if (isOwner || isAdmin) return true;
    final modulePerms = permissions[moduleKey];
    if (modulePerms == null) return false;
    if (modulePerms is bool) return modulePerms;
    if (modulePerms is List) return modulePerms.isNotEmpty;
    return false;
  }
}
