import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:mime_health/core/constants/app_constants.dart';
import 'package:mime_health/core/error/exceptions.dart';
import 'package:mime_health/core/extensions/context_extensions.dart';
import 'package:mime_health/core/theme/app_colors.dart';
import 'package:mime_health/core/widgets/app_button.dart';

import '../../../../core/localization/l10n_keys.dart';
import '../../../face_scan/presentation/provider/face_scan_di.dart';
import '../../../face_scan/presentation/screen/face_scan_health_dashboard_screen.dart';
import '../../../language/presentation/provider/language_provider.dart';
import '../../../profile/domain/entity/profile_entity.dart';
import '../../../profile/presentation/provider/profile_di.dart';

/// Health Hub tab — loads latest Mime scan and shows the results dashboard.
class HealthHubScreen extends ConsumerWidget {
  const HealthHubScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = ref.watch(languageControllerProvider);
    final profilesAsync = ref.watch(profilesProvider);
    final latestAsync = ref.watch(latestMimeScanProvider);

    final displayName = profilesAsync.maybeWhen(
      data: (profiles) => _primaryProfile(profiles)?.displayName ?? 'there',
      orElse: () => 'there',
    );

    return latestAsync.when(
      loading: () => const Center(
        child: CircularProgressIndicator(color: AppColors.primaryContainer),
      ),
      error: (error, _) => _HubMessageBody(
        icon: Icons.error_outline,
        message: error is AppException
            ? error.message
            : l10n.t(L10nKeys.genericError),
        actionLabel: l10n.t(L10nKeys.retry),
        onAction: () => ref.invalidate(latestMimeScanProvider),
      ),
      data: (vitals) {
        if (vitals == null) {
          return _HubMessageBody(
            icon: Icons.monitor_heart_outlined,
            message: l10n.t(L10nKeys.healthHubNoScan),
            actionLabel: l10n.t(L10nKeys.retry),
            onAction: () => ref.invalidate(latestMimeScanProvider),
          );
        }
        return FaceScanHealthDashboardScreen(
          vitals: vitals,
          displayName: displayName,
          showCloseAction: false,
        );
      },
    );
  }

  ProfileEntity? _primaryProfile(List<ProfileEntity> profiles) {
    if (profiles.isEmpty) return null;
    for (final profile in profiles) {
      if (profile.profileKind == AppConstants.profileKindSelf) {
        return profile;
      }
    }
    return profiles.first;
  }
}

class _HubMessageBody extends StatelessWidget {
  const _HubMessageBody({
    required this.icon,
    required this.message,
    required this.actionLabel,
    required this.onAction,
  });

  final IconData icon;
  final String message;
  final String actionLabel;
  final VoidCallback onAction;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Center(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: context.scaleWidth(24)),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 48, color: AppColors.primaryContainer),
              SizedBox(height: context.scaleHeight(12)),
              Text(
                message,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: context.fontSize,
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: context.scaleHeight(16)),
              AppButton(
                expand: false,
                label: actionLabel,
                onPressed: onAction,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
