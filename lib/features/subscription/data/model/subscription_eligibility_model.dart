import 'subscription_json.dart';

/// Trial / free-plan usage. Shared by `/subscription/plans` (top-level
/// `eligibility`) and `/subscription/me` (`data.eligibility`).
class SubscriptionEligibilityModel {
  const SubscriptionEligibilityModel({
    required this.trialConsumed,
    required this.freePlanConsumed,
    required this.trialAvailable,
    this.trialConsumedAt,
    this.freePlanConsumedAt,
  });

  final bool trialConsumed;
  final bool freePlanConsumed;
  final bool trialAvailable;
  final String? trialConsumedAt;
  final String? freePlanConsumedAt;

  factory SubscriptionEligibilityModel.fromJson(Map<String, dynamic> json) {
    return SubscriptionEligibilityModel(
      trialConsumed: json['trial_consumed'] == true,
      freePlanConsumed: json['free_plan_consumed'] == true,
      trialAvailable: json['trial_available'] == true,
      trialConsumedAt: asNullableString(json['trial_consumed_at']),
      freePlanConsumedAt: asNullableString(json['free_plan_consumed_at']),
    );
  }
}
