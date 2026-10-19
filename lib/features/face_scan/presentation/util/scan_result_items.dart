import 'package:flutter/material.dart';

import '../../../../core/localization/l10n_keys.dart';
import '../../../language/presentation/controller/language_controller.dart';

/// One card on the scan result screens.
class ScanResultItem {
  const ScanResultItem({
    required this.title,
    required this.value,
    this.icon = Icons.insights_outlined,
    this.svgAsset,
    this.badge,
  });

  final String title;
  final String value;
  final IconData icon;
  final String? svgAsset;
  final String? badge;
}

typedef _Known = ({
  String titleKey,
  String fallback,
  String Function(String value) format,
  String? svgAsset,
  IconData icon,
});

const _systolic = 'systolic_blood_pressure';
const _diastolic = 'diastolic_blood_pressure';

final Map<String, _Known> _knownBiomarkers = {
  'heart_rate': (
    titleKey: L10nKeys.healthDashboardHeartRate,
    fallback: 'Heart Rate',
    format: (v) => '$v BPM',
    svgAsset: 'assets/images/heart_rate_Icon.svg',
    icon: Icons.favorite_outline,
  ),
  'respiratory_rate': (
    titleKey: L10nKeys.healthDashboardRespRate,
    fallback: 'Resp. Rate',
    format: (v) => '$v/MIN',
    svgAsset: 'assets/images/resporitory_icon.svg',
    icon: Icons.air,
  ),
  'resonant_breathing_score': (
    titleKey: L10nKeys.healthResonantBreathingScore,
    fallback: 'Breathing Score',
    format: (v) => v,
    svgAsset: 'assets/images/resporitory_icon.svg',
    icon: Icons.air,
  ),
  'heart_rate_variability': (
    titleKey: L10nKeys.healthDashboardHrv,
    fallback: 'Heart Rate Variability',
    format: (v) => '$v ms',
    svgAsset: 'assets/images/heart_rate_Icon.svg',
    icon: Icons.monitor_heart_outlined,
  ),
  _systolic: (
    titleKey: L10nKeys.healthDashboardSystolicBp,
    fallback: 'Systolic BP',
    format: (v) => '$v mmHg',
    svgAsset: 'assets/images/blood_pressure_icon.svg',
    icon: Icons.bloodtype_outlined,
  ),
  _diastolic: (
    titleKey: L10nKeys.healthDashboardDiastolicBp,
    fallback: 'Diastolic BP',
    format: (v) => '$v mmHg',
    svgAsset: 'assets/images/blood_pressure_icon.svg',
    icon: Icons.bloodtype_outlined,
  ),
};

const Map<String, (String, String, IconData)> _knownMetrics = {
  'energy_balance': (
    L10nKeys.healthDashboardMetricEnergyBalance,
    'Energy Balance',
    Icons.bolt_outlined,
  ),
  'general_fitness': (
    L10nKeys.healthDashboardMetricGeneralFitness,
    'General Fitness',
    Icons.fitness_center_outlined,
  ),
  'hypertension': (
    L10nKeys.healthDashboardMetricHypertension,
    'Hypertension',
    Icons.monitor_heart_outlined,
  ),
  'mental_health_risk': (
    L10nKeys.healthDashboardMetricMentalHealthRisk,
    'Mental Health Risk',
    Icons.psychology_outlined,
  ),
  'mental_stress': (
    L10nKeys.healthDashboardMetricMentalStress,
    'Mental Stress',
    Icons.spa_outlined,
  ),
  'sleep_quality': (
    L10nKeys.healthDashboardMetricSleepQuality,
    'Sleep Quality',
    Icons.bedtime_outlined,
  ),
};

const Map<String, (String, String, IconData)> _knownWellbeing = {
  'mental': (
    L10nKeys.healthDashboardWellbeingMental,
    'Mental',
    Icons.self_improvement_outlined,
  ),
  'physical': (
    L10nKeys.healthDashboardWellbeingPhysical,
    'Physical',
    Icons.accessibility_new_outlined,
  ),
  'energy_sleep': (
    L10nKeys.healthDashboardWellbeingEnergySleep,
    'Energy & Sleep',
    Icons.nightlight_round,
  ),
};

/// Biomarker cards for exactly the keys present in [raw], in response order.
/// Systolic + diastolic are merged into one blood-pressure card when both
/// exist.
List<ScanResultItem> biomarkerItems(
  Map<String, dynamic> raw,
  LanguageState l10n,
) {
  final systolic = _number(raw[_systolic]);
  final diastolic = _number(raw[_diastolic]);
  final mergeBp = systolic != null && diastolic != null;
  var bpAdded = false;

  final items = <ScanResultItem>[];
  for (final MapEntry(:key, :value) in raw.entries) {
    if (mergeBp && (key == _systolic || key == _diastolic)) {
      if (bpAdded) continue;
      bpAdded = true;
      items.add(
        ScanResultItem(
          title: l10n.t(
            L10nKeys.healthDashboardBloodPressure,
            fallback: 'Blood Pressure',
          ),
          value: '${_format(systolic)}/${_format(diastolic)}',
          svgAsset: 'assets/images/blood_pressure_icon.svg',
          icon: Icons.bloodtype_outlined,
        ),
      );
      continue;
    }

    final text = _displayValue(value);
    if (text == null) continue;
    final known = _knownBiomarkers[key];
    items.add(
      known == null
          ? ScanResultItem(
              title: humanizeCode(key),
              value: text,
              icon: Icons.monitor_heart_outlined,
            )
          : ScanResultItem(
              title: l10n.t(known.titleKey, fallback: known.fallback),
              value: known.format(text),
              svgAsset: known.svgAsset,
              icon: known.icon,
            ),
    );
  }
  return items;
}

/// Score metrics (`{score, confidence}` entries) present in [raw]; the
/// `wellbeing` block is handled by [wellbeingItems].
List<ScanResultItem> metricItems(
  Map<String, dynamic>? raw,
  LanguageState l10n,
) {
  if (raw == null) return const [];
  final items = <ScanResultItem>[];
  for (final MapEntry(:key, :value) in raw.entries) {
    if (key == 'wellbeing' || value is! Map) continue;
    final score = _number(value['score']);
    if (score == null) continue;
    final confidence = _number(value['confidence']);
    final known = _knownMetrics[key];
    items.add(
      ScanResultItem(
        title: known == null
            ? humanizeCode(key)
            : l10n.t(known.$1, fallback: known.$2),
        value: _format(score),
        icon: known?.$3 ?? Icons.insights_outlined,
        badge: confidence == null ? null : '${confidence.round()}%',
      ),
    );
  }
  return items;
}

/// Wellbeing dimensions (`metrics.wellbeing.*` with a score) present in [raw].
List<ScanResultItem> wellbeingItems(
  Map<String, dynamic>? raw,
  LanguageState l10n,
) {
  final wellbeing = raw?['wellbeing'];
  if (wellbeing is! Map) return const [];
  final items = <ScanResultItem>[];
  for (final MapEntry(:key, :value) in wellbeing.entries) {
    if (value is! Map) continue;
    final score = _number(value['score']);
    if (score == null) continue;
    final known = _knownWellbeing[key];
    final assessment = value['assessment']?.toString().trim();
    items.add(
      ScanResultItem(
        title: known == null
            ? humanizeCode('$key')
            : l10n.t(known.$1, fallback: known.$2),
        value: _format(score),
        icon: known?.$3 ?? Icons.insights_outlined,
        badge: assessment == null || assessment.isEmpty
            ? null
            : humanizeCode(assessment),
      ),
    );
  }
  return items;
}

/// `heart_rate_variability` → `Heart Rate Variability`.
String humanizeCode(String code) => code
    .split(RegExp(r'[_\s]+'))
    .where((w) => w.isNotEmpty)
    .map((w) => w[0].toUpperCase() + w.substring(1).toLowerCase())
    .join(' ');

String? _displayValue(Object? value) {
  final number = _number(value);
  if (number != null) return _format(number);
  if (value is String && value.trim().isNotEmpty) return value.trim();
  return null;
}

double? _number(Object? value) {
  if (value is num) return value.toDouble();
  if (value is String) return double.tryParse(value);
  return null;
}

String _format(double value) => value.toStringAsFixed(value % 1 == 0 ? 0 : 1);
