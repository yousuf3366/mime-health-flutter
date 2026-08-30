import 'package:equatable/equatable.dart';

enum BillingInterval {
  monthly,
  annual;

  String get apiValue => name;

  static BillingInterval fromApi(String? value) {
    switch (value?.trim().toLowerCase()) {
      case 'annual':
      case 'yearly':
        return BillingInterval.annual;
      default:
        return BillingInterval.monthly;
    }
  }
}

/// One subscription plan from `GET /subscription/plans`.
class SubscriptionPlanEntity extends Equatable {
  const SubscriptionPlanEntity({
    required this.code,
    required this.name,
    required this.tierType,
    required this.maxProfiles,
    required this.includedPrimaryDevices,
    required this.includedSecondaryDevices,
    required this.maxAdditionalDevices,
    required this.biomarkerCodes,
    required this.metricCodes,
    required this.monthlyPriceBdt,
    required this.annualPriceBdt,
    required this.trialDays,
    required this.sortOrder,
    this.image,
    this.monthlyScanQuota,
    this.historyRetentionDays,
  });

  final String code;
  final String name;
  final String tierType;
  final int maxProfiles;
  final int includedPrimaryDevices;
  final int includedSecondaryDevices;
  final int maxAdditionalDevices;
  final int? monthlyScanQuota;
  final List<String> biomarkerCodes;
  final List<String> metricCodes;
  final int? historyRetentionDays;
  final String monthlyPriceBdt;
  final String annualPriceBdt;
  final int trialDays;
  final int sortOrder;
  final String? image;

  bool get isFree => code == 'free' || monthlyPriceBdt == '0.00';

  String priceFor(BillingInterval interval) =>
      interval == BillingInterval.annual ? annualPriceBdt : monthlyPriceBdt;

  @override
  List<Object?> get props => [
    code,
    name,
    tierType,
    maxProfiles,
    monthlyScanQuota,
    monthlyPriceBdt,
    annualPriceBdt,
    sortOrder,
    image,
  ];
}

/// Result of `POST /subscription/select-plan`.
class SelectedSubscriptionEntity extends Equatable {
  const SelectedSubscriptionEntity({
    required this.id,
    required this.status,
    required this.billingInterval,
    required this.plan,
    this.currentPeriodStart,
    this.currentPeriodEnd,
    this.externalUserId,
  });

  final int id;
  final String status;
  final BillingInterval billingInterval;
  final SubscriptionPlanEntity plan;
  final String? currentPeriodStart;
  final String? currentPeriodEnd;
  final String? externalUserId;

  bool get isActive => status.trim().toLowerCase() == 'active';

  @override
  List<Object?> get props => [id, status, billingInterval, plan];
}

/// Result of `GET /api/v1/subscription/me`.
class MySubscriptionEntity extends Equatable {
  const MySubscriptionEntity({
    required this.subscription,
    this.entitlements,
    this.quota,
  });

  final SelectedSubscriptionEntity subscription;
  final SubscriptionEntitlementsEntity? entitlements;
  final SubscriptionQuotaEntity? quota;

  bool get hasActivePlan => subscription.isActive;

  @override
  List<Object?> get props => [subscription, entitlements, quota];
}

class SubscriptionEntitlementsEntity extends Equatable {
  const SubscriptionEntitlementsEntity({
    required this.maxProfiles,
    required this.monthlyScanQuota,
    required this.biomarkerCodes,
    required this.metricCodes,
    required this.isPaid,
    this.historyRetentionDays,
    this.daysUntilPeriodEnd,
  });

  final int maxProfiles;
  final int monthlyScanQuota;
  final List<String> biomarkerCodes;
  final List<String> metricCodes;
  final int? historyRetentionDays;
  final bool isPaid;
  final int? daysUntilPeriodEnd;

  @override
  List<Object?> get props => [maxProfiles, monthlyScanQuota, isPaid];
}

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
