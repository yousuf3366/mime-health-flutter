import 'package:equatable/equatable.dart';

import '../../domain/entity/face_scan_entity.dart';

const Object _noValue = Object();

enum FaceScanFlowStatus {
  idle,
  preparing,
  scanning,
  questionnaire,
  processing,
  success,
  cancelled,
  error,
}

/// Outcome of [FaceScanFlowNotifier.startScan] for the pre-scan UI.
enum FaceScanStartResult {
  /// Scan flow started / completed its happy path after access check.
  proceeded,

  /// Mime `faceScanUrl` did not grant access — user needs a plan.
  needsPlan,

  /// Busy, cancelled, or another handled error (snackbar already shown).
  aborted,
}

class FaceScanFlowState extends Equatable {
  const FaceScanFlowState({
    this.status = FaceScanFlowStatus.idle,
    this.result,
    this.errorMessage,
  });

  factory FaceScanFlowState.initial() => const FaceScanFlowState();

  final FaceScanFlowStatus status;
  final FaceScanVitalsResult? result;
  final String? errorMessage;

  bool get isBusy =>
      status == FaceScanFlowStatus.preparing ||
      status == FaceScanFlowStatus.scanning ||
      status == FaceScanFlowStatus.questionnaire ||
      status == FaceScanFlowStatus.processing;

  FaceScanFlowState copyWith({
    Object? status = _noValue,
    Object? result = _noValue,
    Object? errorMessage = _noValue,
  }) {
    return FaceScanFlowState(
      status: identical(status, _noValue)
          ? this.status
          : status as FaceScanFlowStatus,
      result: identical(result, _noValue)
          ? this.result
          : result as FaceScanVitalsResult?,
      errorMessage: identical(errorMessage, _noValue)
          ? this.errorMessage
          : errorMessage as String?,
    );
  }

  @override
  List<Object?> get props => [status, result, errorMessage];
}
