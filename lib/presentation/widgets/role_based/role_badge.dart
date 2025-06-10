import 'package:flutter/material.dart';
import '../../../core/constants/app_constants.dart';

/// A badge widget that displays a user's role with appropriate styling
class RoleBadge extends StatelessWidget {
  final String role;
  final RoleBadgeSize size;
  final bool showIcon;

  const RoleBadge({
    super.key,
    required this.role,
    this.size = RoleBadgeSize.medium,
    this.showIcon = true,
  });

  @override
  Widget build(BuildContext context) {
    final colorCode = RoleUtils.getRoleColor(role);
    final color = Color(int.parse(colorCode.substring(1), radix: 16) + 0xFF000000);
    final displayName = RoleUtils.getRoleDisplayName(role);
    
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: _getHorizontalPadding(),
        vertical: _getVerticalPadding(),
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(size == RoleBadgeSize.large ? 8 : 6),
        border: Border.all(
          color: color.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (showIcon) ...[
            Icon(
              _getRoleIcon(role),
              size: _getIconSize(),
              color: color,
            ),
            SizedBox(width: _getSpacing()),
          ],
          Text(
            displayName,
            style: TextStyle(
              color: color,
              fontSize: _getFontSize(),
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  IconData _getRoleIcon(String role) {
    switch (role) {
      case AppConstants.roleAdmin:
        return Icons.admin_panel_settings;
      case AppConstants.roleModerator:
        return Icons.shield;
      case AppConstants.roleSupport:
        return Icons.support_agent;
      case AppConstants.roleUser:
        return Icons.person;
      default:
        return Icons.account_circle;
    }
  }

  double _getFontSize() {
    switch (size) {
      case RoleBadgeSize.small:
        return 10;
      case RoleBadgeSize.medium:
        return 12;
      case RoleBadgeSize.large:
        return 14;
    }
  }

  double _getIconSize() {
    switch (size) {
      case RoleBadgeSize.small:
        return 12;
      case RoleBadgeSize.medium:
        return 16;
      case RoleBadgeSize.large:
        return 20;
    }
  }

  double _getHorizontalPadding() {
    switch (size) {
      case RoleBadgeSize.small:
        return 6;
      case RoleBadgeSize.medium:
        return 8;
      case RoleBadgeSize.large:
        return 12;
    }
  }

  double _getVerticalPadding() {
    switch (size) {
      case RoleBadgeSize.small:
        return 2;
      case RoleBadgeSize.medium:
        return 4;
      case RoleBadgeSize.large:
        return 6;
    }
  }

  double _getSpacing() {
    switch (size) {
      case RoleBadgeSize.small:
        return 4;
      case RoleBadgeSize.medium:
        return 6;
      case RoleBadgeSize.large:
        return 8;
    }
  }
}

enum RoleBadgeSize { small, medium, large }

/// Widget that displays multiple role badges
class RoleBadgeList extends StatelessWidget {
  final List<String> roles;
  final RoleBadgeSize size;
  final bool showIcon;
  final int? maxRoles;
  final WrapAlignment alignment;

  const RoleBadgeList({
    super.key,
    required this.roles,
    this.size = RoleBadgeSize.medium,
    this.showIcon = true,
    this.maxRoles,
    this.alignment = WrapAlignment.start,
  });

  @override
  Widget build(BuildContext context) {
    final displayRoles = maxRoles != null && roles.length > maxRoles!
        ? roles.take(maxRoles!).toList()
        : roles;
    
    final hasMore = maxRoles != null && roles.length > maxRoles!;

    return Wrap(
      alignment: alignment,
      spacing: 8,
      runSpacing: 4,
      children: [
        ...displayRoles.map((role) => RoleBadge(
          role: role,
          size: size,
          showIcon: showIcon,
        )),
        if (hasMore)
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: size == RoleBadgeSize.small ? 6 : 8,
              vertical: size == RoleBadgeSize.small ? 2 : 4,
            ),
            decoration: BoxDecoration(
              color: Colors.grey.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(6),
              border: Border.all(
                color: Colors.grey.withValues(alpha: 0.3),
                width: 1,
              ),
            ),
            child: Text(
              '+${roles.length - maxRoles!}',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: size == RoleBadgeSize.small ? 10 : 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
      ],
    );
  }
}

/// Widget that displays the highest role as a badge
class HighestRoleBadge extends StatelessWidget {
  final List<String> roles;
  final RoleBadgeSize size;
  final bool showIcon;

  const HighestRoleBadge({
    super.key,
    required this.roles,
    this.size = RoleBadgeSize.medium,
    this.showIcon = true,
  });

  @override
  Widget build(BuildContext context) {
    final highestRole = RoleUtils.getHighestRole(roles);
    
    if (highestRole == null) {
      return const SizedBox.shrink();
    }

    return RoleBadge(
      role: highestRole,
      size: size,
      showIcon: showIcon,
    );
  }
}