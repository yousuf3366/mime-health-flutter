import '../../../../core/config/app_config.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/error/result.dart';
import '../../../../core/repository/base_repository.dart';
import '../../domain/entity/face_scan_entity.dart';
import '../../domain/repository/face_scan_repository.dart';
import '../datasource/intelliprove_remote_datasource.dart';
import '../datasource/mime_scan_remote_datasource.dart';
import '../mapper/face_scan_mapper.dart';
import '../model/face_scan_models.dart';
import '../model/mime_scan_models.dart';

class FaceScanRepositoryImpl extends BaseRepository
    implements FaceScanRepository {
  FaceScanRepositoryImpl({
    required IntelliProveRemoteDatasource remoteDatasource,
    required MimeScanRemoteDatasource mimeScanRemoteDatasource,
    required super.connectivityService,
  }) : _remote = remoteDatasource,
       _mimeRemote = mimeScanRemoteDatasource;

  final IntelliProveRemoteDatasource _remote;
  final MimeScanRemoteDatasource _mimeRemote;

  @override
  Future<Result<void>> ensureUser({
    required String externalUserId,
    String? language,
    String? sex,
  }) {
    return safeApiCall(() async {
      await _remote.ensureUser(
        EnsureUserRequestModel(
          externalUserId: externalUserId,
          language: language ?? AppConfig.intelliProveValidatedLanguage,
          sex: FaceScanMapper.toIntelliProveSex(sex),
        ),
      );
    });
  }

  @override
  Future<Result<FaceScanUrlResult>> getFaceScanUrl({required int profileId}) {
    return safeApiCall(() async {
      final data = await _mimeRemote.getFaceScanUrl(profileId: profileId);
      return FaceScanMapper.toUrlResult(
        data.faceScanUrl,
        faceScanId: data.faceScanId,
        faceScanUrlId: data.faceScanUrlId,
        profileId: data.profileId,
        externalUserId: data.externalUserId,
      );
    });
  }

  @override
  Future<Result<IntelliProveUserIdResult>> getIntelliProveUserId(
    String externalUserId,
  ) {
    return safeApiCall(() async {
      final model = await _remote.getIntelliProveUserId(externalUserId);
      return FaceScanMapper.toUserIdResult(model);
    });
  }

  @override
  Future<Result<void>> saveQuestionAnswersMany({
    required String userId,
    required List<FaceScanQuestionAnswer> answers,
    required String timezone,
  }) {
    return safeApiCall(() async {
      await _remote.saveQuestionAnswersMany(
        userId: userId,
        answers: FaceScanMapper.toAnswerRequests(answers, timezone: timezone),
      );
    });
  }

  @override
  Future<Result<void>> saveQuestionAnswers({
    required String externalUserId,
    required List<FaceScanQuestionAnswer> answers,
    required String timezone,
  }) {
    return safeApiCall(() async {
      await _remote.saveQuestionAnswers(
        externalUserId: externalUserId,
        answers: FaceScanMapper.toAnswerRequests(answers, timezone: timezone),
      );
    });
  }

  @override
  Future<Result<FaceScanVitalsResult>> storeMimeScan({
    required String faceScanId,
    required int externalUserId,
    required int profileId,
    int? faceScanUrlId,
  }) {
    return safeApiCall(() async {
      final response = await _mimeRemote.storeScan(
        MimeScanStoreRequestModel(
          faceScanId: FaceScanMapper.normalizeFaceScanId(faceScanId),
          externalUserId: externalUserId,
          profileId: profileId,
          faceScanUrlId: faceScanUrlId,
        ),
      );
      if (!response.success || response.data == null) {
        final detail = response.errors.isEmpty
            ? ''
            : ' ${response.errors.join(', ')}';
        throw ApiException(
          (response.message.isEmpty
                  ? 'Failed to store face scan on Mime Health.'
                  : response.message) +
              detail,
        );
      }
      return FaceScanMapper.toVitalsFromMimeScan(response.data!);
    });
  }

  @override
  Future<Result<FaceScanVitalsResult?>> getLatestMimeScan({int? profileId}) {
    return safeApiCall(() async {
      final response = await _mimeRemote.getLatestScan(profileId: profileId);
      if (!response.success) {
        final detail = response.errors.isEmpty
            ? ''
            : ' ${response.errors.join(', ')}';
        throw ApiException(
          (response.message.isEmpty
                  ? 'Failed to load latest scan.'
                  : response.message) +
              detail,
        );
      }
      if (response.data == null) return null;
      return FaceScanMapper.toVitalsFromMimeScan(response.data!);
    });
  }
}
