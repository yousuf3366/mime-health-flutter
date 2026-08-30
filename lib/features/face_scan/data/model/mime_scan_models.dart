/// Request for `POST /api/v1/scans/get-face-scan-url`.
class MimeFaceScanUrlRequestModel {
  const MimeFaceScanUrlRequestModel({required this.profileId});

  final int profileId;

  Map<String, dynamic> toJson() => {'profile_id': profileId};
}

class MimeFaceScanUrlResponseModel {
  const MimeFaceScanUrlResponseModel({
    required this.success,
    required this.message,
    this.data,
    this.errors = const [],
  });

  final bool success;
  final String message;
  final MimeFaceScanUrlDataModel? data;
  final List<String> errors;

  factory MimeFaceScanUrlResponseModel.fromJson(Map<String, dynamic> json) {
    final dataRaw = json['data'];
    final errorsRaw = json['errors'];
    return MimeFaceScanUrlResponseModel(
      success: json['success'] == true,
      message: json['message']?.toString() ?? '',
      data: dataRaw is Map
          ? MimeFaceScanUrlDataModel.fromJson(
              Map<String, dynamic>.from(dataRaw),
            )
          : null,
      errors: errorsRaw is List
          ? errorsRaw.map((e) => e.toString()).toList(growable: false)
          : const [],
    );
  }
}

class MimeFaceScanUrlDataModel {
  const MimeFaceScanUrlDataModel({
    required this.faceScanUrl,
    this.faceScanId,
    this.faceScanUrlId,
    this.profileId,
    this.externalUserId,
  });

  final String faceScanUrl;
  final String? faceScanId;
  final int? faceScanUrlId;
  final int? profileId;
  final String? externalUserId;

  factory MimeFaceScanUrlDataModel.fromJson(Map<String, dynamic> json) {
    return MimeFaceScanUrlDataModel(
      profileId: _asInt(json['profile_id']),
      externalUserId: json['external_user_id']?.toString(),
      faceScanUrl: json['face_scan_url']?.toString() ?? '',
      faceScanId: json['face_scan_id']?.toString(),
      faceScanUrlId: _asInt(json['face_scan_url_id']),
    );
  }
}

/// Request / response models for `POST /api/v1/scans`.
class MimeScanStoreRequestModel {
  const MimeScanStoreRequestModel({
    required this.faceScanId,
    required this.externalUserId,
    required this.profileId,
    this.faceScanUrlId,
  });

  final String faceScanId;
  final int externalUserId;
  final int profileId;
  final int? faceScanUrlId;

  Map<String, dynamic> toJson() => {
    'face_scan_id': faceScanId,
    'external_user_id': externalUserId,
    'profile_id': profileId,
    if (faceScanUrlId != null) 'face_scan_url_id': faceScanUrlId,
  };
}

class MimeScanStoreResponseModel {
  const MimeScanStoreResponseModel({
    required this.success,
    required this.message,
    this.data,
    this.errors = const [],
  });

  final bool success;
  final String message;
  final MimeScanStoredDataModel? data;
  final List<String> errors;

  factory MimeScanStoreResponseModel.fromJson(Map<String, dynamic> json) {
    final dataRaw = json['data'];
    final errorsRaw = json['errors'];
    return MimeScanStoreResponseModel(
      success: json['success'] == true,
      message: json['message']?.toString() ?? '',
      data: dataRaw is Map
          ? MimeScanStoredDataModel.fromJson(Map<String, dynamic>.from(dataRaw))
          : null,
      errors: errorsRaw is List
          ? errorsRaw.map((e) => e.toString()).toList(growable: false)
          : const [],
    );
  }
}

class MimeScanStoredDataModel {
  const MimeScanStoredDataModel({
    required this.id,
    required this.faceScanId,
    required this.biomarkers,
    this.profileId,
    this.parentUserId,
    this.scannerUserId,
    this.externalUserId,
    this.contextNote,
    this.qualityStatus,
    this.qualityFlags,
    this.metrics,
    this.metricsLastUpdateAt,
    this.createdAt,
    this.raw = const {},
  });

  final int id;
  final String faceScanId;
  final MimeScanBiomarkersModel biomarkers;
  final int? profileId;
  final int? parentUserId;
  final int? scannerUserId;
  final String? externalUserId;
  final String? contextNote;
  final String? qualityStatus;
  final Object? qualityFlags;
  final MimeScanMetricsModel? metrics;
  final String? metricsLastUpdateAt;
  final String? createdAt;
  final Map<String, dynamic> raw;

  factory MimeScanStoredDataModel.fromJson(Map<String, dynamic> json) {
    final biomarkersRaw = json['biomarkers'];
    final metricsRaw = json['metrics'];
    return MimeScanStoredDataModel(
      id: _asInt(json['id']) ?? 0,
      profileId: _asInt(json['profile_id']),
      parentUserId: _asInt(json['parent_user_id']),
      scannerUserId: _asInt(json['scanner_user_id']),
      faceScanId: json['face_scan_id']?.toString() ?? '',
      externalUserId: json['external_user_id']?.toString(),
      contextNote: json['context_note']?.toString(),
      qualityStatus: json['quality_status']?.toString(),
      qualityFlags: json['quality_flags'],
      metrics: metricsRaw is Map
          ? MimeScanMetricsModel.fromJson(Map<String, dynamic>.from(metricsRaw))
          : null,
      metricsLastUpdateAt: json['metrics_last_update_at']?.toString(),
      createdAt: json['created_at']?.toString(),
      biomarkers: MimeScanBiomarkersModel.fromJson(
        biomarkersRaw is Map
            ? Map<String, dynamic>.from(biomarkersRaw)
            : const <String, dynamic>{},
      ),
      raw: json,
    );
  }
}

class MimeScanBiomarkersModel {
  const MimeScanBiomarkersModel({
    this.heartRate,
    this.respiratoryRate,
    this.heartRateVariability,
    this.resonantBreathingScore,
    this.systolicBloodPressure,
    this.diastolicBloodPressure,
    this.raw = const {},
  });

  final double? heartRate;
  final double? respiratoryRate;
  final double? heartRateVariability;
  final double? resonantBreathingScore;
  final double? systolicBloodPressure;
  final double? diastolicBloodPressure;
  final Map<String, dynamic> raw;

  factory MimeScanBiomarkersModel.fromJson(Map<String, dynamic> json) {
    return MimeScanBiomarkersModel(
      heartRate: _asDouble(json['heart_rate']),
      respiratoryRate: _asDouble(json['respiratory_rate']),
      heartRateVariability: _asDouble(json['heart_rate_variability']),
      resonantBreathingScore: _asDouble(json['resonant_breathing_score']),
      systolicBloodPressure: _asDouble(json['systolic_blood_pressure']),
      diastolicBloodPressure: _asDouble(json['diastolic_blood_pressure']),
      raw: json,
    );
  }

  Map<String, dynamic> toMap() => Map<String, dynamic>.from(raw);
}

/// Mime `data.metrics` block from store-scan response.
class MimeScanMetricsModel {
  const MimeScanMetricsModel({
    this.energyBalance,
    this.generalFitness,
    this.hypertension,
    this.mentalHealthRisk,
    this.mentalStress,
    this.sleepQuality,
    this.wellbeing,
    this.raw = const {},
  });

  final MimeScanMetricScoreModel? energyBalance;
  final MimeScanMetricScoreModel? generalFitness;
  final MimeScanMetricScoreModel? hypertension;
  final MimeScanMetricScoreModel? mentalHealthRisk;
  final MimeScanMetricScoreModel? mentalStress;
  final MimeScanMetricScoreModel? sleepQuality;
  final MimeScanWellbeingModel? wellbeing;
  final Map<String, dynamic> raw;

  factory MimeScanMetricsModel.fromJson(Map<String, dynamic> json) {
    return MimeScanMetricsModel(
      energyBalance: _score(json['energy_balance']),
      generalFitness: _score(json['general_fitness']),
      hypertension: _score(json['hypertension']),
      mentalHealthRisk: _score(json['mental_health_risk']),
      mentalStress: _score(json['mental_stress']),
      sleepQuality: _score(json['sleep_quality']),
      wellbeing: json['wellbeing'] is Map
          ? MimeScanWellbeingModel.fromJson(
              Map<String, dynamic>.from(json['wellbeing'] as Map),
            )
          : null,
      raw: json,
    );
  }

  Map<String, dynamic> toMap() => Map<String, dynamic>.from(raw);

  static MimeScanMetricScoreModel? _score(Object? value) {
    if (value is! Map) return null;
    return MimeScanMetricScoreModel.fromJson(Map<String, dynamic>.from(value));
  }
}

class MimeScanMetricScoreModel {
  const MimeScanMetricScoreModel({this.score, this.confidence});

  final double? score;
  final double? confidence;

  factory MimeScanMetricScoreModel.fromJson(Map<String, dynamic> json) {
    return MimeScanMetricScoreModel(
      score: _asDouble(json['score']),
      confidence: _asDouble(json['confidence']),
    );
  }
}

class MimeScanWellbeingModel {
  const MimeScanWellbeingModel({
    this.mental,
    this.physical,
    this.energySleep,
    this.statusLabel,
  });

  final MimeScanWellbeingDimensionModel? mental;
  final MimeScanWellbeingDimensionModel? physical;
  final MimeScanWellbeingDimensionModel? energySleep;
  final String? statusLabel;

  factory MimeScanWellbeingModel.fromJson(Map<String, dynamic> json) {
    return MimeScanWellbeingModel(
      mental: _dimension(json['mental']),
      physical: _dimension(json['physical']),
      energySleep: _dimension(json['energy_sleep']),
      statusLabel: json['status_label']?.toString(),
    );
  }

  static MimeScanWellbeingDimensionModel? _dimension(Object? value) {
    if (value is! Map) return null;
    return MimeScanWellbeingDimensionModel.fromJson(
      Map<String, dynamic>.from(value),
    );
  }
}

class MimeScanWellbeingDimensionModel {
  const MimeScanWellbeingDimensionModel({this.score, this.assessment});

  final double? score;
  final String? assessment;

  factory MimeScanWellbeingDimensionModel.fromJson(Map<String, dynamic> json) {
    return MimeScanWellbeingDimensionModel(
      score: _asDouble(json['score']),
      assessment: json['assessment']?.toString(),
    );
  }
}

int? _asInt(Object? value) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  if (value is String) return int.tryParse(value);
  return null;
}

double? _asDouble(Object? value) {
  if (value is double) return value;
  if (value is num) return value.toDouble();
  if (value is String) return double.tryParse(value);
  return null;
}
