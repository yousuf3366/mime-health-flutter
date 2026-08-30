import 'package:flutter/material.dart';

import '../extensions/context_extensions.dart';
import '../theme/app_colors.dart';

enum AppBottomNavItem {
  home,
  healthHub,
  faceScan,
  trends,
  profile,
}

class AppBottomNavDestination {
  const AppBottomNavDestination({
    required this.item,
    required this.label,
    required this.icon,
  });

  final AppBottomNavItem item;
  final String label;
  final IconData icon;
}

/// Shared bottom navigation bar matching the Health Hub chrome.
class AppBottomNavBar extends StatelessWidget {
  const AppBottomNavBar({
    super.key,
    required this.destinations,
    required this.selected,
    required this.onSelected,
  });

  final List<AppBottomNavDestination> destinations;
  final AppBottomNavItem selected;
  final ValueChanged<AppBottomNavItem> onSelected;

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.paddingOf(context).bottom;

    return Container(
      padding: EdgeInsets.fromLTRB(
        context.scaleWidth(8),
        context.scaleHeight(8),
        context.scaleWidth(8),
        bottom > 0 ? bottom : context.scaleHeight(8),
      ),
      decoration: BoxDecoration(
        color: AppColors.surfaceLow,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(context.scaleWidth(12)),
        ),
        border: const Border(
          top: BorderSide(color: AppColors.outlineVariant),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.35),
            blurRadius: context.scaleWidth(16),
            offset: Offset(0, -context.scaleHeight(4)),
          ),
        ],
      ),
      child: Row(
        children: destinations.map((destination) {
          final isActive = destination.item == selected;
          return Expanded(
            child: _NavItem(
              destination: destination,
              isActive: isActive,
              onTap: () => onSelected(destination.item),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.destination,
    required this.isActive,
    required this.onTap,
  });

  final AppBottomNavDestination destination;
  final bool isActive;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color =
        isActive ? AppColors.primaryContainer : AppColors.textSecondary;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(context.scaleWidth(12)),
        child: Container(
          margin: EdgeInsets.symmetric(horizontal: context.scaleWidth(2)),
          padding: EdgeInsets.symmetric(
            vertical: context.scaleHeight(8),
            horizontal: context.scaleWidth(4),
          ),
          decoration: BoxDecoration(
            color: isActive ? AppColors.pillSelected : Colors.transparent,
            borderRadius: BorderRadius.circular(context.scaleWidth(12)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(destination.icon, color: color, size: context.scaleWidth(24)),
              SizedBox(height: context.scaleHeight(4)),
              Text(
                destination.label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: color,
                  fontSize: context.extraSmallFontSize,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
