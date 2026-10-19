import 'subscription_json.dart';
import 'subscription_plan_model.dart';

/// A subscription row. Returned by `POST /subscription/select-plan` (`data`)
/// and reused by `GET /subscription/me` (`data.subscription`).
class SelectedSubscriptionModel {
  const SelectedSubscriptionModel({
    required this.id,
    required this.status,
    required this.billingInterval,
    required this.plan,
    this.currentPeriodStart,
    this.currentPeriodEnd,
    this.externalUserId,
    this.trialEndsAt,
    this.cancelAt,
    this.cancelledAt,
    this.cancelReason,
    this.isTrialing = false,
    this.isCancelScheduled = false,
  });

  final int id;
  final String status;
  final String billingInterval;
  final SubscriptionPlanModel plan;
  final String? currentPeriodStart;
  final String? currentPeriodEnd;
  final String? externalUserId;
  final String? trialEndsAt;
  final String? cancelAt;
  final String? cancelledAt;
  final String? cancelReason;
  final bool isTrialing;
  final bool isCancelScheduled;

  factory SelectedSubscriptionModel.fromJson(Map<String, dynamic> json) {
    final plan = asJsonMap(json['plan']);
    return SelectedSubscriptionModel(
      id: asInt(json['id']) ?? 0,
      status: json['status']?.toString() ?? '',
      billingInterval: json['billing_interval']?.toString() ?? 'monthly',
      currentPeriodStart: asNullableString(json['current_period_start']),
      currentPeriodEnd: asNullableString(json['current_period_end']),
      externalUserId: json['external_user_id']?.toString(),
      trialEndsAt: asNullableString(json['trial_ends_at']),
      cancelAt: asNullableString(json['cancel_at']),
      cancelledAt: asNullableString(json['cancelled_at']),
      cancelReason: asNullableString(json['cancel_reason']),
      isTrialing: json['is_trialing'] == true,
      isCancelScheduled: json['is_cancel_scheduled'] == true,
      plan: plan == null
          ? SubscriptionPlanModel.empty
          : SubscriptionPlanModel.fromJson(plan),
    );
  }
}
