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

enum PaymentMethod {
  bkash,
  nagad,
  card;

  String get apiValue => name;
}

/// `purpose` values for `POST /subscription/checkout`.
abstract final class CheckoutPurpose {
  /// Plan purchase: `plan_code` (+ optional `addon_codes`).
  static const subscription = 'subscription';

  /// Add-on services on their own: `service_codes`.
  static const serviceSubscription = 'service_subscription';
}
