import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/providers.dart';

class BiometricSetupDialog extends ConsumerStatefulWidget {
  final String email;
  final String password;
  final VoidCallback? onSetupComplete;

  const BiometricSetupDialog({
    super.key,
    required this.email,
    required this.password,
    this.onSetupComplete,
  });

  @override
  ConsumerState<BiometricSetupDialog> createState() => _BiometricSetupDialogState();
}

class _BiometricSetupDialogState extends ConsumerState<BiometricSetupDialog> {
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    final biometricCapability = ref.watch(biometricCapabilityProvider);

    return biometricCapability.when(
      data: (capability) => AlertDialog(
        title: Row(
          children: [
            Icon(
              _getBiometricIcon(capability),
              color: Theme.of(context).primaryColor,
            ),
            const SizedBox(width: 12),
            Text('Enable $capability'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Enable $capability for quick and secure access to your account.',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Icon(
                  Icons.security,
                  size: 16,
                  color: Theme.of(context).textTheme.bodySmall?.color,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Your credentials are encrypted and stored securely on your device.',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: _isLoading ? null : () => Navigator.of(context).pop(false),
            child: const Text('Skip'),
          ),
          FilledButton(
            onPressed: _isLoading ? null : _setupBiometric,
            child: _isLoading
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Text('Enable $capability'),
          ),
        ],
      ),
      loading: () => const AlertDialog(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Loading...'),
          ],
        ),
      ),
      error: (error, _) => AlertDialog(
        title: const Text('Error'),
        content: Text('Failed to load biometric capability: $error'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  IconData _getBiometricIcon(String capability) {
    if (capability.toLowerCase().contains('face')) {
      return Icons.face;
    } else if (capability.toLowerCase().contains('fingerprint')) {
      return Icons.fingerprint;
    } else {
      return Icons.security;
    }
  }

  Future<void> _setupBiometric() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final success = await ref.read(authProvider.notifier).setupBiometricAuthentication(
        widget.email,
        widget.password,
      );

      if (mounted) {
        if (success) {
          widget.onSetupComplete?.call();
          Navigator.of(context).pop(true);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Biometric authentication enabled successfully!'),
              backgroundColor: Colors.green,
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Failed to enable biometric authentication'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

}