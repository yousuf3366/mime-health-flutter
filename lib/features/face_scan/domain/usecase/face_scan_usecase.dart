import '../../../../core/error/result.dart';
import '../entity/face_scan_entity.dart';
import '../repository/face_scan_repository.dart';

class EnsureIntelliProveUserUseCase {
  EnsureIntelliProveUserUseCase(this._repository);

  final FaceScanRepository _repository;

  Future<Result<void>> call({
    required String externalUserId,
    String? language,
    String? sex,
  }) {
    return _repository.ensureUser(
      externalUserId: externalUserId,
      language: language,
      sex: sex,
    );
  }
}

class GetFaceScanUrlUseCase {
  GetFaceScanUrlUseCase(this._repository);

  final FaceScanRepository _repository;

  Future<Result<FaceScanUrlResult>> call({required int profileId}) {
    return _repository.getFaceScanUrl(profileId: profileId);
  }
}

class GetIntelliProveUserIdUseCase {
  GetIntelliProveUserIdUseCase(this._repository);

  final FaceScanRepository _repository;

  Future<Result<IntelliProveUserIdResult>> call(String externalUserId) {
    return _repository.getIntelliProveUserId(externalUserId);
  }
}

class SaveFaceScanQuestionAnswersManyUseCase {
  SaveFaceScanQuestionAnswersManyUseCase(this._repository);

  final FaceScanRepository _repository;

  Future<Result<void>> call({
    required String userId,
    required List<FaceScanQuestionAnswer> answers,
    required String timezone,
  }) {
    return _repository.saveQuestionAnswersMany(
      userId: userId,
      answers: answers,
      timezone: timezone,
    );
  }
}

class SaveFaceScanQuestionAnswersUseCase {
  SaveFaceScanQuestionAnswersUseCase(this._repository);

  final FaceScanRepository _repository;

  Future<Result<void>> call({
    required String externalUserId,
    required List<FaceScanQuestionAnswer> answers,
    required String timezone,
  }) {
    return _repository.saveQuestionAnswers(
      externalUserId: externalUserId,
      answers: answers,
      timezone: timezone,
    );
  }
}

/// Stores the completed scan on Mime Health (`POST /api/v1/scans`).
class StoreMimeFaceScanUseCase {
  StoreMimeFaceScanUseCase(this._repository);

  final FaceScanRepository _repository;

  Future<Result<FaceScanVitalsResult>> call({
    required String faceScanId,
    required int externalUserId,
    required int profileId,
    int? faceScanUrlId,
  }) {
    return _repository.storeMimeScan(
      faceScanId: faceScanId,
      externalUserId: externalUserId,
      profileId: profileId,
      faceScanUrlId: faceScanUrlId,
    );
  }
}

/// Latest scan for Health Hub (`GET /api/v1/scans/latest`).
class GetLatestMimeScanUseCase {
  GetLatestMimeScanUseCase(this._repository);

  final FaceScanRepository _repository;

  Future<Result<FaceScanVitalsResult?>> call({int? profileId}) {
    return _repository.getLatestMimeScan(profileId: profileId);
  }
}
