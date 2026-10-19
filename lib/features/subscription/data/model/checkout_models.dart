import '../../domain/entity/subscription_enums.dart';
import 'subscription_json.dart';

/// Request body of `POST /subscription/checkout`.
class CheckoutRequestModel {
  const CheckoutRequestModel({
    required this.billingInterval,
    required this.paymentMethod,
    this.planCode,
    this.purpose = CheckoutPurpose.subscription,
    this.addonCodes = const [],
    this.serviceCodes = const [],
  });

  /// Required for [CheckoutPurpose.subscription].
  final String? planCode;
  final BillingInterval billingInterval;
  final PaymentMethod paymentMethod;
  final String purpose;

  /// Optional extras bundled with a plan purchase.
  final List<String> addonCodes;

  /// Services bought on their own ([CheckoutPurpose.serviceSubscription]).
  final List<String> serviceCodes;

  Map<String, dynamic> toJson() => {
    if (planCode != null) 'plan_code': planCode,
    'billing_interval': billingInterval.apiValue,
    'payment_method': paymentMethod.apiValue,
    'purpose': purpose,
    if (addonCodes.isNotEmpty) 'addon_codes': addonCodes,
    if (serviceCodes.isNotEmpty) 'service_codes': serviceCodes,
  };
}

/// Response of `POST /subscription/checkout`.
class CheckoutResponseModel {
  const CheckoutResponseModel({
    required this.success,
    required this.message,
    this.payment,
    this.redirectUrl,
  });

  final bool success;
  final String message;
  final CheckoutPaymentModel? payment;

  /// Gateway page (`data.redirect_url`).
  final String? redirectUrl;

  factory CheckoutResponseModel.fromJson(Map<String, dynamic> json) {
    final data = asJsonMap(json['data']);
    final payment = asJsonMap(data?['payment']);
    return CheckoutResponseModel(
      success: json['success'] == true,
      message: json['message']?.toString() ?? '',
      payment: payment == null ? null : CheckoutPaymentModel.fromJson(payment),
      redirectUrl: asNullableString(data?['redirect_url']),
    );
  }
}

/// `data.payment` of the checkout response.
class CheckoutPaymentModel {
  const CheckoutPaymentModel({
    required this.id,
    required this.status,
    required this.amountBdt,
    required this.currency,
    this.invoiceNumber,
    this.gatewayReference,
  });

  final int id;
  final String status;
  final String amountBdt;
  final String currency;
  final String? invoiceNumber;
  final String? gatewayReference;

  factory CheckoutPaymentModel.fromJson(Map<String, dynamic> json) {
    return CheckoutPaymentModel(
      id: asInt(json['id']) ?? 0,
      status: json['status']?.toString() ?? '',
      amountBdt: json['amount_bdt']?.toString() ?? '0.00',
      currency: json['currency']?.toString() ?? 'BDT',
      invoiceNumber: asNullableString(json['invoice_number']),
      gatewayReference: asNullableString(json['gateway_reference']),
    );
  }
}
