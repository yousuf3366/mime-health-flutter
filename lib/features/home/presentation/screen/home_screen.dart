import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:mime_health/core/constants/app_constants.dart';
import 'package:mime_health/core/error/exceptions.dart';
import 'package:mime_health/core/extensions/context_extensions.dart';
import 'package:mime_health/core/providers/core_providers.dart';
import 'package:mime_health/core/theme/app_colors.dart';
import 'package:mime_health/core/widgets/app_button.dart';

import '../../../../core/localization/l10n_keys.dart';
import '../../../../core/router/route_names.dart';
import '../../../feedback/presentation/widget/feedback_dialog.dart';
import '../../../language/presentation/provider/language_provider.dart';
import '../../../login/presentation/controller/login_form_notifier.dart';
import '../../../login/presentation/provider/login_di.dart';
import '../../../profile/presentation/provider/profile_di.dart';

/// Health Hub tab content (branding + static home background).
///
/// Loads profiles on entry. If none exist, navigates to create-profile.
class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = ref.watch(languageControllerProvider);
    final profilesAsync = ref.watch(profilesProvider);

    ref.listen(profilesProvider, (previous, next) {
      next.whenData((profiles) {
        if (profiles.isEmpty && context.mounted) {
          context.go(RouteNames.createProfile);
        }
      });
    });

    return profilesAsync.when(
      loading: () => const Center(
        child: CircularProgressIndicator(color: AppColors.primaryContainer),
      ),
      error: (error, _) => _ProfilesErrorBody(
        message: error is AppException
            ? error.message
            : l10n.t(L10nKeys.genericError),
        onRetry: () => ref.invalidate(profilesProvider),
      ),
      data: (profiles) {
        if (profiles.isEmpty) {
          // Keep a brief loader while [ref.listen] redirects to create-profile.
          return const Center(
            child: CircularProgressIndicator(color: AppColors.primaryContainer),
          );
        }

        return Stack(
          fit: StackFit.expand,
          children: [
            Image.asset(AppConstants.homeBackgroundImage, fit: BoxFit.cover),
            Column(
              children: [
                _HomeTopBar(
                  title: l10n.t(
                    L10nKeys.homeHubTitle,
                    fallback: AppConstants.brandName,
                  ),
                  logoutLabel: l10n.t(L10nKeys.logout),
                  feedbackLabel: l10n.t(L10nKeys.feedbackTooltip),
                  languageLabel: l10n.t(L10nKeys.language),
                  englishLabel: l10n.t(L10nKeys.languageEn),
                  banglaLabel: l10n.t(L10nKeys.languageBn),
                  currentLanguageCode: l10n.entity.code,
                  onLogout: () => _logout(context, ref),
                  onFeedback: () => showFeedbackDialog(context),
                  onLanguageChanged: (code) {
                    ref
                        .read(languageControllerProvider.notifier)
                        .changeLanguage(code);
                  },
                ),
                Expanded(
                  child: SingleChildScrollView(
                    padding: EdgeInsets.fromLTRB(
                      context.defaultPaddingSc,
                      context.scaleHeight(8),
                      context.defaultPaddingSc,
                      context.scaleHeight(24),
                    ),
                    child: _BrandingHeader(
                      headline: l10n.t(L10nKeys.homeHubHeadline),
                      subtitle: l10n.t(L10nKeys.homeHubSubtitle),
                    ),
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  Future<void> _logout(BuildContext context, WidgetRef ref) async {
    final l10n = ref.read(languageControllerProvider);
    final dialog = ref.read(dialogServiceProvider);
    final snackbar = ref.read(snackbarServiceProvider);

    final confirmed = await dialog.confirmationDialog(
      title: l10n.t(L10nKeys.logoutConfirmTitle),
      message: l10n.t(L10nKeys.logoutConfirmMessage),
      confirmLabel: l10n.t(L10nKeys.logout),
      isDestructive: true,
    );
    if (!confirmed) return;

    dialog.showLoading();
    final result = await ref.read(logoutUseCaseProvider).call();
    dialog.hideLoading();

    result.when(
      success: (_) {
        ref.read(loginFormNotifierProvider.notifier).resetState();
        ref.invalidate(profilesProvider);
        snackbar.showInfo(l10n.t(L10nKeys.logout));
        if (context.mounted) context.go(RouteNames.login);
      },
      failure: (error) => snackbar.showError(error.message),
    );
  }
}

class _ProfilesErrorBody extends ConsumerWidget {
  const _ProfilesErrorBody({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = ref.watch(languageControllerProvider);

    return Center(
      child: Padding(
        padding: EdgeInsets.all(context.defaultPaddingSc),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppColors.textPrimary),
            ),
            SizedBox(height: context.scaleHeight(16)),
            AppButton(
              label: l10n.t(L10nKeys.retry),
              onPressed: onRetry,
              btnStyle: AppButtonStyle.secondary,
            ),
          ],
        ),
      ),
    );
  }
}

class _HomeTopBar extends StatelessWidget {
  const _HomeTopBar({
    required this.title,
    required this.logoutLabel,
    required this.feedbackLabel,
    required this.languageLabel,
    required this.englishLabel,
    required this.banglaLabel,
    required this.currentLanguageCode,
    required this.onLogout,
    required this.onFeedback,
    required this.onLanguageChanged,
  });

  final String title;
  final String logoutLabel;
  final String feedbackLabel;
  final String languageLabel;
  final String englishLabel;
  final String banglaLabel;
  final String currentLanguageCode;
  final VoidCallback onLogout;
  final VoidCallback onFeedback;
  final ValueChanged<String> onLanguageChanged;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          context.scaleWidth(8),
          context.scaleHeight(8),
          context.scaleWidth(8),
          context.defaultPaddingSc,
        ),
        child: Row(
          children: [
            IconButton(
              onPressed: onLogout,
              tooltip: logoutLabel,
              icon: const Icon(Icons.logout),
              color: AppColors.primaryContainer,
            ),
            Expanded(
              child: Text(
                title,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: AppColors.primaryContainer,
                  fontSize: context.titleFontSize,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.2,
                ),
              ),
            ),
            IconButton(
              onPressed: onFeedback,
              tooltip: feedbackLabel,
              icon: const Icon(Icons.feedback_outlined),
              color: AppColors.primaryContainer,
            ),
            PopupMenuButton<String>(
              initialValue: currentLanguageCode,
              tooltip: languageLabel,
              icon: const Icon(
                Icons.language,
                color: AppColors.primaryContainer,
              ),
              onSelected: onLanguageChanged,
              itemBuilder: (context) => [
                CheckedPopupMenuItem(
                  value: 'en',
                  checked: currentLanguageCode == 'en',
                  child: Text(englishLabel),
                ),
                CheckedPopupMenuItem(
                  value: 'bn',
                  checked: currentLanguageCode == 'bn',
                  child: Text(banglaLabel),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _BrandingHeader extends StatelessWidget {
  const _BrandingHeader({required this.headline, required this.subtitle});

  final String headline;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              AppConstants.appFullIcon,
              //width: context.scaleWidth(56),
              height: context.scaleWidth(56),
              fit: BoxFit.contain,
            ),
          ],
        ),
        SizedBox(height: context.scaleHeight(50)),
        Text(
          headline,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: context.scaleWidth(28),
            fontWeight: FontWeight.w700,
            height: 1.15,
          ),
        ),
        SizedBox(height: context.scaleHeight(12)),
        ConstrainedBox(
          constraints: BoxConstraints(maxWidth: context.scaleWidth(280)),
          child: Text(
            subtitle,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: context.bodyFontSize,
              height: 1.45,
            ),
          ),
        ),
      ],
    );
  }
}
