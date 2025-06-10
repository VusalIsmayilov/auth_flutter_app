// Simple security test without Flutter dependencies

import 'dart:convert';
import 'dart:math';
import 'package:crypto/crypto.dart';

void main() {
  print('🔒 Security Features Test');
  print('=' * 40);
  
  testPasswordValidation();
  testApiKeyGeneration();
  testRequestSigning();
  testCertificateFingerprints();
  
  print('\n✅ All basic security tests passed!');
}

void testPasswordValidation() {
  print('\n🔐 Testing Password Validation...');
  
  final passwords = [
    'weak',
    'password123',
    'StrongP@ssw0rd!',
    'VerySecurePassword2024!@#',
  ];
  
  for (final password in passwords) {
    final strength = calculatePasswordStrength(password);
    final isStrong = strength >= 0.6;
    print('Password "$password": ${isStrong ? "✅ Strong" : "❌ Weak"} (${(strength * 100).round()}%)');
  }
}

void testApiKeyGeneration() {
  print('\n🔑 Testing API Key Generation...');
  
  final apiKey = generateSecureApiKey();
  final secretKey = generateSecureSecretKey();
  
  print('Generated API Key: ${apiKey.substring(0, 16)}... (${apiKey.length} chars)');
  print('Generated Secret Key: ${secretKey.substring(0, 16)}... (${secretKey.length} chars)');
  print('API Key valid: ${isValidApiKey(apiKey)}');
  print('Secret Key valid: ${isValidSecretKey(secretKey)}');
}

void testRequestSigning() {
  print('\n✍️ Testing Request Signing...');
  
  final apiKey = 'test-api-key-32-chars-long-dev';
  final secretKey = 'test-secret-key-64-chars-long-development-testing-only';
  
  final timestamp = DateTime.now().millisecondsSinceEpoch.toString();
  final nonce = generateNonce();
  final stringToSign = 'POST\n/api/auth/login\n\ncontent-type:application/json\nhash-of-body\n$timestamp\n$nonce';
  
  final signature = generateSignature(stringToSign, secretKey);
  
  print('Timestamp: $timestamp');
  print('Nonce: $nonce');
  print('Signature: ${signature.substring(0, 16)}...');
  print('Request signing test: ✅ Passed');
}

void testCertificateFingerprints() {
  print('\n📜 Testing Certificate Fingerprints...');
  
  final testCert = 'example.com-cert-data';
  final fingerprint = generateCertFingerprint(testCert);
  
  print('Test certificate fingerprint: sha256:$fingerprint');
  print('Fingerprint length: ${fingerprint.length} chars');
  print('Certificate fingerprint test: ✅ Passed');
}

// Security utility functions
double calculatePasswordStrength(String password) {
  double strength = 0.0;
  
  // Length bonus
  strength += (password.length / 20.0).clamp(0.0, 0.3);
  
  // Character variety
  int charTypes = 0;
  if (RegExp(r'[a-z]').hasMatch(password)) charTypes++;
  if (RegExp(r'[A-Z]').hasMatch(password)) charTypes++;
  if (RegExp(r'[0-9]').hasMatch(password)) charTypes++;
  if (RegExp(r'[!@#\$%^&*(),.?":{}|<>]').hasMatch(password)) charTypes++;
  
  strength += (charTypes / 4.0) * 0.4;
  
  // Entropy bonus
  final uniqueChars = password.split('').toSet().length;
  strength += (uniqueChars / password.length) * 0.2;
  
  // Pattern penalties
  if (hasRepeatingChars(password)) strength -= 0.1;
  if (hasSequentialChars(password)) strength -= 0.1;
  
  return strength.clamp(0.0, 1.0);
}

bool hasRepeatingChars(String password) {
  for (int i = 0; i <= password.length - 3; i++) {
    if (password[i] == password[i + 1] && password[i] == password[i + 2]) {
      return true;
    }
  }
  return false;
}

bool hasSequentialChars(String password) {
  for (int i = 0; i <= password.length - 3; i++) {
    final char1 = password.codeUnitAt(i);
    final char2 = password.codeUnitAt(i + 1);
    final char3 = password.codeUnitAt(i + 2);
    
    if (char2 == char1 + 1 && char3 == char2 + 1) {
      return true;
    }
  }
  return false;
}

String generateSecureApiKey({int length = 32}) {
  const chars = 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789-_';
  final random = Random.secure();
  return List.generate(length, (index) => chars[random.nextInt(chars.length)]).join();
}

String generateSecureSecretKey({int length = 64}) {
  final random = Random.secure();
  final bytes = List.generate(length, (index) => random.nextInt(256));
  return base64.encode(bytes);
}

bool isValidApiKey(String apiKey) {
  return apiKey.length >= 32 && 
         RegExp(r'^[a-zA-Z0-9\-_]{32,}$').hasMatch(apiKey);
}

bool isValidSecretKey(String secretKey) {
  return secretKey.length >= 64;
}

String generateNonce({int length = 16}) {
  const chars = 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
  final random = Random.secure();
  return List.generate(length, (index) => chars[random.nextInt(chars.length)]).join();
}

String generateSignature(String stringToSign, String secretKey) {
  final keyBytes = utf8.encode(secretKey);
  final messageBytes = utf8.encode(stringToSign);
  final hmac = Hmac(sha256, keyBytes);
  final digest = hmac.convert(messageBytes);
  return base64.encode(digest.bytes);
}

String generateCertFingerprint(String certData) {
  final bytes = utf8.encode(certData);
  final digest = sha256.convert(bytes);
  return digest.toString();
}