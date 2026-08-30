import 'package:flutter/material.dart';

import '../extensions/context_extensions.dart';
import '../theme/app_colors.dart';

enum AppButtonStyle { primary, secondary, cancel }

/// Single reusable app button. Use this for all primary actions.
class AppButton extends StatelessWidget {
  const AppButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.btnStyle = AppButtonStyle.primary,
    this.isLoading = false,
    this.isEnabled = true,
    this.isDestructive = false,
    this.expand = true,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final AppButtonStyle btnStyle;
  final bool isLoading;
  final bool isEnabled;
  final bool isDestructive;
  final bool expand;

  @override
  Widget build(BuildContext context) {
    final foreground = isDestructive
        ? AppColors.textPrimary
        : AppColors.onButton;

    final button = FilledButton(
      onPressed: (!isEnabled || isLoading) ? null : onPressed,
      style: getButtonStyle(btnStyle, isDestructive, context),
      child: isLoading
          ? SizedBox(
              height: context.scaleWidth(22),
              width: context.scaleWidth(22),
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: foreground,
              ),
            )
          : icon == null
          ? Text(
              label,
              style: TextStyle(fontSize: context.titleFontSize),
            )
          : Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, size: context.scaleWidth(20)),
                SizedBox(width: context.scaleWidth(8)),
                Text(
                  label,
                  style: TextStyle(fontSize: context.scaleWidth(15)),
                ),
              ],
            ),
    );

    if (!expand) return button;

    return SizedBox(
      width: double.infinity,
      height: context.scaleHeight(48),
      child: button,
    );
  }
}

ButtonStyle primaryButton(bool isDestructive, BuildContext context) {
  final background = isDestructive ? AppColors.error : AppColors.button;
  final foreground = isDestructive ? AppColors.textPrimary : AppColors.onButton;
  return FilledButton.styleFrom(
    backgroundColor: background,
    foregroundColor: foreground,
    disabledBackgroundColor: AppColors.surfaceElevated,
    disabledForegroundColor: AppColors.textHint,
    minimumSize: Size(0, context.scaleHeight(48)),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(context.scaleWidth(50)),
    ),
  );
}

ButtonStyle secondaryButton(bool isDestructive, BuildContext context) {
  final background = isDestructive ? AppColors.error : AppColors.secondaryColor;
  final foreground = isDestructive
      ? AppColors.textPrimary
      : AppColors.textPrimary;
  return FilledButton.styleFrom(
    backgroundColor: background,
    foregroundColor: foreground,
    disabledBackgroundColor: AppColors.surfaceElevated,
    disabledForegroundColor: AppColors.textHint,
    minimumSize: Size(0, context.scaleHeight(48)),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(context.scaleWidth(12)),
    ),
  );
}

ButtonStyle cancelButton(bool isDestructive, BuildContext context) {
  final foreground = isDestructive ? AppColors.error : AppColors.error;
  return FilledButton.styleFrom(
    backgroundColor: Colors.transparent,
    foregroundColor: foreground,
    disabledBackgroundColor: AppColors.surfaceElevated,
    disabledForegroundColor: AppColors.textHint,
    minimumSize: Size(0, context.scaleHeight(48)),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(context.scaleWidth(12)),
      side: BorderSide(color: AppColors.error),
    ),
  );
}

ButtonStyle getButtonStyle(
  AppButtonStyle appButtonStyle,
  bool isDestructive,
  BuildContext context,
) {
  switch (appButtonStyle) {
    case AppButtonStyle.primary:
      return primaryButton(isDestructive, context);
    case AppButtonStyle.secondary:
      return secondaryButton(isDestructive, context);
    case AppButtonStyle.cancel:
      return cancelButton(isDestructive, context);
  }
}
