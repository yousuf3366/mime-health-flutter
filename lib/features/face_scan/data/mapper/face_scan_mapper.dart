import '../../../../core/error/exceptions.dart';
import '../../domain/entity/face_scan_entity.dart';
import '../model/face_scan_models.dart';
import '../model/mime_scan_models.dart';

class FaceScanMapper {
  FaceScanMapper._();

  /// Plugin / postMessage ids may include suffixes — keep the UUID-like token.
  static String normalizeFaceScanId(String faceScanId) {
    final trimmed = faceScanId.trim();
    final match = RegExp(
      r'[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}',
    ).firstMatch(trimmed);
    return match?.group(0) ?? trimmed;
  }

  /// IntelliProve accepts only `M` / `F`. Mime profiles use `male` / `female`.
  static String? toIntelliProveSex(String? sex) {
    if (sex == null) return null;
    switch (sex.trim().toLowerCase()) {
      case 'm':
      case 'male':
        return 'M';
      case 'f':
      case 'female':
        return 'F';
      default:
        return null;
    }
  }

  static FaceScanUrlResult toUrlResult(
    String url, {
    String? faceScanId,
    int? faceScanUrlId,
    int? profileId,
    String? externalUserId,
  }) {
    return FaceScanUrlResult(
      url: url,
      faceScanId: faceScanId,
      faceScanUrlId: faceScanUrlId,
      profileId: profileId,
      externalUserId: externalUserId,
    );
  }

  static IntelliProveUserIdResult toUserIdResult(
    IntelliProveUserResponseModel model,
  ) {
    return IntelliProveUserIdResult(userId: model.userId);
  }

  static List<FaceScanQuestionAnswerRequestModel> toAnswerRequests(
    List<FaceScanQuestionAnswer> answers, {
    required String timezone,
  }) {
    return answers
        .map(
          (a) => FaceScanQuestionAnswerRequestModel.fromEntity(
            a,
            timezone: timezone,
          ),
        )
        .toList(growable: false);
  }

  /// Maps Mime `POST /api/v1/scans` stored payload to vitals.
  static FaceScanVitalsResult toVitalsFromMimeScan(
    MimeScanStoredDataModel data,
  ) {
    final b = data.biomarkers;
    final missing = <String>[];
    if (b.heartRate == null) missing.add('heart_rate');
    if (b.respiratoryRate == null) missing.add('respiratory_rate');
    if (b.systolicBloodPressure == null) {
      missing.add('systolic_blood_pressure');
    }
    if (b.diastolicBloodPressure == null) {
      missing.add('diastolic_blood_pressure');
    }
    if (missing.isNotEmpty) {
      throw FaceScanFailedException(
        'Incomplete biomarker data from Mime scan (missing: '
        '${missing.join(', ')}).',
      );
    }

    var timestamp = DateTime.now();
    final createdAt = data.createdAt;
    if (createdAt != null && createdAt.isNotEmpty) {
      timestamp = DateTime.tryParse(createdAt) ?? timestamp;
    }

    return FaceScanVitalsResult(
      faceScanId: normalizeFaceScanId(data.faceScanId),
      timestamp: timestamp,
      heartRate: b.heartRate!,
      respiratoryRate: b.respiratoryRate!,
      bloodPressureSystolic: b.systolicBloodPressure!,
      bloodPressureDiastolic: b.diastolicBloodPressure!,
      // Mime scan response does not include SpO2.
      spo2: 0,
      // Prefer Mime mental_stress score when present.
      stressLevel: data.metrics?.mentalStress?.score ?? 0,
      heartRateVariability: b.heartRateVariability,
      resonantBreathingScore: b.resonantBreathingScore,
      mimeScanId: data.id,
      profileId: data.profileId,
      qualityStatus: data.qualityStatus,
      rawBiomarkers: b.toMap(),
      rawMetrics: data.metrics?.toMap(),
    );
  }
}
