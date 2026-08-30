import 'package:equatable/equatable.dart';

import '../../domain/entity/subscription_entity.dart';

class SubscriptionPlansState extends Equatable {
  const SubscriptionPlansState({
    this.plans = const [],
    this.selectedPlanCode,
    this.billingInterval = BillingInterval.monthly,
    this.isLoading = false,
    this.isSubmitting = false,
    this.errorMessage,
  });

  final List<SubscriptionPlanEntity> plans;
  final String? selectedPlanCode;
  final BillingInterval billingInterval;
  final bool isLoading;
  final bool isSubmitting;
  final String? errorMessage;

  SubscriptionPlanEntity? get selectedPlan {
    final code = selectedPlanCode;
    if (code == null) return null;
    for (final plan in plans) {
      if (plan.code == code) return plan;
    }
    return null;
  }

  SubscriptionPlansState copyWith({
    List<SubscriptionPlanEntity>? plans,
    Object? selectedPlanCode = _noValue,
    BillingInterval? billingInterval,
    bool? isLoading,
    bool? isSubmitting,
    Object? errorMessage = _noValue,
  }) {
    return SubscriptionPlansState(
      plans: plans ?? this.plans,
      selectedPlanCode: identical(selectedPlanCode, _noValue)
          ? this.selectedPlanCode
          : selectedPlanCode as String?,
      billingInterval: billingInterval ?? this.billingInterval,
      isLoading: isLoading ?? this.isLoading,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      errorMessage: identical(errorMessage, _noValue)
          ? this.errorMessage
          : errorMessage as String?,
    );
  }

  @override
  List<Object?> get props => [
        plans,
        selectedPlanCode,
        billingInterval,
        isLoading,
        isSubmitting,
        errorMessage,
      ];
}

const Object _noValue = Object();
