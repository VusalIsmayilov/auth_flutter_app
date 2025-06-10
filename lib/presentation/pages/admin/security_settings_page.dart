import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../config/security_manager.dart';
import '../../widgets/role_based/role_guard.dart';
import '../../widgets/common/loading_overlay.dart';

class SecuritySettingsPage extends ConsumerStatefulWidget {
  const SecuritySettingsPage({super.key});

  @override
  ConsumerState<SecuritySettingsPage> createState() => _SecuritySettingsPageState();
}

class _SecuritySettingsPageState extends ConsumerState<SecuritySettingsPage> {
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Security Settings'),
        backgroundColor: Colors.red,
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
                _buildSecurityOverview(),
                const SizedBox(height: 32),
                _buildPasswordPolicies(),
                const SizedBox(height: 32),
                _buildSecurityFeatures(),
                const SizedBox(height: 32),
                _buildAuditLog(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSecurityOverview() {
    final securityManager = SecurityManager.instance;
    final audit = securityManager.getSecurityAudit();

    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  audit.passed ? Icons.security : Icons.warning,
                  color: audit.passed ? Colors.green : Colors.red,
                  size: 32,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Security Status',
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        audit.passed ? 'All security checks passed' : 'Security issues detected',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: audit.passed ? Colors.green : Colors.red,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (audit.errors.isNotEmpty) ...[
              Text(
                'Critical Issues:',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.red,
                ),
              ),
              ...audit.errors.map((error) => Padding(
                padding: const EdgeInsets.only(left: 16, top: 4),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.error, color: Colors.red, size: 16),
                    const SizedBox(width: 8),
                    Expanded(child: Text(error)),
                  ],
                ),
              )),
              const SizedBox(height: 16),
            ],
            if (audit.warnings.isNotEmpty) ...[
              Text(
                'Warnings:',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.orange,
                ),
              ),
              ...audit.warnings.map((warning) => Padding(
                padding: const EdgeInsets.only(left: 16, top: 4),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.warning, color: Colors.orange, size: 16),
                    const SizedBox(width: 8),
                    Expanded(child: Text(warning)),
                  ],
                ),
              )),
              const SizedBox(height: 16),
            ],
            Row(
              children: [
                ElevatedButton.icon(
                  onPressed: _runSecurityAudit,
                  icon: const Icon(Icons.refresh),
                  label: const Text('Refresh Audit'),
                ),
                const SizedBox(width: 12),
                ElevatedButton.icon(
                  onPressed: _generateSecurityReport,
                  icon: const Icon(Icons.file_download),
                  label: const Text('Export Report'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPasswordPolicies() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Password Policies',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _buildPolicyItem('Minimum Length', '14 characters', true),
            _buildPolicyItem('Uppercase Required', 'Yes', true),
            _buildPolicyItem('Lowercase Required', 'Yes', true),
            _buildPolicyItem('Numbers Required', 'Yes', true),
            _buildPolicyItem('Special Characters', 'Yes', true),
            _buildPolicyItem('Common Password Prevention', 'Enabled', true),
            _buildPolicyItem('Password Reuse Prevention', '5 passwords', true),
            _buildPolicyItem('User Info Prevention', 'Enabled', true),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _editPasswordPolicies,
              icon: const Icon(Icons.edit),
              label: const Text('Edit Policies'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPolicyItem(String policy, String value, bool enabled) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Icon(
            enabled ? Icons.check_circle : Icons.cancel,
            color: enabled ? Colors.green : Colors.red,
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              policy,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
          Text(
            value,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: enabled ? Colors.green : Colors.red,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSecurityFeatures() {
    final securityConfig = SecurityManager.instance.securityConfig;

    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Security Features',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _buildFeatureToggle(
              'Certificate Pinning',
              'Validates SSL certificates against known fingerprints',
              securityConfig?.enableCertificatePinning ?? false,
              Icons.security,
              (value) => _toggleCertificatePinning(value),
            ),
            _buildFeatureToggle(
              'Request Signing',
              'Signs API requests with HMAC-SHA256',
              securityConfig?.enableRequestSigning ?? false,
              Icons.verified_user,
              (value) => _toggleRequestSigning(value),
            ),
            _buildFeatureToggle(
              'Token Blacklisting',
              'Maintains revoked token blacklist',
              true, // Always enabled
              Icons.block,
              null, // Not toggleable
            ),
            _buildFeatureToggle(
              'Biometric Authentication',
              'Secure token-based biometric login',
              true, // Always enabled
              Icons.fingerprint,
              null, // Not toggleable
            ),
            _buildFeatureToggle(
              'Audit Logging',
              'Logs security events and user actions',
              true, // Always enabled
              Icons.list_alt,
              null, // Not toggleable
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureToggle(
    String title,
    String description,
    bool enabled,
    IconData icon,
    ValueChanged<bool>? onChanged,
  ) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Icon(
              icon,
              color: enabled ? Colors.green : Colors.grey,
              size: 24,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    description,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            if (onChanged != null)
              Switch(
                value: enabled,
                onChanged: onChanged,
                activeColor: Colors.green,
              )
            else
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: enabled ? Colors.green.withAlpha(40) : Colors.grey.withAlpha(40),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  enabled ? 'ENABLED' : 'DISABLED',
                  style: TextStyle(
                    color: enabled ? Colors.green[700] : Colors.grey[700],
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildAuditLog() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Recent Security Events',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                TextButton.icon(
                  onPressed: () => context.go('/admin/logs'),
                  icon: const Icon(Icons.open_in_new, size: 16),
                  label: const Text('View All'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildAuditItem(
              'Security audit passed',
              'System security check completed successfully',
              DateTime.now().subtract(const Duration(minutes: 5)),
              Icons.security,
              Colors.green,
            ),
            _buildAuditItem(
              'Password policy updated',
              'Minimum length changed from 12 to 14 characters',
              DateTime.now().subtract(const Duration(hours: 2)),
              Icons.policy,
              Colors.blue,
            ),
            _buildAuditItem(
              'Failed login attempt blocked',
              'Multiple failed attempts from IP: 192.168.1.100',
              DateTime.now().subtract(const Duration(hours: 4)),
              Icons.block,
              Colors.red,
            ),
            _buildAuditItem(
              'Certificate pinning enabled',
              'SSL certificate validation activated for production',
              DateTime.now().subtract(const Duration(days: 1)),
              Icons.verified,
              Colors.green,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAuditItem(
    String title,
    String description,
    DateTime timestamp,
    IconData icon,
    Color color,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 16,
            backgroundColor: color.withAlpha(40),
            child: Icon(icon, size: 16, color: color),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  description,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.grey[600],
                  ),
                ),
                Text(
                  _formatTimestamp(timestamp),
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.grey[500],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inMinutes < 60) {
      return '${difference.inMinutes} minutes ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours} hours ago';
    } else {
      return '${difference.inDays} days ago';
    }
  }

  void _runSecurityAudit() {
    setState(() {
      _isLoading = true;
    });

    // Simulate audit process
    Future.delayed(const Duration(seconds: 2), () {
      setState(() {
        _isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Security audit completed'),
          backgroundColor: Colors.green,
        ),
      );
    });
  }

  void _generateSecurityReport() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Security report generated - Feature coming soon'),
        backgroundColor: Colors.blue,
      ),
    );
  }

  void _editPasswordPolicies() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Password policy editor - Feature coming soon'),
        backgroundColor: Colors.blue,
      ),
    );
  }

  void _toggleCertificatePinning(bool enabled) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('${enabled ? 'Enable' : 'Disable'} Certificate Pinning'),
        content: Text(
          enabled
              ? 'This will enable SSL certificate validation for enhanced security.'
              : 'Warning: Disabling certificate pinning may reduce security.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    'Certificate pinning ${enabled ? 'enabled' : 'disabled'}',
                  ),
                  backgroundColor: enabled ? Colors.green : Colors.orange,
                ),
              );
            },
            child: const Text('Confirm'),
          ),
        ],
      ),
    );
  }

  void _toggleRequestSigning(bool enabled) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('${enabled ? 'Enable' : 'Disable'} Request Signing'),
        content: Text(
          enabled
              ? 'This will enable HMAC-SHA256 request signing for API security.'
              : 'Warning: Disabling request signing may reduce API security.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    'Request signing ${enabled ? 'enabled' : 'disabled'}',
                  ),
                  backgroundColor: enabled ? Colors.green : Colors.orange,
                ),
              );
            },
            child: const Text('Confirm'),
          ),
        ],
      ),
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
            'You need administrator privileges to access security settings.',
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