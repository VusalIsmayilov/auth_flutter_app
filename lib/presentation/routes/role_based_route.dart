import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../data/models/user_model.dart';
import '../providers/providers.dart';

/// Route configuration with role-based access control
class RoleBasedRouteData {
  final String path;
  final Widget Function(BuildContext, GoRouterState) builder;
  final List<String>? requiredRoles;
  final List<String>? requiredPermissions;
  final String? minimumRole;
  final bool requireAll;
  final Widget Function(BuildContext)? accessDeniedBuilder;

  const RoleBasedRouteData({
    required this.path,
    required this.builder,
    this.requiredRoles,
    this.requiredPermissions,
    this.minimumRole,
    this.requireAll = false,
    this.accessDeniedBuilder,
  });
}

/// Route guard that checks user permissions before allowing access
class RoleBasedRouteGuard extends ConsumerWidget {
  final Widget child;
  final List<String>? requiredRoles;
  final List<String>? requiredPermissions;
  final String? minimumRole;
  final bool requireAll;
  final Widget Function(BuildContext)? accessDeniedBuilder;

  const RoleBasedRouteGuard({
    super.key,
    required this.child,
    this.requiredRoles,
    this.requiredPermissions,
    this.minimumRole,
    this.requireAll = false,
    this.accessDeniedBuilder,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);
    
    if (user == null) {
      return _buildAccessDenied(context, 'Authentication required');
    }

    final hasAccess = _checkAccess(user);
    
    if (!hasAccess) {
      return _buildAccessDenied(context, 'Insufficient permissions');
    }

    return child;
  }

  bool _checkAccess(UserModel user) {
    // Check minimum role requirement
    if (minimumRole != null) {
      if (user.currentRole == null) {
        return false;
      }
      
      // Simple role hierarchy check
      final userRoleLevel = _getRoleLevel(user.currentRole!);
      final requiredLevel = _getRoleLevel(minimumRole!);
      
      if (userRoleLevel < requiredLevel) {
        return false;
      }
    }

    // Check specific role requirements
    if (requiredRoles != null && requiredRoles!.isNotEmpty) {
      if (user.currentRole == null) {
        return false;
      }
      
      return requiredRoles!.contains(user.currentRole);
    }

    // For permissions, we'll use role-based permissions
    if (requiredPermissions != null && requiredPermissions!.isNotEmpty) {
      if (user.currentRole == null) {
        return false;
      }
      
      // Check if user's role has required permissions
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
    // Simple permission mapping
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

  Widget _buildAccessDenied(BuildContext context, String message) {
    if (accessDeniedBuilder != null) {
      return accessDeniedBuilder!(context);
    }

    return AccessDeniedPage(message: message);
  }
}

/// Default access denied page
class AccessDeniedPage extends ConsumerWidget {
  final String message;

  const AccessDeniedPage({
    super.key,
    required this.message,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Access Denied'),
        backgroundColor: Colors.red,
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.lock,
                size: 80,
                color: Colors.red[300],
              ),
              const SizedBox(height: 24),
              Text(
                'Access Denied',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  color: Colors.red,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                message,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Colors.grey[600],
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              if (user != null) ...[
                Card(
                  color: Colors.grey[50],
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Your Current Access Level:',
                          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text('User: ${user.displayName}'),
                        Text('Email: ${user.email ?? 'No email'}'),
                        const SizedBox(height: 8),
                        Text(
                          'Role: ${user.currentRoleDisplayName ?? 'No role assigned'}',
                          style: TextStyle(
                            color: Colors.blue[700],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
              ],
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  OutlinedButton.icon(
                    onPressed: () => Navigator.of(context).canPop() 
                        ? Navigator.of(context).pop()
                        : context.go('/home'),
                    icon: const Icon(Icons.arrow_back),
                    label: const Text('Go Back'),
                  ),
                  const SizedBox(width: 16),
                  FilledButton.icon(
                    onPressed: () => context.go('/home'),
                    icon: const Icon(Icons.home),
                    label: const Text('Home'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

