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

class RegisterPage extends ConsumerStatefulWidget {
  const RegisterPage({super.key});

  @override
  ConsumerState<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends ConsumerState<RegisterPage> {
  final _formKey = GlobalKey<FormBuilderState>();
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(isLoadingProvider);

    ref.listen<String?>(authErrorProvider, (previous, next) {
      if (next != null) {
        final fieldErrors = ref.read(authFieldErrorsProvider);
        String errorMessage = next;
        
        // If we have field errors, show a more helpful message
        if (fieldErrors != null && fieldErrors.isNotEmpty) {
          errorMessage = 'Please check the highlighted fields and fix the errors.';
        }
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            backgroundColor: Theme.of(context).colorScheme.error,
            duration: const Duration(seconds: 4),
          ),
        );
      }
    });

    ref.listen(isAuthenticatedProvider, (previous, next) {
      if (next) {
        context.go('/home');
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
                      Icons.person_add,
                      size: 80,
                      color: Theme.of(context).primaryColor,
                    ),
                    const SizedBox(height: 32),
                    
                    // Welcome text
                    Text(
                      'Create Account',
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Sign up to get started',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: Theme.of(context).textTheme.bodySmall?.color,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 48),
                    
                    // Registration form
                    FormBuilder(
                      key: _formKey,
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: CustomTextField(
                                  name: 'firstName',
                                  label: 'First Name',
                                  prefixIcon: Icons.person_outlined,
                                  validators: [
                                    FormBuilderValidators.required(),
                                    FormBuilderValidators.minLength(2),
                                  ],
                                  errorText: _getFieldError('firstName'),
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: CustomTextField(
                                  name: 'lastName',
                                  label: 'Last Name',
                                  prefixIcon: Icons.person_outlined,
                                  validators: [
                                    FormBuilderValidators.required(),
                                    FormBuilderValidators.minLength(2),
                                  ],
                                  errorText: _getFieldError('lastName'),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          
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
                              FormBuilderValidators.minLength(8),
                              _passwordValidator,
                            ],
                            errorText: _getFieldError('password'),
                          ),
                          const SizedBox(height: 16),
                          
                          CustomTextField(
                            name: 'confirmPassword',
                            label: 'Confirm Password',
                            obscureText: _obscureConfirmPassword,
                            prefixIcon: Icons.lock_outlined,
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscureConfirmPassword ? Icons.visibility : Icons.visibility_off,
                              ),
                              onPressed: () {
                                setState(() {
                                  _obscureConfirmPassword = !_obscureConfirmPassword;
                                });
                              },
                            ),
                            validators: [
                              FormBuilderValidators.required(),
                              (value) {
                                final password = _formKey.currentState?.fields['password']?.value;
                                if (value != password) {
                                  return 'Passwords do not match';
                                }
                                return null;
                              },
                            ],
                          ),
                          const SizedBox(height: 24),
                          
                          // Terms and conditions
                          FormBuilderCheckbox(
                            name: 'acceptTerms',
                            title: RichText(
                              text: TextSpan(
                                style: Theme.of(context).textTheme.bodyMedium,
                                children: [
                                  const TextSpan(text: 'I agree to the '),
                                  TextSpan(
                                    text: 'Terms of Service',
                                    style: TextStyle(
                                      color: Theme.of(context).primaryColor,
                                      decoration: TextDecoration.underline,
                                    ),
                                  ),
                                  const TextSpan(text: ' and '),
                                  TextSpan(
                                    text: 'Privacy Policy',
                                    style: TextStyle(
                                      color: Theme.of(context).primaryColor,
                                      decoration: TextDecoration.underline,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            validator: FormBuilderValidators.required(
                              errorText: 'You must accept the terms and conditions',
                            ),
                          ),
                          const SizedBox(height: 32),
                          
                          // Register button
                          CustomButton(
                            onPressed: _handleRegister,
                            text: 'Create Account',
                            isLoading: isLoading,
                          ),
                          const SizedBox(height: 32),
                          
                          // Sign in link
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text('Already have an account? '),
                              TextButton(
                                onPressed: () {
                                  context.go('/login');
                                },
                                child: const Text('Sign In'),
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
    if (fieldErrors == null) return null;
    
    // Try exact match first
    if (fieldErrors[fieldName] != null) {
      return fieldErrors[fieldName]!.first;
    }
    
    // Try field name with _warnings suffix
    final warningsKey = '${fieldName}_warnings';
    if (fieldErrors[warningsKey] != null) {
      return fieldErrors[warningsKey]!.first;
    }
    
    // Try capitalized field name (backend might send PascalCase)
    final capitalizedKey = fieldName[0].toUpperCase() + fieldName.substring(1);
    if (fieldErrors[capitalizedKey] != null) {
      return fieldErrors[capitalizedKey]!.first;
    }
    
    return null;
  }

  String? _passwordValidator(String? value) {
    if (value == null || value.isEmpty) return null;
    
    final hasUppercase = value.contains(RegExp(r'[A-Z]'));
    final hasLowercase = value.contains(RegExp(r'[a-z]'));
    final hasDigits = value.contains(RegExp(r'[0-9]'));
    final hasSpecialCharacters = value.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'));
    
    if (!hasUppercase) {
      return 'Password must contain at least one uppercase letter';
    }
    if (!hasLowercase) {
      return 'Password must contain at least one lowercase letter';
    }
    if (!hasDigits) {
      return 'Password must contain at least one number';
    }
    if (!hasSpecialCharacters) {
      return 'Password must contain at least one special character';
    }
    
    return null;
  }

  Future<void> _handleRegister() async {
    print('DEBUG: Register button clicked');
    if (_formKey.currentState?.saveAndValidate() ?? false) {
      final formData = _formKey.currentState!.value;
      print('DEBUG: Form validation passed. Form data: $formData');
      
      final registerRequest = RegisterRequestModel(
        email: formData['email'] as String,
        password: formData['password'] as String,
        firstName: formData['firstName'] as String?,
        lastName: formData['lastName'] as String?,
        phoneNumber: formData['phoneNumber'] as String?,
      );

      print('DEBUG: Created RegisterRequestModel: ${registerRequest.email}');
      print('DEBUG: Calling auth provider register...');
      
      try {
        await ref.read(authProvider.notifier).register(registerRequest);
        
        // Registration successful - redirect to email verification
        if (mounted) {
          context.go('/email-verification', extra: {'email': registerRequest.email});
        }
      } catch (e) {
        // Error handling is already done in the auth provider and displayed via the error provider
        print('DEBUG: Registration failed: $e');
      }
    } else {
      print('DEBUG: Form validation failed');
      final currentState = _formKey.currentState;
      if (currentState != null) {
        print('DEBUG: Form errors: ${currentState.errors}');
      }
    }
  }
}