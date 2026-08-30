import '../../../../core/error/result.dart';
import '../entity/profile_entity.dart';

/// Profile repository contract.
abstract class ProfileRepository {
  Future<Result<CreateProfileResult>> createProfile(ProfileDraftEntity draft);

  Future<Result<CreateProfileResult>> updateProfile(
    int profileId,
    ProfileDraftEntity draft,
  );

  Future<Result<UploadAvatarResult>> uploadAvatar({
    required int profileId,
    required String filePath,
    required String fileName,
    String? mimeType,
  });

  Future<Result<List<ProfileEntity>>> getProfiles();
}
