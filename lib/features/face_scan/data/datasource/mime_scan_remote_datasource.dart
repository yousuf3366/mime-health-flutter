import 'dart:convert';

import 'package:dio/dio.dart';

import '../../../../core/constants/api_endpoints.dart';
import '../../../../core/error/exceptions.dart';
import '../../domain/entity/face_scan_entity.dart';
import '../mapper/face_scan_mapper.dart';
import '../model/mime_scan_models.dart';

/// Mime Health scans API (app Dio / JWT) — not IntelliProve.
class MimeScanRemoteDatasource {
  MimeScanRemoteDatasource(this._dio);

  final Dio _dio;

  /// POST `/api/v1/scans/get-face-scan-url`
  Future<MimeFaceScanUrlDataModel> getFaceScanUrl({
    required int profileId,
  }) async {
    final response = await _dio.get<Map<String, dynamic>>(
      ApiEndpoints.faceScanUrl,
      data: MimeFaceScanUrlRequestModel(profileId: profileId).toJson(),
    );
    final parsed = MimeFaceScanUrlResponseModel.fromJson(
      _asJsonMap(response.data),
    );
    if (!parsed.success ||
        parsed.data == null ||
        parsed.data!.faceScanUrl.isEmpty) {
      final detail = parsed.errors.isEmpty
          ? ''
          : ' ${parsed.errors.join(', ')}';
      throw ApiException(
        (parsed.message.isEmpty
                ? 'Failed to retrieve face scan URL.'
                : parsed.message) +
            detail,
      );
    }
    return parsed.data!;
  }

  Future<MimeScanStoreResponseModel> storeScan(
    MimeScanStoreRequestModel request,
  ) async {
    final response = await _dio.post<Map<String, dynamic>>(
      ApiEndpoints.scans,
      data: request.toJson(),
    );
    return MimeScanStoreResponseModel.fromJson(_asJsonMap(response.data));
  //  return MimeScanStoreResponseModel.fromJson(_vitalsFromSampleScanJson());
  }

  /// GET `/api/v1/scans/latest` — same `data` shape as store-scan response.
  Future<MimeScanStoreResponseModel> getLatestScan({int? profileId}) async {
   // print('...........getLatestScan..........called............');
    final response = await _dio.get<Map<String, dynamic>>(
      ApiEndpoints.latestScansResult,
     // queryParameters: {'profile_id': ?profileId},
    );
   // print('...........getLatestScan..........${MimeScanStoreResponseModel.fromJson(_vitalsFromSampleScanJson()).message}');

    return MimeScanStoreResponseModel.fromJson(_asJsonMap(response.data));
   // return MimeScanStoreResponseModel.fromJson(_vitalsFromSampleScanJson());
  }

  Map<String, dynamic> _asJsonMap(dynamic data) {
    if (data is Map<String, dynamic>) return data;
    if (data is Map) return Map<String, dynamic>.from(data);
    return <String, dynamic>{};
  }
}

Map<String, dynamic> _vitalsFromSampleScanJson() {
  const raw = '''
{
  "success": true,
  "message": "Scan stored successfully.",
  "data": {
    "id": 1,
    "profile_id": 1,
    "parent_user_id": 2,
    "scanner_user_id": 2,
    "face_scan_id": "55e7b4f3-c240-475b-8a9b-a6a071943073",
    "external_user_id": "1",
    "context_note": null,
    "quality_status": "good",
    "quality_flags": null,
    "biomarkers": {
      "heart_rate": 82,
      "respiratory_rate": 10,
      "heart_rate_variability": 114,
      "resonant_breathing_score": 11,
      "systolic_blood_pressure": 130,
      "diastolic_blood_pressure": 83
    },
    "metrics": {
      "energy_balance": { "score": 67.37, "confidence": 66.67 },
      "general_fitness": { "score": 73.94, "confidence": 87.5 },
      "hypertension": { "score": 82, "confidence": 100 },
      "mental_health_risk": { "score": 84.17, "confidence": 75 },
      "mental_stress": { "score": 93.33, "confidence": 91.67 },
      "sleep_quality": { "score": 67.28, "confidence": 50 },
      "wellbeing": {
        "mental": { "score": 89, "assessment": "optimal" },
        "physical": { "score": 76, "assessment": "optimal" },
        "energy_sleep": { "score": 67, "assessment": "optimal" },
        "status_label": "GGG"
      }
    },
    "metrics_last_update_at": "2026-08-04T15:12:57+00:00",
    "created_at": "2026-08-09T04:09:49+00:00"
  },
  "errors": []
}
''';
  final decoded = jsonDecode(raw) as Map<String, dynamic>;
  return decoded;
  // final response = MimeScanStoreResponseModel.fromJson(decoded);
  // return FaceScanMapper.toVitalsFromMimeScan(response.data!);
}
