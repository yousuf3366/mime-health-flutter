import 'subscription_json.dart';

/// One entry of a plan's `services` list. Shared by `/subscription/plans`,
/// `/select-plan` and `/me`.
class SubscriptionServiceModel {
  const SubscriptionServiceModel({
    required this.code,
    required this.name,
    required this.type,
  });

  final String code;
  final String name;

  /// `limit` | `feature` | `biomarker` | `metric` | `device` | `partner_cta`.
  final String type;

  factory SubscriptionServiceModel.fromJson(Map<String, dynamic> json) {
    return SubscriptionServiceModel(
      code: json['code']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      type: json['type']?.toString().trim().toLowerCase() ?? '',
    );
  }
}

/// One subscription plan. Shared by `/subscription/plans` (`data[]`),
/// `/select-plan` and `/me` (`subscription.plan`).
class SubscriptionPlanModel {
  const SubscriptionPlanModel({
    required this.code,
    required this.name,
    required this.tierType,
    required this.maxProfiles,
    required this.includedPrimaryDevices,
    required this.includedSecondaryDevices,
    required this.maxAdditionalDevices,
    required this.biomarkerCodes,
    required this.metricCodes,
    required this.monthlyPriceBdt,
    required this.annualPriceBdt,
    required this.trialDays,
    required this.sortOrder,
    this.services = const [],
    this.pricingMode,
    this.image,
    this.monthlyScanQuota,
    this.historyRetentionDays,
  });

  /// Placeholder when a response omits the plan object.
  static const empty = SubscriptionPlanModel(
    code: '',
    name: '',
    tierType: '',
    maxProfiles: 0,
    includedPrimaryDevices: 0,
    includedSecondaryDevices: 0,
    maxAdditionalDevices: 0,
    biomarkerCodes: [],
    metricCodes: [],
    monthlyPriceBdt: '0.00',
    annualPriceBdt: '0.00',
    trialDays: 0,
    sortOrder: 0,
  );

  final String code;
  final String name;
  final String tierType;
  final int maxProfiles;
  final int includedPrimaryDevices;
  final int includedSecondaryDevices;
  final int maxAdditionalDevices;
  final int? monthlyScanQuota;
  final List<String> biomarkerCodes;
  final List<String> metricCodes;
  final int? historyRetentionDays;
  final String monthlyPriceBdt;
  final String annualPriceBdt;
  final int trialDays;
  final int sortOrder;
  final List<SubscriptionServiceModel> services;
  final String? pricingMode;
  final String? image;

  factory SubscriptionPlanModel.fromJson(Map<String, dynamic> json) {
    final services = _asServices(json['services']);

    List<String> codesOfType(String type, String legacyKey) {
      final legacy = asStringList(json[legacyKey]);
      if (legacy.isNotEmpty) return legacy;
      return services
          .where((s) => s.type == type && s.code.isNotEmpty)
          .map((s) => s.code)
          .toList(growable: false);
    }

    return SubscriptionPlanModel(
      code: json['code']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      tierType: json['tier_type']?.toString() ?? '',
      maxProfiles: asInt(json['max_profiles']) ?? 0,
      includedPrimaryDevices: asInt(json['included_primary_devices']) ?? 0,
      includedSecondaryDevices: asInt(json['included_secondary_devices']) ?? 0,
      maxAdditionalDevices: asInt(json['max_additional_devices']) ?? 0,
      monthlyScanQuota: asInt(json['monthly_scan_quota']),
      biomarkerCodes: codesOfType('biomarker', 'biomarker_codes'),
      metricCodes: codesOfType('metric', 'metric_codes'),
      historyRetentionDays: asInt(json['history_retention_days']),
      monthlyPriceBdt: json['monthly_price_bdt']?.toString() ?? '0.00',
      annualPriceBdt: json['annual_price_bdt']?.toString() ?? '0.00',
      trialDays: asInt(json['trial_days']) ?? 0,
      sortOrder: asInt(json['sort_order']) ?? 0,
      services: services,
      pricingMode: asNullableString(json['pricing_mode']),
      image:
          asNullableString(json['image_path']) ??
          asNullableString(json['image']),
    );
  }
}

/// Accepts either a flat list or a `{type: [service, ...]}` map.
List<SubscriptionServiceModel> _asServices(Object? value) {
  final items = switch (value) {
    List() => value,
    Map() => value.values.whereType<List>().expand((list) => list),
    _ => const [],
  };
  return items
      .whereType<Map>()
      .map(
        (e) => SubscriptionServiceModel.fromJson(Map<String, dynamic>.from(e)),
      )
      .toList(growable: false);
}
