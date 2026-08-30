import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../theme/app_colors.dart';

/// Shared app AppBar. Prefer this over raw [AppBar] so color and chrome stay consistent.
class AppAppBar extends StatelessWidget implements PreferredSizeWidget {
  const AppAppBar({
    super.key,
    this.title,
    this.titleWidget,
    this.leading,
    this.actions,
    this.automaticallyImplyLeading = true,
    this.centerTitle = true,
    this.backgroundColor,
    this.bottomRadius = 16,
    this.onBack,
  });

  /// Plain title text. Ignored when [titleWidget] is set.
  final String? title;

  /// Custom title widget (takes precedence over [title]).
  final Widget? titleWidget;

  final Widget? leading;
  final List<Widget>? actions;
  final bool automaticallyImplyLeading;
  final bool centerTitle;
  final Color? backgroundColor;
  final double bottomRadius;

  /// Called when the default back button is pressed.
  /// Defaults to [Navigator.maybePop].
  final VoidCallback? onBack;

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    final canPop = Navigator.of(context).canPop();
    final Widget? resolvedLeading = leading ??
        (automaticallyImplyLeading && canPop
            ? IconButton(
                onPressed: onBack ?? () => Navigator.of(context).maybePop(),
                icon: const Icon(Icons.arrow_back_ios_new_rounded),
              )
            : null);

    return AppBar(
      title: titleWidget ?? (title == null ? null : Text(title!)),
      leading: resolvedLeading,
      automaticallyImplyLeading: false,
      actions: actions,
      centerTitle: centerTitle,
      backgroundColor: backgroundColor ?? AppColors.backgroundDeep,
      foregroundColor: AppColors.textPrimary,
      elevation: 0,
      scrolledUnderElevation: 0,
      surfaceTintColor: Colors.transparent,
      iconTheme: const IconThemeData(color: AppColors.icon),
      actionsIconTheme: const IconThemeData(color: AppColors.icon),
      systemOverlayStyle: SystemUiOverlayStyle.light,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(bottomRadius),
          bottomRight: Radius.circular(bottomRadius),
        ),
      ),
    );
  }
}
