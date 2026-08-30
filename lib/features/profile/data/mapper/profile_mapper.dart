import '../../../../core/config/app_config.dart';
import '../../domain/entity/profile_entity.dart';
import '../model/profile_models.dart';

class ProfileMapper {
  ProfileMapper._();

  /// Turns a relative media path into an absolute URL using [AppConfig.baseUrl].
  ///
  /// Avatar storage is served on `:8443` over HTTPS. If the API returns
  /// `http://…:8443/…`, browsers/clients get HTTP 400 ("plain HTTP to HTTPS
  /// port") — upgrade those URLs to `https`.
  static String? resolveMediaUrl(String? path) {
    if (path == null) return null;
    final trimmed = path.trim();
    if (trimmed.isEmpty) return null;

    late final String absolute;
    if (trimmed.startsWith('http://') || trimmed.startsWith('https://')) {
      absolute = trimmed;
    } else {
      final base = AppConfig.baseUrl.replaceAll(RegExp(r'/+$'), '');
      absolute = trimmed.startsWith('/') ? '$base$trimmed' : '$base/$trimmed';
    }

    final uri = Uri.tryParse(absolute);
    if (uri == null) return absolute;

    // Storage TLS port — never fetch via plain HTTP.
    if (uri.scheme == 'http' &&
        (uri.port == 8443 || uri.path.contains('/storage/'))) {
      return uri.replace(scheme: 'https').toString();
    }

    return absolute;
  }

  static CreateProfileRequestModel toRequest(ProfileDraftEntity entity) {
    return CreateProfileRequestModel(
      profileKind: entity.profileKind,
      displayName: entity.displayName,
      dateOfBirth: entity.dateOfBirth,
      sex: entity.sex,
      lifeStyle: entity.lifeStyle,
      phone: entity.phone,
      email: entity.email,
      bloodGroup: entity.bloodGroup,
      heightFeet: entity.heightFeet,
      heightInches: entity.heightInches,
      weightKg: entity.weightKg,
      currentSmoker: entity.currentSmoker,
      diabetes: entity.diabetes,
      historyOfHypertension: entity.historyOfHypertension,
      historyOfHighGlucoseLevels: entity.historyOfHighGlucoseLevels,
      privacyLevel: entity.privacyLevel,
    );
  }

  static CreateProfileResult toResult(CreateProfileResponseModel model) {
    return CreateProfileResult(id: model.id, message: model.message);
  }

  static UploadAvatarResult toAvatarResult(UploadAvatarResponseModel model) {
    return UploadAvatarResult(
      avatarPath: resolveMediaUrl(model.avatarPath),
      message: model.message,
    );
  }

  static ProfileEntity toEntity(ProfileModel model) {
    return ProfileEntity(
      id: model.id,
      userId: model.userId,
      householdId: model.householdId,
      displayName: model.displayName,
      dateOfBirth: model.dateOfBirth,
      sex: model.sex,
      lifeStyle: model.lifeStyle,
      profileKind: model.profileKind,
      phone: model.phone,
      email: model.email,
      bloodGroup: model.bloodGroup,
      heightFeet: model.heightFeet,
      heightInches: model.heightInches,
      weightKg: model.weightKg,
      currentSmoker: model.currentSmoker,
      diabetes: model.diabetes,
      historyOfHypertension: model.historyOfHypertension,
      historyOfHighGlucoseLevels: model.historyOfHighGlucoseLevels,
      isMinor: model.isMinor,
      privacyLevel: model.privacyLevel,
      status: model.status,
      avatarPath: resolveMediaUrl(model.avatarPath),
    );
  }

  static List<ProfileEntity> toEntityList(ProfilesListResponseModel model) {
    return model.profiles.map(toEntity).toList(growable: false);
  }
}
