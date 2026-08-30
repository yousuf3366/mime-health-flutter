import 'package:equatable/equatable.dart';

/// Answer payload for IntelliProve question APIs.
class FaceScanQuestionAnswer extends Equatable {
  const FaceScanQuestionAnswer({required this.lookupKey, required this.value});

  final String lookupKey;
  final Object value;

  @override
  List<Object?> get props => [lookupKey, value];
}

/// Result of starting / resolving a Face Scan plug-in session.
class FaceScanUrlResult extends Equatable {
  const FaceScanUrlResult({
    required this.url,
    this.faceScanId,
    this.faceScanUrlId,
    this.profileId,
    this.externalUserId,
  });

  final String url;
  final String? faceScanId;
  final int? faceScanUrlId;
  final int? profileId;
  final String? externalUserId;

  /// Server granted a usable scan session (URL and/or scan id).
  bool get hasScanAccess =>
      url.trim().isNotEmpty || (faceScanId?.trim().isNotEmpty ?? false);

  @override
  List<Object?> get props => [
    url,
    faceScanId,
    faceScanUrlId,
    profileId,
    externalUserId,
  ];
}

/// IntelliProve internal user id for an external user.
class IntelliProveUserIdResult extends Equatable {
  const IntelliProveUserIdResult({required this.userId});

  final String userId;

  @override
  List<Object?> get props => [userId];
}

/// Mapped vitals from Mime scan store response.
class FaceScanVitalsResult extends Equatable {
  const FaceScanVitalsResult({
    required this.faceScanId,
    required this.timestamp,
    required this.heartRate,
    required this.respiratoryRate,
    required this.bloodPressureSystolic,
    required this.bloodPressureDiastolic,
    required this.spo2,
    required this.stressLevel,
    this.heartRateVariability,
    this.resonantBreathingScore,
    this.mimeScanId,
    this.profileId,
    this.qualityStatus,
    this.rawBiomarkers = const {},
    this.rawMetrics,
  });

  final String faceScanId;
  final DateTime timestamp;
  final double heartRate;
  final double respiratoryRate;
  final double bloodPressureSystolic;
  final double bloodPressureDiastolic;
  final double spo2;
  final double stressLevel;

  /// From Mime `biomarkers.heart_rate_variability`.
  final double? heartRateVariability;

  /// From Mime `biomarkers.resonant_breathing_score`.
  final double? resonantBreathingScore;

  /// Mime server row id (`data.id`).
  final int? mimeScanId;
  final int? profileId;
  final String? qualityStatus;

  final Map<String, dynamic> rawBiomarkers;
  final Map<String, dynamic>? rawMetrics;

  @override
  List<Object?> get props => [
    faceScanId,
    timestamp,
    heartRate,
    respiratoryRate,
    bloodPressureSystolic,
    bloodPressureDiastolic,
    spo2,
    stressLevel,
    heartRateVariability,
    resonantBreathingScore,
    mimeScanId,
    profileId,
    qualityStatus,
    rawBiomarkers,
    rawMetrics,
  ];
}
