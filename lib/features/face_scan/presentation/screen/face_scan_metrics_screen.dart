import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:mime_health/core/extensions/context_extensions.dart';
import 'package:mime_health/core/theme/app_colors.dart';
import 'package:mime_health/core/widgets/app_app_bar.dart';

import '../../../../core/localization/l10n_keys.dart';
import '../../../language/presentation/provider/language_provider.dart';
import '../../domain/entity/face_scan_entity.dart';

/// Full metrics view opened from Health Dashboard "Upgrade".
class FaceScanMetricsScreen extends ConsumerWidget {
  const FaceScanMetricsScreen({super.key, required this.vitals});

  final FaceScanVitalsResult vitals;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = ref.watch(languageControllerProvider);
    final scoreMetrics = _scoreMetrics(vitals.rawMetrics);
    final wellbeing = _wellbeingRows(vitals.rawMetrics);

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppAppBar(
        title: l10n.t(L10nKeys.healthDashboardMetrics),
      ),
      body: SafeArea(
        top: false,
        child: scoreMetrics.isEmpty && wellbeing.isEmpty
            ? Center(
                child: Text(
                  l10n.t(
                    L10nKeys.healthHubNoScan,
                    fallback: 'No metrics available.',
                  ),
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: context.fontSize,
                  ),
                ),
              )
            : ListView(
                padding: EdgeInsets.fromLTRB(
                  context.defaultPaddingSc,
                  context.scaleHeight(12),
                  context.defaultPaddingSc,
                  context.scaleHeight(24),
                ),
                children: [
                  if (scoreMetrics.isNotEmpty) ...[
                    Text(
                      l10n.t(L10nKeys.healthDashboardMetrics),
                      style: TextStyle(
                        color: AppColors.primaryContainer,
                        fontSize: context.titleFontSize,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.2,
                      ),
                    ),
                    SizedBox(height: context.defaultPaddingSc),
                    GridView.count(
                      crossAxisCount: 2,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisSpacing: context.scaleWidth(6),
                      mainAxisSpacing: context.scaleHeight(6),
                      childAspectRatio: 1.9,
                      children: [
                        for (final metric in scoreMetrics)
                          _DashboardMetricCard(
                            icon: metric.icon,
                            title: l10n.t(
                              metric.titleKey,
                              fallback: metric.fallbackTitle,
                            ),
                            value: metric.score.toStringAsFixed(
                              metric.score % 1 == 0 ? 0 : 1,
                            ),
                            badge: metric.confidence == null
                                ? null
                                : '${metric.confidence!.toStringAsFixed(0)}%',
                          ),
                      ],
                    ),
                  ],
                  if (wellbeing.isNotEmpty) ...[
                    SizedBox(height: context.defaultPaddingSc),
                    Text(
                      l10n.t(
                        L10nKeys.healthDashboardWellbeing,
                        fallback: 'Wellbeing',
                      ),
                      style: TextStyle(
                        color: AppColors.primaryContainer,
                        fontSize: context.titleFontSize,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.2,
                      ),
                    ),
                    SizedBox(height: context.defaultPaddingSc),
                    GridView.count(
                      crossAxisCount: 2,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisSpacing: context.scaleWidth(6),
                      mainAxisSpacing: context.scaleHeight(6),
                      childAspectRatio: 1.9,
                      children: [
                        for (final row in wellbeing)
                          _DashboardMetricCard(
                            icon: row.icon,
                            title: l10n.t(
                              row.titleKey,
                              fallback: row.fallbackTitle,
                            ),
                            value: row.score == null
                                ? (row.assessment ?? '--')
                                : row.score!.toStringAsFixed(
                                    row.score! % 1 == 0 ? 0 : 1,
                                  ),
                            badge: row.score == null
                                ? null
                                : _formatAssessment(row.assessment),
                          ),
                      ],
                    ),
                  ],
                ],
              ),
      ),
    );
  }

  static String? _formatAssessment(String? assessment) {
    final label = (assessment ?? '').trim();
    if (label.isEmpty) return null;
    if (label.length == 1) return label.toUpperCase();
    return '${label[0].toUpperCase()}${label.substring(1).toLowerCase()}';
  }

  static List<_ScoreMetric> _scoreMetrics(Map<String, dynamic>? raw) {
    if (raw == null) return const [];
    const keys = <(String, String, String, IconData)>[
      (
        'energy_balance',
        L10nKeys.healthDashboardMetricEnergyBalance,
        'Energy Balance',
        Icons.bolt_outlined,
      ),
      (
        'general_fitness',
        L10nKeys.healthDashboardMetricGeneralFitness,
        'General Fitness',
        Icons.fitness_center_outlined,
      ),
      (
        'hypertension',
        L10nKeys.healthDashboardMetricHypertension,
        'Hypertension',
        Icons.monitor_heart_outlined,
      ),
      (
        'mental_health_risk',
        L10nKeys.healthDashboardMetricMentalHealthRisk,
        'Mental Health Risk',
        Icons.psychology_outlined,
      ),
      (
        'mental_stress',
        L10nKeys.healthDashboardMetricMentalStress,
        'Mental Stress',
        Icons.spa_outlined,
      ),
      (
        'sleep_quality',
        L10nKeys.healthDashboardMetricSleepQuality,
        'Sleep Quality',
        Icons.bedtime_outlined,
      ),
    ];

    final out = <_ScoreMetric>[];
    for (final (apiKey, titleKey, fallback, icon) in keys) {
      final value = raw[apiKey];
      if (value is! Map) continue;
      final score = _asDouble(value['score']);
      if (score == null) continue;
      out.add(
        _ScoreMetric(
          titleKey: titleKey,
          fallbackTitle: fallback,
          score: score,
          confidence: _asDouble(value['confidence']),
          icon: icon,
        ),
      );
    }
    return out;
  }

  static List<_WellbeingRow> _wellbeingRows(Map<String, dynamic>? raw) {
    final wellbeing = raw?['wellbeing'];
    if (wellbeing is! Map) return const [];

    const dims = <(String, String, String, IconData)>[
      (
        'mental',
        L10nKeys.healthDashboardWellbeingMental,
        'Mental',
        Icons.self_improvement_outlined,
      ),
      (
        'physical',
        L10nKeys.healthDashboardWellbeingPhysical,
        'Physical',
        Icons.accessibility_new_outlined,
      ),
      (
        'energy_sleep',
        L10nKeys.healthDashboardWellbeingEnergySleep,
        'Energy & Sleep',
        Icons.nightlight_round,
      ),
    ];

    final out = <_WellbeingRow>[];
    for (final (apiKey, titleKey, fallback, icon) in dims) {
      final value = wellbeing[apiKey];
      if (value is! Map) continue;
      final score = _asDouble(value['score']);
      if (score == null) continue;
      out.add(
        _WellbeingRow(
          titleKey: titleKey,
          fallbackTitle: fallback,
          score: score,
          assessment: value['assessment']?.toString(),
          icon: icon,
        ),
      );
    }
    return out;
  }

  static double? _asDouble(Object? value) {
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value);
    return null;
  }
}

class _ScoreMetric {
  const _ScoreMetric({
    required this.titleKey,
    required this.fallbackTitle,
    required this.score,
    required this.icon,
    this.confidence,
  });

  final String titleKey;
  final String fallbackTitle;
  final double score;
  final double? confidence;
  final IconData icon;
}

class _WellbeingRow {
  const _WellbeingRow({
    required this.titleKey,
    required this.fallbackTitle,
    required this.score,
    required this.icon,
    this.assessment,
  });

  final String titleKey;
  final String fallbackTitle;
  final double? score;
  final String? assessment;
  final IconData icon;
}

/// Matches Health Dashboard [_BiomarkerCard] visual style.
class _DashboardMetricCard extends StatelessWidget {
  const _DashboardMetricCard({
    required this.icon,
    required this.title,
    required this.value,
    this.badge,
  });

  final IconData icon;
  final String title;
  final String value;
  final String? badge;

  @override
  Widget build(BuildContext context) {
    final iconSize = context.scaleWidth(20);
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: context.scaleWidth(8),
        vertical: context.scaleHeight(8),
      ),
      decoration: BoxDecoration(
        color: AppColors.backgroundDeep,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: AppColors.borderFocused.withAlpha(120),
          width: 0.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Icon(
                icon,
                size: iconSize,
                color: AppColors.primaryContainer,
              ),
              const Spacer(),
              if (badge != null)
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: context.scaleWidth(4),
                    vertical: context.scaleHeight(1),
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.greenLight.withAlpha(240),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    badge!,
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: context.extraSmallFontSize,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
            ],
          ),
          Expanded(
            child: Center(
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  value,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: AppColors.primaryContainer,
                    fontSize: context.scaleWidth(22),
                    fontWeight: FontWeight.w700,
                    height: 1.0,
                  ),
                ),
              ),
            ),
          ),
          Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: context.extraSmallFontSize,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.3,
                    height: 1.0,
                  ),
                ),
              ),
              SizedBox(width: context.scaleWidth(4)),
              Image.asset(
                'assets/images/warning_Info_icon.png',
                width: context.scaleWidth(25),
                height: context.scaleWidth(25),
                fit: BoxFit.contain,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
