import 'package:equatable/equatable.dart';

import '../../domain/entity/subscription_entity.dart';

class PaymentHistoryState extends Equatable {
  const PaymentHistoryState({
    this.items = const [],
    this.page = 0,
    this.hasMore = false,
    this.isLoading = false,
    this.isLoadingMore = false,
    this.downloadingIds = const {},
    this.fromDate,
    this.toDate,
    this.errorMessage,
  });

  final List<PaymentEntity> items;

  /// Active date filter (`from_date` / `to_date`); both null when unfiltered.
  final DateTime? fromDate;
  final DateTime? toDate;

  bool get hasDateFilter => fromDate != null || toDate != null;

  /// Last page loaded (0 before the first load).
  final int page;
  final bool hasMore;
  final bool isLoading;
  final bool isLoadingMore;

  /// Payments whose invoice is downloading (drives each row's spinner).
  final Set<int> downloadingIds;
  final String? errorMessage;

  PaymentHistoryState copyWith({
    List<PaymentEntity>? items,
    int? page,
    bool? hasMore,
    bool? isLoading,
    bool? isLoadingMore,
    Set<int>? downloadingIds,
    Object? fromDate = _noValue,
    Object? toDate = _noValue,
    Object? errorMessage = _noValue,
  }) {
    return PaymentHistoryState(
      items: items ?? this.items,
      fromDate: identical(fromDate, _noValue)
          ? this.fromDate
          : fromDate as DateTime?,
      toDate: identical(toDate, _noValue) ? this.toDate : toDate as DateTime?,
      page: page ?? this.page,
      hasMore: hasMore ?? this.hasMore,
      isLoading: isLoading ?? this.isLoading,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      downloadingIds: downloadingIds ?? this.downloadingIds,
      errorMessage: identical(errorMessage, _noValue)
          ? this.errorMessage
          : errorMessage as String?,
    );
  }

  @override
  List<Object?> get props => [
    items,
    page,
    hasMore,
    isLoading,
    isLoadingMore,
    downloadingIds,
    fromDate,
    toDate,
    errorMessage,
  ];
}

const Object _noValue = Object();
