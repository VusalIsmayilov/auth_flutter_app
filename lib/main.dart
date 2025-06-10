import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'presentation/routes/app_router.dart';
import 'config/theme.dart';
import 'config/environment_config.dart';
import 'config/security_manager.dart';
import 'core/monitoring/error_monitoring_service.dart';
import 'data/datasources/local/secure_storage_service.dart';

void main() async {
  // Ensure Flutter binding is initialized
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize environment configuration
  EnvironmentService.initialize();
  
  // Initialize security systems with comprehensive protection
  await SecurityInitializer.initializeForApp();
  
  // Initialize error monitoring and crash reporting
  await ErrorMonitoringService.initialize(
    storageService: SecureStorageService(),
  );
  
  runApp(const ProviderScope(child: AuthFlutterApp()));
}

class AuthFlutterApp extends ConsumerWidget {
  const AuthFlutterApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);

    return MaterialApp.router(
      title: 'Auth Flutter App',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      routerConfig: router,
      debugShowCheckedModeBanner: false,
    );
  }
}