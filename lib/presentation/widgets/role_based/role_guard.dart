import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_constants.dart';
import '../../../data/models/user_model.dart';
import '../../providers/providers.dart';

/// Widget that conditionally renders content based on user roles
class RoleGuard extends ConsumerWidget {
  final List<String>? requiredRoles;
  final List<String>? requiredPermissions;
  final String? minimumRole;
  final Widget child;
  final Widget? fallback;
  final bool requireAll; // If true, user must have ALL required roles/permissions

  const RoleGuard({
    super.key,
    this.requiredRoles,
    this.requiredPermissions,
    this.minimumRole,
    required this.child,
    this.fallback,
    this.requireAll = false,
  }) : assert(
         requiredRoles != null || requiredPermissions != null || minimumRole != null,
         'At least one of requiredRoles, requiredPermissions, or minimumRole must be provided',
       );

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);
    
    if (user == null) {
      return fallback ?? const SizedBox.shrink();
    }

    final hasAccess = _checkAccess(user);
    
    return hasAccess ? child : (fallback ?? const SizedBox.shrink());
  }

  bool _checkAccess(UserModel user) {
    // Check minimum role requirement
    if (minimumRole != null) {
      if (user.currentRole == null) return false;
      
      final userRoleLevel = _getRoleLevel(user.currentRole!);
      final requiredLevel = _getRoleLevel(minimumRole!);
      
      if (userRoleLevel < requiredLevel) {
        return false;
      }
    }

    // Check specific role requirements
    if (requiredRoles != null && requiredRoles!.isNotEmpty) {
      if (user.currentRole == null) return false;
      
      return requiredRoles!.contains(user.currentRole);
    }

    // Check permission requirements
    if (requiredPermissions != null && requiredPermissions!.isNotEmpty) {
      if (user.currentRole == null) return false;
      
      return _hasRolePermissions(user.currentRole!, requiredPermissions!);
    }

    return true;
  }
  
  int _getRoleLevel(String role) {
    switch (role.toLowerCase()) {
      case 'user':
        return 1;
      case 'support':
        return 2;
      case 'moderator':
        return 3;
      case 'admin':
        return 4;
      default:
        return 0;
    }
  }
  
  bool _hasRolePermissions(String role, List<String> permissions) {
    final rolePermissions = <String, List<String>>{
      'user': ['read'],
      'support': ['read', 'support'],
      'moderator': ['read', 'support', 'moderate'],
      'admin': ['read', 'support', 'moderate', 'admin'],
    };
    
    final userPermissions = rolePermissions[role.toLowerCase()] ?? [];
    
    if (requireAll) {
      return permissions.every((permission) => userPermissions.contains(permission));
    } else {
      return permissions.any((permission) => userPermissions.contains(permission));
    }
  }
}

/// Simple role guard for admin-only content
class AdminOnly extends RoleGuard {
  const AdminOnly({
    super.key,
    required super.child,
    super.fallback,
  }) : super(requiredRoles: const [AppConstants.roleAdmin]);
}

/// Simple role guard for moderator and admin content
class ModeratorOrAdmin extends RoleGuard {
  const ModeratorOrAdmin({
    super.key,
    required super.child,
    super.fallback,
  }) : super(minimumRole: AppConstants.roleModerator);
}

/// Simple role guard for support and above content
class SupportOrAbove extends RoleGuard {
  const SupportOrAbove({
    super.key,
    required super.child,
    super.fallback,
  }) : super(minimumRole: AppConstants.roleSupport);
}

/// Permission-based guard
class PermissionGuard extends RoleGuard {
  const PermissionGuard({
    super.key,
    required List<String> permissions,
    required super.child,
    super.fallback,
    super.requireAll,
  }) : super(requiredPermissions: permissions);
}

/// Widget that shows different content based on user's highest role
class RoleBasedContent extends ConsumerWidget {
  final Widget? adminContent;
  final Widget? moderatorContent;
  final Widget? supportContent;
  final Widget? userContent;
  final Widget? fallbackContent;

  const RoleBasedContent({
    super.key,
    this.adminContent,
    this.moderatorContent,
    this.supportContent,
    this.userContent,
    this.fallbackContent,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);
    
    if (user == null) {
      return fallbackContent ?? const SizedBox.shrink();
    }

    final currentRole = user.currentRole?.toLowerCase();
    
    switch (currentRole) {
      case 'admin':
        return adminContent ?? moderatorContent ?? supportContent ?? userContent ?? fallbackContent ?? const SizedBox.shrink();
      case 'moderator':
        return moderatorContent ?? supportContent ?? userContent ?? fallbackContent ?? const SizedBox.shrink();
      case 'support':
        return supportContent ?? userContent ?? fallbackContent ?? const SizedBox.shrink();
      case 'user':
        return userContent ?? fallbackContent ?? const SizedBox.shrink();
      default:
        return fallbackContent ?? const SizedBox.shrink();
    }
  }
}