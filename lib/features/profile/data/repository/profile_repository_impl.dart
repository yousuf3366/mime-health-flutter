import '../../../../core/error/result.dart';
import '../../../../core/repository/base_repository.dart';
import '../../domain/entity/profile_entity.dart';
import '../../domain/repository/profile_repository.dart';
import '../datasource/profile_remote_datasource.dart';
import '../mapper/profile_mapper.dart';

class ProfileRepositoryImpl extends BaseRepository
    implements ProfileRepository {
  ProfileRepositoryImpl({
    required ProfileRemoteDatasource remoteDatasource,
    required super.connectivityService,
  }) : _remote = remoteDatasource;

  final ProfileRemoteDatasource _remote;

  @override
  Future<Result<CreateProfileResult>> createProfile(ProfileDraftEntity draft) {
    return safeApiCall(() async {
      final response = await _remote.createProfile(
        ProfileMapper.toRequest(draft),
      );
      return ProfileMapper.toResult(response);
    });
  }

  @override
  Future<Result<CreateProfileResult>> updateProfile(
    int profileId,
    ProfileDraftEntity draft,
  ) {
    return safeApiCall(() async {
      final response = await _remote.updateProfile(
        profileId,
        ProfileMapper.toRequest(draft),
      );
      return ProfileMapper.toResult(response);
    });
  }

  @override
  Future<Result<UploadAvatarResult>> uploadAvatar({
    required int profileId,
    required String filePath,
    required String fileName,
    String? mimeType,
  }) {
    return safeApiCall(() async {
      final response = await _remote.uploadAvatar(
        profileId: profileId,
        filePath: filePath,
        fileName: fileName,
        mimeType: mimeType,
      );
      return ProfileMapper.toAvatarResult(response);
    });
  }

  @override
  Future<Result<List<ProfileEntity>>> getProfiles() {
    return safeApiCall(() async {
      final response = await _remote.getProfiles();
      return ProfileMapper.toEntityList(response);
    });
  }
}
