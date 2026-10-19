import 'package:equatable/equatable.dart';

import 'subscription_enums.dart';

/// An add-on service the user can buy (`GET /subscription/services`).
class SubscriptionServiceOfferEntity extends Equatable {
  const SubscriptionServiceOfferEntity({
    required this.code,
    required this.name,
    required this.type,
    required this.monthlyPriceBdt,
    required this.annualPriceBdt,
    this.description,
  });

  final String code;
  final String name;

  /// e.g. `biomarker`, `metric`.
  final String type;
  final String monthlyPriceBdt;
  final String annualPriceBdt;
  final String? description;

  String priceFor(BillingInterval interval) =>
      interval == BillingInterval.annual ? annualPriceBdt : monthlyPriceBdt;

  @override
  List<Object?> get props => [
    code,
    name,
    type,
    monthlyPriceBdt,
    annualPriceBdt,
    description,
  ];
}
