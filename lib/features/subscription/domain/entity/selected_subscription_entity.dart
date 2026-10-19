import 'package:equatable/equatable.dart';

import 'subscription_enums.dart';
import 'subscription_plan_entity.dart';

/// A subscription row. Returned by `POST /subscription/select-plan` (`data`)
/// and reused by `GET /subscription/me` (`data.subscription`).
class SelectedSubscriptionEntity extends Equatable {
  const SelectedSubscriptionEntity({
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

  /// Raw subscription row status. For "is the plan active?" use
  /// `MySubscriptionEntity.hasActivePlan` (top-level `data.status`).
  final String status;
  final BillingInterval billingInterval;
  final SubscriptionPlanEntity plan;
  final String? currentPeriodStart;
  final String? currentPeriodEnd;
  final String? externalUserId;
  final String? trialEndsAt;
  final String? cancelAt;
  final String? cancelledAt;
  final String? cancelReason;
  final bool isTrialing;
  final bool isCancelScheduled;

  @override
  List<Object?> get props => [
    id,
    status,
    billingInterval,
    plan,
    currentPeriodStart,
    currentPeriodEnd,
    externalUserId,
    trialEndsAt,
    cancelAt,
    cancelledAt,
    cancelReason,
    isTrialing,
    isCancelScheduled,
  ];
}
