import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:mime_health/core/extensions/context_extensions.dart';
import 'package:mime_health/core/theme/app_colors.dart';
import 'package:mime_health/core/widgets/app_button.dart';
import 'package:mime_health/core/widgets/app_dropdown_field.dart';
import '../../../../core/localization/l10n_keys.dart';
import '../../../../core/router/route_names.dart';
import '../../../language/presentation/provider/language_provider.dart';
import '../../domain/entity/subscription_entity.dart';
import '../provider/subscription_provider.dart';
import '../widget/plan_artwork.dart';
import 'subscription_payment_screen.dart' show addonsTotal;

enum _PlansTab { selectPlan, addOns }

/// Lists Mime subscription plans and submits the user's selection.
class SubscriptionPlansScreen extends HookConsumerWidget {
  const SubscriptionPlansScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = ref.watch(languageControllerProvider);
    final state = ref.watch(subscriptionPlansNotifierProvider);
    final notifier = ref.read(subscriptionPlansNotifierProvider.notifier);
    // Watched here (not only in the Add-ons tab) so the auto-disposed add-ons
    // selection survives tab switches and the payment screen.
    ref.watch(subscriptionAddonsNotifierProvider);
    final addonsNotifier = ref.read(
      subscriptionAddonsNotifierProvider.notifier,
    );
    final tab = useState(_PlansTab.selectPlan);
    final busy = state.isStartingTrial;

    useEffect(() {
      Future.microtask(() {
        notifier.loadPlans();
        addonsNotifier.load();
      });
      return null;
    }, const []);

    Future<void> openAddonPayment(
      List<SubscriptionServiceOfferEntity> addons,
    ) async {
      final paid = await context.push<bool>(
        RouteNames.subscriptionPayment,
        extra: addons,
      );
      if (paid == true && context.mounted) {
        addonsNotifier.clearSelection();
        context.pop(true);
      }
    }

    Future<void> openPayment(SubscriptionPlanEntity plan) async {
      notifier.selectPlanCode(plan.code);
      final paid = await context.push<bool>(
        RouteNames.subscriptionPayment,
        extra: plan.code,
      );
      if (paid == true && context.mounted) {
        context.pop(true);
      }
    }

    Future<void> startTrial(SubscriptionPlanEntity plan) async {
      final ok = await notifier.startTrial(plan);
      if (ok && context.mounted) context.pop(true);
    }

    Future<void> openDetails(SubscriptionPlanEntity plan) async {
      final paid = await context.push<bool>(
        RouteNames.subscriptionPlanDetails,
        extra: plan,
      );
      if (paid == true && context.mounted) {
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
            Padding(
              padding: EdgeInsets.fromLTRB(
                context.defaultPaddingSc,
                context.scaleHeight(4),
                context.defaultPaddingSc,
                context.scaleHeight(12),
              ),
              child: _PlansTabSwitcher(
                value: tab.value,
                selectPlanLabel: l10n.t(L10nKeys.subscriptionSelectPlanTab),
                addOnsLabel: l10n.t(L10nKeys.subscriptionAddOnsTab),
                onChanged: (value) => tab.value = value,
              ),
            ),
            if (tab.value == _PlansTab.addOns ||
                (!state.isLoading &&
                    !(state.errorMessage != null && state.plans.isEmpty)))
              Padding(
                padding: EdgeInsets.fromLTRB(
                  context.defaultPaddingSc,
                  context.scaleHeight(4),
                  context.defaultPaddingSc,
                  context.scaleHeight(12),
                ),
                child: AppDropdownField<BillingInterval>(
                  label: l10n.t(L10nKeys.subscriptionBillingPeriod),
                  value: state.billingInterval,
                  items: BillingInterval.values,
                  itemLabelBuilder: (interval) => l10n.t(
                    interval == BillingInterval.annual
                        ? L10nKeys.subscriptionAnnual
                        : L10nKeys.subscriptionMonthly,
                  ),
                  enabled: !busy,
                  onChanged: (value) {
                    if (value != null) notifier.setBillingInterval(value);
                  },
                ),
              ),
            Expanded(
              child: tab.value == _PlansTab.addOns
                  ? _AddonsTab(
                      billingInterval: state.billingInterval,
                      onCheckout: openAddonPayment,
                    )
                  : state.isLoading
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
                  : RefreshIndicator(
                      color: AppColors.primaryContainer,
                      onRefresh: () => notifier.loadPlans(showLoading: false),
                      child: ListView.separated(
                        physics: const AlwaysScrollableScrollPhysics(),
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
                            profilesLabel: l10n.t(
                              L10nKeys.subscriptionProfiles,
                            ),
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
                            onTap: busy ? null : () => openPayment(plan),
                            freeTrialLabel: l10n.t(
                              L10nKeys.subscriptionFreeTrial,
                            ),
                            isStartingTrial: state.trialPlanCode == plan.code,
                            onFreeTrial: !state.canStartTrial(plan)
                                ? null
                                : busy
                                ? () {}
                                : () => startTrial(plan),
                            onOpenDetails: busy
                                ? null
                                : () => openDetails(plan),
                          );
                        },
                      ),
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

class _PlansTabSwitcher extends StatelessWidget {
  const _PlansTabSwitcher({
    required this.value,
    required this.selectPlanLabel,
    required this.addOnsLabel,
    required this.onChanged,
  });

  final _PlansTab value;
  final String selectPlanLabel;
  final String addOnsLabel;
  final ValueChanged<_PlansTab> onChanged;

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
              label: selectPlanLabel,
              selected: value == _PlansTab.selectPlan,
              onTap: () => onChanged(_PlansTab.selectPlan),
            ),
          ),
          Expanded(
            child: _Segment(
              label: addOnsLabel,
              selected: value == _PlansTab.addOns,
              onTap: () => onChanged(_PlansTab.addOns),
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
    required this.onTap,
    required this.onOpenDetails,
    required this.freeTrialLabel,
    required this.isStartingTrial,
    required this.onFreeTrial,
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

  /// "Pay Now" on the card.
  final VoidCallback? onTap;

  final String freeTrialLabel;
  final bool isStartingTrial;

  /// `null` hides the "Free Trial" button (trial not available).
  final VoidCallback? onFreeTrial;

  /// Tapping anywhere else on the card.
  final VoidCallback? onOpenDetails;

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
        GestureDetector(
          onTap: onOpenDetails,
          behavior: HitTestBehavior.opaque,
          child: Container(
            width: double.infinity,
            clipBehavior: Clip.antiAlias,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: selected
                    ? AppColors.primaryContainer
                    : Colors.transparent,
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
                Positioned.fill(child: PlanArtwork(imageUrl: plan.image)),
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
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
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
                              ],
                            ),
                          ),
                          const Expanded(flex: 36, child: SizedBox.shrink()),
                        ],
                      ),
                      SizedBox(height: context.scaleHeight(14)),
                      // Full card width so both labels keep the same size.
                      Row(
                        children: [
                          Expanded(
                            child: _PayNowButton(
                              label: payNowLabel,
                              isLoading: false,
                              onPressed: onTap,
                            ),
                          ),
                          if (onFreeTrial != null) ...[
                            SizedBox(width: context.scaleWidth(10)),
                            Expanded(
                              child: _FreeTrialButton(
                                label: freeTrialLabel,
                                isLoading: isStartingTrial,
                                onPressed: onFreeTrial!,
                              ),
                            ),
                          ] else
                            Expanded(child: const SizedBox.shrink()),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
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

/// Outlined companion to [_PayNowButton] on the white plan card.
class _FreeTrialButton extends StatelessWidget {
  const _FreeTrialButton({
    required this.label,
    required this.isLoading,
    required this.onPressed,
  });

  final String label;
  final bool isLoading;
  final VoidCallback onPressed;

  static const _color = Color(0xFF1775E1);

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(context.scaleWidth(50));
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: isLoading ? null : onPressed,
        borderRadius: radius,
        child: Container(
          height: _cardButtonHeight(context),
          alignment: Alignment.center,
          padding: EdgeInsets.symmetric(horizontal: context.scaleWidth(10)),
          decoration: BoxDecoration(
            borderRadius: radius,
            border: Border.all(color: _color, width: 1.2),
          ),
          child: isLoading
              ? SizedBox(
                  width: context.scaleWidth(18),
                  height: context.scaleWidth(18),
                  child: const CircularProgressIndicator(
                    strokeWidth: 2,
                    color: _color,
                  ),
                )
              : Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: _cardButtonTextStyle(context, _color),
                ),
        ),
      ),
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
          child: Container(
            height: _cardButtonHeight(context),
            alignment: Alignment.center,
            padding: EdgeInsets.symmetric(horizontal: context.scaleWidth(10)),
            child: isLoading
                ? SizedBox(
                    width: context.scaleWidth(18),
                    height: context.scaleWidth(18),
                    child: const CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: _cardButtonTextStyle(context, Colors.white),
                  ),
          ),
        ),
      ),
    );
  }
}

/// Standard tap-target height for the plan card's Pay Now / Free Trial.
double _cardButtonHeight(BuildContext context) => context.scaleHeight(44);

/// Shared label style so Pay Now and Free Trial always match.
TextStyle _cardButtonTextStyle(BuildContext context, Color color) => TextStyle(
  color: color,
  fontSize: context.fontSize,
  fontWeight: FontWeight.w700,
);

/// Add-on services from `GET /subscription/services`, grouped by type, with
/// multi-select and a sticky checkout bar.
class _AddonsTab extends ConsumerWidget {
  const _AddonsTab({required this.billingInterval, required this.onCheckout});

  final BillingInterval billingInterval;
  final ValueChanged<List<SubscriptionServiceOfferEntity>> onCheckout;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = ref.watch(languageControllerProvider);
    final addons = ref.watch(subscriptionAddonsNotifierProvider);
    final addonsNotifier = ref.read(
      subscriptionAddonsNotifierProvider.notifier,
    );
    final period = l10n
        .t(
          billingInterval == BillingInterval.annual
              ? L10nKeys.subscriptionAnnual
              : L10nKeys.subscriptionMonthly,
        )
        .toLowerCase();

    if (addons.isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.primaryContainer),
      );
    }
    if (addons.errorMessage != null && addons.services.isEmpty) {
      return _ErrorBody(
        message: addons.errorMessage!,
        onRetry: addonsNotifier.load,
        retryLabel: l10n.t(L10nKeys.retry),
      );
    }

    return Builder(
      builder: (context) {
        final services = addons.services;
        if (services.isEmpty) {
          return Center(
            child: Padding(
              padding: EdgeInsets.all(context.defaultPaddingSc),
              child: Text(
                l10n.t(L10nKeys.subscriptionAddonsEmpty),
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: context.fontSize,
                ),
              ),
            ),
          );
        }

        final groups = <String, List<SubscriptionServiceOfferEntity>>{};
        for (final service in services) {
          groups.putIfAbsent(service.type, () => []).add(service);
        }
        final selected = addons.selectedServices;

        String groupTitle(String type) => switch (type) {
          'biomarker' => l10n.t(L10nKeys.mySubscriptionBiomarkers),
          'metric' => l10n.t(L10nKeys.mySubscriptionMetrics),
          _ => _humanize(type),
        };

        return Column(
          children: [
            Expanded(
              child: RefreshIndicator(
                color: AppColors.primaryContainer,
                onRefresh: () => addonsNotifier.load(showLoading: false),
                child: ListView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: EdgeInsets.fromLTRB(
                    context.defaultPaddingSc,
                    context.scaleHeight(4),
                    context.defaultPaddingSc,
                    context.scaleHeight(16),
                  ),
                  children: [
                    for (final MapEntry(key: type, value: items)
                        in groups.entries) ...[
                      Padding(
                        padding: EdgeInsets.fromLTRB(
                          context.scaleWidth(4),
                          context.scaleHeight(12),
                          0,
                          context.scaleHeight(8),
                        ),
                        child: Text(
                          '${groupTitle(type)} (${items.length})'.toUpperCase(),
                          style: TextStyle(
                            color: AppColors.primaryContainer,
                            fontSize: context.smallFontSize,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 1.1,
                          ),
                        ),
                      ),
                      for (final service in items)
                        Padding(
                          padding: EdgeInsets.only(
                            bottom: context.scaleHeight(8),
                          ),
                          child: _AddonServiceTile(
                            service: service,
                            priceLabel:
                                '৳${service.priceFor(billingInterval)} / $period',
                            selected: addons.isSelected(service.code),
                            onTap: () => addonsNotifier.toggle(service.code),
                          ),
                        ),
                    ],
                  ],
                ),
              ),
            ),
            _AddonsCheckoutBar(
              summary: selected.isEmpty
                  ? l10n.t(L10nKeys.subscriptionAddonsNoneSelected)
                  : '${l10n.t(L10nKeys.subscriptionAddonsSelected).replaceAll('{count}', '${selected.length}')}'
                        ' · ৳${addonsTotal(selected, billingInterval)} / $period',
              checkoutLabel: l10n.t(L10nKeys.paymentCheckout),
              onCheckout: selected.isEmpty ? null : () => onCheckout(selected),
            ),
          ],
        );
      },
    );
  }

  static String _humanize(String code) => code
      .split(RegExp(r'[_\s]+'))
      .where((w) => w.isNotEmpty)
      .map((w) => w[0].toUpperCase() + w.substring(1).toLowerCase())
      .join(' ');
}

class _AddonServiceTile extends StatelessWidget {
  const _AddonServiceTile({
    required this.service,
    required this.priceLabel,
    required this.selected,
    required this.onTap,
  });

  final SubscriptionServiceOfferEntity service;
  final String priceLabel;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(14);
    final description = service.description;

    return Material(
      color: selected ? AppColors.pillSelected : AppColors.glass,
      borderRadius: radius,
      child: InkWell(
        onTap: onTap,
        borderRadius: radius,
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: context.scaleWidth(8),
            vertical: context.scaleHeight(8),
          ),
          decoration: BoxDecoration(
            borderRadius: radius,
            border: Border.all(
              color: selected
                  ? AppColors.primaryContainer
                  : AppColors.glassBorder,
              width: selected ? 1.2 : 0.5,
            ),
          ),
          child: Row(
            children: [
              Checkbox(
                value: selected,
                onChanged: (_) => onTap(),
                activeColor: AppColors.primaryContainer,
                checkColor: AppColors.onPrimary,
                side: const BorderSide(color: AppColors.textSecondary),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      service.name,
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: context.fontSize,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    if (description != null) ...[
                      SizedBox(height: context.scaleHeight(2)),
                      Text(
                        description,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: context.smallFontSize,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              SizedBox(width: context.scaleWidth(8)),
              Text(
                priceLabel,
                style: TextStyle(
                  color: AppColors.primaryContainer,
                  fontSize: context.smallFontSize,
                  fontWeight: FontWeight.w800,
                ),
              ),
              SizedBox(width: context.scaleWidth(6)),
            ],
          ),
        ),
      ),
    );
  }
}

class _AddonsCheckoutBar extends StatelessWidget {
  const _AddonsCheckoutBar({
    required this.summary,
    required this.checkoutLabel,
    required this.onCheckout,
  });

  final String summary;
  final String checkoutLabel;
  final VoidCallback? onCheckout;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(
        context.defaultPaddingSc,
        context.scaleHeight(12),
        context.defaultPaddingSc,
        context.scaleHeight(12),
      ),
      decoration: const BoxDecoration(
        color: AppColors.backgroundDeep,
        border: Border(top: BorderSide(color: AppColors.glassBorder)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            summary,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: context.fontSize,
              fontWeight: FontWeight.w700,
            ),
          ),
          SizedBox(height: context.scaleHeight(10)),
          AppButton(
            label: checkoutLabel,
            isEnabled: onCheckout != null,
            onPressed: onCheckout,
          ),
        ],
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
