import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:mime_health/core/config/app_config.dart';
import 'package:mime_health/core/extensions/context_extensions.dart';
import 'package:mime_health/core/theme/app_colors.dart';
import 'package:mime_health/core/widgets/app_button.dart';
import 'package:mime_health/core/widgets/app_network_image.dart';

import '../../../../core/localization/l10n_keys.dart';
import '../../../language/presentation/provider/language_provider.dart';
import '../../domain/entity/subscription_entity.dart';
import '../provider/subscription_provider.dart';

/// Lists Mime subscription plans and submits the user's selection.
class SubscriptionPlansScreen extends ConsumerWidget {
  const SubscriptionPlansScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = ref.watch(languageControllerProvider);
    final state = ref.watch(subscriptionPlansNotifierProvider);
    final notifier = ref.read(subscriptionPlansNotifierProvider.notifier);

    Future<void> selectAndSubmit(SubscriptionPlanEntity plan) async {
      notifier.selectPlanCode(plan.code);
      final ok = await notifier.submitSelectedPlan();
      if (ok && context.mounted) {
        context.pop(true);
      }
    }

    return Scaffold(
      backgroundColor: AppColors.backgroundDeep,
      body: SafeArea(
        child: Column(
          children: [
            _PackagesTopBar(
              onBack: () => context.pop(),
              onClose: () => context.pop(false),
            ),
            if (!state.isLoading &&
                !(state.errorMessage != null && state.plans.isEmpty))
              Padding(
                padding: EdgeInsets.fromLTRB(
                  context.defaultPaddingSc,
                  context.scaleHeight(4),
                  context.defaultPaddingSc,
                  context.scaleHeight(12),
                ),
                child: _BillingToggle(
                  value: state.billingInterval,
                  monthlyLabel: l10n.t(L10nKeys.subscriptionMonthly),
                  annualLabel: l10n.t(L10nKeys.subscriptionAnnual),
                  onChanged: notifier.setBillingInterval,
                ),
              ),
            Expanded(
              child: state.isLoading
                  ? const Center(
                      child: CircularProgressIndicator(
                        color: AppColors.primaryContainer,
                      ),
                    )
                  : state.errorMessage != null && state.plans.isEmpty
                  ? _ErrorBody(
                      message: state.errorMessage!,
                      onRetry: notifier.loadPlans,
                      retryLabel: l10n.t(L10nKeys.retry),
                    )
                  : ListView.separated(
                      padding: EdgeInsets.fromLTRB(
                        context.defaultPaddingSc,
                        context.scaleHeight(4),
                        context.defaultPaddingSc,
                        context.scaleHeight(28),
                      ),
                      itemCount: state.plans.length,
                      separatorBuilder: (_, _) =>
                          SizedBox(height: context.scaleHeight(24)),
                      itemBuilder: (context, index) {
                        final plan = state.plans[index];
                        final selected = plan.code == state.selectedPlanCode;
                        return _PackageSection(
                          plan: plan,
                          selected: selected,
                          billingInterval: state.billingInterval,
                          unlimitedLabel: l10n.t(
                            L10nKeys.subscriptionUnlimited,
                          ),
                          profilesLabel: l10n.t(L10nKeys.subscriptionProfiles),
                          scansLabel: l10n.t(L10nKeys.subscriptionScans),
                          trialLabel: l10n.t(L10nKeys.subscriptionTrial),
                          biomarkersLabel: l10n.t(
                            L10nKeys.subscriptionBiomarkers,
                          ),
                          devicesLabel: l10n.t(L10nKeys.subscriptionDevices),
                          payNowLabel: l10n.t(L10nKeys.subscriptionPayNow),
                          headingTemplate: l10n.t(
                            L10nKeys.subscriptionHealthCheckup,
                          ),
                          monthlyLabel: l10n.t(L10nKeys.subscriptionMonthly),
                          annualLabel: l10n.t(L10nKeys.subscriptionAnnual),
                          isSubmitting: state.isSubmitting && selected,
                          onTap: state.isSubmitting
                              ? null
                              : () => selectAndSubmit(plan),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PackagesTopBar extends StatelessWidget {
  const _PackagesTopBar({required this.onBack, required this.onClose});

  final VoidCallback onBack;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: context.scaleWidth(4),
        vertical: context.scaleHeight(4),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            onPressed: onBack,
            icon: const Icon(Icons.arrow_back),
            color: AppColors.textPrimary,
            tooltip: MaterialLocalizations.of(context).backButtonTooltip,
          ),
          IconButton(
            onPressed: onClose,
            icon: const Icon(Icons.close),
            color: AppColors.textPrimary,
            tooltip: MaterialLocalizations.of(context).closeButtonTooltip,
          ),
        ],
      ),
    );
  }
}

class _BillingToggle extends StatelessWidget {
  const _BillingToggle({
    required this.value,
    required this.monthlyLabel,
    required this.annualLabel,
    required this.onChanged,
  });

  final BillingInterval value;
  final String monthlyLabel;
  final String annualLabel;
  final ValueChanged<BillingInterval> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(context.scaleWidth(4)),
      decoration: BoxDecoration(
        color: AppColors.backgroundDeep,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: AppColors.glassBorder, width: 0.5),
      ),
      child: Row(
        children: [
          Expanded(
            child: _Segment(
              label: monthlyLabel,
              selected: value == BillingInterval.monthly,
              onTap: () => onChanged(BillingInterval.monthly),
            ),
          ),
          Expanded(
            child: _Segment(
              label: annualLabel,
              selected: value == BillingInterval.annual,
              onTap: () => onChanged(BillingInterval.annual),
            ),
          ),
        ],
      ),
    );
  }
}

class _Segment extends StatelessWidget {
  const _Segment({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: EdgeInsets.symmetric(vertical: context.scaleHeight(10)),
          decoration: BoxDecoration(
            color: selected ? AppColors.pillSelected : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: TextStyle(
              color: selected ? AppColors.textPrimary : AppColors.textSecondary,
              fontSize: context.fontSize,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}

class _PackageSection extends StatelessWidget {
  const _PackageSection({
    required this.plan,
    required this.selected,
    required this.billingInterval,
    required this.unlimitedLabel,
    required this.profilesLabel,
    required this.scansLabel,
    required this.trialLabel,
    required this.biomarkersLabel,
    required this.devicesLabel,
    required this.payNowLabel,
    required this.headingTemplate,
    required this.monthlyLabel,
    required this.annualLabel,
    required this.isSubmitting,
    required this.onTap,
  });

  final SubscriptionPlanEntity plan;
  final bool selected;
  final BillingInterval billingInterval;
  final String unlimitedLabel;
  final String profilesLabel;
  final String scansLabel;
  final String trialLabel;
  final String biomarkersLabel;
  final String devicesLabel;
  final String payNowLabel;
  final String headingTemplate;
  final String monthlyLabel;
  final String annualLabel;
  final bool isSubmitting;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final price = plan.priceFor(billingInterval);
    final quota = plan.monthlyScanQuota == null
        ? unlimitedLabel
        : '${plan.monthlyScanQuota}';
    final period = billingInterval == BillingInterval.annual
        ? annualLabel
        : monthlyLabel;
    final deviceCount =
        plan.includedPrimaryDevices + plan.includedSecondaryDevices;
    final features = <_PackageFeatureData>[
      _PackageFeatureData(value: quota, template: scansLabel),
      _PackageFeatureData(
        value: '${plan.biomarkerCodes.length}',
        template: biomarkersLabel,
      ),
      if (plan.maxProfiles > 1)
        _PackageFeatureData(
          value: '${plan.maxProfiles}',
          template: profilesLabel,
        ),
      if (deviceCount > 0)
        _PackageFeatureData(value: '$deviceCount', template: devicesLabel),
      if (plan.trialDays > 0)
        _PackageFeatureData(
          value: '${plan.trialDays}',
          template: trialLabel,
          placeholder: '{days}',
        ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(left: context.scaleWidth(8)),
          child: Text(
            headingTemplate.replaceAll('{name}', plan.name).toUpperCase(),
            style: TextStyle(
              color: AppColors.primaryContainer,
              fontSize: context.smallFontSize,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.1,
            ),
          ),
        ),
        SizedBox(height: context.scaleHeight(10)),
        Container(
          width: double.infinity,
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: selected ? AppColors.primaryContainer : Colors.transparent,
              width: selected ? 2 : 0,
            ),
            boxShadow: const [
              BoxShadow(
                color: Color(0x33000000),
                blurRadius: 14,
                offset: Offset(0, 7),
              ),
            ],
          ),
          child: Stack(
            children: [
              Positioned.fill(child: _PackageArtwork(imageUrl: plan.image)),
              const Positioned.fill(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                      colors: [
                        Colors.white,
                        Colors.white,
                        Color(0xE6FFFFFF),
                        Color(0x00FFFFFF),
                      ],
                      stops: [0, 0.46, 0.68, 0.9],
                    ),
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.all(context.scaleWidth(18)),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 64,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            plan.name,
                            style: TextStyle(
                              color: const Color(0xFF0F172A),
                              fontSize: context.titleFontSize,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          SizedBox(height: context.scaleHeight(4)),
                          Text(
                            '৳$price / ${period.toLowerCase()}',
                            style: TextStyle(
                              color: const Color(0xFF334155),
                              fontSize: context.smallFontSize,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          SizedBox(height: context.scaleHeight(12)),
                          ...features.map(
                            (feature) => Padding(
                              padding: EdgeInsets.only(
                                bottom: context.scaleHeight(4),
                              ),
                              child: _PackageFeature(feature: feature),
                            ),
                          ),
                          SizedBox(height: context.scaleHeight(14)),
                          _PayNowButton(
                            label: payNowLabel,
                            isLoading: isSubmitting,
                            onPressed: onTap,
                          ),
                        ],
                      ),
                    ),
                    const Expanded(flex: 36, child: SizedBox.shrink()),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _PackageFeatureData {
  const _PackageFeatureData({
    required this.value,
    required this.template,
    this.placeholder = '{count}',
  });

  final String value;
  final String template;
  final String placeholder;
}

class _PackageFeature extends StatelessWidget {
  const _PackageFeature({required this.feature});

  final _PackageFeatureData feature;

  @override
  Widget build(BuildContext context) {
    final placeholderIndex = feature.template.indexOf(feature.placeholder);
    final prefix = placeholderIndex < 0
        ? ''
        : feature.template.substring(0, placeholderIndex);
    final suffix = placeholderIndex < 0
        ? feature.template
        : feature.template.substring(
            placeholderIndex + feature.placeholder.length,
          );
    return Text.rich(
      TextSpan(
        style: TextStyle(
          color: const Color(0xFF475569),
          fontSize: context.extraSmallFontSize,
          fontWeight: FontWeight.w500,
          height: 1.25,
        ),
        children: [
          if (prefix.isNotEmpty) TextSpan(text: prefix),
          TextSpan(
            text: feature.value,
            style: const TextStyle(
              color: Color(0xFF0F172A),
              fontWeight: FontWeight.w800,
            ),
          ),
          if (suffix.isNotEmpty) TextSpan(text: suffix),
        ],
      ),
    );
  }
}

class _PackageArtwork extends StatelessWidget {
  const _PackageArtwork({required this.imageUrl});

  static const _fallbackAsset = 'assets/images/health_plan_default.png';

  final String? imageUrl;

  @override
  Widget build(BuildContext context) {
    Widget fallback() => Image.asset(
      _fallbackAsset,
      width: double.infinity,
      height: double.infinity,
      fit: BoxFit.cover,
    );

    final url = imageUrl?.trim();
    if (url == null || url.isEmpty) return fallback();
    final uri = Uri.tryParse(url);
    final resolvedUrl = uri?.hasScheme == true
        ? url
        : '${AppConfig.baseUrl.replaceAll(RegExp(r'/+$'), '')}/'
              '${url.replaceFirst(RegExp(r'^/+'), '')}';

    return AppNetworkImage(
      resolvedUrl,
      width: double.infinity,
      height: double.infinity,
      fit: BoxFit.cover,
      errorBuilder: (_, _, _) => fallback(),
      loadingBuilder: (context, child, progress) {
        return progress == null ? child : fallback();
      },
    );
  }
}

class _PayNowButton extends StatelessWidget {
  const _PayNowButton({
    required this.label,
    required this.isLoading,
    required this.onPressed,
  });

  final String label;
  final bool isLoading;
  final VoidCallback? onPressed;

  static const _top = Color(0xFF469390);
  static const _bottom = Color(0xFF1775E1);

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(context.scaleWidth(50));
    final enabled = onPressed != null && !isLoading;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: enabled ? onPressed : null,
        borderRadius: radius,
        child: Ink(
          decoration: BoxDecoration(
            borderRadius: radius,
            gradient: enabled || isLoading
                ? const LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [_top, _bottom, _bottom, _bottom],
                  )
                : null,
            color: enabled || isLoading ? null : AppColors.surfaceElevated,
          ),
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: context.scaleWidth(20),
              vertical: context.scaleHeight(5),
            ),
            child: isLoading
                ? SizedBox(
                    width: context.scaleWidth(16),
                    height: context.scaleWidth(16),
                    child: const CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : Text(
                    label,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: context.bodyFontSize,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}

class _ErrorBody extends StatelessWidget {
  const _ErrorBody({
    required this.message,
    required this.onRetry,
    required this.retryLabel,
  });

  final String message;
  final VoidCallback onRetry;
  final String retryLabel;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(context.defaultPaddingSc),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: context.fontSize,
              ),
            ),
            SizedBox(height: context.scaleHeight(16)),
            AppButton(label: retryLabel, expand: false, onPressed: onRetry),
          ],
        ),
      ),
    );
  }
}
