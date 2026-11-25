/*
================================================================================
LLM CONTEXT & QUERY SPACE
================================================================================
1. DOMAIN & PURPOSE:
   - Data models for authentication, user profiles (`IMMBE2627.sb_APP_PROFILES`),
     role definitions (`IMMBE2627.sb_USER_ROLES`), and unified onboarding requests
     (`IMMBE2627.sb_onboarding_requests`).
   - Serves as the domain object layer for User ID login, self-registration with
     Admin approval gating, and RBAC permission resolution (Staff now, Vendors later).

2. BUSINESS LOGIC & DATA CONTRACTS:
   - `sb_APP_PROFILES` joins 1:1 with `auth.users` via UUID primary key.
   - Roles: 0 = OWNER, 1 = ADMIN, 2 = MANAGER, 3 = STAFF.
   - `appType`: `'INTERNAL'` (team/floor users) or `'VENDOR'` (future vendor portal).
   - `approvalStatus`: `'PENDING'`, `'APPROVED'`, or `'REJECTED'`.
   - Access is granted only when `isApproved` (`approvalStatus == 'APPROVED' && isActive`).

3. DATA AUDIT / NULL RATES / GOTCHAS:
   - `mobile_no`, `email`, and `auth_email` added in migration
     `upgrade_auth_userid_and_onboarding_queue`.
   - Existing legacy profiles (`SUBHAM`, `JATIN`, `DESIGN`) default to `APPROVED`.

4. OPEN QUESTIONS & CLARIFICATIONS:
   - Future vendor onboarding uses the same `OnboardingRequestModel` with
     `requestType = 'VENDOR'` and `vendorOrgCode`.
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

  static const owner =
      UserRoleModel(id: 0, name: 'OWNER', description: 'System Owner');
  static const admin =
      UserRoleModel(id: 1, name: 'ADMIN', description: 'Administrator');
  static const manager =
      UserRoleModel(id: 2, name: 'MANAGER', description: 'Manager');
  static const staff =
      UserRoleModel(id: 3, name: 'STAFF', description: 'Staff');

  static const List<UserRoleModel> assignableRoles = [
    staff,
    manager,
    admin,
  ];
}

@immutable
class AppProfileModel {
  final String id;
  final String fullName;
  final String username;
  final String mobileNo;
  final String? email;
  final String? authEmail;
  final int roleId;
  final String roleName;
  final Map<String, dynamic> permissions;
  final bool isActive;
  final String approvalStatus;
  final String appType;
  final String? approvedBy;
  final DateTime? approvedAt;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const AppProfileModel({
    required this.id,
    required this.fullName,
    required this.username,
    this.mobileNo = '',
    this.email,
    this.authEmail,
    required this.roleId,
    this.roleName = 'STAFF',
    required this.permissions,
    required this.isActive,
    this.approvalStatus = 'APPROVED',
    required this.appType,
    this.approvedBy,
    this.approvedAt,
    this.createdAt,
    this.updatedAt,
  });

  factory AppProfileModel.fromJson(
    Map<String, dynamic> json, {
    String? roleNameOverride,
  }) {
    final int parsedRole = json['role_id'] as int? ?? 3;
    return AppProfileModel(
      id: (json['id'] as String?)?.trim() ?? '',
      fullName: (json['full_name'] as String?)?.trim() ??
          (json['username'] as String?)?.trim() ??
          'ERP User',
      username: (json['username'] as String?)?.trim() ?? '',
      mobileNo: (json['mobile_no'] as String?)?.trim() ?? '',
      email: (json['email'] as String?)?.trim(),
      authEmail: (json['auth_email'] as String?)?.trim(),
      roleId: parsedRole,
      roleName: roleNameOverride ?? _resolveRoleName(parsedRole),
      permissions: (json['permissions'] is Map)
          ? Map<String, dynamic>.from(json['permissions'] as Map)
          : <String, dynamic>{},
      isActive: json['is_active'] as bool? ?? true,
      approvalStatus:
          (json['approval_status'] as String?)?.trim().toUpperCase() ??
              'APPROVED',
      appType: (json['app_type'] as String?)?.trim().toUpperCase() ?? 'INTERNAL',
      approvedBy: (json['approved_by'] as String?)?.trim(),
      approvedAt: json['approved_at'] != null
          ? DateTime.tryParse(json['approved_at'].toString())
          : null,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'].toString())
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.tryParse(json['updated_at'].toString())
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'full_name': fullName,
      'username': username,
      'mobile_no': mobileNo,
      'email': email,
      'auth_email': authEmail,
      'role_id': roleId,
      'permissions': permissions,
      'is_active': isActive,
      'approval_status': approvalStatus,
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
  bool get isApproved => approvalStatus.toUpperCase() == 'APPROVED' && isActive;
  bool get isPendingApproval => approvalStatus.toUpperCase() == 'PENDING';
  bool get isRejected => approvalStatus.toUpperCase() == 'REJECTED';

  bool hasPermission(String moduleKey) {
    if (!isApproved) return false;
    if (isOwner || isAdmin) return true;
    final modulePerms = permissions[moduleKey];
    if (modulePerms == null) return false;
    if (modulePerms is bool) return modulePerms;
    if (modulePerms is List) return modulePerms.isNotEmpty;
    return false;
  }
}

/// [OnboardingRequestModel] — Unified access request queue row
/// (`IMMBE2627.sb_onboarding_requests`) for both Internal Staff and Vendors.
@immutable
class OnboardingRequestModel {
  final String id;
  final String userId;
  final String requestType;
  final String username;
  final String fullName;
  final String mobileNo;
  final String? email;
  final String? vendorOrgCode;
  final int requestedRoleId;
  final String status;
  final String? reviewedBy;
  final DateTime? reviewedAt;
  final String? reviewNote;
  final DateTime? createdAt;

  const OnboardingRequestModel({
    required this.id,
    required this.userId,
    required this.requestType,
    required this.username,
    required this.fullName,
    required this.mobileNo,
    this.email,
    this.vendorOrgCode,
    required this.requestedRoleId,
    required this.status,
    this.reviewedBy,
    this.reviewedAt,
    this.reviewNote,
    this.createdAt,
  });

  factory OnboardingRequestModel.fromJson(Map<String, dynamic> json) {
    return OnboardingRequestModel(
      id: (json['id'] as String?)?.trim() ?? '',
      userId: (json['user_id'] as String?)?.trim() ?? '',
      requestType:
          (json['request_type'] as String?)?.trim().toUpperCase() ??
              'INTERNAL_USER',
      username: (json['username'] as String?)?.trim() ?? '',
      fullName: (json['full_name'] as String?)?.trim() ?? '',
      mobileNo: (json['mobile_no'] as String?)?.trim() ?? '',
      email: (json['email'] as String?)?.trim(),
      vendorOrgCode: (json['vendor_org_code'] as String?)?.trim(),
      requestedRoleId: json['requested_role_id'] as int? ?? 3,
      status: (json['status'] as String?)?.trim().toUpperCase() ?? 'PENDING',
      reviewedBy: (json['reviewed_by'] as String?)?.trim(),
      reviewedAt: json['reviewed_at'] != null
          ? DateTime.tryParse(json['reviewed_at'].toString())
          : null,
      reviewNote: (json['review_note'] as String?)?.trim(),
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'].toString())
          : null,
    );
  }

  bool get isPending => status == 'PENDING';
  bool get isVendor => requestType == 'VENDOR';
}
