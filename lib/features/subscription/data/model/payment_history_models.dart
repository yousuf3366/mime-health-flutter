import 'subscription_json.dart';

/// Response of `GET /subscription/payments?page=&per_page=`.
class PaymentHistoryResponseModel {
  const PaymentHistoryResponseModel({
    required this.success,
    required this.message,
    this.items = const [],
    this.pagination,
  });

  final bool success;
  final String message;
  final List<PaymentModel> items;
  final PaginationModel? pagination;

  factory PaymentHistoryResponseModel.fromJson(Map<String, dynamic> json) {
    final data = asJsonMap(json['data']);
    final items = data?['items'];
    final pagination = asJsonMap(data?['pagination']);
    return PaymentHistoryResponseModel(
      success: json['success'] == true,
      message: json['message']?.toString() ?? '',
      items: items is List
          ? items
                .whereType<Map>()
                .map((e) => PaymentModel.fromJson(Map<String, dynamic>.from(e)))
                .toList(growable: false)
          : const [],
      pagination: pagination == null
          ? null
          : PaginationModel.fromJson(pagination),
    );
  }
}

/// One payment (`data.items[]`).
class PaymentModel {
  const PaymentModel({
    required this.id,
    required this.purpose,
    required this.amountBdt,
    required this.currency,
    required this.paymentMethod,
    required this.status,
    this.subscriptionId,
    this.parentUserId,
    this.gateway,
    this.gatewayReference,
    this.gatewayTransactionId,
    this.invoiceNumber,
    this.lineItems = const [],
    this.paidAt,
    this.reconciledAt,
    this.failureReason,
    this.createdAt,
    this.updatedAt,
    this.downloadUrl,
  });

  final int id;
  final int? subscriptionId;
  final int? parentUserId;
  final String purpose;
  final String amountBdt;
  final String currency;
  final String paymentMethod;
  final String status;
  final String? gateway;
  final String? gatewayReference;
  final String? gatewayTransactionId;
  final String? invoiceNumber;
  final List<PaymentLineItemModel> lineItems;
  final String? paidAt;
  final String? reconciledAt;
  final String? failureReason;
  final String? createdAt;
  final String? updatedAt;
  final String? downloadUrl;

  factory PaymentModel.fromJson(Map<String, dynamic> json) {
    final lineItems = json['line_items'];
    return PaymentModel(
      id: asInt(json['id']) ?? 0,
      subscriptionId: asInt(json['subscription_id']),
      parentUserId: asInt(json['parent_user_id']),
      purpose: json['purpose']?.toString() ?? '',
      amountBdt: json['amount_bdt']?.toString() ?? '0.00',
      currency: json['currency']?.toString() ?? 'BDT',
      paymentMethod: json['payment_method']?.toString() ?? '',
      status: json['status']?.toString() ?? '',
      gateway: asNullableString(json['gateway']),
      gatewayReference: asNullableString(json['gateway_reference']),
      gatewayTransactionId: asNullableString(json['gateway_transaction_id']),
      invoiceNumber: asNullableString(json['invoice_number']),
      lineItems: lineItems is List
          ? lineItems
                .whereType<Map>()
                .map(
                  (e) => PaymentLineItemModel.fromJson(
                    Map<String, dynamic>.from(e),
                  ),
                )
                .toList(growable: false)
          : const [],
      paidAt: asNullableString(json['paid_at']),
      reconciledAt: asNullableString(json['reconciled_at']),
      failureReason: asNullableString(json['failure_reason']),
      createdAt: asNullableString(json['created_at']),
      updatedAt: asNullableString(json['updated_at']),
      downloadUrl: asNullableString(json['download_url']),
    );
  }
}

/// One entry of a payment's `line_items`.
class PaymentLineItemModel {
  const PaymentLineItemModel({
    required this.type,
    required this.amountBdt,
    this.code,
    this.title,
    this.billingInterval,
  });

  final String type;
  final String? code;
  final String? title;
  final String amountBdt;
  final String? billingInterval;

  factory PaymentLineItemModel.fromJson(Map<String, dynamic> json) {
    return PaymentLineItemModel(
      type: json['type']?.toString() ?? '',
      // Older payloads used plan_code / service_code / service_name.
      code:
          asNullableString(json['code']) ??
          asNullableString(json['plan_code']) ??
          asNullableString(json['service_code']),
      title:
          asNullableString(json['title']) ??
          asNullableString(json['service_name']),
      amountBdt: json['amount_bdt']?.toString() ?? '0',
      billingInterval: asNullableString(json['billing_interval']),
    );
  }
}

/// `data.pagination`.
class PaginationModel {
  const PaginationModel({
    required this.currentPage,
    required this.perPage,
    required this.total,
    required this.lastPage,
  });

  final int currentPage;
  final int perPage;
  final int total;
  final int lastPage;

  factory PaginationModel.fromJson(Map<String, dynamic> json) {
    return PaginationModel(
      currentPage: asInt(json['current_page']) ?? 1,
      perPage: asInt(json['per_page']) ?? 0,
      total: asInt(json['total']) ?? 0,
      lastPage: asInt(json['last_page']) ?? 1,
    );
  }
}
