import '../../../../core/error/result.dart';
import '../entity/face_scan_entity.dart';

/// Face Scan repository: Mime for scan URL/store, IntelliProve for Q&A only.
abstract class FaceScanRepository {
  /// Ensures the IntelliProve user exists before Q&A submit (idempotent).
  Future<Result<void>> ensureUser({
    required String externalUserId,
    String? language,
    String? sex,
  });

  /// Returns the Face Scan plug-in URL from Mime (`POST …/get-face-scan-url`).
  Future<Result<FaceScanUrlResult>> getFaceScanUrl({required int profileId});

  /// Resolves IntelliProve internal `user_id` for batch answer submit.
  Future<Result<IntelliProveUserIdResult>> getIntelliProveUserId(
    String externalUserId,
  );

  /// Batch-save profile answers (`user_id` query).
  Future<Result<void>> saveQuestionAnswersMany({
    required String userId,
    required List<FaceScanQuestionAnswer> answers,
    required String timezone,
  });

  /// Fallback: save answers one-by-one via `external_user_id`.
  Future<Result<void>> saveQuestionAnswers({
    required String externalUserId,
    required List<FaceScanQuestionAnswer> answers,
    required String timezone,
  });

  /// Stores a completed face scan on Mime Health (`POST /api/v1/scans`).
  Future<Result<FaceScanVitalsResult>> storeMimeScan({
    required String faceScanId,
    required int externalUserId,
    required int profileId,
    int? faceScanUrlId,
  });

  /// Latest scan for Health Hub (`GET /api/v1/scans/latest`).
  /// Returns `null` when the user has no scans yet.
  Future<Result<FaceScanVitalsResult?>> getLatestMimeScan({int? profileId});
}
