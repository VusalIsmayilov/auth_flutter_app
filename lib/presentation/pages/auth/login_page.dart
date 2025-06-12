import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:go_router/go_router.dart';
import '../../../data/models/login_request_model.dart';
import '../../providers/providers.dart';
import '../../widgets/common/custom_button.dart';
import '../../widgets/common/custom_text_field.dart';
import '../../widgets/common/loading_overlay.dart';
import '../../widgets/auth/biometric_setup_dialog.dart';

class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  final _formKey = GlobalKey<FormBuilderState>();
  bool _obscurePassword = true;

  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(isLoadingProvider);

    ref.listen<String?>(authErrorProvider, (previous, next) {
      if (next != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    });

    ref.listen(isAuthenticatedProvider, (previous, next) async {
      if (next && previous == false) {
        // User just logged in, check if we should offer biometric setup
        final authNotifier = ref.read(authProvider.notifier);
        final shouldOffer = await authNotifier.shouldOfferBiometricSetup();
        
        if (shouldOffer && mounted) {
          final credentials = authNotifier.getLastLoginCredentials();
          if (credentials != null) {
            // Show biometric setup dialog
            await showDialog<bool>(
              context: context,
              barrierDismissible: false,
              builder: (context) => BiometricSetupDialog(
                email: credentials['email']!,
                password: credentials['password']!,
                onSetupComplete: () {
                  authNotifier.clearLastLoginCredentials();
                },
              ),
            );
            
            // Clear credentials regardless of setup result
            authNotifier.clearLastLoginCredentials();
          }
        }
        
        if (mounted) {
          context.go('/home');
        }
      }
    });

    return Scaffold(
      body: LoadingOverlay(
        isLoading: isLoading,
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Center(
              child: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Logo
                    Icon(
                      Icons.security,
                      size: 80,
                      color: Theme.of(context).primaryColor,
                    ),
                    const SizedBox(height: 32),
                    
                    // Welcome text
                    Text(
                      'Welcome Back',
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Sign in to your account',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: Theme.of(context).textTheme.bodySmall?.color,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 48),
                    
                    // Login form
                    FormBuilder(
                      key: _formKey,
                      child: Column(
                        children: [
                          CustomTextField(
                            name: 'email',
                            label: 'Email',
                            keyboardType: TextInputType.emailAddress,
                            prefixIcon: Icons.email_outlined,
                            validators: [
                              FormBuilderValidators.required(),
                              FormBuilderValidators.email(),
                            ],
                            errorText: _getFieldError('email'),
                          ),
                          const SizedBox(height: 16),
                          
                          CustomTextField(
                            name: 'password',
                            label: 'Password',
                            obscureText: _obscurePassword,
                            prefixIcon: Icons.lock_outlined,
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscurePassword ? Icons.visibility : Icons.visibility_off,
                              ),
                              onPressed: () {
                                setState(() {
                                  _obscurePassword = !_obscurePassword;
                                });
                              },
                            ),
                            validators: [
                              FormBuilderValidators.required(),
                              FormBuilderValidators.minLength(6),
                            ],
                            errorText: _getFieldError('password'),
                          ),
                          const SizedBox(height: 24),
                          
                          // Remember me checkbox
                          FormBuilderCheckbox(
                            name: 'rememberMe',
                            title: const Text('Remember me'),
                            initialValue: false,
                          ),
                          const SizedBox(height: 32),
                          
                          // Login button
                          CustomButton(
                            onPressed: _handleLogin,
                            text: 'Sign In',
                            isLoading: isLoading,
                          ),
                          const SizedBox(height: 16),
                          
                          // Biometric login
                          _buildBiometricLoginSection(),
                          const SizedBox(height: 16),
                          
                          // Forgot password
                          TextButton(
                            onPressed: () {
                              context.go('/forgot-password');
                            },
                            child: const Text('Forgot Password?'),
                          ),
                          const SizedBox(height: 32),
                          
                          
                          // Sign up link
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text("Don't have an account? "),
                              TextButton(
                                onPressed: () {
                                  context.go('/register');
                                },
                                child: const Text('Sign Up'),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  String? _getFieldError(String fieldName) {
    final fieldErrors = ref.watch(authFieldErrorsProvider);
    return fieldErrors?[fieldName]?.first;
  }

  Widget _buildBiometricLoginSection() {
    final biometricAvailable = ref.watch(biometricAvailableProvider);
    final hasBiometricCredentials = ref.watch(hasBiometricCredentialsProvider);
    final biometricCapability = ref.watch(biometricCapabilityProvider);
    final isLoading = ref.watch(isLoadingProvider);

    return biometricAvailable.when(
      data: (isAvailable) {
        if (!isAvailable) return const SizedBox.shrink();
        
        return hasBiometricCredentials.when(
          data: (hasCredentials) {
            if (!hasCredentials) return const SizedBox.shrink();
            
            return biometricCapability.when(
              data: (capability) => Column(
                children: [
                  const Row(
                    children: [
                      Expanded(child: Divider()),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16),
                        child: Text('OR'),
                      ),
                      Expanded(child: Divider()),
                    ],
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: OutlinedButton.icon(
                      onPressed: isLoading ? null : _handleBiometricLogin,
                      icon: Icon(_getBiometricIcon(capability)),
                      label: Text('Sign in with $capability'),
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(
                          color: Theme.of(context).primaryColor,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              loading: () => const SizedBox.shrink(),
              error: (_, __) => const SizedBox.shrink(),
            );
          },
          loading: () => const SizedBox.shrink(),
          error: (_, __) => const SizedBox.shrink(),
        );
      },
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
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

  void _handleBiometricLogin() {
    ref.read(authProvider.notifier).loginWithBiometric();
  }

  void _handleLogin() {
    if (_formKey.currentState?.saveAndValidate() ?? false) {
      final formData = _formKey.currentState!.value;
      
      final loginRequest = LoginRequestModel(
        email: formData['email'] as String,
        password: formData['password'] as String,
      );

      ref.read(authProvider.notifier).login(loginRequest);
    }
  }

}