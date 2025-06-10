import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../providers/providers.dart';
import '../../widgets/common/loading_overlay.dart';
import '../../widgets/common/custom_button.dart';
import '../../../data/models/user_model.dart';
import '../../../core/errors/exceptions.dart';
import '../../../core/monitoring/error_monitoring_service.dart';

class ProfilePage extends ConsumerStatefulWidget {
  const ProfilePage({super.key});

  @override
  ConsumerState<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends ConsumerState<ProfilePage> {
  final _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  
  bool _isLoading = false;
  bool _isEditing = false;
  String? _avatarUrl;

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
    _fetchCompleteProfile();
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  void _loadUserProfile() {
    final user = ref.read(currentUserProvider);
    if (user != null) {
      // Use actual firstName and lastName from user model, fallback to email extraction if empty
      String firstName = user.firstName ?? '';
      String lastName = user.lastName ?? '';
      
      // If firstName/lastName are empty, extract from email as fallback
      if (firstName.isEmpty || lastName.isEmpty) {
        final nameParts = _extractNameFromEmail(user.email ?? '');
        firstName = firstName.isEmpty ? (nameParts['firstName'] ?? '') : firstName;
        lastName = lastName.isEmpty ? (nameParts['lastName'] ?? '') : lastName;
      }
      
      _firstNameController.text = firstName;
      _lastNameController.text = lastName;
      _emailController.text = user.email ?? '';
      _phoneController.text = user.phoneNumber ?? '';
    }
  }

  Future<void> _fetchCompleteProfile() async {
    try {
      await ref.read(authProvider.notifier).refreshUserProfile();
      // Reload the form fields with updated user data
      _loadUserProfile();
    } catch (e) {
      // Silently handle error - user will just see basic info
      print('Profile fetch failed: $e');
    }
  }

  Map<String, String> _extractNameFromEmail(String email) {
    if (email.isEmpty) return {'firstName': '', 'lastName': ''};
    
    final localPart = email.split('@').first;
    final nameParts = localPart.split(RegExp(r'[._-]'));
    
    return {
      'firstName': nameParts.isNotEmpty ? _capitalize(nameParts.first) : '',
      'lastName': nameParts.length > 1 ? _capitalize(nameParts.last) : '',
    };
  }

  String _capitalize(String text) {
    if (text.isEmpty) return text;
    return text[0].toUpperCase() + text.substring(1).toLowerCase();
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(currentUserProvider);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Profile'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        elevation: 2,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/home'),
          tooltip: 'Back to Home',
        ),
        actions: [
          if (!_isEditing)
            IconButton(
              onPressed: _toggleEditMode,
              icon: const Icon(Icons.edit),
              tooltip: 'Edit Profile',
            )
          else ...[
            IconButton(
              onPressed: _cancelEdit,
              icon: const Icon(Icons.close),
              tooltip: 'Cancel',
            ),
            IconButton(
              onPressed: _saveProfile,
              icon: const Icon(Icons.check),
              tooltip: 'Save',
            ),
          ],
        ],
      ),
      body: LoadingOverlay(
        isLoading: _isLoading,
        child: user == null
            ? _buildUserNotFound()
            : SingleChildScrollView(
                padding: const EdgeInsets.all(24.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildProfileHeader(user),
                      const SizedBox(height: 32),
                      _buildPersonalInfo(),
                      const SizedBox(height: 32),
                      _buildAccountInfo(user),
                      const SizedBox(height: 32),
                      _buildSecuritySection(),
                      if (_isEditing) ...[
                        const SizedBox(height: 32),
                        _buildActionButtons(),
                      ],
                    ],
                  ),
                ),
              ),
      ),
    );
  }

  Widget _buildProfileHeader(UserModel user) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Row(
          children: [
            CircleAvatar(
              radius: 40,
              backgroundColor: Colors.blue.withValues(alpha: 0.1),
              backgroundImage: _avatarUrl != null ? NetworkImage(_avatarUrl!) : null,
              child: _avatarUrl == null
                  ? Icon(
                      Icons.person,
                      size: 40,
                      color: Colors.blue[700],
                    )
                  : null,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    user.displayName,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    user.email ?? 'No email',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      _buildStatusChip(
                        user.isActive ? 'Active' : 'Inactive',
                        user.isActive ? Colors.green : Colors.red,
                      ),
                      const SizedBox(width: 8),
                      _buildStatusChip(
                        user.currentRoleDisplayName ?? 'User',
                        Colors.blue,
                      ),
                    ],
                  ),
                ],
              ),
            ),
            if (_isEditing)
              IconButton(
                onPressed: _changeAvatar,
                icon: const Icon(Icons.camera_alt),
                tooltip: 'Change Avatar',
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusChip(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildPersonalInfo() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Personal Information',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _firstNameController,
                    enabled: _isEditing,
                    decoration: InputDecoration(
                      labelText: 'First Name',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    validator: (value) {
                      if (_isEditing && (value == null || value.trim().isEmpty)) {
                        return 'First name is required';
                      }
                      if (_isEditing && value!.trim().length < 2) {
                        return 'First name must be at least 2 characters';
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextFormField(
                    controller: _lastNameController,
                    enabled: _isEditing,
                    decoration: InputDecoration(
                      labelText: 'Last Name',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    validator: (value) {
                      if (_isEditing && (value == null || value.trim().isEmpty)) {
                        return 'Last name is required';
                      }
                      if (_isEditing && value!.trim().length < 2) {
                        return 'Last name must be at least 2 characters';
                      }
                      return null;
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _phoneController,
              enabled: _isEditing,
              keyboardType: TextInputType.phone,
              decoration: InputDecoration(
                labelText: 'Phone Number',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              validator: (value) {
                if (_isEditing && value != null && value.isNotEmpty) {
                  if (!RegExp(r'^\+?[\d\s\-\(\)]{10,}$').hasMatch(value)) {
                    return 'Please enter a valid phone number';
                  }
                }
                return null;
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAccountInfo(UserModel user) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Account Information',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _emailController,
              enabled: false, // Email changes require special verification
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(
                labelText: 'Email Address',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                suffixIcon: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (user.isEmailVerified)
                      const Icon(Icons.verified, color: Colors.green, size: 20)
                    else
                      const Icon(Icons.warning, color: Colors.orange, size: 20),
                    const SizedBox(width: 8),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 8),
            if (!user.isEmailVerified)
              Row(
                children: [
                  const Icon(Icons.info, color: Colors.orange, size: 16),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Email not verified. ',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.orange[700],
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: _resendEmailVerification,
                    child: const Text('Verify Now'),
                  ),
                ],
              ),
            const SizedBox(height: 16),
            _buildInfoRow('Member Since', _formatDate(user.createdAt)),
            _buildInfoRow('Last Login', _formatDate(user.lastLoginAt)),
            _buildInfoRow('Account Status', user.isActive ? 'Active' : 'Inactive'),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
                color: Colors.grey[700],
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSecuritySection() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Security',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(Icons.lock, color: Colors.blue),
              title: const Text('Change Password'),
              subtitle: const Text('Update your account password'),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: _changePassword,
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.fingerprint, color: Colors.green),
              title: const Text('Biometric Authentication'),
              subtitle: const Text('Manage fingerprint and face unlock'),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: _manageBiometrics,
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.devices, color: Colors.orange),
              title: const Text('Active Sessions'),
              subtitle: const Text('Manage your logged-in devices'),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: _manageActiveSessions,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: CustomButton(
            text: 'Cancel',
            onPressed: _cancelEdit,
            backgroundColor: Colors.grey[300]!,
            textColor: Colors.black87,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: CustomButton(
            text: 'Save Changes',
            onPressed: _saveProfile,
            backgroundColor: Colors.blue,
          ),
        ),
      ],
    );
  }

  Widget _buildUserNotFound() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.person_off,
            size: 80,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'Profile Not Found',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Unable to load your profile information.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.grey[500],
            ),
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

  String _formatDate(DateTime? dateTime) {
    if (dateTime == null) return 'Unknown';
    
    final now = DateTime.now();
    final difference = now.difference(dateTime);
    
    if (difference.inDays == 0) {
      return 'Today';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else {
      return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
    }
  }

  void _toggleEditMode() {
    setState(() {
      _isEditing = true;
    });
  }

  void _cancelEdit() {
    setState(() {
      _isEditing = false;
    });
    _loadUserProfile(); // Reset form fields
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final profileData = {
        'firstName': _firstNameController.text.trim(),
        'lastName': _lastNameController.text.trim(),
        'phoneNumber': _phoneController.text.trim(),
      };

      // Update profile through auth provider
      await ref.read(authProvider.notifier).updateProfile(profileData);

      setState(() {
        _isEditing = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Profile updated successfully'),
          backgroundColor: Colors.green,
        ),
      );
    } on ValidationException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.message),
          backgroundColor: Colors.red,
        ),
      );
    } catch (e) {
      ErrorMonitoringService.instance.reportError(
        e,
        context: 'Profile update failed',
        additionalData: {'userId': ref.read(currentUserProvider)?.id.toString()},
      );
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to update profile. Please try again.'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _changeAvatar() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Change Avatar'),
        content: const Text('Avatar upload functionality coming soon.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _resendEmailVerification() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Email verification sent - Feature coming soon'),
        backgroundColor: Colors.blue,
      ),
    );
  }

  void _changePassword() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Change password feature - Coming soon'),
        backgroundColor: Colors.blue,
      ),
    );
  }

  void _manageBiometrics() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Biometric management - Coming soon'),
        backgroundColor: Colors.blue,
      ),
    );
  }

  void _manageActiveSessions() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Active sessions management - Coming soon'),
        backgroundColor: Colors.blue,
      ),
    );
  }
}