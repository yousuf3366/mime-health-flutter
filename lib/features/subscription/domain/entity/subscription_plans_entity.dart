import 'package:equatable/equatable.dart';

import 'subscription_eligibility_entity.dart';
import 'subscription_plan_entity.dart';

/// Result of `GET /subscription/plans`: the plans plus account eligibility.
class SubscriptionPlansResultEntity extends Equatable {
  const SubscriptionPlansResultEntity({required this.plans, this.eligibility});

  final List<SubscriptionPlanEntity> plans;
  final SubscriptionEligibilityEntity? eligibility;

  @override
  List<Object?> get props => [plans, eligibility];
}
