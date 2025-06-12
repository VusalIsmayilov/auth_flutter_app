import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../pages/auth/login_page.dart';
import '../pages/auth/register_page.dart';
import '../pages/auth/forgot_password_page.dart';
import '../pages/auth/reset_password_page.dart';
import '../pages/auth/email_verification_page.dart';
import '../pages/home/home_page.dart';
import '../pages/common/splash_page.dart';
import '../pages/user/profile_page.dart';
import '../providers/providers.dart';
import '../providers/auth_provider.dart';
import '../../core/constants/app_constants.dart';
import 'role_based_route.dart';

final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/splash',
    refreshListenable: AuthStateListener(ref),
    redirect: (context, state) {
      final isAuthenticated = ref.read(isAuthenticatedProvider);
      final isLoading = ref.read(isLoadingProvider);
      
      // If we're loading, stay where we are
      if (isLoading) return null;
      
      // If we're on splash page, check auth and redirect accordingly
      if (state.matchedLocation == '/splash') {
        if (isAuthenticated) {
          return '/home';
        } else {
          return '/login';
        }
      }
      
      // If not authenticated and trying to access protected routes
      if (!isAuthenticated && _isProtectedRoute(state.matchedLocation)) {
        return '/login';
      }
      
      // If authenticated and trying to access auth routes
      if (isAuthenticated && _isAuthRoute(state.matchedLocation)) {
        return '/home';
      }
      
      return null;
    },
    routes: [
      GoRoute(
        path: '/splash',
        builder: (context, state) => const SplashPage(),
      ),
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginPage(),
      ),
      GoRoute(
        path: '/register',
        builder: (context, state) => const RegisterPage(),
      ),
      GoRoute(
        path: '/forgot-password',
        builder: (context, state) => const ForgotPasswordPage(),
      ),
      GoRoute(
        path: '/reset-password',
        builder: (context, state) {
          final token = state.uri.queryParameters['token'] ?? '';
          final email = state.uri.queryParameters['email'];
          return ResetPasswordPage(token: token, email: email);
        },
      ),
      GoRoute(
        path: '/email-verification',
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>?;
          final email = extra?['email'] ?? state.uri.queryParameters['email'] ?? '';
          return EmailVerificationPage(email: email);
        },
      ),
      GoRoute(
        path: '/home',
        builder: (context, state) => const HomePage(),
      ),
      GoRoute(
        path: '/profile',
        builder: (context, state) => const ProfilePage(),
      ),
      // Admin routes with role protection
      GoRoute(
        path: '/admin/users',
        builder: (context, state) => RoleBasedRouteGuard(
          requiredPermissions: const [AppConstants.permissionViewUsers],
          child: const AdminUsersPage(),
        ),
      ),
      GoRoute(
        path: '/admin/reports',
        builder: (context, state) => RoleBasedRouteGuard(
          requiredPermissions: const [AppConstants.permissionViewReports],
          child: const AdminReportsPage(),
        ),
      ),
      GoRoute(
        path: '/admin/logs',
        builder: (context, state) => RoleBasedRouteGuard(
          requiredPermissions: const [AppConstants.permissionViewLogs],
          child: const AdminLogsPage(),
        ),
      ),
      GoRoute(
        path: '/admin/settings',
        builder: (context, state) => RoleBasedRouteGuard(
          requiredPermissions: const [AppConstants.permissionManageSettings],
          child: const AdminSettingsPage(),
        ),
      ),
      GoRoute(
        path: '/admin/system',
        builder: (context, state) => RoleBasedRouteGuard(
          requiredPermissions: const [AppConstants.permissionManageSystem],
          child: const AdminSystemPage(),
        ),
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text(
              'Page not found',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(state.error.toString()),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => context.go('/login'),
              child: const Text('Go to Login'),
            ),
          ],
        ),
      ),
    ),
  );
});

bool _isProtectedRoute(String location) {
  const protectedRoutes = ['/home', '/profile', '/admin'];
  return protectedRoutes.any((route) => location.startsWith(route));
}

bool _isAuthRoute(String location) {
  const authRoutes = ['/login', '/register', '/forgot-password', '/reset-password', '/email-verification'];
  return authRoutes.any((route) => location.startsWith(route));
}


// Placeholder Admin Pages
class AdminUsersPage extends StatelessWidget {
  const AdminUsersPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('User Management'),
        backgroundColor: Colors.orange,
        foregroundColor: Colors.white,
      ),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.people, size: 64, color: Colors.orange),
            SizedBox(height: 16),
            Text(
              'User Management',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text('Manage users, roles, and permissions'),
          ],
        ),
      ),
    );
  }
}

class AdminReportsPage extends StatelessWidget {
  const AdminReportsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Reports'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.analytics, size: 64, color: Colors.blue),
            SizedBox(height: 16),
            Text(
              'Analytics & Reports',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text('View system analytics and generate reports'),
          ],
        ),
      ),
    );
  }
}

class AdminLogsPage extends StatelessWidget {
  const AdminLogsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('System Logs'),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
      ),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.list_alt, size: 64, color: Colors.green),
            SizedBox(height: 16),
            Text(
              'System Logs',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text('Monitor system activity and audit logs'),
          ],
        ),
      ),
    );
  }
}

class AdminSettingsPage extends StatelessWidget {
  const AdminSettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        backgroundColor: Colors.purple,
        foregroundColor: Colors.white,
      ),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.settings, size: 64, color: Colors.purple),
            SizedBox(height: 16),
            Text(
              'System Settings',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text('Configure system settings and preferences'),
          ],
        ),
      ),
    );
  }
}

class AdminSystemPage extends StatelessWidget {
  const AdminSystemPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('System Management'),
        backgroundColor: Colors.red,
        foregroundColor: Colors.white,
      ),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.admin_panel_settings, size: 64, color: Colors.red),
            SizedBox(height: 16),
            Text(
              'System Management',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text('Advanced system administration tools'),
          ],
        ),
      ),
    );
  }
}

// Auth state listener for router refresh
class AuthStateListener extends ChangeNotifier {
  final Ref _ref;
  late final ProviderSubscription _authSubscription;

  AuthStateListener(this._ref) {
    _authSubscription = _ref.listen<AuthState>(authProvider, (previous, next) {
      notifyListeners();
    });
  }

  @override
  void dispose() {
    _authSubscription.close();
    super.dispose();
  }
}