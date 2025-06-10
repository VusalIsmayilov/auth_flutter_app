import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:auth_flutter_app/main.dart' as app;
import 'package:auth_flutter_app/presentation/providers/providers.dart';
import 'package:auth_flutter_app/data/models/user_model.dart';
import 'package:auth_flutter_app/presentation/widgets/role_based/role_guard.dart';
import 'package:auth_flutter_app/presentation/widgets/role_based/role_badge.dart';
import 'package:auth_flutter_app/core/constants/app_constants.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Role-Based Access Control Integration Tests', () {
    
    testWidgets('User role permissions work correctly', (WidgetTester tester) async {
      // Test user role access to features
      app.main();
      await tester.pumpAndSettle();
      await tester.pumpAndSettle(const Duration(seconds: 2));

      // Create test container with user role
      final container = ProviderContainer(
        overrides: [
          currentUserProvider.overrideWith((ref) => const UserModel(
            id: 1,
            email: 'user@example.com',
            currentRole: 'User',
            currentRoleDisplayName: 'User',
            isActive: true,
          )),
        ],
      );

      try {
        final user = container.read(currentUserProvider);
        
        // Test user role properties
        expect(user?.isUser, isTrue);
        expect(user?.isAdmin, isFalse);
        expect(user?.isModerator, isFalse);
        expect(user?.isSupport, isFalse);
        
        // Test role display
        expect(user?.currentRoleDisplayName, 'User');
        
      } finally {
        container.dispose();
      }
    });

    testWidgets('Admin role permissions work correctly', (WidgetTester tester) async {
      // Test admin role access to all features
      app.main();
      await tester.pumpAndSettle();
      await tester.pumpAndSettle(const Duration(seconds: 2));

      final container = ProviderContainer(
        overrides: [
          currentUserProvider.overrideWith((ref) => const UserModel(
            id: 1,
            email: 'admin@example.com',
            currentRole: 'Admin',
            currentRoleDisplayName: 'Administrator',
            isActive: true,
          )),
        ],
      );

      try {
        final user = container.read(currentUserProvider);
        
        // Test admin role properties
        expect(user?.isAdmin, isTrue);
        expect(user?.isUser, isFalse);
        expect(user?.isModerator, isFalse);
        expect(user?.isSupport, isFalse);
        
        // Test role display
        expect(user?.currentRoleDisplayName, 'Administrator');
        
      } finally {
        container.dispose();
      }
    });

    testWidgets('Moderator role permissions work correctly', (WidgetTester tester) async {
      // Test moderator role access
      app.main();
      await tester.pumpAndSettle();
      await tester.pumpAndSettle(const Duration(seconds: 2));

      final container = ProviderContainer(
        overrides: [
          currentUserProvider.overrideWith((ref) => const UserModel(
            id: 1,
            email: 'moderator@example.com',
            currentRole: 'Moderator',
            currentRoleDisplayName: 'Moderator',
            isActive: true,
          )),
        ],
      );

      try {
        final user = container.read(currentUserProvider);
        
        // Test moderator role properties
        expect(user?.isModerator, isTrue);
        expect(user?.isAdmin, isFalse);
        expect(user?.isUser, isFalse);
        expect(user?.isSupport, isFalse);
        
      } finally {
        container.dispose();
      }
    });

    testWidgets('Support role permissions work correctly', (WidgetTester tester) async {
      // Test support role access
      app.main();
      await tester.pumpAndSettle();
      await tester.pumpAndSettle(const Duration(seconds: 2));

      final container = ProviderContainer(
        overrides: [
          currentUserProvider.overrideWith((ref) => const UserModel(
            id: 1,
            email: 'support@example.com',
            currentRole: 'Support',
            currentRoleDisplayName: 'Support Agent',
            isActive: true,
          )),
        ],
      );

      try {
        final user = container.read(currentUserProvider);
        
        // Test support role properties
        expect(user?.isSupport, isTrue);
        expect(user?.isAdmin, isFalse);
        expect(user?.isUser, isFalse);
        expect(user?.isModerator, isFalse);
        
      } finally {
        container.dispose();
      }
    });

    testWidgets('Role badges display correctly', (WidgetTester tester) async {
      // Test role badge components
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Column(
              children: [
                RoleBadge(role: 'Admin', size: RoleBadgeSize.small),
                RoleBadge(role: 'Moderator', size: RoleBadgeSize.medium),
                RoleBadge(role: 'Support', size: RoleBadgeSize.large),
                RoleBadge(role: 'User', size: RoleBadgeSize.medium),
              ],
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Check that role badges are rendered
      expect(find.byType(RoleBadge), findsNWidgets(4));
      
      // Check role text is displayed
      expect(find.text('Admin'), findsOneWidget);
      expect(find.text('Moderator'), findsOneWidget);
      expect(find.text('Support'), findsOneWidget);
      expect(find.text('User'), findsOneWidget);
    });

    testWidgets('Role guards protect content correctly', (WidgetTester tester) async {
      // Test admin-only content protection
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            currentUserProvider.overrideWith((ref) => const UserModel(
              id: 1,
              email: 'user@example.com',
              currentRole: 'User',
              isActive: true,
            )),
          ],
          child: const MaterialApp(
            home: Scaffold(
              body: AdminOnly(
                child: Text('Admin Content'),
                fallback: Text('Access Denied'),
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // User should see access denied message
      expect(find.text('Access Denied'), findsOneWidget);
      expect(find.text('Admin Content'), findsNothing);

      // Now test with admin user
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            currentUserProvider.overrideWith((ref) => const UserModel(
              id: 1,
              email: 'admin@example.com',
              currentRole: 'Admin',
              isActive: true,
            )),
          ],
          child: const MaterialApp(
            home: Scaffold(
              body: AdminOnly(
                child: Text('Admin Content'),
                fallback: Text('Access Denied'),
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Admin should see protected content
      expect(find.text('Admin Content'), findsOneWidget);
      expect(find.text('Access Denied'), findsNothing);
    });

    testWidgets('Moderator guards work correctly', (WidgetTester tester) async {
      // Test moderator-level protection
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            currentUserProvider.overrideWith((ref) => const UserModel(
              id: 1,
              email: 'user@example.com',
              currentRole: 'User',
              isActive: true,
            )),
          ],
          child: const MaterialApp(
            home: Scaffold(
              body: ModeratorOrAbove(
                child: Text('Moderator Content'),
                fallback: Text('Access Denied'),
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // User should see access denied
      expect(find.text('Access Denied'), findsOneWidget);
      expect(find.text('Moderator Content'), findsNothing);

      // Test with moderator
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            currentUserProvider.overrideWith((ref) => const UserModel(
              id: 1,
              email: 'moderator@example.com',
              currentRole: 'Moderator',
              isActive: true,
            )),
          ],
          child: const MaterialApp(
            home: Scaffold(
              body: ModeratorOrAbove(
                child: Text('Moderator Content'),
                fallback: Text('Access Denied'),
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Moderator should see content
      expect(find.text('Moderator Content'), findsOneWidget);
      expect(find.text('Access Denied'), findsNothing);

      // Test with admin (should also have access)
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            currentUserProvider.overrideWith((ref) => const UserModel(
              id: 1,
              email: 'admin@example.com',
              currentRole: 'Admin',
              isActive: true,
            )),
          ],
          child: const MaterialApp(
            home: Scaffold(
              body: ModeratorOrAbove(
                child: Text('Moderator Content'),
                fallback: Text('Access Denied'),
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Admin should also see content
      expect(find.text('Moderator Content'), findsOneWidget);
      expect(find.text('Access Denied'), findsNothing);
    });

    testWidgets('Role-based content switching works', (WidgetTester tester) async {
      // Test RoleBasedContent widget
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            currentUserProvider.overrideWith((ref) => const UserModel(
              id: 1,
              email: 'admin@example.com',
              currentRole: 'Admin',
              isActive: true,
            )),
          ],
          child: const MaterialApp(
            home: Scaffold(
              body: RoleBasedContent(
                adminContent: Text('Admin Dashboard'),
                moderatorContent: Text('Moderator Panel'),
                supportContent: Text('Support Tools'),
                userContent: Text('User Profile'),
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Admin should see admin content
      expect(find.text('Admin Dashboard'), findsOneWidget);
      expect(find.text('Moderator Panel'), findsNothing);
      expect(find.text('Support Tools'), findsNothing);
      expect(find.text('User Profile'), findsNothing);

      // Test with user role
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            currentUserProvider.overrideWith((ref) => const UserModel(
              id: 1,
              email: 'user@example.com',
              currentRole: 'User',
              isActive: true,
            )),
          ],
          child: const MaterialApp(
            home: Scaffold(
              body: RoleBasedContent(
                adminContent: Text('Admin Dashboard'),
                moderatorContent: Text('Moderator Panel'),
                supportContent: Text('Support Tools'),
                userContent: Text('User Profile'),
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // User should see user content
      expect(find.text('User Profile'), findsOneWidget);
      expect(find.text('Admin Dashboard'), findsNothing);
      expect(find.text('Moderator Panel'), findsNothing);
      expect(find.text('Support Tools'), findsNothing);
    });

    testWidgets('Permission-based access control works', (WidgetTester tester) async {
      // Test permission-based guards
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            currentUserProvider.overrideWith((ref) => const UserModel(
              id: 1,
              email: 'admin@example.com',
              currentRole: 'Admin',
              isActive: true,
            )),
          ],
          child: MaterialApp(
            home: Scaffold(
              body: PermissionGuard(
                permissions: const [AppConstants.permissionManageUsers],
                child: const Text('User Management'),
                fallback: const Text('No Permission'),
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Admin should have permission to manage users
      expect(find.text('User Management'), findsOneWidget);
      expect(find.text('No Permission'), findsNothing);

      // Test with user role (should not have permission)
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            currentUserProvider.overrideWith((ref) => const UserModel(
              id: 1,
              email: 'user@example.com',
              currentRole: 'User',
              isActive: true,
            )),
          ],
          child: MaterialApp(
            home: Scaffold(
              body: PermissionGuard(
                permissions: const [AppConstants.permissionManageUsers],
                child: const Text('User Management'),
                fallback: const Text('No Permission'),
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // User should not have permission
      expect(find.text('No Permission'), findsOneWidget);
      expect(find.text('User Management'), findsNothing);
    });

    testWidgets('Inactive user access is restricted', (WidgetTester tester) async {
      // Test that inactive users are handled properly
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            currentUserProvider.overrideWith((ref) => const UserModel(
              id: 1,
              email: 'admin@example.com',
              currentRole: 'Admin',
              isActive: false, // Inactive user
            )),
          ],
          child: const MaterialApp(
            home: Scaffold(
              body: AdminOnly(
                child: Text('Admin Content'),
                fallback: Text('Access Denied'),
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Even admin role should be denied if inactive
      expect(find.text('Access Denied'), findsOneWidget);
      expect(find.text('Admin Content'), findsNothing);
    });

    testWidgets('Null user is handled correctly', (WidgetTester tester) async {
      // Test null user scenarios
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            currentUserProvider.overrideWith((ref) => null),
          ],
          child: const MaterialApp(
            home: Scaffold(
              body: AdminOnly(
                child: Text('Admin Content'),
                fallback: Text('Please Login'),
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Null user should see fallback
      expect(find.text('Please Login'), findsOneWidget);
      expect(find.text('Admin Content'), findsNothing);
    });

    testWidgets('Role hierarchy is respected', (WidgetTester tester) async {
      // Test that higher roles can access lower role content
      
      // Admin should access all content
      final adminUser = const UserModel(
        id: 1,
        email: 'admin@example.com',
        currentRole: 'Admin',
        isActive: true,
      );

      expect(adminUser.isAdmin, isTrue);
      expect(adminUser.isModerator, isFalse); // Admin is not moderator role but has higher privileges
      expect(adminUser.isSupport, isFalse);
      expect(adminUser.isUser, isFalse);

      // Moderator should not access admin content but should access user content
      final moderatorUser = const UserModel(
        id: 2,
        email: 'moderator@example.com',
        currentRole: 'Moderator',
        isActive: true,
      );

      expect(moderatorUser.isAdmin, isFalse);
      expect(moderatorUser.isModerator, isTrue);
      expect(moderatorUser.isSupport, isFalse);
      expect(moderatorUser.isUser, isFalse);

      // Support should only access support and user content
      final supportUser = const UserModel(
        id: 3,
        email: 'support@example.com',
        currentRole: 'Support',
        isActive: true,
      );

      expect(supportUser.isAdmin, isFalse);
      expect(supportUser.isModerator, isFalse);
      expect(supportUser.isSupport, isTrue);
      expect(supportUser.isUser, isFalse);

      // User should only access user content
      final regularUser = const UserModel(
        id: 4,
        email: 'user@example.com',
        currentRole: 'User',
        isActive: true,
      );

      expect(regularUser.isAdmin, isFalse);
      expect(regularUser.isModerator, isFalse);
      expect(regularUser.isSupport, isFalse);
      expect(regularUser.isUser, isTrue);
    });
  });
}