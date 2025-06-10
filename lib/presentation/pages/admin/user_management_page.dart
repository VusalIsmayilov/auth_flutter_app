import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../widgets/role_based/role_guard.dart';
import '../../widgets/common/loading_overlay.dart';
import '../../providers/providers.dart';

class UserManagementPage extends ConsumerStatefulWidget {
  const UserManagementPage({super.key});

  @override
  ConsumerState<UserManagementPage> createState() => _UserManagementPageState();
}

class _UserManagementPageState extends ConsumerState<UserManagementPage> {
  bool _isLoading = false;
  String _searchQuery = '';
  String _selectedFilter = 'all';

  // Mock user data - in production this would come from API
  final List<Map<String, dynamic>> _users = [
    {
      'id': 1,
      'email': 'admin@example.com',
      'displayName': 'System Administrator',
      'role': 'admin',
      'isEmailVerified': true,
      'isActive': true,
      'lastLogin': DateTime.now().subtract(const Duration(hours: 1)),
      'createdAt': DateTime.now().subtract(const Duration(days: 30)),
    },
    {
      'id': 2,
      'email': 'john.doe@example.com',
      'displayName': 'John Doe',
      'role': 'user',
      'isEmailVerified': true,
      'isActive': true,
      'lastLogin': DateTime.now().subtract(const Duration(minutes: 30)),
      'createdAt': DateTime.now().subtract(const Duration(days: 15)),
    },
    {
      'id': 3,
      'email': 'jane.smith@example.com',
      'displayName': 'Jane Smith',
      'role': 'moderator',
      'isEmailVerified': false,
      'isActive': false,
      'lastLogin': DateTime.now().subtract(const Duration(days: 5)),
      'createdAt': DateTime.now().subtract(const Duration(days: 10)),
    },
    {
      'id': 4,
      'email': 'support@example.com',
      'displayName': 'Support Team',
      'role': 'support',
      'isEmailVerified': true,
      'isActive': true,
      'lastLogin': DateTime.now().subtract(const Duration(hours: 2)),
      'createdAt': DateTime.now().subtract(const Duration(days: 7)),
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('User Management'),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
        elevation: 2,
      ),
      body: LoadingOverlay(
        isLoading: _isLoading,
        child: AdminOnly(
          fallback: _buildAccessDenied(),
          child: Column(
            children: [
              _buildSearchAndFilters(),
              Expanded(
                child: _buildUserList(),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: AdminOnly(
        child: FloatingActionButton.extended(
          onPressed: _showCreateUserDialog,
          icon: const Icon(Icons.person_add),
          label: const Text('Add User'),
          backgroundColor: Colors.indigo,
          foregroundColor: Colors.white,
        ),
      ),
    );
  }

  Widget _buildSearchAndFilters() {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        border: Border(bottom: BorderSide(color: Colors.grey[200]!)),
      ),
      child: Column(
        children: [
          TextField(
            decoration: InputDecoration(
              hintText: 'Search users by email or name...',
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              filled: true,
              fillColor: Colors.white,
            ),
            onChanged: (value) {
              setState(() {
                _searchQuery = value;
              });
            },
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              const Text(
                'Filter:',
                style: TextStyle(fontWeight: FontWeight.w500),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _buildFilterChip('All', 'all'),
                      _buildFilterChip('Active', 'active'),
                      _buildFilterChip('Inactive', 'inactive'),
                      _buildFilterChip('Admins', 'admin'),
                      _buildFilterChip('Users', 'user'),
                      _buildFilterChip('Unverified', 'unverified'),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, String value) {
    final isSelected = _selectedFilter == value;
    return Padding(
      padding: const EdgeInsets.only(right: 8.0),
      child: FilterChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (selected) {
          setState(() {
            _selectedFilter = value;
          });
        },
        selectedColor: Colors.indigo.withOpacity(0.2),
        checkmarkColor: Colors.indigo,
      ),
    );
  }

  Widget _buildUserList() {
    final filteredUsers = _getFilteredUsers();

    if (filteredUsers.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.people_outline,
              size: 80,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'No users found',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Try adjusting your search or filter criteria.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.grey[500],
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16.0),
      itemCount: filteredUsers.length,
      itemBuilder: (context, index) {
        final user = filteredUsers[index];
        return _buildUserCard(user);
      },
    );
  }

  Widget _buildUserCard(Map<String, dynamic> user) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12.0),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 24,
                  backgroundColor: _getRoleColor(user['role']),
                  child: Text(
                    user['displayName'][0].toUpperCase(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        user['displayName'],
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        user['email'],
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                _buildStatusChip(user),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                _buildInfoChip(
                  user['role'].toString().toUpperCase(),
                  _getRoleColor(user['role']),
                ),
                const SizedBox(width: 8),
                if (user['isEmailVerified'])
                  _buildInfoChip('VERIFIED', Colors.green)
                else
                  _buildInfoChip('UNVERIFIED', Colors.orange),
                const Spacer(),
                Text(
                  'Last login: ${_formatDateTime(user['lastLogin'])}',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.grey[500],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton.icon(
                  onPressed: () => _viewUserDetails(user),
                  icon: const Icon(Icons.visibility, size: 16),
                  label: const Text('View'),
                ),
                TextButton.icon(
                  onPressed: () => _editUser(user),
                  icon: const Icon(Icons.edit, size: 16),
                  label: const Text('Edit'),
                ),
                TextButton.icon(
                  onPressed: () => _toggleUserStatus(user),
                  icon: Icon(
                    user['isActive'] ? Icons.block : Icons.check_circle,
                    size: 16,
                  ),
                  label: Text(user['isActive'] ? 'Disable' : 'Enable'),
                  style: TextButton.styleFrom(
                    foregroundColor: user['isActive'] ? Colors.red : Colors.green,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusChip(Map<String, dynamic> user) {
    final isActive = user['isActive'];
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: isActive ? Colors.green.withOpacity(0.1) : Colors.red.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        isActive ? 'ACTIVE' : 'INACTIVE',
        style: TextStyle(
          color: isActive ? Colors.green[700] : Colors.red[700],
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildInfoChip(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color.shade700,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Color _getRoleColor(String role) {
    switch (role.toLowerCase()) {
      case 'admin':
        return Colors.red;
      case 'moderator':
        return Colors.orange;
      case 'support':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }

  String _formatDateTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else {
      return '${difference.inDays}d ago';
    }
  }

  List<Map<String, dynamic>> _getFilteredUsers() {
    return _users.where((user) {
      // Search filter
      if (_searchQuery.isNotEmpty) {
        final query = _searchQuery.toLowerCase();
        if (!user['email'].toLowerCase().contains(query) &&
            !user['displayName'].toLowerCase().contains(query)) {
          return false;
        }
      }

      // Status filter
      switch (_selectedFilter) {
        case 'active':
          return user['isActive'];
        case 'inactive':
          return !user['isActive'];
        case 'admin':
          return user['role'] == 'admin';
        case 'user':
          return user['role'] == 'user';
        case 'unverified':
          return !user['isEmailVerified'];
        default:
          return true;
      }
    }).toList();
  }

  void _viewUserDetails(Map<String, dynamic> user) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('User Details: ${user['displayName']}'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildDetailRow('ID', user['id'].toString()),
              _buildDetailRow('Email', user['email']),
              _buildDetailRow('Display Name', user['displayName']),
              _buildDetailRow('Role', user['role']),
              _buildDetailRow('Status', user['isActive'] ? 'Active' : 'Inactive'),
              _buildDetailRow('Email Verified', user['isEmailVerified'] ? 'Yes' : 'No'),
              _buildDetailRow('Last Login', user['lastLogin'].toString()),
              _buildDetailRow('Created At', user['createdAt'].toString()),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  void _editUser(Map<String, dynamic> user) {
    // TODO: Implement user editing functionality
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Edit user ${user['displayName']} - Feature coming soon'),
        backgroundColor: Colors.blue,
      ),
    );
  }

  void _toggleUserStatus(Map<String, dynamic> user) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(user['isActive'] ? 'Disable User' : 'Enable User'),
        content: Text(
          'Are you sure you want to ${user['isActive'] ? 'disable' : 'enable'} ${user['displayName']}?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              setState(() {
                user['isActive'] = !user['isActive'];
              });
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    'User ${user['displayName']} ${user['isActive'] ? 'enabled' : 'disabled'}',
                  ),
                  backgroundColor: user['isActive'] ? Colors.green : Colors.orange,
                ),
              );
            },
            child: Text(user['isActive'] ? 'Disable' : 'Enable'),
          ),
        ],
      ),
    );
  }

  void _showCreateUserDialog() {
    // TODO: Implement create user functionality
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Create user feature - Coming soon'),
        backgroundColor: Colors.blue,
      ),
    );
  }

  Widget _buildAccessDenied() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.manage_accounts_outlined,
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
            'You need administrator privileges to manage users.',
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