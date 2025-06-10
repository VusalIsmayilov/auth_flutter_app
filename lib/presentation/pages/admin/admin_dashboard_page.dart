import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../widgets/role_based/role_guard.dart';
import '../../widgets/common/loading_overlay.dart';
import '../../providers/providers.dart';

class AdminDashboardPage extends ConsumerStatefulWidget {
  const AdminDashboardPage({super.key});

  @override
  ConsumerState<AdminDashboardPage> createState() => _AdminDashboardPageState();
}

class _AdminDashboardPageState extends ConsumerState<AdminDashboardPage> {
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(currentUserProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
        elevation: 2,
      ),
      body: LoadingOverlay(
        isLoading: _isLoading,
        child: AdminOnly(
          fallback: _buildAccessDenied(),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildWelcomeSection(user),
                const SizedBox(height: 32),
                _buildQuickStats(),
                const SizedBox(height: 32),
                _buildAdminActions(),
                const SizedBox(height: 32),
                _buildRecentActivity(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildWelcomeSection(user) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Row(
          children: [
            CircleAvatar(
              radius: 32,
              backgroundColor: Colors.indigo,
              child: Icon(
                Icons.admin_panel_settings,
                size: 32,
                color: Colors.white,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Welcome, ${user?.displayName ?? 'Administrator'}',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.indigo[800],
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Role: ${user?.currentRoleDisplayName ?? 'Administrator'}',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Last login: ${DateTime.now().toString().substring(0, 19)}',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.grey[500],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickStats() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'System Overview',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          children: [
            _buildStatCard('Total Users', '1,234', Icons.people, Colors.blue),
            _buildStatCard('Active Sessions', '89', Icons.login, Colors.green),
            _buildStatCard('Security Events', '3', Icons.security, Colors.orange),
            _buildStatCard('System Health', '99%', Icons.health_and_safety, Colors.purple),
          ],
        ),
      ],
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 32, color: color),
            const SizedBox(height: 8),
            Text(
              value,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAdminActions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Administrative Actions',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: 2,
          children: [
            _buildActionCard(
              'User Management',
              'Manage users, roles, and permissions',
              Icons.manage_accounts,
              Colors.blue,
              () => context.go('/admin/users'),
            ),
            _buildActionCard(
              'Security Settings',
              'Configure security policies',
              Icons.security,
              Colors.red,
              () => context.go('/admin/security'),
            ),
            _buildActionCard(
              'System Logs',
              'View audit trails and logs',
              Icons.list_alt,
              Colors.orange,
              () => context.go('/admin/logs'),
            ),
            _buildActionCard(
              'Reports',
              'Generate system reports',
              Icons.analytics,
              Colors.green,
              () => context.go('/admin/reports'),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActionCard(
    String title,
    String subtitle,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return Card(
      elevation: 2,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Icon(icon, size: 24, color: color),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.grey[600],
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: Colors.grey[400],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRecentActivity() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Recent Activity',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        Card(
          elevation: 2,
          child: Column(
            children: [
              _buildActivityItem(
                'User john.doe@example.com logged in',
                '2 minutes ago',
                Icons.login,
                Colors.green,
              ),
              _buildActivityItem(
                'Security policy updated',
                '15 minutes ago',
                Icons.security,
                Colors.orange,
              ),
              _buildActivityItem(
                'New user registration: jane.smith@example.com',
                '1 hour ago',
                Icons.person_add,
                Colors.blue,
              ),
              _buildActivityItem(
                'System backup completed',
                '2 hours ago',
                Icons.backup,
                Colors.purple,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildActivityItem(
    String activity,
    String timestamp,
    IconData icon,
    Color color,
  ) {
    return ListTile(
      leading: CircleAvatar(
        radius: 16,
        backgroundColor: color.withValues(alpha: 0.1),
        child: Icon(icon, size: 16, color: color),
      ),
      title: Text(
        activity,
        style: Theme.of(context).textTheme.bodyMedium,
      ),
      subtitle: Text(
        timestamp,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
          color: Colors.grey[500],
        ),
      ),
      dense: true,
    );
  }

  Widget _buildAccessDenied() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.admin_panel_settings_outlined,
            size: 80,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'Administrator Access Required',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'You need administrator privileges to access this page.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.grey[500],
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () => context.go('/home'),
            icon: const Icon(Icons.home),
            label: const Text('Go to Home'),
          ),
        ],
      ),
    );
  }
}