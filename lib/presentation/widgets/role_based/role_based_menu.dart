import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_constants.dart';
import '../../providers/providers.dart';
import 'role_guard.dart';

class MenuItemData {
  final String title;
  final IconData icon;
  final String route;
  final List<String>? requiredRoles;
  final List<String>? requiredPermissions;
  final String? minimumRole;
  final List<MenuItemData>? children;

  const MenuItemData({
    required this.title,
    required this.icon,
    required this.route,
    this.requiredRoles,
    this.requiredPermissions,
    this.minimumRole,
    this.children,
  });
}

/// Role-based navigation drawer
class RoleBasedDrawer extends ConsumerWidget {
  final List<MenuItemData> menuItems;

  const RoleBasedDrawer({
    super.key,
    required this.menuItems,
  });

  static List<MenuItemData> getDefaultMenuItems() {
    return [
      const MenuItemData(
        title: 'Dashboard',
        icon: Icons.dashboard,
        route: '/home',
      ),
      const MenuItemData(
        title: 'Profile',
        icon: Icons.person,
        route: '/profile',
      ),
      const MenuItemData(
        title: 'User Management',
        icon: Icons.people,
        route: '/admin/users',
        requiredPermissions: [AppConstants.permissionViewUsers],
      ),
      const MenuItemData(
        title: 'Reports',
        icon: Icons.analytics,
        route: '/reports',
        requiredPermissions: [AppConstants.permissionViewReports],
      ),
      const MenuItemData(
        title: 'System Logs',
        icon: Icons.list_alt,
        route: '/admin/logs',
        requiredPermissions: [AppConstants.permissionViewLogs],
      ),
      const MenuItemData(
        title: 'Settings',
        icon: Icons.settings,
        route: '/admin/settings',
        requiredPermissions: [AppConstants.permissionManageSettings],
      ),
      const MenuItemData(
        title: 'System Management',
        icon: Icons.admin_panel_settings,
        route: '/admin/system',
        requiredPermissions: [AppConstants.permissionManageSystem],
      ),
    ];
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);
    
    return Drawer(
      child: Column(
        children: [
          // Drawer header with user info
          _buildDrawerHeader(context, user),
          
          // Menu items
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: menuItems.map((item) => _buildMenuItem(context, item)).toList(),
            ),
          ),
          
          // Logout button
          _buildLogoutSection(context, ref),
        ],
      ),
    );
  }

  Widget _buildDrawerHeader(BuildContext context, user) {
    return DrawerHeader(
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColor,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 32,
            backgroundColor: Colors.white,
            child: user?.avatar != null
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(32),
                    child: Image.network(
                      user!.avatar!,
                      width: 64,
                      height: 64,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Icon(
                        Icons.person,
                        size: 32,
                        color: Theme.of(context).primaryColor,
                      ),
                    ),
                  )
                : Icon(
                    Icons.person,
                    size: 32,
                    color: Theme.of(context).primaryColor,
                  ),
          ),
          const SizedBox(height: 12),
          if (user != null) ...[
            Text(
              user.fullName,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              user.email,
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 14,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildMenuItem(BuildContext context, MenuItemData item) {
    return RoleGuard(
      requiredRoles: item.requiredRoles,
      requiredPermissions: item.requiredPermissions,
      minimumRole: item.minimumRole,
      child: ListTile(
        leading: Icon(item.icon),
        title: Text(item.title),
        onTap: () {
          Navigator.of(context).pop(); // Close drawer
          context.go(item.route);
        },
        trailing: item.children != null ? const Icon(Icons.arrow_forward_ios, size: 16) : null,
      ),
    );
  }

  Widget _buildLogoutSection(BuildContext context, WidgetRef ref) {
    return Container(
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(
            color: Theme.of(context).dividerColor,
            width: 1,
          ),
        ),
      ),
      child: ListTile(
        leading: const Icon(Icons.logout, color: Colors.red),
        title: const Text(
          'Logout',
          style: TextStyle(color: Colors.red),
        ),
        onTap: () {
          Navigator.of(context).pop(); // Close drawer
          _showLogoutConfirmation(context, ref);
        },
      ),
    );
  }

  void _showLogoutConfirmation(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.of(context).pop();
              ref.read(authProvider.notifier).logout();
            },
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }
}

/// Role-based bottom navigation bar
class RoleBasedBottomNavigation extends ConsumerStatefulWidget {
  final List<MenuItemData> menuItems;
  final ValueChanged<int>? onIndexChanged;

  const RoleBasedBottomNavigation({
    super.key,
    required this.menuItems,
    this.onIndexChanged,
  });

  @override
  ConsumerState<RoleBasedBottomNavigation> createState() => _RoleBasedBottomNavigationState();
}

class _RoleBasedBottomNavigationState extends ConsumerState<RoleBasedBottomNavigation> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(currentUserProvider);
    
    if (user == null) return const SizedBox.shrink();

    // Filter menu items based on user roles
    final visibleItems = widget.menuItems.where((item) {
      return _hasAccess(user.currentRole, item);
    }).toList();

    if (visibleItems.isEmpty) return const SizedBox.shrink();

    return BottomNavigationBar(
      currentIndex: _currentIndex.clamp(0, visibleItems.length - 1),
      onTap: (index) {
        setState(() {
          _currentIndex = index;
        });
        widget.onIndexChanged?.call(index);
        context.go(visibleItems[index].route);
      },
      type: BottomNavigationBarType.fixed,
      items: visibleItems.map((item) => BottomNavigationBarItem(
        icon: Icon(item.icon),
        label: item.title,
      )).toList(),
    );
  }

  bool _hasAccess(String? userRole, MenuItemData item) {
    // Check minimum role requirement
    if (item.minimumRole != null) {
      if (userRole == null) return false;
      
      final userRoleLevel = _getRoleLevel(userRole);
      final requiredLevel = _getRoleLevel(item.minimumRole!);
      
      if (userRoleLevel < requiredLevel) {
        return false;
      }
    }

    // Check specific role requirements
    if (item.requiredRoles != null && item.requiredRoles!.isNotEmpty) {
      if (userRole == null) return false;
      
      if (!item.requiredRoles!.contains(userRole)) {
        return false;
      }
    }

    // Simple permission check based on role
    if (item.requiredPermissions != null && item.requiredPermissions!.isNotEmpty) {
      if (userRole == null) return false;
      
      return _hasRolePermissions(userRole, item.requiredPermissions!);
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
    return permissions.any((permission) => userPermissions.contains(permission));
  }
}

/// Floating action button that appears only for certain roles
class RoleBasedFAB extends ConsumerWidget {
  final Widget child;
  final VoidCallback? onPressed;
  final List<String>? requiredRoles;
  final List<String>? requiredPermissions;
  final String? minimumRole;

  const RoleBasedFAB({
    super.key,
    required this.child,
    this.onPressed,
    this.requiredRoles,
    this.requiredPermissions,
    this.minimumRole,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return RoleGuard(
      requiredRoles: requiredRoles,
      requiredPermissions: requiredPermissions,
      minimumRole: minimumRole,
      child: FloatingActionButton(
        onPressed: onPressed,
        child: child,
      ),
    );
  }
}