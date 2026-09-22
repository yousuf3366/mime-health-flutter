import 'package:flutter/material.dart';
import 'package:mime_health/core/extensions/context_extensions.dart';
import 'package:mime_health/core/theme/app_colors.dart';

/// Reusable warning / disclaimer card used for medical notices and similar alerts.
class AppWarningCard extends StatelessWidget {
  const AppWarningCard({
    super.key,
    required this.message,
    this.icon = Icons.warning_amber_rounded,
  });

  final String message;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        horizontal: context.scaleWidth(12),
        vertical: context.scaleHeight(10),
      ),
      decoration: BoxDecoration(
        color: AppColors.warning.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(context.scaleWidth(12)),
        border: Border.all(
          color: AppColors.warning.withValues(alpha: 0.45),
          width: 0.8,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            size: context.scaleWidth(22),
            color: AppColors.warning,
          ),
          SizedBox(width: context.scaleWidth(10)),
          Expanded(
            child: Text(
              message,
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: context.extraSmallFontSize,
                height: 1.35,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
