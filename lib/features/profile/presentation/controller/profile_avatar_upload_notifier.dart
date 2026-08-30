import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/localization/l10n_keys.dart';
import '../../../../core/providers/core_providers.dart';
import '../../../../core/widgets/app_media_picker.dart';
import '../../../language/presentation/provider/language_provider.dart';
import '../provider/profile_di.dart';
import '../state/profile_avatar_upload_state.dart';

class ProfileAvatarUploadNotifier extends Notifier<ProfileAvatarUploadState> {
  @override
  ProfileAvatarUploadState build() => ProfileAvatarUploadState.initial();

  Future<bool> upload({
    required int profileId,
    required AppPickedMedia media,
  }) async {
    final l10n = ref.read(languageControllerProvider);
    final snackbar = ref.read(snackbarServiceProvider);

    state = state.copyWith(
      status: ProfileAvatarUploadStatus.uploading,
      pickedMedia: media,
      errorMessage: null,
      successMessage: null,
    );

    final result = await ref
        .read(uploadAvatarUseCaseProvider)
        .call(
          profileId: profileId,
          filePath: media.path,
          fileName: media.name,
          mimeType: media.mimeType,
        );

    return result.when(
      success: (uploaded) {
        state = state.copyWith(
          status: ProfileAvatarUploadStatus.success,
          uploadedAvatarPath: uploaded.avatarPath,
          successMessage: uploaded.message.isNotEmpty
              ? uploaded.message
              : l10n.t(L10nKeys.profilePhotoUploadSuccess),
          errorMessage: null,
        );
        ref.invalidate(profilesProvider);
        snackbar.showSuccess(state.successMessage!);
        return true;
      },
      failure: (error) {
        state = state.copyWith(
          status: ProfileAvatarUploadStatus.error,
          errorMessage: error.message,
          successMessage: null,
        );
        snackbar.showError(error.message);
        return false;
      },
    );
  }

  void reset() {
    state = ProfileAvatarUploadState.initial();
  }
}

final profileAvatarUploadNotifierProvider =
    NotifierProvider<ProfileAvatarUploadNotifier, ProfileAvatarUploadState>(
      ProfileAvatarUploadNotifier.new,
    );
