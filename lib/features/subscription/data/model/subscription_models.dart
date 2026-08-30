import '../../domain/entity/subscription_entity.dart';

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
    this.image,
    this.monthlyScanQuota,
    this.historyRetentionDays,
  });

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
  final String? image;

  factory SubscriptionPlanModel.fromJson(Map<String, dynamic> json) {
    return SubscriptionPlanModel(
      code: json['code']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      tierType: json['tier_type']?.toString() ?? '',
      maxProfiles: _asInt(json['max_profiles']) ?? 0,
      includedPrimaryDevices: _asInt(json['included_primary_devices']) ?? 0,
      includedSecondaryDevices: _asInt(json['included_secondary_devices']) ?? 0,
      maxAdditionalDevices: _asInt(json['max_additional_devices']) ?? 0,
      monthlyScanQuota: _asInt(json['monthly_scan_quota']),
      biomarkerCodes: _asStringList(json['biomarker_codes']),
      metricCodes: _asStringList(json['metric_codes']),
      historyRetentionDays: _asInt(json['history_retention_days']),
      monthlyPriceBdt: json['monthly_price_bdt']?.toString() ?? '0.00',
      annualPriceBdt: json['annual_price_bdt']?.toString() ?? '0.00',
      trialDays: _asInt(json['trial_days']) ?? 0,
      sortOrder: _asInt(json['sort_order']) ?? 0,
      image: _asNullableString(json['image']),
    );
  }
}

class SubscriptionPlansResponseModel {
  const SubscriptionPlansResponseModel({
    required this.success,
    required this.message,
    required this.plans,
  });

  final bool success;
  final String message;
  final List<SubscriptionPlanModel> plans;

  factory SubscriptionPlansResponseModel.fromJson(Map<String, dynamic> json) {
    final raw = json['data'];
    final plans = <SubscriptionPlanModel>[];
    if (raw is List) {
      for (final item in raw) {
        if (item is Map) {
          plans.add(
            SubscriptionPlanModel.fromJson(Map<String, dynamic>.from(item)),
          );
        }
      }
    }
    plans.sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
    return SubscriptionPlansResponseModel(
      success: json['success'] == true,
      message: json['message']?.toString() ?? '',
      plans: plans,
    );
  }
}

class SelectPlanRequestModel {
  const SelectPlanRequestModel({
    required this.planCode,
    required this.billingInterval,
  });

  final String planCode;
  final BillingInterval billingInterval;

  Map<String, dynamic> toJson() => {
    'plan_code': planCode,
    'billing_interval': billingInterval.apiValue,
  };
}

class SelectPlanResponseModel {
  const SelectPlanResponseModel({
    required this.success,
    required this.message,
    this.data,
  });

  final bool success;
  final String message;
  final SelectedSubscriptionModel? data;

  factory SelectPlanResponseModel.fromJson(Map<String, dynamic> json) {
    final dataRaw = json['data'];
    return SelectPlanResponseModel(
      success: json['success'] == true,
      message: json['message']?.toString() ?? '',
      data: dataRaw is Map
          ? SelectedSubscriptionModel.fromJson(
              Map<String, dynamic>.from(dataRaw),
            )
          : null,
    );
  }
}

class SelectedSubscriptionModel {
  const SelectedSubscriptionModel({
    required this.id,
    required this.status,
    required this.billingInterval,
    required this.plan,
    this.currentPeriodStart,
    this.currentPeriodEnd,
    this.externalUserId,
  });

  final int id;
  final String status;
  final String billingInterval;
  final SubscriptionPlanModel plan;
  final String? currentPeriodStart;
  final String? currentPeriodEnd;
  final String? externalUserId;

  factory SelectedSubscriptionModel.fromJson(Map<String, dynamic> json) {
    final planRaw = json['plan'];
    return SelectedSubscriptionModel(
      id: _asInt(json['id']) ?? 0,
      status: json['status']?.toString() ?? '',
      billingInterval: json['billing_interval']?.toString() ?? 'monthly',
      currentPeriodStart: json['current_period_start']?.toString(),
      currentPeriodEnd: json['current_period_end']?.toString(),
      externalUserId: json['external_user_id']?.toString(),
      plan: planRaw is Map
          ? SubscriptionPlanModel.fromJson(Map<String, dynamic>.from(planRaw))
          : const SubscriptionPlanModel(
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
            ),
    );
  }
}

class MySubscriptionResponseModel {
  const MySubscriptionResponseModel({
    required this.success,
    required this.message,
    this.data,
    this.errors = const [],
  });

  final bool success;
  final String message;
  final MySubscriptionDataModel? data;
  final List<String> errors;

  factory MySubscriptionResponseModel.fromJson(Map<String, dynamic> json) {
    final dataRaw = json['data'];
    final errorsRaw = json['errors'];
    return MySubscriptionResponseModel(
      success: json['success'] == true,
      message: json['message']?.toString() ?? '',
      data: dataRaw is Map
          ? MySubscriptionDataModel.fromJson(Map<String, dynamic>.from(dataRaw))
          : null,
      errors: errorsRaw is List
          ? errorsRaw.map((e) => e.toString()).toList(growable: false)
          : const [],
    );
  }
}

class MySubscriptionDataModel {
  const MySubscriptionDataModel({
    this.subscription,
    this.entitlements,
    this.quota,
  });

  final SelectedSubscriptionModel? subscription;
  final SubscriptionEntitlementsModel? entitlements;
  final SubscriptionQuotaModel? quota;

  factory MySubscriptionDataModel.fromJson(Map<String, dynamic> json) {
    final subRaw = json['subscription'];
    final entRaw = json['entitlements'];
    final quotaRaw = json['quota'];
    return MySubscriptionDataModel(
      subscription: subRaw is Map
          ? SelectedSubscriptionModel.fromJson(
              Map<String, dynamic>.from(subRaw),
            )
          : null,
      entitlements: entRaw is Map
          ? SubscriptionEntitlementsModel.fromJson(
              Map<String, dynamic>.from(entRaw),
            )
          : null,
      quota: quotaRaw is Map
          ? SubscriptionQuotaModel.fromJson(Map<String, dynamic>.from(quotaRaw))
          : null,
    );
  }
}

class SubscriptionEntitlementsModel {
  const SubscriptionEntitlementsModel({
    required this.maxProfiles,
    required this.monthlyScanQuota,
    required this.biomarkerCodes,
    required this.metricCodes,
    required this.isPaid,
    this.historyRetentionDays,
    this.daysUntilPeriodEnd,
  });

  final int maxProfiles;
  final int monthlyScanQuota;
  final List<String> biomarkerCodes;
  final List<String> metricCodes;
  final int? historyRetentionDays;
  final bool isPaid;
  final int? daysUntilPeriodEnd;

  factory SubscriptionEntitlementsModel.fromJson(Map<String, dynamic> json) {
    return SubscriptionEntitlementsModel(
      maxProfiles: _asInt(json['max_profiles']) ?? 0,
      monthlyScanQuota: _asInt(json['monthly_scan_quota']) ?? 0,
      biomarkerCodes: _asStringList(json['biomarker_codes']),
      metricCodes: _asStringList(json['metric_codes']),
      historyRetentionDays: _asInt(json['history_retention_days']),
      isPaid: json['is_paid'] == true,
      daysUntilPeriodEnd: _asInt(json['days_until_period_end']),
    );
  }
}

class SubscriptionQuotaModel {
  const SubscriptionQuotaModel({
    required this.periodYear,
    required this.periodMonth,
    required this.scansUsed,
    required this.quotaLimit,
    required this.remaining,
  });

  final int periodYear;
  final int periodMonth;
  final int scansUsed;
  final int quotaLimit;
  final int remaining;

  factory SubscriptionQuotaModel.fromJson(Map<String, dynamic> json) {
    return SubscriptionQuotaModel(
      periodYear: _asInt(json['period_year']) ?? 0,
      periodMonth: _asInt(json['period_month']) ?? 0,
      scansUsed: _asInt(json['scans_used']) ?? 0,
      quotaLimit: _asInt(json['quota_limit']) ?? 0,
      remaining: _asInt(json['remaining']) ?? 0,
    );
  }
}

int? _asInt(dynamic value) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  return int.tryParse(value?.toString() ?? '');
}

List<String> _asStringList(dynamic value) {
  if (value is! List) return const [];
  return value.map((e) => e.toString()).toList(growable: false);
}

String? _asNullableString(dynamic value) {
  final text = value?.toString().trim();
  return text == null || text.isEmpty ? null : text;
}
