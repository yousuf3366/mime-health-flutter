import 'package:equatable/equatable.dart';

/// Payment screen: whether a checkout request is in flight.
class SubscriptionCheckoutState extends Equatable {
  const SubscriptionCheckoutState({
    this.isSubmitting = false,
    this.errorMessage,
  });

  final bool isSubmitting;
  final String? errorMessage;

  SubscriptionCheckoutState copyWith({
    bool? isSubmitting,
    Object? errorMessage = _noValue,
  }) {
    return SubscriptionCheckoutState(
      isSubmitting: isSubmitting ?? this.isSubmitting,
      errorMessage: identical(errorMessage, _noValue)
          ? this.errorMessage
          : errorMessage as String?,
    );
  }

  @override
  List<Object?> get props => [isSubmitting, errorMessage];
}

const Object _noValue = Object();
