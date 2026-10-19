import 'package:equatable/equatable.dart';

/// Trial / free-plan usage for the account. Shared by `/subscription/plans`
/// (top-level `eligibility`) and `/subscription/me` (`data.eligibility`).
class SubscriptionEligibilityEntity extends Equatable {
  const SubscriptionEligibilityEntity({
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

  @override
  List<Object?> get props => [
    trialConsumed,
    freePlanConsumed,
    trialAvailable,
    trialConsumedAt,
    freePlanConsumedAt,
  ];
}
