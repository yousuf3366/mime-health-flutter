import 'package:equatable/equatable.dart';

import 'selected_subscription_entity.dart';
import 'subscription_eligibility_entity.dart';

/// Result of `GET /subscription/me`.
class MySubscriptionEntity extends Equatable {
  const MySubscriptionEntity({
    required this.status,
    this.subscription,
    this.pendingPlanChange,
    this.eligibility,
    this.addons = const [],
    this.quota,
  });

  /// Top-level `data.status` — the single source of truth for plan state.
  final String status;
  final SelectedSubscriptionEntity? subscription;

  /// Raw `data.pending_plan_change` (shape not finalised by the API).
  final Map<String, dynamic>? pendingPlanChange;
  final SubscriptionEligibilityEntity? eligibility;
  final List<SubscriptionAddonEntity> addons;
  final SubscriptionQuotaEntity? quota;

  bool get hasActivePlan => status.trim().toLowerCase() == 'active';

  bool get hasPendingPlanChange => pendingPlanChange != null;

  @override
  List<Object?> get props => [
    status,
    subscription,
    pendingPlanChange,
    eligibility,
    addons,
    quota,
  ];
}

/// A purchased add-on service (`data.addons_services[]`).
class SubscriptionAddonEntity extends Equatable {
  const SubscriptionAddonEntity({
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

  /// e.g. `one_time`, `monthly`, `annual`.
  final String billingInterval;
  final String amountBdt;
  final String? purchaseType;
  final String? serviceType;
  final String? startsAt;
  final String? endsAt;
  final int? daysUntilExpiry;
  final int? subscriptionId;
  final int? lastPaymentId;

  bool get isActive => status.trim().toLowerCase() == 'active';

  @override
  List<Object?> get props => [
    id,
    code,
    name,
    status,
    billingInterval,
    amountBdt,
    purchaseType,
    serviceType,
    startsAt,
    endsAt,
    daysUntilExpiry,
    subscriptionId,
    lastPaymentId,
  ];
}

/// Monthly scan usage (`data.quota`).
class SubscriptionQuotaEntity extends Equatable {
  const SubscriptionQuotaEntity({
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

  @override
  List<Object?> get props => [
    periodYear,
    periodMonth,
    scansUsed,
    quotaLimit,
    remaining,
  ];
}
