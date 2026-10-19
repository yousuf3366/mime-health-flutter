import 'package:equatable/equatable.dart';

import '../../domain/entity/subscription_entity.dart';

/// Add-ons tab: purchasable services and the user's selection.
class SubscriptionAddonsState extends Equatable {
  const SubscriptionAddonsState({
    this.services = const [],
    this.selectedCodes = const {},
    this.isLoading = false,
    this.errorMessage,
  });

  final List<SubscriptionServiceOfferEntity> services;
  final Set<String> selectedCodes;
  final bool isLoading;
  final String? errorMessage;

  /// Selected services in list order.
  List<SubscriptionServiceOfferEntity> get selectedServices => services
      .where((s) => selectedCodes.contains(s.code))
      .toList(growable: false);

  bool isSelected(String code) => selectedCodes.contains(code);

  SubscriptionAddonsState copyWith({
    List<SubscriptionServiceOfferEntity>? services,
    Set<String>? selectedCodes,
    bool? isLoading,
    Object? errorMessage = _noValue,
  }) {
    return SubscriptionAddonsState(
      services: services ?? this.services,
      selectedCodes: selectedCodes ?? this.selectedCodes,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: identical(errorMessage, _noValue)
          ? this.errorMessage
          : errorMessage as String?,
    );
  }

  @override
  List<Object?> get props => [services, selectedCodes, isLoading, errorMessage];
}

const Object _noValue = Object();
