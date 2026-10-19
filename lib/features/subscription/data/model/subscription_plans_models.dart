import 'subscription_eligibility_model.dart';
import 'subscription_json.dart';
import 'subscription_plan_model.dart';

/// Response of `GET /subscription/plans`.
class SubscriptionPlansResponseModel {
  const SubscriptionPlansResponseModel({
    required this.success,
    required this.message,
    required this.plans,
    this.eligibility,
  });

  final bool success;
  final String message;

  /// `data[]`, sorted by `sort_order`.
  final List<SubscriptionPlanModel> plans;

  /// Top-level `eligibility` (sibling of `data`).
  final SubscriptionEligibilityModel? eligibility;

  factory SubscriptionPlansResponseModel.fromJson(Map<String, dynamic> json) {
    final raw = json['data'];
    final eligibility = asJsonMap(json['eligibility']);
    final plans = raw is List
        ? raw
              .whereType<Map>()
              .map(
                (e) => SubscriptionPlanModel.fromJson(
                  Map<String, dynamic>.from(e),
                ),
              )
              .toList()
        : <SubscriptionPlanModel>[];
    plans.sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
    return SubscriptionPlansResponseModel(
      success: json['success'] == true,
      message: json['message']?.toString() ?? '',
      plans: plans,
      eligibility: eligibility == null
          ? null
          : SubscriptionEligibilityModel.fromJson(eligibility),
    );
  }
}
