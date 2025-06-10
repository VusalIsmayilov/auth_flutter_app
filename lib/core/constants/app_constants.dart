class AppConstants {
  // App Information
  static const String appName = 'Secure Auth App';
  static const String appVersion = '1.0.0';
  
  // User Roles
  static const String roleAdmin = 'admin';
  static const String roleUser = 'user';
  static const String roleModerator = 'moderator';
  static const String roleSupport = 'support';
  
  // Role Hierarchies (higher index = more permissions)
  static const List<String> roleHierarchy = [
    roleUser,
    roleSupport,
    roleModerator,
    roleAdmin,
  ];
  
  // Permissions
  static const String permissionViewUsers = 'view_users';
  static const String permissionManageUsers = 'manage_users';
  static const String permissionViewReports = 'view_reports';
  static const String permissionManageSettings = 'manage_settings';
  static const String permissionViewLogs = 'view_logs';
  static const String permissionManageSystem = 'manage_system';
  
  // Role-based permissions mapping
  static const Map<String, List<String>> rolePermissions = {
    roleUser: [],
    roleSupport: [
      permissionViewUsers,
      permissionViewReports,
    ],
    roleModerator: [
      permissionViewUsers,
      permissionManageUsers,
      permissionViewReports,
      permissionViewLogs,
    ],
    roleAdmin: [
      permissionViewUsers,
      permissionManageUsers,
      permissionViewReports,
      permissionManageSettings,
      permissionViewLogs,
      permissionManageSystem,
    ],
  };
  
  // UI Constants
  static const double defaultPadding = 16.0;
  static const double defaultRadius = 8.0;
  static const Duration defaultAnimationDuration = Duration(milliseconds: 300);
  
  // Timeouts
  static const Duration connectionTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);
  static const Duration sendTimeout = Duration(seconds: 30);
  
  // Pagination
  static const int defaultPageSize = 20;
  static const int maxPageSize = 100;
}

class RoleUtils {
  /// Check if a role has higher or equal permissions than another role
  static bool hasEqualOrHigherRole(String userRole, String requiredRole) {
    final userIndex = AppConstants.roleHierarchy.indexOf(userRole);
    final requiredIndex = AppConstants.roleHierarchy.indexOf(requiredRole);
    
    if (userIndex == -1 || requiredIndex == -1) return false;
    
    return userIndex >= requiredIndex;
  }
  
  /// Get all permissions for a list of roles
  static List<String> getPermissionsForRoles(List<String> roles) {
    final permissions = <String>{};
    
    for (final role in roles) {
      final rolePerms = AppConstants.rolePermissions[role] ?? [];
      permissions.addAll(rolePerms);
    }
    
    return permissions.toList();
  }
  
  /// Check if user has a specific permission
  static bool hasPermission(List<String> userRoles, String permission) {
    final userPermissions = getPermissionsForRoles(userRoles);
    return userPermissions.contains(permission);
  }
  
  /// Get the highest role from a list of roles
  static String? getHighestRole(List<String> roles) {
    int highestIndex = -1;
    String? highestRole;
    
    for (final role in roles) {
      final index = AppConstants.roleHierarchy.indexOf(role);
      if (index > highestIndex) {
        highestIndex = index;
        highestRole = role;
      }
    }
    
    return highestRole;
  }
  
  /// Get role display name
  static String getRoleDisplayName(String role) {
    switch (role) {
      case AppConstants.roleAdmin:
        return 'Administrator';
      case AppConstants.roleModerator:
        return 'Moderator';
      case AppConstants.roleSupport:
        return 'Support Agent';
      case AppConstants.roleUser:
        return 'User';
      default:
        return role.substring(0, 1).toUpperCase() + role.substring(1);
    }
  }
  
  /// Get role color
  static String getRoleColor(String role) {
    switch (role) {
      case AppConstants.roleAdmin:
        return '#FF5722'; // Deep Orange
      case AppConstants.roleModerator:
        return '#FF9800'; // Orange
      case AppConstants.roleSupport:
        return '#2196F3'; // Blue
      case AppConstants.roleUser:
        return '#4CAF50'; // Green
      default:
        return '#9E9E9E'; // Grey
    }
  }
}