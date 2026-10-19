import '../../domain/entity/subscription_enums.dart';
import 'selected_subscription_model.dart';
import 'subscription_json.dart';

/// Request body of `POST /subscription/select-plan`.
class SelectPlanRequestModel {
  const SelectPlanRequestModel({
    required this.planCode,
    required this.billingInterval,
    this.useTrial = false,
  });

  final String planCode;
  final BillingInterval billingInterval;

  /// Starts the plan's free trial instead of a paid subscription.
  final bool useTrial;

  Map<String, dynamic> toJson() => {
    'plan_code': planCode,
    'billing_interval': billingInterval.apiValue,
    if (useTrial) 'use_trial': true,
  };
}

/// Response of `POST /subscription/select-plan`.
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
    final data = asJsonMap(json['data']);
    return SelectPlanResponseModel(
      success: json['success'] == true,
      message: json['message']?.toString() ?? '',
      data: data == null ? null : SelectedSubscriptionModel.fromJson(data),
    );
  }
}
