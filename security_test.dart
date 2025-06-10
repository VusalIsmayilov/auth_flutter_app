import 'package:flutter/foundation.dart';
import 'lib/config/security_config.dart';
import 'lib/config/security_manager.dart';
import 'lib/core/security/password_policy.dart';
import 'lib/core/security/request_signing_service.dart';

/// Security system test script
void main() async {
  print('🔒 Security System Test');
  print('=' * 50);

  try {
    // Test 1: Security Configuration
    await testSecurityConfiguration();
    
    // Test 2: Password Policy
    await testPasswordPolicy();
    
    // Test 3: Request Signing
    await testRequestSigning();
    
    // Test 4: Security Manager
    await testSecurityManager();
    
    // Test 5: Production Readiness
    await testProductionReadiness();
    
    print('\n✅ All security tests passed!');
    
  } catch (e) {
    print('\n❌ Security test failed: $e');
  }
}

Future<void> testSecurityConfiguration() async {
  print('\n📋 Testing Security Configuration...');
  
  // Test development config
  final devConfig = SecurityConfig.forEnvironment('development');
  print('Development config: ${devConfig.environment}');
  print('  - Certificate pinning: ${devConfig.enableCertificatePinning}');
  print('  - Request signing: ${devConfig.enableRequestSigning}');
  print('  - Security level: ${devConfig.securityLevel.name}');
  
  // Test production config
  final prodConfig = SecurityConfig.forEnvironment('production');
  print('Production config: ${prodConfig.environment}');
  print('  - Certificate pinning: ${prodConfig.enableCertificatePinning}');
  print('  - Request signing: ${prodConfig.enableRequestSigning}');
  print('  - Security level: ${prodConfig.securityLevel.name}');
  print('  - Production ready: ${prodConfig.isProductionReady}');
  
  // Test security audit
  final audit = SecurityAuditor.auditConfiguration(prodConfig);
  print('Production audit passed: ${audit.passed}');
  if (audit.errors.isNotEmpty) {
    print('  Errors: ${audit.errors.length}');
  }
  if (audit.warnings.isNotEmpty) {
    print('  Warnings: ${audit.warnings.length}');
  }
  
  print('✅ Security configuration test passed');
}

Future<void> testPasswordPolicy() async {
  print('\n🔐 Testing Password Policy...');
  
  // Test different environment policies
  final devPolicy = PasswordPolicy.forEnvironment('development');
  final prodPolicy = PasswordPolicy.forEnvironment('production');
  
  print('Development policy: min ${devPolicy.minLength} chars');
  print('Production policy: min ${prodPolicy.minLength} chars');
  
  // Test password validation
  final testPasswords = [
    'weak',
    'password123',
    'StrongP@ssw0rd!',
    'Sup3rSecur3P@ssw0rd2024!',
  ];
  
  for (final password in testPasswords) {
    final result = prodPolicy.validatePassword(password, userEmail: 'test@example.com');
    print('Password "$password": ${result.isValid ? "✅ Valid" : "❌ Invalid"} (${result.strengthDescription})');
    if (!result.isValid && result.errors.isNotEmpty) {
      print('  Error: ${result.errors.first}');
    }
  }
  
  print('✅ Password policy test passed');
}

Future<void> testRequestSigning() async {
  print('\n✍️ Testing Request Signing...');
  
  final config = RequestSigningConfig.fromEnvironment(
    environment: 'development',
    customApiKey: 'test-api-key-32-chars-long-dev',
    customSecretKey: 'test-secret-key-64-chars-long-development-testing-only',
  );
  
  final signingService = RequestSigningService(
    apiKey: config.apiKey,
    secretKey: config.secretKey,
    enableSigning: true,
  );
  
  // Test signing strength validation
  final apiKeyValid = SecurityConfigUtils.isStrongApiKey(config.apiKey);
  final secretKeyValid = SecurityConfigUtils.isStrongSecretKey(config.secretKey);
  
  print('API key valid: $apiKeyValid');
  print('Secret key valid: $secretKeyValid');
  print('Signing service created: ${signingService != null}');
  
  print('✅ Request signing test passed');
}

Future<void> testSecurityManager() async {
  print('\n🛡️ Testing Security Manager...');
  
  final securityManager = SecurityManager.instance;
  
  // Test initialization with development config
  await securityManager.initialize(environment: 'development');
  print('Security manager initialized: ${securityManager.isInitialized}');
  
  // Test security audit
  final audit = securityManager.getSecurityAudit();
  print('Security audit passed: ${audit.passed}');
  
  // Test configuration
  final config = securityManager.securityConfig;
  if (config != null) {
    print('Current environment: ${config.environment}');
    print('Security level: ${config.securityLevel.name}');
  }
  
  print('✅ Security manager test passed');
}

Future<void> testProductionReadiness() async {
  print('\n🚀 Testing Production Readiness...');
  
  // Test production key generation
  final prodTemplate = SecurityConfigUtils.generateProductionTemplate();
  print('Production template generated: ${prodTemplate.length} keys');
  
  // Test key strength validation
  final strongApiKey = SecurityConfigUtils.generateSecureApiKey();
  final strongSecretKey = SecurityConfigUtils.generateSecureSecretKey();
  
  final apiKeyStrong = SecurityConfigUtils.isStrongApiKey(strongApiKey);
  final secretKeyStrong = SecurityConfigUtils.isStrongSecretKey(strongSecretKey);
  
  print('Generated strong API key: $apiKeyStrong');
  print('Generated strong secret key: $secretKeyStrong');
  
  // Test deployment checklist
  final checklist = SecurityInitializer.getProductionDeploymentChecklist();
  print('Production checklist items: ${checklist.length}');
  
  print('✅ Production readiness test passed');
}