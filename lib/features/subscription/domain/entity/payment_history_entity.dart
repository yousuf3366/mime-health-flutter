import 'package:equatable/equatable.dart';

/// One page of `GET /subscription/payments`.
class PaymentHistoryPageEntity extends Equatable {
  const PaymentHistoryPageEntity({
    required this.items,
    required this.currentPage,
    required this.lastPage,
    required this.total,
  });

  final List<PaymentEntity> items;
  final int currentPage;
  final int lastPage;
  final int total;

  bool get hasMore => currentPage < lastPage;

  @override
  List<Object?> get props => [items, currentPage, lastPage, total];
}

/// A payment the user made (plan or add-on services).
class PaymentEntity extends Equatable {
  const PaymentEntity({
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

  /// e.g. `subscription`, `service_subscription`.
  final String purpose;
  final String amountBdt;
  final String currency;

  /// `bkash` | `nagad` | `card`.
  final String paymentMethod;

  /// e.g. `completed`, `pending`, `failed`.
  final String status;
  final String? gateway;
  final String? gatewayReference;
  final String? gatewayTransactionId;
  final String? invoiceNumber;
  final List<PaymentLineItemEntity> lineItems;
  final String? paidAt;
  final String? reconciledAt;
  final String? failureReason;
  final String? createdAt;
  final String? updatedAt;

  /// Invoice PDF (authenticated API URL).
  final String? downloadUrl;

  @override
  List<Object?> get props => [
    id,
    subscriptionId,
    parentUserId,
    purpose,
    amountBdt,
    currency,
    paymentMethod,
    status,
    gateway,
    gatewayReference,
    gatewayTransactionId,
    invoiceNumber,
    lineItems,
    paidAt,
    reconciledAt,
    failureReason,
    createdAt,
    updatedAt,
    downloadUrl,
  ];
}

class PaymentLineItemEntity extends Equatable {
  const PaymentLineItemEntity({
    required this.type,
    required this.amountBdt,
    this.code,
    this.title,
    this.billingInterval,
  });

  /// e.g. `subscription`, `service_addon`.
  final String type;
  final String? code;
  final String? title;
  final String amountBdt;
  final String? billingInterval;

  @override
  List<Object?> get props => [type, code, title, amountBdt, billingInterval];
}
