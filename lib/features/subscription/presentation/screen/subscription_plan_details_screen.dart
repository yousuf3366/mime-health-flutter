import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:mime_health/core/extensions/context_extensions.dart';
import 'package:mime_health/core/theme/app_colors.dart';
import 'package:mime_health/core/widgets/app_app_bar.dart';
import 'package:mime_health/core/widgets/app_button.dart';
import 'package:mime_health/core/widgets/app_dropdown_field.dart';

import '../../../../core/localization/l10n_keys.dart';
import '../../../../core/router/route_names.dart';
import '../../../language/presentation/provider/language_provider.dart';
import '../../domain/entity/subscription_entity.dart';
import '../provider/subscription_provider.dart';
import '../widget/plan_artwork.dart';

/// Full details of one subscription plan, opened from a plan card. Pops `true`
/// once the user has paid for it.
class SubscriptionPlanDetailsScreen extends ConsumerWidget {
  const SubscriptionPlanDetailsScreen({super.key, required this.plan});

  final SubscriptionPlanEntity plan;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = ref.watch(languageControllerProvider);
    final state = ref.watch(subscriptionPlansNotifierProvider);
    final notifier = ref.read(subscriptionPlansNotifierProvider.notifier);
    final mySubscription = ref.watch(mySubscriptionProvider).asData?.value;
    final isCurrentPlan =
        mySubscription?.hasActivePlan == true &&
        mySubscription?.subscription?.plan.code == plan.code;

    final interval = state.billingInterval;
    final period = l10n.t(
      interval == BillingInterval.annual
          ? L10nKeys.subscriptionAnnual
          : L10nKeys.subscriptionMonthly,
    );
    final quota = plan.monthlyScanQuota;
    final includedDevices =
        plan.includedPrimaryDevices + plan.includedSecondaryDevices;
    final historyDays = plan.historyRetentionDays;

    // Every service type except `limit` (shown in "What's included"), in the
    // order the API sends them; unknown types get a humanized title.
    final groups = <String, List<String>>{};
    for (final s in plan.services) {
      if (s.type == 'limit' || s.type.isEmpty) continue;
      groups
          .putIfAbsent(s.type, () => [])
          .add(s.name.isEmpty ? s.code : s.name);
    }
    String groupTitle(String type) => switch (type) {
      'feature' => l10n.t(L10nKeys.mySubscriptionFeatures),
      'biomarker' => l10n.t(L10nKeys.mySubscriptionBiomarkers),
      'metric' => l10n.t(L10nKeys.mySubscriptionMetrics),
      'device' => l10n.t(L10nKeys.planDetailsDevicesSection),
      'partner_cta' => l10n.t(L10nKeys.planDetailsPartnerServices),
      _ => _humanize(type),
    };
    final serviceSections = [
      for (final MapEntry(key: type, value: names) in groups.entries)
        (t: groupTitle(type), names: names),
    ];
    final canStartTrial = state.canStartTrial(plan);
    final isStartingTrial = state.trialPlanCode == plan.code;

    Future<void> startTrial() async {
      final ok = await notifier.startTrial(plan);
      if (ok && context.mounted) context.pop(true);
    }

    Future<void> payNow() async {
      notifier.selectPlanCode(plan.code);
      final paid = await context.push<bool>(
        RouteNames.subscriptionPayment,
        extra: plan.code,
      );
      if (paid == true && context.mounted) context.pop(true);
    }

    return Scaffold(
      backgroundColor: AppColors.backgroundDeep,
      appBar: AppAppBar(title: plan.name),
      body: SafeArea(
        top: false,
        child: Column(
          children: [
            Expanded(
              child: ListView(
                padding: EdgeInsets.fromLTRB(
                  context.defaultPaddingSc,
                  context.scaleHeight(16),
                  context.defaultPaddingSc,
                  context.scaleHeight(24),
                ),
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: SizedBox(
                      height: context.scaleHeight(160),
                      child: PlanArtwork(imageUrl: plan.image),
                    ),
                  ),
                  SizedBox(height: context.scaleHeight(16)),
                  _GlassCard(
                    padding: EdgeInsets.all(context.scaleWidth(20)),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Text(
                                plan.name,
                                style: TextStyle(
                                  color: AppColors.textPrimary,
                                  fontSize: context.titleFontSize,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ),
                            if (isCurrentPlan)
                              _Chip(
                                label: l10n.t(L10nKeys.planDetailsCurrent),
                                color: AppColors.success,
                              )
                            else if (plan.tierType.isNotEmpty)
                              _Chip(
                                label: _humanize(plan.tierType),
                                color: AppColors.primaryContainer,
                              ),
                          ],
                        ),
                        SizedBox(height: context.scaleHeight(6)),
                        Text(
                          '৳${plan.priceFor(interval)} / ${period.toLowerCase()}',
                          style: TextStyle(
                            color: AppColors.primaryContainer,
                            fontSize: context.fontSize,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        if (plan.trialDays > 0) ...[
                          SizedBox(height: context.scaleHeight(8)),
                          Row(
                            children: [
                              Icon(
                                Icons.card_giftcard_outlined,
                                size: context.scaleWidth(16),
                                color: AppColors.success,
                              ),
                              SizedBox(width: context.scaleWidth(6)),
                              Text(
                                l10n
                                    .t(L10nKeys.subscriptionTrial)
                                    .replaceAll('{days}', '${plan.trialDays}'),
                                style: TextStyle(
                                  color: AppColors.success,
                                  fontSize: context.smallFontSize,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                        ],
                        SizedBox(height: context.scaleHeight(16)),
                        AppDropdownField<BillingInterval>(
                          label: l10n.t(L10nKeys.subscriptionBillingPeriod),
                          value: interval,
                          items: BillingInterval.values,
                          itemLabelBuilder: (i) => l10n.t(
                            i == BillingInterval.annual
                                ? L10nKeys.subscriptionAnnual
                                : L10nKeys.subscriptionMonthly,
                          ),
                          enabled: !state.isStartingTrial,
                          onChanged: (value) {
                            if (value != null) {
                              notifier.setBillingInterval(value);
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: context.scaleHeight(16)),
                  _SectionTitle(l10n.t(L10nKeys.planDetailsIncluded)),
                  _GlassCard(
                    child: Column(
                      children: _withDividers([
                        _InfoRow(
                          icon: Icons.document_scanner_outlined,
                          title: l10n.t(L10nKeys.planDetailsMonthlyScans),
                          value: quota == null
                              ? l10n.t(L10nKeys.subscriptionUnlimited)
                              : '$quota',
                        ),
                        _InfoRow(
                          icon: Icons.people_outline,
                          title: l10n.t(L10nKeys.mySubscriptionMaxProfiles),
                          value: '${plan.maxProfiles}',
                        ),
                        _InfoRow(
                          icon: Icons.devices_outlined,
                          title: l10n.t(L10nKeys.planDetailsDevices),
                          value: '$includedDevices',
                        ),
                        _InfoRow(
                          icon: Icons.add_to_queue_outlined,
                          title: l10n.t(L10nKeys.mySubscriptionDevices),
                          value: '${plan.maxAdditionalDevices}',
                        ),
                        if (historyDays != null)
                          _InfoRow(
                            icon: Icons.history,
                            title: l10n.t(L10nKeys.mySubscriptionHistory),
                            value: l10n
                                .t(L10nKeys.mySubscriptionDays)
                                .replaceAll('{count}', '$historyDays'),
                          ),
                      ]),
                    ),
                  ),
                  for (final section in serviceSections) ...[
                    SizedBox(height: context.scaleHeight(16)),
                    _SectionTitle('${section.t} (${section.names.length})'),
                    _GlassCard(child: _ServiceChips(names: section.names)),
                  ],
                ],
              ),
            ),
            Container(
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
              child: Row(
                children: [
                  Expanded(
                    child: AppButton(
                      label: l10n.t(L10nKeys.subscriptionPayNow),
                      isEnabled: !state.isStartingTrial,
                      onPressed: payNow,
                    ),
                  ),
                  if (canStartTrial) ...[
                    SizedBox(width: context.scaleWidth(10)),
                    Expanded(
                      child: AppButton(
                        label: l10n.t(L10nKeys.subscriptionFreeTrial),
                        btnStyle: AppButtonStyle.secondary,
                        isLoading: isStartingTrial,
                        isEnabled: !state.isStartingTrial,
                        onPressed: startTrial,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  static String _humanize(String code) => code
      .split(RegExp(r'[_\s]+'))
      .where((w) => w.isNotEmpty)
      .map((w) => w[0].toUpperCase() + w.substring(1).toLowerCase())
      .join(' ');
}

class _Chip extends StatelessWidget {
  const _Chip({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: context.scaleWidth(10),
        vertical: context.scaleHeight(4),
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.6)),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: context.smallFontSize,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.title);

  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: context.scaleWidth(4),
        bottom: context.scaleHeight(8),
      ),
      child: Text(
        title.toUpperCase(),
        style: TextStyle(
          color: AppColors.primaryContainer,
          fontSize: context.smallFontSize,
          fontWeight: FontWeight.w800,
          letterSpacing: 1.1,
        ),
      ),
    );
  }
}

class _GlassCard extends StatelessWidget {
  const _GlassCard({required this.child, this.padding});

  final Widget child;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding:
          padding ?? EdgeInsets.symmetric(horizontal: context.scaleWidth(20)),
      decoration: BoxDecoration(
        color: AppColors.glass,
        borderRadius: BorderRadius.circular(context.scaleWidth(20)),
        border: Border.all(color: AppColors.glassBorder),
      ),
      child: child,
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.icon,
    required this.title,
    required this.value,
  });

  final IconData icon;
  final String title;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: context.scaleHeight(14)),
      child: Row(
        children: [
          Icon(
            icon,
            size: context.scaleWidth(18),
            color: AppColors.primaryContainer,
          ),
          SizedBox(width: context.scaleWidth(12)),
          Expanded(
            child: Text(
              title,
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: context.fontSize,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Text(
            value,
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: context.fontSize,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _ServiceChips extends StatelessWidget {
  const _ServiceChips({required this.names});

  final List<String> names;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: context.scaleHeight(14)),
      child: Wrap(
        spacing: context.scaleWidth(8),
        runSpacing: context.scaleHeight(8),
        children: [
          for (final name in names)
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: context.scaleWidth(10),
                vertical: context.scaleHeight(6),
              ),
              decoration: BoxDecoration(
                color: AppColors.pillSelected,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.check_circle_rounded,
                    size: context.scaleWidth(14),
                    color: AppColors.primaryContainer,
                  ),
                  SizedBox(width: context.scaleWidth(6)),
                  Text(
                    name,
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: context.smallFontSize,
                      fontWeight: FontWeight.w600,
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

List<Widget> _withDividers(List<Widget> rows) => [
  for (var i = 0; i < rows.length; i++) ...[
    rows[i],
    if (i < rows.length - 1)
      Divider(height: 1, color: AppColors.border.withValues(alpha: 0.5)),
  ],
];
