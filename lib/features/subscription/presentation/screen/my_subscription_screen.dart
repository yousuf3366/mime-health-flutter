import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:mime_health/core/extensions/context_extensions.dart';
import 'package:mime_health/core/theme/app_colors.dart';
import 'package:mime_health/core/widgets/app_app_bar.dart';
import 'package:mime_health/core/widgets/app_button.dart';

import '../../../../core/error/exceptions.dart';
import '../../../../core/localization/l10n_keys.dart';
import '../../../../core/router/route_names.dart';
import '../../../language/presentation/provider/language_provider.dart';
import '../../domain/entity/subscription_entity.dart';
import '../provider/subscription_provider.dart';

/// Details of the user's current plan from `GET /subscription/me`.
class MySubscriptionScreen extends ConsumerWidget {
  const MySubscriptionScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = ref.watch(languageControllerProvider);
    final subscription = ref.watch(mySubscriptionProvider);

    Future<void> openPlans() async {
      await context.push(RouteNames.subscriptionPlans);
      ref.invalidate(mySubscriptionProvider);
    }

    Future<void> refresh() => ref.refresh(mySubscriptionProvider.future);

    return Scaffold(
      backgroundColor: AppColors.backgroundDeep,
      appBar: AppAppBar(title: l10n.t(L10nKeys.mySubscriptionTitle)),
      body: SafeArea(
        child: subscription.when(
          loading: () => const Center(
            child: CircularProgressIndicator(color: AppColors.primaryContainer),
          ),
          error: (error, _) => _MessageBody(
            message: error is AppException ? error.message : '$error',
            actionLabel: l10n.t(L10nKeys.retry),
            onAction: () => ref.invalidate(mySubscriptionProvider),
          ),
          data: (data) {
            final subscription = data?.subscription;
            if (data == null || subscription == null) {
              return _MessageBody(
                message: l10n.t(L10nKeys.mySubscriptionEmpty),
                actionLabel: l10n.t(L10nKeys.mySubscriptionViewPlans),
                onAction: openPlans,
              );
            }
            return RefreshIndicator(
              color: AppColors.primaryContainer,
              onRefresh: refresh,
              child: _SubscriptionDetails(
                data: data,
                subscription: subscription,
                t: l10n.t,
                onChangePlan: openPlans,
              ),
            );
          },
        ),
      ),
    );
  }
}

class _SubscriptionDetails extends StatelessWidget {
  const _SubscriptionDetails({
    required this.data,
    required this.subscription,
    required this.t,
    required this.onChangePlan,
  });

  final MySubscriptionEntity data;
  final SelectedSubscriptionEntity subscription;
  final String Function(String key) t;
  final VoidCallback onChangePlan;

  @override
  Widget build(BuildContext context) {
    final plan = subscription.plan;
    final quota = data.quota;

    List<String> namesOf(String type) => plan.services
        .where((s) => s.type == type)
        .map((s) => s.name.isEmpty ? s.code : s.name)
        .toList(growable: false);

    final historyDays = plan.historyRetentionDays;

    final serviceSections = [
      (t(L10nKeys.mySubscriptionFeatures), namesOf('feature')),
      (t(L10nKeys.mySubscriptionBiomarkers), namesOf('biomarker')),
      (t(L10nKeys.mySubscriptionMetrics), namesOf('metric')),
    ].where((section) => section.$2.isNotEmpty);

    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: EdgeInsets.fromLTRB(
        context.defaultPaddingSc,
        context.scaleHeight(16),
        context.defaultPaddingSc,
        context.scaleHeight(28),
      ),
      children: [
        _PlanHeaderCard(
          subscription: subscription,
          status: data.status,
          isActive: data.hasActivePlan,
          t: t,
        ),
        if (quota != null && quota.quotaLimit > 0) ...[
          SizedBox(height: context.scaleHeight(16)),
          _UsageCard(quota: quota, t: t),
        ],
        SizedBox(height: context.scaleHeight(16)),
        _SectionTitle(t(L10nKeys.mySubscriptionLimits)),
        _GlassCard(
          child: Column(
            children: _withDividers([
              _InfoRow(
                title: t(L10nKeys.mySubscriptionMaxProfiles),
                value: '${plan.maxProfiles}',
              ),
              if (historyDays != null)
                _InfoRow(
                  title: t(L10nKeys.mySubscriptionHistory),
                  value: t(
                    L10nKeys.mySubscriptionDays,
                  ).replaceAll('{count}', '$historyDays'),
                ),
              _InfoRow(
                title: t(L10nKeys.mySubscriptionDevices),
                value: '${plan.maxAdditionalDevices}',
              ),
            ]),
          ),
        ),
        if (data.addons.isNotEmpty) ...[
          SizedBox(height: context.scaleHeight(16)),
          _SectionTitle(
            '${t(L10nKeys.mySubscriptionAddons)} (${data.addons.length})',
          ),
          for (var i = 0; i < data.addons.length; i++) ...[
            if (i > 0) SizedBox(height: context.scaleHeight(10)),
            _AddonCard(addon: data.addons[i], t: t),
          ],
        ],
        for (final (title, names) in serviceSections) ...[
          SizedBox(height: context.scaleHeight(16)),
          _SectionTitle('$title (${names.length})'),
          _GlassCard(child: _ServiceChips(names: names)),
        ],
        SizedBox(height: context.scaleHeight(28)),
        AppButton(
          label: t(L10nKeys.mySubscriptionChangePlan),
          icon: Icons.swap_horiz_rounded,
          onPressed: onChangePlan,
        ),
        SizedBox(height: context.scaleHeight(12)),
        AppButton(
          label: t(L10nKeys.paymentHistoryTitle),
          icon: Icons.receipt_long_outlined,
          btnStyle: AppButtonStyle.secondary,
          onPressed: () => context.push(RouteNames.paymentHistory),
        ),
      ],
    );
  }
}

class _PlanHeaderCard extends StatelessWidget {
  const _PlanHeaderCard({
    required this.subscription,
    required this.status,
    required this.isActive,
    required this.t,
  });

  final SelectedSubscriptionEntity subscription;

  /// Top-level `data.status`.
  final String status;
  final bool isActive;
  final String Function(String key) t;

  @override
  Widget build(BuildContext context) {
    final plan = subscription.plan;
    final interval = subscription.billingInterval;
    final period = t(
      interval == BillingInterval.annual
          ? L10nKeys.subscriptionAnnual
          : L10nKeys.subscriptionMonthly,
    );
    final (label, color) = subscription.isCancelScheduled
        ? (t(L10nKeys.mySubscriptionStatusCancelScheduled), AppColors.warning)
        : subscription.isTrialing
        ? (t(L10nKeys.mySubscriptionStatusTrial), AppColors.primaryContainer)
        : isActive
        ? (t(L10nKeys.mySubscriptionStatusActive), AppColors.success)
        : (_capitalize(status), AppColors.textSecondary);
    final trialEnds = subscription.isTrialing
        ? _formatDate(subscription.trialEndsAt)
        : null;
    final cancelsOn = subscription.isCancelScheduled
        ? _formatDate(subscription.cancelAt)
        : null;

    return _GlassCard(
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
              _StatusChip(label: label, color: color),
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
          if (subscription.currentPeriodStart != null ||
              subscription.currentPeriodEnd != null) ...[
            SizedBox(height: context.scaleHeight(16)),
            _Timeline(
              title: t(L10nKeys.mySubscriptionPeriod),
              startsAt: subscription.currentPeriodStart,
              endsAt: subscription.currentPeriodEnd,
              t: t,
            ),
          ],
          if (trialEnds != null)
            _InfoRow(
              title: t(L10nKeys.mySubscriptionTrialEnds),
              value: trialEnds,
            ),
          if (cancelsOn != null)
            _InfoRow(
              title: t(L10nKeys.mySubscriptionCancelsOn),
              value: cancelsOn,
              valueColor: AppColors.warning,
            ),
        ],
      ),
    );
  }
}

class _AddonCard extends StatelessWidget {
  const _AddonCard({required this.addon, required this.t});

  final SubscriptionAddonEntity addon;
  final String Function(String key) t;

  @override
  Widget build(BuildContext context) {
    final (label, color) = addon.isActive
        ? (t(L10nKeys.mySubscriptionStatusActive), AppColors.success)
        : (_capitalize(addon.status), AppColors.textSecondary);
    final interval = switch (addon.billingInterval.trim().toLowerCase()) {
      'monthly' => t(L10nKeys.subscriptionMonthly),
      'annual' || 'yearly' => t(L10nKeys.subscriptionAnnual),
      'one_time' => t(L10nKeys.mySubscriptionOneTime),
      final other => _capitalize(other),
    };

    return _GlassCard(
      padding: EdgeInsets.all(context.scaleWidth(18)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: EdgeInsets.all(context.scaleWidth(8)),
                decoration: BoxDecoration(
                  color: AppColors.pillSelected,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  Icons.extension_outlined,
                  size: context.scaleWidth(20),
                  color: AppColors.primaryContainer,
                ),
              ),
              SizedBox(width: context.scaleWidth(12)),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      addon.name.isEmpty ? addon.code : addon.name,
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: context.fontSize,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    SizedBox(height: context.scaleHeight(2)),
                    Text(
                      '৳${addon.amountBdt} · $interval',
                      style: TextStyle(
                        color: AppColors.primaryContainer,
                        fontSize: context.smallFontSize,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
              _StatusChip(label: label, color: color),
            ],
          ),
          if (addon.startsAt != null || addon.endsAt != null) ...[
            SizedBox(height: context.scaleHeight(14)),
            _Timeline(
              title: t(L10nKeys.mySubscriptionValidity),
              startsAt: addon.startsAt,
              endsAt: addon.endsAt,
              daysLeft: addon.daysUntilExpiry,
              t: t,
            ),
          ],
        ],
      ),
    );
  }
}

/// Start → end dates with an elapsed-time bar and "N days left".
class _Timeline extends StatelessWidget {
  const _Timeline({
    required this.title,
    required this.startsAt,
    required this.endsAt,
    required this.t,
    this.daysLeft,
  });

  final String title;
  final String? startsAt;
  final String? endsAt;
  final int? daysLeft;
  final String Function(String key) t;

  @override
  Widget build(BuildContext context) {
    final start = _parseDate(startsAt);
    final end = _parseDate(endsAt);
    final today = DateUtils.dateOnly(DateTime.now());
    final daysToEnd = end?.difference(today).inDays;
    final remaining =
        daysLeft ?? (daysToEnd == null ? null : math.max(0, daysToEnd));
    final progress = start == null || end == null || !end.isAfter(start)
        ? null
        : (today.difference(start).inDays / end.difference(start).inDays).clamp(
            0.0,
            1.0,
          );
    final dateStyle = TextStyle(
      color: AppColors.textPrimary,
      fontSize: context.smallFontSize,
      fontWeight: FontWeight.w700,
    );
    final captionStyle = TextStyle(
      color: AppColors.textSecondary,
      fontSize: context.extraSmallFontSize,
      fontWeight: FontWeight.w600,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(child: Text(title, style: captionStyle)),
            if (remaining != null)
              Text(
                t(
                  L10nKeys.mySubscriptionDaysLeft,
                ).replaceAll('{count}', '$remaining'),
                style: captionStyle.copyWith(
                  color: remaining <= 3
                      ? AppColors.warning
                      : AppColors.primaryContainer,
                ),
              ),
          ],
        ),
        SizedBox(height: context.scaleHeight(8)),
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: LinearProgressIndicator(
            value: progress ?? 0,
            minHeight: context.scaleHeight(6),
            color: AppColors.primaryContainer,
            backgroundColor: AppColors.surfaceElevated,
          ),
        ),
        SizedBox(height: context.scaleHeight(8)),
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(t(L10nKeys.mySubscriptionStarts), style: captionStyle),
                  Text(_formatDate(startsAt) ?? '-', style: dateStyle),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(t(L10nKeys.mySubscriptionEnds), style: captionStyle),
                Text(_formatDate(endsAt) ?? '-', style: dateStyle),
              ],
            ),
          ],
        ),
      ],
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.label, required this.color});

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

class _UsageCard extends StatelessWidget {
  const _UsageCard({required this.quota, required this.t});

  final SubscriptionQuotaEntity quota;
  final String Function(String key) t;

  @override
  Widget build(BuildContext context) {
    final ratio = (quota.scansUsed / quota.quotaLimit).clamp(0.0, 1.0);

    return _GlassCard(
      padding: EdgeInsets.all(context.scaleWidth(20)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            t(L10nKeys.mySubscriptionUsage),
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: context.fontSize,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: context.scaleHeight(10)),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: ratio,
              minHeight: context.scaleHeight(8),
              color: ratio >= 0.9
                  ? AppColors.warning
                  : AppColors.primaryContainer,
              backgroundColor: AppColors.surfaceElevated,
            ),
          ),
          SizedBox(height: context.scaleHeight(10)),
          Row(
            children: [
              Expanded(
                child: Text(
                  t(L10nKeys.mySubscriptionUsageValue)
                      .replaceAll('{used}', '${quota.scansUsed}')
                      .replaceAll('{limit}', '${quota.quotaLimit}'),
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: context.smallFontSize,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Text(
                t(
                  L10nKeys.mySubscriptionRemaining,
                ).replaceAll('{count}', '${quota.remaining}'),
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: context.smallFontSize,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
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
  const _InfoRow({required this.title, required this.value, this.valueColor});

  final String title;
  final String value;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: context.scaleHeight(14)),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 4,
            child: Text(
              title,
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: context.fontSize,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          SizedBox(width: context.scaleWidth(12)),
          Expanded(
            flex: 5,
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: TextStyle(
                color: valueColor ?? AppColors.textPrimary,
                fontSize: context.fontSize,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MessageBody extends StatelessWidget {
  const _MessageBody({
    required this.message,
    required this.actionLabel,
    required this.onAction,
  });

  final String message;
  final String actionLabel;
  final VoidCallback onAction;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(context.defaultPaddingSc),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.workspace_premium_outlined,
              size: context.scaleWidth(56),
              color: AppColors.textHint,
            ),
            SizedBox(height: context.scaleHeight(16)),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: context.fontSize,
              ),
            ),
            SizedBox(height: context.scaleHeight(20)),
            AppButton(label: actionLabel, expand: false, onPressed: onAction),
          ],
        ),
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

DateTime? _parseDate(String? raw) {
  final date = raw == null ? null : DateTime.tryParse(raw);
  return date == null ? null : DateUtils.dateOnly(date);
}

String? _formatDate(String? raw) {
  final date = _parseDate(raw);
  return date == null ? null : DateFormat('dd MMM yyyy').format(date);
}

String _capitalize(String value) {
  final text = value.trim();
  if (text.isEmpty) return '-';
  return text[0].toUpperCase() + text.substring(1).replaceAll('_', ' ');
}
