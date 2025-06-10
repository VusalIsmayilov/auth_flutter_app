import 'package:flutter_test/flutter_test.dart';
import 'package:auth_flutter_app/core/constants/app_constants.dart';

void main() {
  group('RoleUtils', () {
    group('hasEqualOrHigherRole', () {
      test('should return true when user role is higher than required role', () {
        // arrange
        const userRole = AppConstants.roleAdmin;
        const requiredRole = AppConstants.roleUser;

        // act
        final result = RoleUtils.hasEqualOrHigherRole(userRole, requiredRole);

        // assert
        expect(result, true);
      });

      test('should return true when user role equals required role', () {
        // arrange
        const userRole = AppConstants.roleUser;
        const requiredRole = AppConstants.roleUser;

        // act
        final result = RoleUtils.hasEqualOrHigherRole(userRole, requiredRole);

        // assert
        expect(result, true);
      });

      test('should return false when user role is lower than required role', () {
        // arrange
        const userRole = AppConstants.roleUser;
        const requiredRole = AppConstants.roleAdmin;

        // act
        final result = RoleUtils.hasEqualOrHigherRole(userRole, requiredRole);

        // assert
        expect(result, false);
      });

      test('should return false when user role does not exist in hierarchy', () {
        // arrange
        const userRole = 'invalid_role';
        const requiredRole = AppConstants.roleUser;

        // act
        final result = RoleUtils.hasEqualOrHigherRole(userRole, requiredRole);

        // assert
        expect(result, false);
      });

      test('should return false when required role does not exist in hierarchy', () {
        // arrange
        const userRole = AppConstants.roleUser;
        const requiredRole = 'invalid_role';

        // act
        final result = RoleUtils.hasEqualOrHigherRole(userRole, requiredRole);

        // assert
        expect(result, false);
      });
    });

    group('getPermissionsForRoles', () {
      test('should return correct permissions for admin role', () {
        // arrange
        const roles = [AppConstants.roleAdmin];

        // act
        final result = RoleUtils.getPermissionsForRoles(roles);

        // assert
        expect(result, contains(AppConstants.permissionViewUsers));
        expect(result, contains(AppConstants.permissionManageUsers));
        expect(result, contains(AppConstants.permissionViewReports));
        expect(result, contains(AppConstants.permissionManageSettings));
        expect(result, contains(AppConstants.permissionViewLogs));
        expect(result, contains(AppConstants.permissionManageSystem));
      });

      test('should return correct permissions for user role', () {
        // arrange
        const roles = [AppConstants.roleUser];

        // act
        final result = RoleUtils.getPermissionsForRoles(roles);

        // assert
        expect(result, isEmpty);
      });

      test('should return combined permissions for multiple roles', () {
        // arrange
        const roles = [AppConstants.roleUser, AppConstants.roleSupport];

        // act
        final result = RoleUtils.getPermissionsForRoles(roles);

        // assert
        expect(result, contains(AppConstants.permissionViewUsers));
        expect(result, contains(AppConstants.permissionViewReports));
        expect(result.length, 2);
      });

      test('should handle empty roles list', () {
        // arrange
        const roles = <String>[];

        // act
        final result = RoleUtils.getPermissionsForRoles(roles);

        // assert
        expect(result, isEmpty);
      });

      test('should handle invalid roles', () {
        // arrange
        const roles = ['invalid_role'];

        // act
        final result = RoleUtils.getPermissionsForRoles(roles);

        // assert
        expect(result, isEmpty);
      });
    });

    group('hasPermission', () {
      test('should return true when user has the required permission', () {
        // arrange
        const userRoles = [AppConstants.roleModerator];
        const permission = AppConstants.permissionViewUsers;

        // act
        final result = RoleUtils.hasPermission(userRoles, permission);

        // assert
        expect(result, true);
      });

      test('should return false when user does not have the required permission', () {
        // arrange
        const userRoles = [AppConstants.roleUser];
        const permission = AppConstants.permissionViewUsers;

        // act
        final result = RoleUtils.hasPermission(userRoles, permission);

        // assert
        expect(result, false);
      });

      test('should return true when user has permission through multiple roles', () {
        // arrange
        const userRoles = [AppConstants.roleUser, AppConstants.roleSupport];
        const permission = AppConstants.permissionViewReports;

        // act
        final result = RoleUtils.hasPermission(userRoles, permission);

        // assert
        expect(result, true);
      });
    });

    group('getHighestRole', () {
      test('should return admin when roles include admin', () {
        // arrange
        const roles = [AppConstants.roleUser, AppConstants.roleAdmin, AppConstants.roleSupport];

        // act
        final result = RoleUtils.getHighestRole(roles);

        // assert
        expect(result, AppConstants.roleAdmin);
      });

      test('should return moderator when admin is not present', () {
        // arrange
        const roles = [AppConstants.roleUser, AppConstants.roleModerator, AppConstants.roleSupport];

        // act
        final result = RoleUtils.getHighestRole(roles);

        // assert
        expect(result, AppConstants.roleModerator);
      });

      test('should return user for single user role', () {
        // arrange
        const roles = [AppConstants.roleUser];

        // act
        final result = RoleUtils.getHighestRole(roles);

        // assert
        expect(result, AppConstants.roleUser);
      });

      test('should return null for empty roles list', () {
        // arrange
        const roles = <String>[];

        // act
        final result = RoleUtils.getHighestRole(roles);

        // assert
        expect(result, null);
      });

      test('should return null for roles not in hierarchy', () {
        // arrange
        const roles = ['invalid_role', 'another_invalid_role'];

        // act
        final result = RoleUtils.getHighestRole(roles);

        // assert
        expect(result, null);
      });
    });

    group('getRoleDisplayName', () {
      test('should return correct display names for known roles', () {
        expect(RoleUtils.getRoleDisplayName(AppConstants.roleAdmin), 'Administrator');
        expect(RoleUtils.getRoleDisplayName(AppConstants.roleModerator), 'Moderator');
        expect(RoleUtils.getRoleDisplayName(AppConstants.roleSupport), 'Support Agent');
        expect(RoleUtils.getRoleDisplayName(AppConstants.roleUser), 'User');
      });

      test('should return capitalized role name for unknown roles', () {
        // arrange
        const unknownRole = 'custom_role';

        // act
        final result = RoleUtils.getRoleDisplayName(unknownRole);

        // assert
        expect(result, 'Custom_role');
      });
    });

    group('getRoleColor', () {
      test('should return correct colors for known roles', () {
        expect(RoleUtils.getRoleColor(AppConstants.roleAdmin), '#FF5722');
        expect(RoleUtils.getRoleColor(AppConstants.roleModerator), '#FF9800');
        expect(RoleUtils.getRoleColor(AppConstants.roleSupport), '#2196F3');
        expect(RoleUtils.getRoleColor(AppConstants.roleUser), '#4CAF50');
      });

      test('should return default grey color for unknown roles', () {
        // arrange
        const unknownRole = 'custom_role';

        // act
        final result = RoleUtils.getRoleColor(unknownRole);

        // assert
        expect(result, '#9E9E9E');
      });
    });
  });
}