import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:mime_health/core/extensions/context_extensions.dart';
import 'package:mime_health/core/localization/l10n_keys.dart';
import 'package:mime_health/core/theme/app_colors.dart';
import 'package:mime_health/core/widgets/app_media_picker.dart';
import 'package:mime_health/features/language/presentation/provider/language_provider.dart';

/// Parameterized media-picker trigger, similar in spirit to [AppTextField1].
///
/// Frontend passes options + [onPicked]; this widget only opens the sheet and
/// returns the selected [AppPickedMedia] via callback. Source sheet labels are
/// resolved from l10n internally.
///
/// ```dart
/// AppMediaPickerField(
///   label: 'Add photo',
///   allowedTypes: {AppMediaType.jpg, AppMediaType.png},
///   allowFiles: false,
///   onPicked: (media) => controller.upload(media),
/// )
/// ```
class AppMediaPickerField extends ConsumerWidget {
  const AppMediaPickerField({
    super.key,
    required this.label,
    required this.onPicked,
    this.allowedTypes = const {AppMediaType.image},
    this.allowCamera = true,
    this.allowGallery = true,
    this.allowFiles = true,
    this.isLoading = false,
    this.enabled = true,
  });

  final String label;
  final ValueChanged<AppPickedMedia> onPicked;
  final Set<AppMediaType> allowedTypes;
  final bool allowCamera;
  final bool allowGallery;
  final bool allowFiles;
  final bool isLoading;
  final bool enabled;

  Future<void> _openPicker(BuildContext context, WidgetRef ref) async {
    if (!enabled || isLoading) return;

    final l10n = ref.read(languageControllerProvider);
    final media = await AppMediaPicker.pick(
      context,
      allowedTypes: allowedTypes,
      allowCamera: allowCamera,
      allowGallery: allowGallery,
      allowFiles: allowFiles,
      title: l10n.t(L10nKeys.mediaChooseSource),
      cameraLabel: l10n.t(L10nKeys.mediaCamera),
      galleryLabel: l10n.t(L10nKeys.mediaGallery),
      filesLabel: l10n.t(L10nKeys.mediaFiles),
      cancelLabel: l10n.t(L10nKeys.mediaCancel),
    );
    if (media == null) return;
    onPicked(media);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final canPress = enabled && !isLoading;

    return TextButton.icon(
      onPressed: canPress ? () => _openPicker(context, ref) : null,
      icon: isLoading
          ? SizedBox(
              width: context.scaleWidth(18),
              height: context.scaleWidth(18),
              child: const CircularProgressIndicator(
                strokeWidth: 2,
                color: AppColors.primaryContainer,
              ),
            )
          : Icon(
              Icons.add_a_photo_outlined,
              size: context.scaleWidth(18),
              color: canPress
                  ? AppColors.primaryContainer
                  : AppColors.textHint,
            ),
      label: Text(
        label,
        style: TextStyle(
          color: canPress ? AppColors.primaryContainer : AppColors.textHint,
          fontSize: context.smallFontSize,
          fontWeight: FontWeight.w700,
        ),
      ),
      style: TextButton.styleFrom(
        padding: EdgeInsets.symmetric(
          horizontal: context.scaleWidth(12),
          vertical: context.scaleHeight(6),
        ),
        backgroundColor: AppColors.glass,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(999),
          side: const BorderSide(color: AppColors.glassBorder),
        ),
      ),
    );
  }
}
