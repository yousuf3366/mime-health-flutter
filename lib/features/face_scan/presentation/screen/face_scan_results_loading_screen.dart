import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:mime_health/core/extensions/context_extensions.dart';
import 'package:mime_health/core/theme/app_colors.dart';

import '../../../../core/localization/l10n_keys.dart';
import '../../../language/presentation/provider/language_provider.dart';

/// Full-screen wait state after face scan, before store + dashboard.
class FaceScanResultsLoadingScreen extends ConsumerStatefulWidget {
  const FaceScanResultsLoadingScreen({super.key});

  @override
  ConsumerState<FaceScanResultsLoadingScreen> createState() =>
      _FaceScanResultsLoadingScreenState();
}

class _FaceScanResultsLoadingScreenState
    extends ConsumerState<FaceScanResultsLoadingScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _spin;

  @override
  void initState() {
    super.initState();
    _spin = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();
  }

  @override
  void dispose() {
    _spin.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = ref.watch(languageControllerProvider);

    return PopScope(
      canPop: false,
      child: Scaffold(
        backgroundColor: AppColors.backgroundDeep,
        body: SafeArea(
          child: Center(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: context.scaleWidth(32)),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  RotationTransition(
                    turns: _spin,
                    child: Image.asset(
                      'assets/images/health_result_loading_icon.png',
                      width: context.scaleWidth(72),
                      height: context.scaleWidth(72),
                      fit: BoxFit.contain,
                    ),
                  ),
                  SizedBox(height: context.scaleHeight(28)),
                  Text(
                    l10n.t(L10nKeys.faceScanResultsLoadingTitle),
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: context.titleFontSize,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  SizedBox(height: context.scaleHeight(8)),
                  Text(
                    l10n.t(L10nKeys.faceScanResultsLoadingSubtitle),
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: context.fontSize,
                      height: 1.35,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
