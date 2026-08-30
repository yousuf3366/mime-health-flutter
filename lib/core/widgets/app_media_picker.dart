import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mime_health/core/extensions/context_extensions.dart';
import 'package:mime_health/core/theme/app_colors.dart';

/// Allowed media kinds for [AppMediaPicker].
///
/// Combine values to make the picker dynamic, e.g.
/// `{AppMediaType.jpg, AppMediaType.png}` or `{AppMediaType.all}`.
enum AppMediaType { image, png, jpg, pdf, video, audio, all }

enum _MediaSource { camera, gallery, files }

/// Result returned after the user picks a file.
class AppPickedMedia {
  const AppPickedMedia({
    required this.path,
    required this.name,
    this.mimeType,
    this.sizeBytes,
  });

  final String path;
  final String name;
  final String? mimeType;
  final int? sizeBytes;
}

/// Reusable camera / gallery / files picker sheet.
///
/// Example:
/// ```dart
/// final media = await AppMediaPicker.pick(
///   context,
///   allowedTypes: {AppMediaType.jpg, AppMediaType.png},
/// );
/// ```
class AppMediaPicker {
  AppMediaPicker._();

  static final ImagePicker _imagePicker = ImagePicker();

  /// Shows a bottom sheet and returns the selected file, or `null` if cancelled.
  static Future<AppPickedMedia?> pick(
    BuildContext context, {
    Set<AppMediaType> allowedTypes = const {AppMediaType.image},
    bool allowCamera = true,
    bool allowGallery = true,
    bool allowFiles = true,
    String? title,
    String cameraLabel = 'Camera',
    String galleryLabel = 'Gallery',
    String filesLabel = 'Files',
    String cancelLabel = 'Cancel',
  }) async {
    final resolved = _ResolvedTypes(allowedTypes);

    // Close the sheet first, then open the native picker. Launching
    // image_picker / file_picker while the modal is still presented fails on
    // both iOS and Android.
    final source = await showModalBottomSheet<_MediaSource>(
      context: context,
      backgroundColor: AppColors.surfaceLow,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(context.scaleWidth(16)),
        ),
      ),
      builder: (sheetContext) {
        return SafeArea(
          child: Padding(
            padding: EdgeInsets.fromLTRB(
              context.defaultPaddingSc,
              context.scaleHeight(12),
              context.defaultPaddingSc,
              context.scaleHeight(16),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: context.scaleWidth(40),
                  height: context.scaleHeight(4),
                  decoration: BoxDecoration(
                    color: AppColors.textPrimary.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
                SizedBox(height: context.scaleHeight(16)),
                Text(
                  title ?? 'Choose source',
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: context.titleFontSize,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                SizedBox(height: context.scaleHeight(12)),
                if (allowCamera && resolved.supportsCamera)
                  _PickerOption(
                    icon: Icons.photo_camera_outlined,
                    label: cameraLabel,
                    onTap: () =>
                        Navigator.of(sheetContext).pop(_MediaSource.camera),
                  ),
                if (allowGallery && resolved.supportsGallery)
                  _PickerOption(
                    icon: Icons.photo_library_outlined,
                    label: galleryLabel,
                    onTap: () =>
                        Navigator.of(sheetContext).pop(_MediaSource.gallery),
                  ),
                if (allowFiles && resolved.supportsFiles)
                  _PickerOption(
                    icon: Icons.folder_open_outlined,
                    label: filesLabel,
                    onTap: () =>
                        Navigator.of(sheetContext).pop(_MediaSource.files),
                  ),
                SizedBox(height: context.scaleHeight(4)),
                TextButton(
                  onPressed: () => Navigator.of(sheetContext).pop(),
                  child: Text(
                    cancelLabel,
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: context.fontSize,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );

    if (source == null || !context.mounted) return null;

    return switch (source) {
      _MediaSource.camera => _pickFromCamera(resolved),
      _MediaSource.gallery => _pickFromGallery(resolved),
      _MediaSource.files => _pickFromFiles(resolved),
    };
  }

  static Future<AppPickedMedia?> _pickFromCamera(
    _ResolvedTypes resolved,
  ) async {
    final file = await _imagePicker.pickImage(
      source: ImageSource.camera,
      imageQuality: 85,
    );
    return _fromXFile(file, fallbackMime: 'image/jpeg');
  }

  static Future<AppPickedMedia?> _pickFromGallery(
    _ResolvedTypes resolved,
  ) async {
    if (resolved.imagesOnly) {
      final file = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
      );
      return _fromXFile(file, fallbackMime: 'image/jpeg');
    }

    if (resolved.videosOnly) {
      final file = await _imagePicker.pickVideo(source: ImageSource.gallery);
      return _fromXFile(file, fallbackMime: 'video/mp4');
    }

    // Mixed image/video gallery → prefer image for avatar-style flows.
    if (resolved.allowImage) {
      final file = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
      );
      return _fromXFile(file, fallbackMime: 'image/jpeg');
    }

    final file = await _imagePicker.pickVideo(source: ImageSource.gallery);
    return _fromXFile(file, fallbackMime: 'video/mp4');
  }

  static Future<AppPickedMedia?> _pickFromFiles(_ResolvedTypes resolved) async {
    final result = await FilePicker.pickFiles(
      type: resolved.filePickerType,
      allowedExtensions: resolved.fileExtensions,
      allowMultiple: false,
      withData: false,
    );

    final files = result?.files;
    final file = (files == null || files.isEmpty) ? null : files.first;
    if (file == null || file.path == null || file.path!.isEmpty) return null;

    return AppPickedMedia(
      path: file.path!,
      name: file.name,
      mimeType: _mimeFromName(file.name),
      sizeBytes: file.size,
    );
  }

  static Future<AppPickedMedia?> _fromXFile(
    XFile? file, {
    required String fallbackMime,
  }) async {
    if (file == null) return null;
    final bytes = await file.length();
    final name = file.name.isNotEmpty
        ? file.name
        : file.path.split(RegExp(r'[/\\]')).last;
    return AppPickedMedia(
      path: file.path,
      name: name,
      mimeType: file.mimeType ?? _mimeFromName(name) ?? fallbackMime,
      sizeBytes: bytes,
    );
  }

  static String? _mimeFromName(String name) {
    final lower = name.toLowerCase();
    if (lower.endsWith('.png')) return 'image/png';
    if (lower.endsWith('.jpg') || lower.endsWith('.jpeg')) return 'image/jpeg';
    if (lower.endsWith('.webp')) return 'image/webp';
    if (lower.endsWith('.gif')) return 'image/gif';
    if (lower.endsWith('.pdf')) return 'application/pdf';
    if (lower.endsWith('.mp4')) return 'video/mp4';
    if (lower.endsWith('.mov')) return 'video/quicktime';
    if (lower.endsWith('.mp3')) return 'audio/mpeg';
    if (lower.endsWith('.m4a')) return 'audio/mp4';
    if (lower.endsWith('.wav')) return 'audio/wav';
    return null;
  }
}

class _ResolvedTypes {
  _ResolvedTypes(Set<AppMediaType> raw)
    : allowAll = raw.contains(AppMediaType.all),
      allowImage =
          raw.contains(AppMediaType.all) ||
          raw.contains(AppMediaType.image) ||
          raw.contains(AppMediaType.png) ||
          raw.contains(AppMediaType.jpg),
      allowPng =
          raw.contains(AppMediaType.all) ||
          raw.contains(AppMediaType.image) ||
          raw.contains(AppMediaType.png),
      allowJpg =
          raw.contains(AppMediaType.all) ||
          raw.contains(AppMediaType.image) ||
          raw.contains(AppMediaType.jpg),
      allowPdf =
          raw.contains(AppMediaType.all) || raw.contains(AppMediaType.pdf),
      allowVideo =
          raw.contains(AppMediaType.all) || raw.contains(AppMediaType.video),
      allowAudio =
          raw.contains(AppMediaType.all) || raw.contains(AppMediaType.audio);

  final bool allowAll;
  final bool allowImage;
  final bool allowPng;
  final bool allowJpg;
  final bool allowPdf;
  final bool allowVideo;
  final bool allowAudio;

  bool get supportsCamera => allowImage;
  bool get supportsGallery => allowImage || allowVideo;
  bool get supportsFiles =>
      allowAll || allowPdf || allowAudio || allowImage || allowVideo;

  bool get imagesOnly => allowImage && !allowVideo && !allowPdf && !allowAudio;
  bool get videosOnly => allowVideo && !allowImage && !allowPdf && !allowAudio;

  FileType get filePickerType {
    if (allowAll) return FileType.any;
    if (allowAudio && !allowImage && !allowVideo && !allowPdf) {
      return FileType.audio;
    }
    if (allowVideo && !allowImage && !allowPdf && !allowAudio) {
      return FileType.video;
    }
    if (allowImage && !allowPdf && !allowVideo && !allowAudio) {
      return FileType.image;
    }
    return FileType.custom;
  }

  List<String>? get fileExtensions {
    if (filePickerType != FileType.custom) return null;

    final extensions = <String>{};
    if (allowJpg) {
      extensions.addAll(['jpg', 'jpeg']);
    }
    if (allowPng) extensions.add('png');
    if (allowPdf) extensions.add('pdf');
    if (allowVideo) extensions.addAll(['mp4', 'mov', 'avi', 'mkv']);
    if (allowAudio) extensions.addAll(['mp3', 'm4a', 'wav', 'aac']);
    if (allowImage && !allowJpg && !allowPng) {
      extensions.addAll(['jpg', 'jpeg', 'png', 'webp']);
    }
    return extensions.toList(growable: false);
  }
}

class _PickerOption extends StatelessWidget {
  const _PickerOption({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(icon, color: AppColors.primaryContainer),
      title: Text(
        label,
        style: TextStyle(
          color: AppColors.textPrimary,
          fontSize: context.bodyFontSize,
          fontWeight: FontWeight.w600,
        ),
      ),
      onTap: onTap,
    );
  }
}
