import 'package:equatable/equatable.dart';

import '../../../../core/widgets/app_media_picker.dart';

const Object _noValue = Object();

enum ProfileAvatarUploadStatus { idle, uploading, success, error }

class ProfileAvatarUploadState extends Equatable {
  const ProfileAvatarUploadState({
    this.status = ProfileAvatarUploadStatus.idle,
    this.pickedMedia,
    this.uploadedAvatarPath,
    this.successMessage,
    this.errorMessage,
  });

  factory ProfileAvatarUploadState.initial() =>
      const ProfileAvatarUploadState();

  final ProfileAvatarUploadStatus status;
  final AppPickedMedia? pickedMedia;
  final String? uploadedAvatarPath;
  final String? successMessage;
  final String? errorMessage;

  bool get isUploading => status == ProfileAvatarUploadStatus.uploading;

  ProfileAvatarUploadState copyWith({
    Object? status = _noValue,
    Object? pickedMedia = _noValue,
    Object? uploadedAvatarPath = _noValue,
    Object? successMessage = _noValue,
    Object? errorMessage = _noValue,
  }) {
    return ProfileAvatarUploadState(
      status: identical(status, _noValue)
          ? this.status
          : status as ProfileAvatarUploadStatus,
      pickedMedia: identical(pickedMedia, _noValue)
          ? this.pickedMedia
          : pickedMedia as AppPickedMedia?,
      uploadedAvatarPath: identical(uploadedAvatarPath, _noValue)
          ? this.uploadedAvatarPath
          : uploadedAvatarPath as String?,
      successMessage: identical(successMessage, _noValue)
          ? this.successMessage
          : successMessage as String?,
      errorMessage: identical(errorMessage, _noValue)
          ? this.errorMessage
          : errorMessage as String?,
    );
  }

  @override
  List<Object?> get props => [
        status,
        pickedMedia,
        uploadedAvatarPath,
        successMessage,
        errorMessage,
      ];
}
