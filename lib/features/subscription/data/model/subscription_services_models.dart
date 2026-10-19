import 'subscription_json.dart';

/// Response of `GET /subscription/services` (`data` grouped by type).
class SubscriptionServicesResponseModel {
  const SubscriptionServicesResponseModel({
    required this.success,
    required this.message,
    this.services = const [],
  });

  final bool success;
  final String message;

  /// Flattened in response order; the group key is kept in each `type`.
  final List<SubscriptionServiceOfferModel> services;

  factory SubscriptionServicesResponseModel.fromJson(
    Map<String, dynamic> json,
  ) {
    final data = json['data'];
    final services = <SubscriptionServiceOfferModel>[];
    if (data is Map) {
      for (final MapEntry(:key, :value) in data.entries) {
        if (value is! List) continue;
        for (final item in value.whereType<Map>()) {
          services.add(
            SubscriptionServiceOfferModel.fromJson(
              Map<String, dynamic>.from(item),
              fallbackType: '$key',
            ),
          );
        }
      }
    }
    return SubscriptionServicesResponseModel(
      success: json['success'] == true,
      message: json['message']?.toString() ?? '',
      services: services,
    );
  }
}

/// One purchasable service from `GET /subscription/services`.
class SubscriptionServiceOfferModel {
  const SubscriptionServiceOfferModel({
    required this.code,
    required this.name,
    required this.type,
    required this.monthlyPriceBdt,
    required this.annualPriceBdt,
    this.description,
  });

  final String code;
  final String name;
  final String type;
  final String monthlyPriceBdt;
  final String annualPriceBdt;
  final String? description;

  factory SubscriptionServiceOfferModel.fromJson(
    Map<String, dynamic> json, {
    String? fallbackType,
  }) {
    return SubscriptionServiceOfferModel(
      code: json['code']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      type: asNullableString(json['type'])?.toLowerCase() ?? fallbackType ?? '',
      monthlyPriceBdt: json['monthly_price_bdt']?.toString() ?? '0.00',
      annualPriceBdt: json['annual_price_bdt']?.toString() ?? '0.00',
      description: asNullableString(json['description']),
    );
  }
}
