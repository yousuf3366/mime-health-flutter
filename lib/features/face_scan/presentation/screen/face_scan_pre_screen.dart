import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:mime_health/core/extensions/context_extensions.dart';
import 'package:mime_health/core/theme/app_colors.dart';
import 'package:mime_health/core/widgets/app_button.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/localization/l10n_keys.dart';
import '../../../../core/providers/core_providers.dart';
import '../../../../core/router/route_names.dart';
import '../../../language/presentation/provider/language_provider.dart';
import '../../../profile/domain/entity/profile_entity.dart';
import '../../../profile/presentation/provider/profile_provider.dart';
import '../../../subscription/presentation/provider/subscription_provider.dart';
import '../../presentation/screen/face_camera_screen.dart';
import '../provider/face_scan_provider.dart';
import 'face_scan_profile_select_screen.dart';

/// Consent + tips shown before opening the face-scan camera.
class FaceScanPreScreen extends HookConsumerWidget {
  const FaceScanPreScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = ref.watch(languageControllerProvider);
    final flowState = ref.watch(faceScanFlowNotifierProvider);
    final mySubscription = ref.watch(mySubscriptionProvider);
    final dataSharingConsent = useState(true);
    final selectedProfile = ref.watch(faceScanSelectedProfileProvider);

    final hasPlan = mySubscription.maybeWhen(
      data: (data) => data?.hasActivePlan == true,
      orElse: () => false,
    );
    final planLabel = mySubscription.maybeWhen(
      data: (data) {
        if (data?.hasActivePlan != true) return null;
        return data!.subscription.plan.name;
      },
      orElse: () => null,
    );

    // Fresh UI whenever this tab/screen is shown again.
    useEffect(() {
      dataSharingConsent.value = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ref.invalidate(mySubscriptionProvider);
        ref.read(faceScanFlowNotifierProvider.notifier).reset();
      });
      return null;
    }, const []);

    // After a finished/cancelled flow (e.g. questionnaire closed), reset consent.
    ref.listen(faceScanFlowNotifierProvider, (previous, next) {
      if (previous?.isBusy == true && !next.isBusy) {
        dataSharingConsent.value = true;
      }
    });

    Future<void> openPlans() async {
      final saved = await context.push<bool>(RouteNames.subscriptionPlans);
      if (saved == true) {
        ref.invalidate(mySubscriptionProvider);
      }
    }

    return SafeArea(
      child: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(
          context.defaultPaddingSc,
          context.scaleHeight(16),
          context.defaultPaddingSc,
          context.scaleHeight(24),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (selectedProfile != null) ...[
              _SelectedProfileBar(
                profile: selectedProfile,
                changeLabel: l10n.t(L10nKeys.faceScanChangeProfile),
                onChange: flowState.isBusy
                    ? null
                    : () =>
                          ref
                                  .read(
                                    faceScanSelectedProfileProvider.notifier,
                                  )
                                  .state =
                              null,
              ),
              SizedBox(height: context.scaleHeight(12)),
            ],
            _HeroCard(
              title: l10n.t(L10nKeys.faceScanTitle),
              intro: l10n.t(L10nKeys.faceScanIntro),
            ),
            SizedBox(height: context.scaleHeight(16)),
            _TipCard(
              icon: Icons.wb_sunny_outlined,
              title: l10n.t(L10nKeys.faceScanTipLightingTitle),
              body: l10n.t(L10nKeys.faceScanTipLightingBody),
            ),
            SizedBox(height: context.scaleHeight(10)),
            _TipCard(
              icon: Icons.center_focus_strong_outlined,
              title: l10n.t(L10nKeys.faceScanTipHoldStillTitle),
              body: l10n.t(L10nKeys.faceScanTipHoldStillBody),
            ),
            SizedBox(height: context.scaleHeight(10)),
            _TipCard(
              icon: Icons.phonelink_lock_outlined,
              title: l10n.t(L10nKeys.faceScanTipScreenOnTitle),
              body: l10n.t(L10nKeys.faceScanTipScreenOnBody),
            ),
            // SizedBox(height: context.scaleHeight(16)),
            // if (!hasPlan)
            //   _PlanBanner(
            //     message: l10n.t(L10nKeys.faceScanPlanRequired),
            //     actionLabel: l10n.t(L10nKeys.faceScanChoosePlan),
            //     onPressed: flowState.isBusy ? null : openPlans,
            //   )
            // else
            //   _PlanBanner(
            //     message: 'Plan: $planLabel',
            //     actionLabel: l10n.t(L10nKeys.faceScanChoosePlan),
            //     onPressed: flowState.isBusy ? null : openPlans,
            //   ),
            SizedBox(height: context.scaleHeight(16)),
            _ConsentTile(
              value: dataSharingConsent.value,
              prefix: l10n.t(L10nKeys.faceScanDataSharingPrefix),
              linkLabel: l10n.t(L10nKeys.faceScanDataSharingLink),
              onChanged: flowState.isBusy
                  ? null
                  : (value) => dataSharingConsent.value = value,
              onLinkTap: flowState.isBusy
                  ? null
                  : () => context.push(RouteNames.dataSharingConsent),
            ),
            SizedBox(height: context.scaleHeight(16)),
            AppButton(
              label: l10n.t(L10nKeys.faceScanStart),
              icon: Icons.camera_alt_outlined,
              isEnabled: dataSharingConsent.value && !flowState.isBusy,
              isLoading: flowState.isBusy,
              onPressed: () async {
                final profile =
                    selectedProfile ??
                    await () async {
                      final profiles = await ref.read(profilesProvider.future);
                      return profiles.isEmpty
                          ? null
                          : _primaryProfile(profiles);
                    }();
                if (profile == null) {
                  ref
                      .read(snackbarServiceProvider)
                      .showError(l10n.t(L10nKeys.faceRecognitionNoStoredFace));
                  return;
                }
                final storedEmbedding = profile.imageEmbedding?.trim() ?? '';
                final isSelf =
                    profile.profileKind == AppConstants.profileKindSelf;

                // Family/other profiles are created without a face, so only
                // verify when a face is on file; self profiles always need one.
                if (storedEmbedding.isEmpty && isSelf) {
                  ref
                      .read(snackbarServiceProvider)
                      .showError(l10n.t(L10nKeys.faceRecognitionNoStoredFace));
                  return;
                }

                if (storedEmbedding.isNotEmpty) {
                  if (!context.mounted) return;
                  final verified = await Navigator.of(context).push<bool>(
                    MaterialPageRoute(
                      builder: (_) => FaceCameraScreen(
                        mode: FaceCameraMode.verify,
                        storedEmbedding: storedEmbedding,
                      ),
                    ),
                  );
                  if (verified != true || !context.mounted) return;
                }

                final result = await ref
                    .read(faceScanFlowNotifierProvider.notifier)
                    .startScan(forProfile: profile);
                if (!context.mounted) return;
                if (result == FaceScanStartResult.needsPlan) {
                  ref
                      .read(snackbarServiceProvider)
                      .showError(l10n.t(L10nKeys.faceScanUrlFailedMessage));
                  // await openPlans();
                }
              },
            ),
            SizedBox(height: context.scaleHeight(4)),
            TextButton(
              onPressed: flowState.isBusy
                  ? null
                  : () {
                      dataSharingConsent.value = true;
                    },
              child: Text(
                l10n.t(L10nKeys.mediaCancel),
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: context.fontSize,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

ProfileEntity _primaryProfile(List<ProfileEntity> profiles) {
  for (final profile in profiles) {
    if (profile.profileKind == AppConstants.profileKindSelf) {
      return profile;
    }
  }
  return profiles.first;
}

class _SelectedProfileBar extends StatelessWidget {
  const _SelectedProfileBar({
    required this.profile,
    required this.changeLabel,
    required this.onChange,
  });

  final ProfileEntity profile;
  final String changeLabel;
  final VoidCallback? onChange;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        IconButton(
          onPressed: onChange,
          icon: const Icon(Icons.arrow_back),
          color: AppColors.primaryContainer,
          tooltip: changeLabel,
        ),
        ProfileAvatar(
          name: profile.displayName,
          url: profile.avatarPath,
          size: context.scaleWidth(36),
        ),
        SizedBox(width: context.scaleWidth(10)),
        Expanded(
          child: Text(
            profile.displayName,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: context.bodyFontSize,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        TextButton(
          onPressed: onChange,
          child: Text(
            changeLabel,
            style: TextStyle(
              color: AppColors.primaryContainer,
              fontSize: context.smallFontSize,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}

class _PlanBanner extends StatelessWidget {
  const _PlanBanner({
    required this.message,
    required this.actionLabel,
    required this.onPressed,
  });

  final String message;
  final String actionLabel;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(context.scaleWidth(14)),
      decoration: BoxDecoration(
        color: AppColors.glass,
        borderRadius: BorderRadius.circular(context.scaleWidth(16)),
        border: Border.all(color: AppColors.glassBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            message,
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: context.smallFontSize,
              height: 1.35,
            ),
          ),
          SizedBox(height: context.scaleHeight(10)),
          AppButton(
            label: actionLabel,
            icon: Icons.workspace_premium_outlined,
            btnStyle: AppButtonStyle.secondary,
            isEnabled: onPressed != null,
            onPressed: onPressed,
          ),
        ],
      ),
    );
  }
}

class _HeroCard extends StatelessWidget {
  const _HeroCard({required this.title, required this.intro});

  final String title;
  final String intro;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(context.scaleWidth(20)),
      decoration: BoxDecoration(
        color: AppColors.glass,
        borderRadius: BorderRadius.circular(context.scaleWidth(20)),
        border: Border.all(color: AppColors.glassBorder),
      ),
      child: Column(
        children: [
          Icon(
            Icons.face_retouching_natural,
            size: context.scaleWidth(72),
            color: AppColors.primaryContainer,
          ),
          SizedBox(height: context.scaleHeight(16)),
          Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: context.largeFontSize,
              fontWeight: FontWeight.w700,
            ),
          ),
          SizedBox(height: context.scaleHeight(8)),
          Text(
            intro,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: context.fontSize,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}

class _TipCard extends StatelessWidget {
  const _TipCard({required this.icon, required this.title, required this.body});

  final IconData icon;
  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        horizontal: context.scaleWidth(14),
        vertical: context.scaleHeight(12),
      ),
      decoration: BoxDecoration(
        color: AppColors.glass,
        borderRadius: BorderRadius.circular(context.scaleWidth(16)),
        border: Border.all(color: AppColors.glassBorder),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            color: AppColors.primaryContainer,
            size: context.scaleWidth(24),
          ),
          SizedBox(width: context.scaleWidth(12)),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: context.fontSize,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                SizedBox(height: context.scaleHeight(4)),
                Text(
                  body,
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: context.smallFontSize,
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ConsentTile extends StatelessWidget {
  const _ConsentTile({
    required this.value,
    required this.prefix,
    required this.linkLabel,
    required this.onChanged,
    required this.onLinkTap,
  });

  final bool value;
  final String prefix;
  final String linkLabel;
  final ValueChanged<bool>? onChanged;
  final VoidCallback? onLinkTap;

  @override
  Widget build(BuildContext context) {
    final baseStyle = TextStyle(
      color: AppColors.textPrimary,
      fontSize: context.fontSize,
      height: 1.35,
    );

    return InkWell(
      //onTap: onChanged == null ? null : () => onChanged!(!value),
      borderRadius: BorderRadius.circular(context.scaleWidth(12)),
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: context.scaleHeight(4)),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: context.scaleWidth(24),
              height: context.scaleWidth(24),
              child: Checkbox(
                value: value,
                onChanged: onChanged == null
                    ? null
                    : (v) => onChanged!(v ?? false),
                activeColor: AppColors.primaryContainer,
                checkColor: AppColors.onPrimary,
                fillColor: WidgetStateProperty.resolveWith((states) {
                  if (states.contains(WidgetState.selected)) {
                    return AppColors.primaryContainer;
                  }
                  return Colors.transparent;
                }),
                side: BorderSide(
                  color: value
                      ? AppColors.primaryContainer
                      : AppColors.textHint,
                  width: 1.5,
                ),
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
            ),
            SizedBox(width: context.scaleWidth(10)),
            Expanded(
              child: Text.rich(
                TextSpan(
                  style: baseStyle,
                  children: [
                    TextSpan(text: prefix),
                    WidgetSpan(
                      alignment: PlaceholderAlignment.baseline,
                      baseline: TextBaseline.alphabetic,
                      child: GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTap: onLinkTap,
                        child: Text(
                          linkLabel,
                          style: baseStyle.copyWith(
                            color: AppColors.primaryContainer,
                            fontWeight: FontWeight.w600,
                            decoration: TextDecoration.underline,
                            decorationColor: AppColors.primaryContainer,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
