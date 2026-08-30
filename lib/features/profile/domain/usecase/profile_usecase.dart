import '../../../../core/error/result.dart';
import '../entity/profile_entity.dart';
import '../repository/profile_repository.dart';

class CreateProfileUseCase {
  CreateProfileUseCase(this._repository);

  final ProfileRepository _repository;

  Future<Result<CreateProfileResult>> call(ProfileDraftEntity draft) {
    return _repository.createProfile(draft);
  }
}

class GetProfilesUseCase {
  GetProfilesUseCase(this._repository);

  final ProfileRepository _repository;

  Future<Result<List<ProfileEntity>>> call() {
    return _repository.getProfiles();
  }
}

class UpdateProfileUseCase {
  UpdateProfileUseCase(this._repository);

  final ProfileRepository _repository;

  Future<Result<CreateProfileResult>> call(
    int profileId,
    ProfileDraftEntity draft,
  ) {
    return _repository.updateProfile(profileId, draft);
  }
}

class UploadAvatarUseCase {
  UploadAvatarUseCase(this._repository);

  final ProfileRepository _repository;

  Future<Result<UploadAvatarResult>> call({
    required int profileId,
    required String filePath,
    required String fileName,
    String? mimeType,
  }) {
    return _repository.uploadAvatar(
      profileId: profileId,
      filePath: filePath,
      fileName: fileName,
      mimeType: mimeType,
    );
  }
}
