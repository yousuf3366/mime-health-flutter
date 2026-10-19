import 'selected_subscription_model.dart';
import 'subscription_eligibility_model.dart';
import 'subscription_json.dart';

/// Response of `GET /subscription/me`.
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
    final data = asJsonMap(json['data']);
    return MySubscriptionResponseModel(
      success: json['success'] == true,
      message: json['message']?.toString() ?? '',
      data: data == null ? null : MySubscriptionDataModel.fromJson(data),
      errors: asStringList(json['errors']),
    );
  }
}

/// `data` of the `/subscription/me` response.
class MySubscriptionDataModel {
  const MySubscriptionDataModel({
    required this.status,
    this.subscription,
    this.pendingPlanChange,
    this.eligibility,
    this.addons = const [],
    this.quota,
  });

  final String status;
  final SelectedSubscriptionModel? subscription;

  /// Shape not finalised by the API yet, so it is kept as raw JSON.
  final Map<String, dynamic>? pendingPlanChange;
  final SubscriptionEligibilityModel? eligibility;
  final List<SubscriptionAddonModel> addons;
  final SubscriptionQuotaModel? quota;

  factory MySubscriptionDataModel.fromJson(Map<String, dynamic> json) {
    final subscription = asJsonMap(json['subscription']);
    final eligibility = asJsonMap(json['eligibility']);
    final quota = asJsonMap(json['quota']);
    final addons = json['addons_services'];
    return MySubscriptionDataModel(
      status: json['status']?.toString() ?? '',
      subscription: subscription == null
          ? null
          : SelectedSubscriptionModel.fromJson(subscription),
      pendingPlanChange: asJsonMap(json['pending_plan_change']),
      eligibility: eligibility == null
          ? null
          : SubscriptionEligibilityModel.fromJson(eligibility),
      addons: addons is List
          ? addons
                .whereType<Map>()
                .map(
                  (e) => SubscriptionAddonModel.fromJson(
                    Map<String, dynamic>.from(e),
                  ),
                )
                .toList(growable: false)
          : const [],
      quota: quota == null ? null : SubscriptionQuotaModel.fromJson(quota),
    );
  }
}

/// One entry of `data.addons_services`.
class SubscriptionAddonModel {
  const SubscriptionAddonModel({
    required this.id,
    required this.code,
    required this.name,
    required this.status,
    required this.billingInterval,
    required this.amountBdt,
    this.purchaseType,
    this.serviceType,
    this.startsAt,
    this.endsAt,
    this.daysUntilExpiry,
    this.subscriptionId,
    this.lastPaymentId,
  });

  final int id;
  final String code;
  final String name;
  final String status;
  final String billingInterval;
  final String amountBdt;
  final String? purchaseType;
  final String? serviceType;
  final String? startsAt;
  final String? endsAt;
  final int? daysUntilExpiry;
  final int? subscriptionId;
  final int? lastPaymentId;

  factory SubscriptionAddonModel.fromJson(Map<String, dynamic> json) {
    return SubscriptionAddonModel(
      id: asInt(json['id']) ?? 0,
      code: json['code']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      status: json['status']?.toString() ?? '',
      billingInterval: json['billing_interval']?.toString() ?? '',
      amountBdt: json['amount_bdt']?.toString() ?? '0.00',
      purchaseType: asNullableString(json['purchase_type']),
      serviceType: asNullableString(json['service_type']),
      startsAt: asNullableString(json['starts_at']),
      endsAt: asNullableString(json['ends_at']),
      daysUntilExpiry: asInt(json['days_until_expiry']),
      subscriptionId: asInt(json['subscription_id']),
      lastPaymentId: asInt(json['last_payment_id']),
    );
  }
}

/// `data.quota` — monthly scan usage.
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
      periodYear: asInt(json['period_year']) ?? 0,
      periodMonth: asInt(json['period_month']) ?? 0,
      scansUsed: asInt(json['scans_used']) ?? 0,
      quotaLimit: asInt(json['quota_limit']) ?? 0,
      remaining: asInt(json['remaining']) ?? 0,
    );
  }
}
