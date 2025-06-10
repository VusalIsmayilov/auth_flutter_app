import 'dart:convert';
import 'package:crypto/crypto.dart';

/// Comprehensive password policy enforcement
class PasswordPolicy {
  final int minLength;
  final int maxLength;
  final bool requireUppercase;
  final bool requireLowercase;
  final bool requireNumbers;
  final bool requireSpecialChars;
  final bool preventCommonPasswords;
  final bool preventReuse;
  final int maxReuseCount;
  final bool preventUserInfo;
  final List<String> customForbiddenWords;
  final String environment;

  const PasswordPolicy({
    this.minLength = 12,
    this.maxLength = 128,
    this.requireUppercase = true,
    this.requireLowercase = true,
    this.requireNumbers = true,
    this.requireSpecialChars = true,
    this.preventCommonPasswords = true,
    this.preventReuse = true,
    this.maxReuseCount = 5,
    this.preventUserInfo = true,
    this.customForbiddenWords = const [],
    this.environment = 'production',
  });

  /// Create password policy for different environments
  factory PasswordPolicy.forEnvironment(String environment) {
    switch (environment.toLowerCase()) {
      case 'production':
        return const PasswordPolicy(
          minLength: 14,
          maxLength: 128,
          requireUppercase: true,
          requireLowercase: true,
          requireNumbers: true,
          requireSpecialChars: true,
          preventCommonPasswords: true,
          preventReuse: true,
          maxReuseCount: 5,
          preventUserInfo: true,
          environment: 'production',
        );
      case 'staging':
        return const PasswordPolicy(
          minLength: 12,
          maxLength: 128,
          requireUppercase: true,
          requireLowercase: true,
          requireNumbers: true,
          requireSpecialChars: true,
          preventCommonPasswords: true,
          preventReuse: true,
          maxReuseCount: 3,
          preventUserInfo: true,
          environment: 'staging',
        );
      case 'development':
      case 'debug':
        return const PasswordPolicy(
          minLength: 8,
          maxLength: 128,
          requireUppercase: false,
          requireLowercase: true,
          requireNumbers: true,
          requireSpecialChars: false,
          preventCommonPasswords: false,
          preventReuse: false,
          maxReuseCount: 0,
          preventUserInfo: false,
          environment: 'development',
        );
      default:
        return const PasswordPolicy();
    }
  }

  /// Validate password against policy
  PasswordValidationResult validatePassword(
    String password, {
    String? userEmail,
    String? userName,
    List<String>? previousPasswordHashes,
  }) {
    final errors = <String>[];
    final warnings = <String>[];
    final suggestions = <String>[];

    // Length validation
    if (password.length < minLength) {
      errors.add('Password must be at least $minLength characters long');
    }
    if (password.length > maxLength) {
      errors.add('Password must not exceed $maxLength characters');
    }

    // Character requirements
    if (requireUppercase && !RegExp(r'[A-Z]').hasMatch(password)) {
      errors.add('Password must contain at least one uppercase letter (A-Z)');
    }
    if (requireLowercase && !RegExp(r'[a-z]').hasMatch(password)) {
      errors.add('Password must contain at least one lowercase letter (a-z)');
    }
    if (requireNumbers && !RegExp(r'[0-9]').hasMatch(password)) {
      errors.add('Password must contain at least one number (0-9)');
    }
    if (requireSpecialChars && !RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(password)) {
      errors.add('Password must contain at least one special character (!@#\$%^&*(),.?":{}|<>)');
    }

    // Advanced validations
    if (preventCommonPasswords && _isCommonPassword(password)) {
      errors.add('This password is too common. Please choose a more unique password');
    }

    if (preventUserInfo && _containsUserInfo(password, userEmail, userName)) {
      errors.add('Password cannot contain your email address or username');
    }

    if (preventReuse && _isPasswordReused(password, previousPasswordHashes)) {
      errors.add('Cannot reuse one of your previous $maxReuseCount passwords');
    }

    // Pattern analysis
    if (_hasRepeatingCharacters(password)) {
      warnings.add('Password contains repeating characters');
      suggestions.add('Avoid consecutive repeating characters');
    }

    if (_hasSequentialCharacters(password)) {
      warnings.add('Password contains sequential characters');
      suggestions.add('Avoid sequential patterns like "123" or "abc"');
    }

    if (_hasKeyboardPatterns(password)) {
      warnings.add('Password contains keyboard patterns');
      suggestions.add('Avoid keyboard patterns like "qwerty" or "asdf"');
    }

    // Strength assessment
    final strength = _calculatePasswordStrength(password);
    if (strength < 0.6 && environment == 'production') {
      warnings.add('Password strength is below recommended level');
      suggestions.add('Consider using a longer password with mixed characters');
    }

    return PasswordValidationResult(
      isValid: errors.isEmpty,
      errors: errors,
      warnings: warnings,
      suggestions: suggestions,
      strength: strength,
      score: _calculatePasswordScore(password),
    );
  }

  /// Check if password is commonly used
  bool _isCommonPassword(String password) {
    final common = _getCommonPasswords();
    return common.contains(password.toLowerCase());
  }

  /// Check if password contains user information
  bool _containsUserInfo(String password, String? userEmail, String? userName) {
    if (userEmail != null) {
      final emailUser = userEmail.split('@').first.toLowerCase();
      if (password.toLowerCase().contains(emailUser) && emailUser.length >= 3) {
        return true;
      }
    }
    
    if (userName != null && userName.length >= 3) {
      if (password.toLowerCase().contains(userName.toLowerCase())) {
        return true;
      }
    }
    
    return false;
  }

  /// Check if password was previously used
  bool _isPasswordReused(String password, List<String>? previousHashes) {
    if (previousHashes == null || previousHashes.isEmpty) {
      return false;
    }
    
    final currentHash = _hashPassword(password);
    return previousHashes.take(maxReuseCount).contains(currentHash);
  }

  /// Hash password for comparison
  String _hashPassword(String password) {
    final bytes = utf8.encode(password);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  /// Check for repeating characters
  bool _hasRepeatingCharacters(String password, {int threshold = 3}) {
    for (int i = 0; i <= password.length - threshold; i++) {
      final char = password[i];
      bool hasRepeats = true;
      for (int j = 1; j < threshold; j++) {
        if (i + j >= password.length || password[i + j] != char) {
          hasRepeats = false;
          break;
        }
      }
      if (hasRepeats) return true;
    }
    return false;
  }

  /// Check for sequential characters
  bool _hasSequentialCharacters(String password, {int threshold = 3}) {
    for (int i = 0; i <= password.length - threshold; i++) {
      bool isSequential = true;
      final startChar = password.codeUnitAt(i);
      
      for (int j = 1; j < threshold; j++) {
        if (i + j >= password.length || 
            password.codeUnitAt(i + j) != startChar + j) {
          isSequential = false;
          break;
        }
      }
      
      if (isSequential) return true;
    }
    return false;
  }

  /// Check for keyboard patterns
  bool _hasKeyboardPatterns(String password) {
    final patterns = [
      'qwerty', 'qwertyuiop', 'asdf', 'asdfghjkl', 'zxcv', 'zxcvbnm',
      '1234', '12345', '123456', '1234567', '12345678',
    ];
    
    final lowerPassword = password.toLowerCase();
    for (final pattern in patterns) {
      if (lowerPassword.contains(pattern)) {
        return true;
      }
    }
    return false;
  }

  /// Calculate password strength (0.0 to 1.0)
  double _calculatePasswordStrength(String password) {
    double strength = 0.0;
    
    // Length bonus
    strength += (password.length / 20.0).clamp(0.0, 0.3);
    
    // Character variety
    int charTypes = 0;
    if (RegExp(r'[a-z]').hasMatch(password)) charTypes++;
    if (RegExp(r'[A-Z]').hasMatch(password)) charTypes++;
    if (RegExp(r'[0-9]').hasMatch(password)) charTypes++;
    if (RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(password)) charTypes++;
    
    strength += (charTypes / 4.0) * 0.4;
    
    // Entropy bonus
    final uniqueChars = password.split('').toSet().length;
    strength += (uniqueChars / password.length) * 0.2;
    
    // Pattern penalties
    if (_hasRepeatingCharacters(password)) strength -= 0.1;
    if (_hasSequentialCharacters(password)) strength -= 0.1;
    if (_hasKeyboardPatterns(password)) strength -= 0.1;
    
    return strength.clamp(0.0, 1.0);
  }

  /// Calculate numerical password score (0-100)
  int _calculatePasswordScore(String password) {
    return (_calculatePasswordStrength(password) * 100).round();
  }

  /// Get list of common passwords
  Set<String> _getCommonPasswords() {
    // Top 100 most common passwords - shortened for demo
    return {
      'password', '123456', '123456789', 'qwerty', 'abc123', 
      'password123', 'admin', 'letmein', 'welcome', 'monkey',
      'dragon', 'master', 'hello', 'login', 'pass', 'test',
      'guest', 'user', 'root', 'admin123', 'password1',
      'sunshine', 'princess', 'football', 'baseball', 'soccer',
      'jordan', 'taylor', 'jessica', 'michelle', 'daniel',
      'qwertyuiop', 'asdfghjkl', 'zxcvbnm', '1qaz2wsx',
      'iloveyou', 'welcome123', 'passw0rd', 'p@ssw0rd',
    };
  }

  /// Generate password suggestions
  List<String> generatePasswordSuggestions({
    String? baseWord,
    int count = 3,
  }) {
    // This is a basic implementation - in production you'd use
    // a proper password generation library with cryptographically secure randomness
    final suggestions = <String>[];
    // Implementation would generate secure password suggestions
    return suggestions;
  }

  /// Get policy description for users
  String getPolicyDescription() {
    final buffer = StringBuffer();
    buffer.writeln('Password Requirements:');
    buffer.writeln('• Length: $minLength-$maxLength characters');
    
    if (requireUppercase) buffer.writeln('• At least one uppercase letter (A-Z)');
    if (requireLowercase) buffer.writeln('• At least one lowercase letter (a-z)');
    if (requireNumbers) buffer.writeln('• At least one number (0-9)');
    if (requireSpecialChars) buffer.writeln('• At least one special character (!@#\$%^&*(),.?":{}|<>)');
    
    if (preventCommonPasswords) buffer.writeln('• Cannot be a commonly used password');
    if (preventUserInfo) buffer.writeln('• Cannot contain your email or username');
    if (preventReuse) buffer.writeln('• Cannot reuse your last $maxReuseCount passwords');
    
    return buffer.toString();
  }

  /// Copy with override parameters
  PasswordPolicy copyWith({
    int? minLength,
    int? maxLength,
    bool? requireUppercase,
    bool? requireLowercase,
    bool? requireNumbers,
    bool? requireSpecialChars,
    bool? preventCommonPasswords,
    bool? preventReuse,
    int? maxReuseCount,
    bool? preventUserInfo,
    List<String>? customForbiddenWords,
  }) {
    return PasswordPolicy(
      minLength: minLength ?? this.minLength,
      maxLength: maxLength ?? this.maxLength,
      requireUppercase: requireUppercase ?? this.requireUppercase,
      requireLowercase: requireLowercase ?? this.requireLowercase,
      requireNumbers: requireNumbers ?? this.requireNumbers,
      requireSpecialChars: requireSpecialChars ?? this.requireSpecialChars,
      preventCommonPasswords: preventCommonPasswords ?? this.preventCommonPasswords,
      preventReuse: preventReuse ?? this.preventReuse,
      maxReuseCount: maxReuseCount ?? this.maxReuseCount,
      preventUserInfo: preventUserInfo ?? this.preventUserInfo,
      customForbiddenWords: customForbiddenWords ?? this.customForbiddenWords,
      environment: environment,
    );
  }
}

/// Password validation result
class PasswordValidationResult {
  final bool isValid;
  final List<String> errors;
  final List<String> warnings;
  final List<String> suggestions;
  final double strength; // 0.0 to 1.0
  final int score; // 0 to 100

  const PasswordValidationResult({
    required this.isValid,
    required this.errors,
    required this.warnings,
    required this.suggestions,
    required this.strength,
    required this.score,
  });

  /// Get strength description
  String get strengthDescription {
    if (strength >= 0.8) return 'Very Strong';
    if (strength >= 0.6) return 'Strong';
    if (strength >= 0.4) return 'Medium';
    if (strength >= 0.2) return 'Weak';
    return 'Very Weak';
  }

  /// Get strength color (for UI)
  String get strengthColor {
    if (strength >= 0.8) return '#4CAF50'; // Green
    if (strength >= 0.6) return '#8BC34A'; // Light Green
    if (strength >= 0.4) return '#FFC107'; // Amber
    if (strength >= 0.2) return '#FF9800'; // Orange
    return '#F44336'; // Red
  }

  /// Check if password meets minimum requirements
  bool get meetsMinimumRequirements => isValid;

  /// Check if password is recommended
  bool get isRecommended => isValid && strength >= 0.6;

  @override
  String toString() {
    return 'PasswordValidationResult{isValid: $isValid, strength: $strengthDescription ($score/100)}';
  }
}

/// Password history manager
class PasswordHistoryManager {
  final int maxHistoryCount;
  final List<String> _passwordHashes = [];

  PasswordHistoryManager({this.maxHistoryCount = 5});

  /// Add password to history
  void addPassword(String password) {
    final hash = _hashPassword(password);
    _passwordHashes.insert(0, hash);
    
    // Keep only the most recent passwords
    if (_passwordHashes.length > maxHistoryCount) {
      _passwordHashes.removeRange(maxHistoryCount, _passwordHashes.length);
    }
  }

  /// Check if password was recently used
  bool isPasswordReused(String password) {
    final hash = _hashPassword(password);
    return _passwordHashes.contains(hash);
  }

  /// Get password history hashes (for validation)
  List<String> get passwordHashes => List.unmodifiable(_passwordHashes);

  /// Clear password history
  void clearHistory() {
    _passwordHashes.clear();
  }

  /// Hash password
  String _hashPassword(String password) {
    final bytes = utf8.encode(password);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }
}

/// Password strength meter widget data
class PasswordStrengthMeterData {
  final double strength;
  final String description;
  final String color;
  final int score;
  final List<String> requirements;
  final List<String> suggestions;

  const PasswordStrengthMeterData({
    required this.strength,
    required this.description,
    required this.color,
    required this.score,
    required this.requirements,
    required this.suggestions,
  });

  factory PasswordStrengthMeterData.fromValidation(
    PasswordValidationResult validation,
    PasswordPolicy policy,
  ) {
    final requirements = <String>[];
    
    // Add failed requirements
    for (final error in validation.errors) {
      requirements.add('❌ $error');
    }
    
    // Add warnings
    for (final warning in validation.warnings) {
      requirements.add('⚠️ $warning');
    }
    
    return PasswordStrengthMeterData(
      strength: validation.strength,
      description: validation.strengthDescription,
      color: validation.strengthColor,
      score: validation.score,
      requirements: requirements,
      suggestions: validation.suggestions,
    );
  }
}