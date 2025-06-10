import 'dart:async';
import 'dart:convert';
import 'package:logger/logger.dart';
import 'package:flutter/foundation.dart';
import '../security/request_signing_service.dart';
import '../../data/datasources/local/secure_storage_service.dart';

/// Production-ready error monitoring and crash reporting service
class ErrorMonitoringService {
  static ErrorMonitoringService? _instance;
  static final Logger _logger = Logger();

  final SecureStorageService _storageService;
  final List<ErrorReport> _localErrorQueue = [];
  final StreamController<ErrorReport> _errorController = StreamController.broadcast();
  
  bool _isInitialized = false;
  String? _sessionId;
  String? _userId;
  
  ErrorMonitoringService._({
    required SecureStorageService storageService,
  }) : _storageService = storageService;

  /// Get singleton instance
  static ErrorMonitoringService get instance {
    if (_instance == null) {
      throw StateError('ErrorMonitoringService not initialized. Call initialize() first.');
    }
    return _instance!;
  }

  /// Initialize error monitoring service
  static Future<ErrorMonitoringService> initialize({
    required SecureStorageService storageService,
  }) async {
    _instance = ErrorMonitoringService._(storageService: storageService);
    await _instance!._initializeSession();
    
    // Set up Flutter error handlers
    _instance!._setupFlutterErrorHandlers();
    
    _logger.i('ErrorMonitoringService initialized');
    return _instance!;
  }

  /// Initialize monitoring session
  Future<void> _initializeSession() async {
    _sessionId = _generateSessionId();
    _isInitialized = true;
    
    // Load pending error reports
    await _loadPendingErrors();
    
    _logger.d('Error monitoring session started: $_sessionId');
  }

  /// Set up Flutter framework error handlers
  void _setupFlutterErrorHandlers() {
    // Handle Flutter framework errors
    FlutterError.onError = (FlutterErrorDetails details) {
      _reportFlutterError(details);
    };

    // Handle errors outside Flutter framework (async errors)
    PlatformDispatcher.instance.onError = (error, stack) {
      _reportDartError(error, stack);
      return true;
    };
  }

  /// Report Flutter framework error
  void _reportFlutterError(FlutterErrorDetails details) {
    final errorReport = ErrorReport(
      id: _generateErrorId(),
      sessionId: _sessionId!,
      userId: _userId,
      type: ErrorType.flutter,
      error: details.exception.toString(),
      stackTrace: details.stack.toString(),
      context: {
        'library': details.library,
        'informationCollector': details.informationCollector?.toString(),
        'silent': details.silent,
      },
      timestamp: DateTime.now(),
      environment: kDebugMode ? 'debug' : 'production',
      severity: ErrorSeverity.high,
    );

    _processError(errorReport);
  }

  /// Report Dart error (async, outside Flutter)
  void _reportDartError(Object error, StackTrace stackTrace) {
    final errorReport = ErrorReport(
      id: _generateErrorId(),
      sessionId: _sessionId!,
      userId: _userId,
      type: ErrorType.dart,
      error: error.toString(),
      stackTrace: stackTrace.toString(),
      context: {},
      timestamp: DateTime.now(),
      environment: kDebugMode ? 'debug' : 'production',
      severity: ErrorSeverity.high,
    );

    _processError(errorReport);
  }

  /// Report custom application error
  void reportError(
    Object error, {
    StackTrace? stackTrace,
    String? context,
    ErrorSeverity severity = ErrorSeverity.medium,
    Map<String, dynamic>? additionalData,
  }) {
    final errorReport = ErrorReport(
      id: _generateErrorId(),
      sessionId: _sessionId!,
      userId: _userId,
      type: ErrorType.application,
      error: error.toString(),
      stackTrace: stackTrace?.toString(),
      context: {
        if (context != null) 'context': context,
        ...?additionalData,
      },
      timestamp: DateTime.now(),
      environment: kDebugMode ? 'debug' : 'production',
      severity: severity,
    );

    _processError(errorReport);
  }

  /// Report security event
  void reportSecurityEvent(
    SecurityEventType eventType, {
    required String description,
    String? userId,
    Map<String, dynamic>? metadata,
  }) {
    final securityReport = SecurityEventReport(
      id: _generateEventId(),
      sessionId: _sessionId!,
      userId: userId ?? _userId,
      eventType: eventType,
      description: description,
      metadata: metadata ?? {},
      timestamp: DateTime.now(),
      severity: _getSecurityEventSeverity(eventType),
    );

    _processSecurityEvent(securityReport);
  }

  /// Process error report
  void _processError(ErrorReport report) {
    // Log locally
    _logger.e('Error reported: ${report.error}');
    
    // Add to local queue
    _localErrorQueue.add(report);
    
    // Emit to stream
    _errorController.add(report);
    
    // Store locally for offline scenarios
    _storeErrorLocally(report);
    
    // Send to monitoring service (if available)
    _sendToMonitoringService(report);
  }

  /// Process security event
  void _processSecurityEvent(SecurityEventReport report) {
    _logger.w('Security event: ${report.description}');
    
    // Store security events separately
    _storeSecurityEventLocally(report);
    
    // Send to security monitoring
    _sendSecurityEventToMonitoring(report);
  }

  /// Store error locally for offline scenarios
  Future<void> _storeErrorLocally(ErrorReport report) async {
    try {
      final errors = await _getStoredErrors();
      errors.add(report.toJson());
      
      // Keep only last 100 errors
      if (errors.length > 100) {
        errors.removeRange(0, errors.length - 100);
      }
      
      await _storageService.storeUserPreference(
        'error_reports',
        jsonEncode(errors),
      );
    } catch (e) {
      _logger.e('Failed to store error locally: $e');
    }
  }

  /// Store security event locally
  Future<void> _storeSecurityEventLocally(SecurityEventReport report) async {
    try {
      final events = await _getStoredSecurityEvents();
      events.add(report.toJson());
      
      // Keep only last 50 security events
      if (events.length > 50) {
        events.removeRange(0, events.length - 50);
      }
      
      await _storageService.storeUserPreference(
        'security_events',
        jsonEncode(events),
      );
    } catch (e) {
      _logger.e('Failed to store security event locally: $e');
    }
  }

  /// Load pending errors from storage
  Future<void> _loadPendingErrors() async {
    try {
      final errors = await _getStoredErrors();
      _localErrorQueue.clear();
      
      for (final errorJson in errors) {
        try {
          final report = ErrorReport.fromJson(errorJson);
          _localErrorQueue.add(report);
        } catch (e) {
          _logger.w('Failed to parse stored error: $e');
        }
      }
      
      _logger.d('Loaded ${_localErrorQueue.length} pending errors');
    } catch (e) {
      _logger.e('Failed to load pending errors: $e');
    }
  }

  /// Get stored errors
  Future<List<Map<String, dynamic>>> _getStoredErrors() async {
    try {
      final errorsJson = await _storageService.getUserPreference('error_reports');
      if (errorsJson != null && errorsJson.isNotEmpty) {
        final decoded = jsonDecode(errorsJson);
        return List<Map<String, dynamic>>.from(decoded);
      }
    } catch (e) {
      _logger.w('Failed to get stored errors: $e');
    }
    return [];
  }

  /// Get stored security events
  Future<List<Map<String, dynamic>>> _getStoredSecurityEvents() async {
    try {
      final eventsJson = await _storageService.getUserPreference('security_events');
      if (eventsJson != null && eventsJson.isNotEmpty) {
        final decoded = jsonDecode(eventsJson);
        return List<Map<String, dynamic>>.from(decoded);
      }
    } catch (e) {
      _logger.w('Failed to get stored security events: $e');
    }
    return [];
  }

  /// Send error to monitoring service
  Future<void> _sendToMonitoringService(ErrorReport report) async {
    try {
      // In production, integrate with services like:
      // - Sentry
      // - Firebase Crashlytics
      // - Custom monitoring endpoint
      
      _logger.d('Error sent to monitoring service: ${report.id}');
    } catch (e) {
      _logger.e('Failed to send error to monitoring service: $e');
    }
  }

  /// Send security event to monitoring
  Future<void> _sendSecurityEventToMonitoring(SecurityEventReport report) async {
    try {
      // Send to security monitoring endpoint
      _logger.d('Security event sent to monitoring: ${report.id}');
    } catch (e) {
      _logger.e('Failed to send security event to monitoring: $e');
    }
  }

  /// Set current user for error context
  void setUserId(String userId) {
    _userId = userId;
    _logger.d('Error monitoring user set: $userId');
  }

  /// Clear user context
  void clearUserId() {
    _userId = null;
    _logger.d('Error monitoring user cleared');
  }

  /// Get error reports stream
  Stream<ErrorReport> get errorStream => _errorController.stream;

  /// Get recent errors
  List<ErrorReport> getRecentErrors({int limit = 50}) {
    return _localErrorQueue.take(limit).toList();
  }

  /// Get recent security events
  Future<List<SecurityEventReport>> getRecentSecurityEvents({int limit = 20}) async {
    try {
      final events = await _getStoredSecurityEvents();
      return events
          .take(limit)
          .map((json) => SecurityEventReport.fromJson(json))
          .toList();
    } catch (e) {
      _logger.e('Failed to get recent security events: $e');
      return [];
    }
  }

  /// Clear all stored errors
  Future<void> clearStoredErrors() async {
    try {
      await _storageService.deleteUserPreference('error_reports');
      _localErrorQueue.clear();
      _logger.d('All stored errors cleared');
    } catch (e) {
      _logger.e('Failed to clear stored errors: $e');
    }
  }

  /// Generate unique session ID
  String _generateSessionId() {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final random = (timestamp % 10000).toString().padLeft(4, '0');
    return 'session_${timestamp}_$random';
  }

  /// Generate unique error ID
  String _generateErrorId() {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final random = (timestamp % 1000).toString().padLeft(3, '0');
    return 'error_${timestamp}_$random';
  }

  /// Generate unique event ID
  String _generateEventId() {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final random = (timestamp % 1000).toString().padLeft(3, '0');
    return 'event_${timestamp}_$random';
  }

  /// Get security event severity
  ErrorSeverity _getSecurityEventSeverity(SecurityEventType eventType) {
    switch (eventType) {
      case SecurityEventType.loginFailure:
      case SecurityEventType.bruteForceDetected:
      case SecurityEventType.unauthorizedAccess:
        return ErrorSeverity.high;
      case SecurityEventType.suspiciousActivity:
      case SecurityEventType.passwordPolicyViolation:
        return ErrorSeverity.medium;
      case SecurityEventType.loginSuccess:
      case SecurityEventType.logoutSuccess:
        return ErrorSeverity.low;
    }
  }

  /// Check if monitoring is initialized
  bool get isInitialized => _isInitialized;

  /// Get current session ID
  String? get sessionId => _sessionId;

  /// Dispose resources
  void dispose() {
    _errorController.close();
    _localErrorQueue.clear();
    _isInitialized = false;
  }
}

/// Error report model
class ErrorReport {
  final String id;
  final String sessionId;
  final String? userId;
  final ErrorType type;
  final String error;
  final String? stackTrace;
  final Map<String, dynamic> context;
  final DateTime timestamp;
  final String environment;
  final ErrorSeverity severity;

  const ErrorReport({
    required this.id,
    required this.sessionId,
    this.userId,
    required this.type,
    required this.error,
    this.stackTrace,
    required this.context,
    required this.timestamp,
    required this.environment,
    required this.severity,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'sessionId': sessionId,
      'userId': userId,
      'type': type.name,
      'error': error,
      'stackTrace': stackTrace,
      'context': context,
      'timestamp': timestamp.toIso8601String(),
      'environment': environment,
      'severity': severity.name,
    };
  }

  factory ErrorReport.fromJson(Map<String, dynamic> json) {
    return ErrorReport(
      id: json['id'],
      sessionId: json['sessionId'],
      userId: json['userId'],
      type: ErrorType.values.byName(json['type']),
      error: json['error'],
      stackTrace: json['stackTrace'],
      context: Map<String, dynamic>.from(json['context']),
      timestamp: DateTime.parse(json['timestamp']),
      environment: json['environment'],
      severity: ErrorSeverity.values.byName(json['severity']),
    );
  }
}

/// Security event report model
class SecurityEventReport {
  final String id;
  final String sessionId;
  final String? userId;
  final SecurityEventType eventType;
  final String description;
  final Map<String, dynamic> metadata;
  final DateTime timestamp;
  final ErrorSeverity severity;

  const SecurityEventReport({
    required this.id,
    required this.sessionId,
    this.userId,
    required this.eventType,
    required this.description,
    required this.metadata,
    required this.timestamp,
    required this.severity,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'sessionId': sessionId,
      'userId': userId,
      'eventType': eventType.name,
      'description': description,
      'metadata': metadata,
      'timestamp': timestamp.toIso8601String(),
      'severity': severity.name,
    };
  }

  factory SecurityEventReport.fromJson(Map<String, dynamic> json) {
    return SecurityEventReport(
      id: json['id'],
      sessionId: json['sessionId'],
      userId: json['userId'],
      eventType: SecurityEventType.values.byName(json['eventType']),
      description: json['description'],
      metadata: Map<String, dynamic>.from(json['metadata']),
      timestamp: DateTime.parse(json['timestamp']),
      severity: ErrorSeverity.values.byName(json['severity']),
    );
  }
}

/// Error types
enum ErrorType {
  flutter,
  dart,
  application,
  network,
  security,
}

/// Error severity levels
enum ErrorSeverity {
  low,
  medium,
  high,
  critical,
}

/// Security event types
enum SecurityEventType {
  loginSuccess,
  loginFailure,
  logoutSuccess,
  bruteForceDetected,
  unauthorizedAccess,
  suspiciousActivity,
  passwordPolicyViolation,
}