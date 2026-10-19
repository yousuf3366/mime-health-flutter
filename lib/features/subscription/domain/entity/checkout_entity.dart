import 'package:equatable/equatable.dart';

/// Result of `POST /subscription/checkout`: a pending payment plus the
/// gateway page the user must complete it on.
class CheckoutEntity extends Equatable {
  const CheckoutEntity({
    required this.paymentId,
    required this.status,
    required this.amountBdt,
    required this.currency,
    required this.redirectUrl,
    this.invoiceNumber,
    this.gatewayReference,
  });

  final int paymentId;
  final String status;
  final String amountBdt;
  final String currency;
  final String redirectUrl;
  final String? invoiceNumber;
  final String? gatewayReference;

  @override
  List<Object?> get props => [
    paymentId,
    status,
    amountBdt,
    currency,
    redirectUrl,
    invoiceNumber,
    gatewayReference,
  ];
}
