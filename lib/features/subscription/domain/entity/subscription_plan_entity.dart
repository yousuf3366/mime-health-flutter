import 'package:equatable/equatable.dart';

import 'subscription_enums.dart';

/// One service included in a plan (limit, feature, biomarker, metric, ...).
/// Shared by `/subscription/plans`, `/select-plan` and `/me`.
class SubscriptionServiceEntity extends Equatable {
  const SubscriptionServiceEntity({
    required this.code,
    required this.name,
    required this.type,
  });

  final String code;
  final String name;

  /// `limit` | `feature` | `biomarker` | `metric` | `device` | `partner_cta`.
  final String type;

  @override
  List<Object?> get props => [code, name, type];
}

/// One subscription plan. Shared by `/subscription/plans`, `/select-plan`
/// and `/me` (`subscription.plan`).
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
    this.services = const [],
    this.pricingMode,
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
  final List<SubscriptionServiceEntity> services;
  final String? pricingMode;
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
    services,
    pricingMode,
    image,
  ];
}
