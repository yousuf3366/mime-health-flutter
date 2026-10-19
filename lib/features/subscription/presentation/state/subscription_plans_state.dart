import 'package:equatable/equatable.dart';

import '../../domain/entity/subscription_entity.dart';

/// Plans tab: plans list, current selection, billing period and free trial.
class SubscriptionPlansState extends Equatable {
  const SubscriptionPlansState({
    this.plans = const [],
    this.eligibility,
    this.selectedPlanCode,
    this.billingInterval = BillingInterval.monthly,
    this.isLoading = false,
    this.trialPlanCode,
    this.errorMessage,
  });

  final List<SubscriptionPlanEntity> plans;
  final SubscriptionEligibilityEntity? eligibility;
  final String? selectedPlanCode;

  /// Shared by plans, add-ons and checkout.
  final BillingInterval billingInterval;
  final bool isLoading;

  /// Plan whose free trial is being started (drives that button's spinner).
  final String? trialPlanCode;
  final String? errorMessage;

  bool get isStartingTrial => trialPlanCode != null;

  SubscriptionPlanEntity? get selectedPlan {
    final code = selectedPlanCode;
    if (code == null) return null;
    for (final plan in plans) {
      if (plan.code == code) return plan;
    }
    return null;
  }

  bool canStartTrial(SubscriptionPlanEntity plan) =>
      eligibility?.trialAvailable == true && plan.trialDays > 0;

  SubscriptionPlansState copyWith({
    List<SubscriptionPlanEntity>? plans,
    Object? eligibility = _noValue,
    Object? selectedPlanCode = _noValue,
    BillingInterval? billingInterval,
    bool? isLoading,
    Object? trialPlanCode = _noValue,
    Object? errorMessage = _noValue,
  }) {
    return SubscriptionPlansState(
      plans: plans ?? this.plans,
      eligibility: identical(eligibility, _noValue)
          ? this.eligibility
          : eligibility as SubscriptionEligibilityEntity?,
      selectedPlanCode: identical(selectedPlanCode, _noValue)
          ? this.selectedPlanCode
          : selectedPlanCode as String?,
      billingInterval: billingInterval ?? this.billingInterval,
      isLoading: isLoading ?? this.isLoading,
      trialPlanCode: identical(trialPlanCode, _noValue)
          ? this.trialPlanCode
          : trialPlanCode as String?,
      errorMessage: identical(errorMessage, _noValue)
          ? this.errorMessage
          : errorMessage as String?,
    );
  }

  @override
  List<Object?> get props => [
    plans,
    eligibility,
    selectedPlanCode,
    billingInterval,
    isLoading,
    trialPlanCode,
    errorMessage,
  ];
}

const Object _noValue = Object();
