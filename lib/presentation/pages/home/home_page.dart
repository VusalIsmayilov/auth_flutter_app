import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../providers/providers.dart';
import '../../widgets/role_based/role_guard.dart';
import '../../widgets/role_based/role_badge.dart';
import '../../widgets/role_based/role_based_menu.dart';
import '../../../core/constants/app_constants.dart';

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentUser = ref.watch(currentUserProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: () => context.go('/profile'),
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => _showLogoutDialog(context, ref),
          ),
        ],
      ),
      drawer: RoleBasedDrawer(
        menuItems: RoleBasedDrawer.getDefaultMenuItems(),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Welcome message
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Welcome back!',
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    if (currentUser != null) ...[
                      Text(
                        'Hello, ${currentUser.displayName}',
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        currentUser.email ?? 'No email',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context).textTheme.bodySmall?.color,
                        ),
                      ),
                      const SizedBox(height: 12),
                      if (currentUser.currentRole != null)
                        RoleBadge(
                          role: currentUser.currentRole!,
                          size: RoleBadgeSize.medium,
                        ),
                    ],
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            
            // User info section
            Text(
              'Account Information',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            
            if (currentUser != null) ...[
              _buildInfoCard(
                context,
                'User ID',
                currentUser.id.toString(),
                Icons.fingerprint,
              ),
              const SizedBox(height: 12),
              
              _buildInfoCard(
                context,
                'Role',
                currentUser.currentRoleDisplayName ?? 'No role assigned',
                Icons.admin_panel_settings,
              ),
              const SizedBox(height: 12),
              
              _buildInfoCard(
                context,
                'Account Status',
                currentUser.isActive ? 'Active' : 'Inactive',
                currentUser.isActive ? Icons.check_circle : Icons.cancel,
                statusColor: currentUser.isActive ? Colors.green : Colors.red,
              ),
              const SizedBox(height: 12),
              
              if (currentUser.lastLoginAt != null)
                _buildInfoCard(
                  context,
                  'Last Login',
                  _formatDateTime(currentUser.lastLoginAt!),
                  Icons.access_time,
                ),
            ],
            
            const SizedBox(height: 24),
            
            // Role-based quick actions
            RoleBasedContent(
              adminContent: _buildAdminQuickActions(context),
              moderatorContent: _buildModeratorQuickActions(context),
              supportContent: _buildSupportQuickActions(context),
              userContent: _buildUserQuickActions(context),
            ),
            
            const Spacer(),
            
            // Action buttons
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => context.go('/profile'),
                    icon: const Icon(Icons.person),
                    label: const Text('View Profile'),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _showLogoutDialog(context, ref),
                    icon: const Icon(Icons.logout),
                    label: const Text('Logout'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard(
    BuildContext context,
    String label,
    String value,
    IconData icon, {
    Color? statusColor,
  }) {
    return Card(
      child: ListTile(
        leading: Icon(
          icon,
          color: statusColor ?? Theme.of(context).primaryColor,
        ),
        title: Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Theme.of(context).textTheme.bodySmall?.color,
          ),
        ),
        subtitle: Text(
          value,
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.day}/${dateTime.month}/${dateTime.year} at ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  Widget _buildAdminQuickActions(BuildContext context) {
    return _buildQuickActionsSection(
      context,
      'Administrator Actions',
      [
        _QuickAction(
          title: 'User Management',
          subtitle: 'Manage users and roles',
          icon: Icons.people,
          color: Colors.orange,
          onTap: () => context.go('/admin/users'),
        ),
        _QuickAction(
          title: 'System Settings',
          subtitle: 'Configure system',
          icon: Icons.settings,
          color: Colors.purple,
          onTap: () => context.go('/admin/settings'),
        ),
        _QuickAction(
          title: 'System Management',
          subtitle: 'Advanced admin tools',
          icon: Icons.admin_panel_settings,
          color: Colors.red,
          onTap: () => context.go('/admin/system'),
        ),
      ],
    );
  }

  Widget _buildModeratorQuickActions(BuildContext context) {
    return _buildQuickActionsSection(
      context,
      'Moderator Actions',
      [
        _QuickAction(
          title: 'User Management',
          subtitle: 'Manage users',
          icon: Icons.people,
          color: Colors.orange,
          onTap: () => context.go('/admin/users'),
        ),
        _QuickAction(
          title: 'System Logs',
          subtitle: 'View audit logs',
          icon: Icons.list_alt,
          color: Colors.green,
          onTap: () => context.go('/admin/logs'),
        ),
      ],
    );
  }

  Widget _buildSupportQuickActions(BuildContext context) {
    return _buildQuickActionsSection(
      context,
      'Support Actions',
      [
        _QuickAction(
          title: 'View Users',
          subtitle: 'View user information',
          icon: Icons.people,
          color: Colors.blue,
          onTap: () => context.go('/admin/users'),
        ),
        _QuickAction(
          title: 'Reports',
          subtitle: 'View system reports',
          icon: Icons.analytics,
          color: Colors.teal,
          onTap: () => context.go('/admin/reports'),
        ),
      ],
    );
  }

  Widget _buildUserQuickActions(BuildContext context) {
    return _buildQuickActionsSection(
      context,
      'Quick Actions',
      [
        _QuickAction(
          title: 'Profile',
          subtitle: 'View and edit profile',
          icon: Icons.person,
          color: Colors.blue,
          onTap: () => context.go('/profile'),
        ),
      ],
    );
  }

  Widget _buildQuickActionsSection(
    BuildContext context,
    String title,
    List<_QuickAction> actions,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 1.2,
          ),
          itemCount: actions.length,
          itemBuilder: (context, index) {
            final action = actions[index];
            return Card(
              elevation: 2,
              child: InkWell(
                onTap: action.onTap,
                borderRadius: BorderRadius.circular(8),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        action.icon,
                        size: 32,
                        color: action.color,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        action.title,
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        action.subtitle,
                        style: Theme.of(context).textTheme.bodySmall,
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  void _showLogoutDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Logout'),
          content: const Text('Are you sure you want to logout?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                ref.read(authProvider.notifier).logout();
              },
              child: const Text('Logout'),
            ),
          ],
        );
      },
    );
  }
}

class _QuickAction {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _QuickAction({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.onTap,
  });
}