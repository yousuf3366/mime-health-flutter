import 'dart:io';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:mime_health/core/constants/app_constants.dart';
import 'package:mime_health/core/error/exceptions.dart';
import 'package:mime_health/core/extensions/context_extensions.dart';
import 'package:mime_health/core/theme/app_colors.dart';
import 'package:mime_health/core/widgets/app_button.dart';
import 'package:mime_health/core/widgets/app_media_picker.dart';
import 'package:mime_health/core/widgets/app_media_picker_field.dart';
import 'package:mime_health/core/widgets/app_network_image.dart';

import '../../../../core/localization/l10n_keys.dart';
import '../../../../core/router/route_names.dart';
import '../../../language/presentation/provider/language_provider.dart';
import '../../domain/entity/profile_entity.dart';
import '../provider/profile_provider.dart';
import '../../data/mapper/profile_mapper.dart';

/// Shows the signed-in user's primary profile details.
class ProfileDetailsScreen extends ConsumerWidget {
  const ProfileDetailsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = ref.watch(languageControllerProvider);
    final profilesAsync = ref.watch(profilesProvider);

    return profilesAsync.when(
      loading: () => const Center(
        child: CircularProgressIndicator(color: AppColors.primaryContainer),
      ),
      error: (error, _) => Center(
        child: Padding(
          padding: EdgeInsets.all(context.defaultPaddingSc),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                error is AppException
                    ? error.message
                    : l10n.t(L10nKeys.genericError),
                textAlign: TextAlign.center,
                style: const TextStyle(color: AppColors.textPrimary),
              ),
              SizedBox(height: context.scaleHeight(16)),
              AppButton(
                label: l10n.t(L10nKeys.retry),
                onPressed: () => ref.invalidate(profilesProvider),
              ),
            ],
          ),
        ),
      ),
      data: (profiles) {
        if (profiles.isEmpty) {
          return Center(
            child: Padding(
              padding: EdgeInsets.all(context.defaultPaddingSc),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    l10n.t(L10nKeys.homeCreateProfile),
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: AppColors.textPrimary),
                  ),
                  SizedBox(height: context.scaleHeight(16)),
                  AppButton(
                    label: l10n.t(L10nKeys.homeCreateProfile),
                    onPressed: () => context.push(RouteNames.createProfile),
                  ),
                ],
              ),
            ),
          );
        }

        final profile = _primaryProfile(profiles);
        final user = ref.watch(currentUserProvider).asData?.value;
        return _ProfileDetailsBody(
          profile: profile,
          phoneNumber:
              (profile.phone != null && profile.phone!.trim().isNotEmpty)
              ? profile.phone
              : user?.phone,
          emailAddress:
              (profile.email != null && profile.email!.trim().isNotEmpty)
              ? profile.email
              : user?.email,
        );
      },
    );
  }

  ProfileEntity _primaryProfile(List<ProfileEntity> profiles) {
    for (final profile in profiles) {
      if (profile.profileKind == AppConstants.profileKindSelf) {
        return profile;
      }
    }
    return profiles.first;
  }
}

class _ProfileDetailsBody extends ConsumerWidget {
  const _ProfileDetailsBody({
    required this.profile,
    required this.phoneNumber,
    required this.emailAddress,
  });

  final ProfileEntity profile;
  final String? phoneNumber;
  final String? emailAddress;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = ref.watch(languageControllerProvider);
    final uploadState = ref.watch(profileAvatarUploadNotifierProvider);
    final uploadNotifier = ref.read(
      profileAvatarUploadNotifierProvider.notifier,
    );
    final localPreviewPath = uploadState.pickedMedia?.path;
    // Prefer the profiles API avatar (full URL on :8443). Fall back to upload
    // response only when the list has not refreshed yet.
    final avatarUrl = ProfileMapper.resolveMediaUrl(
      (profile.avatarPath != null && profile.avatarPath!.trim().isNotEmpty)
          ? profile.avatarPath
          : uploadState.uploadedAvatarPath,
    );
    final showLocalPreview =
        uploadState.isUploading &&
        localPreviewPath != null &&
        localPreviewPath.trim().isNotEmpty;
    final hasAvatar =
        showLocalPreview || (avatarUrl != null && avatarUrl.trim().isNotEmpty);

    return Stack(
      children: [
        SafeArea(
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: EdgeInsets.fromLTRB(
                    context.defaultPaddingSc,
                    context.scaleHeight(16),
                    context.defaultPaddingSc,
                    context.scaleHeight(140),
                  ),
                  child: Column(
                    children: [
                      _AvatarSection(
                        localImagePath: showLocalPreview
                            ? localPreviewPath
                            : null,
                        avatarUrl: avatarUrl,
                        displayName: profile.displayName,
                        photoButton: AppMediaPickerField(
                          label: l10n.t(
                            hasAvatar
                                ? L10nKeys.profileUpdatePhoto
                                : L10nKeys.profileAddPhoto,
                          ),
                          allowedTypes: {AppMediaType.jpg, AppMediaType.png},
                          allowCamera: true,
                          allowGallery: true,
                          allowFiles: false,
                          isLoading: uploadState.isUploading,
                          onPicked: (media) {
                            uploadNotifier.upload(
                              profileId: profile.id,
                              media: media,
                            );
                          },
                        ),
                      ),
                      SizedBox(height: context.scaleHeight(24)),
                      _InfoCard(
                        rows: [
                          _InfoRowData(
                            title: l10n.t(L10nKeys.profileAge),
                            value: _age(profile.dateOfBirth),
                          ),
                          _InfoRowData(
                            title: l10n.t(L10nKeys.homeGender),
                            value: _sexLabel(l10n.t, profile.sex),
                          ),
                          _InfoRowData(
                            title: l10n.t(L10nKeys.homeLifestyle),
                            value: _lifestyleLabel(l10n.t, profile.lifeStyle),
                          ),
                          _InfoRowData(
                            title: l10n.t(L10nKeys.homeDisplayName),
                            value: profile.displayName,
                          ),
                          _InfoRowData(
                            title: l10n.t(L10nKeys.profilePhone),
                            value: _orNotSet(l10n.t, phoneNumber),
                          ),
                          _InfoRowData(
                            title: l10n.t(L10nKeys.profileEmail),
                            value: _orNotSet(l10n.t, emailAddress),
                          ),
                          _InfoRowData(
                            title: l10n.t(L10nKeys.profileHeight),
                            value: profile.heightFeet != null
                                ? '${profile.heightFeet}′ ${profile.heightInches ?? 0}″'
                                : l10n.t(L10nKeys.profileNotSet),
                          ),
                          _InfoRowData(
                            title: l10n.t(L10nKeys.profileWeight),
                            value: profile.weightKg != null
                                ? '${profile.weightKg} kg'
                                : l10n.t(L10nKeys.profileNotSet),
                          ),
                          _InfoRowData(
                            title: l10n.t(L10nKeys.profileBloodGroup),
                            value: _orNotSet(l10n.t, profile.bloodGroup),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        Positioned(
          left: 0,
          right: 0,
          bottom: 0,
          child: _BottomCta(
            label: l10n.t(L10nKeys.profileEdit),
            onPressed: () =>
                context.push(RouteNames.createProfile, extra: profile),
          ),
        ),
      ],
    );
  }

  String _age(String dateOfBirth) {
    final birthDate = DateTime.tryParse(dateOfBirth);
    if (birthDate == null) return '-';

    final today = DateTime.now();
    var age = today.year - birthDate.year;
    if (today.month < birthDate.month ||
        (today.month == birthDate.month && today.day < birthDate.day)) {
      age--;
    }
    return age.toString();
  }

  String _orNotSet(
    String Function(String key, {String? fallback}) t,
    String? value,
  ) {
    if (value == null || value.trim().isEmpty) {
      return t(L10nKeys.profileNotSet);
    }
    return value;
  }

  String _sexLabel(
    String Function(String key, {String? fallback}) t,
    String sex,
  ) {
    return switch (sex.toLowerCase()) {
      'male' => t(L10nKeys.homeMale),
      'female' => t(L10nKeys.homeFemale),
      _ => sex,
    };
  }

  String _lifestyleLabel(
    String Function(String key, {String? fallback}) t,
    String lifestyle,
  ) {
    return switch (lifestyle.toLowerCase()) {
      'active' => t(L10nKeys.homeActive),
      'moderate' => t(L10nKeys.homeModerate),
      'inactive' => t(L10nKeys.homeInactive),
      _ => lifestyle,
    };
  }
}

class _AvatarSection extends StatelessWidget {
  const _AvatarSection({
    required this.displayName,
    required this.photoButton,
    this.localImagePath,
    this.avatarUrl,
  });

  final String? localImagePath;
  final String? avatarUrl;
  final String displayName;
  final Widget photoButton;

  @override
  Widget build(BuildContext context) {
    final size = context.scaleWidth(112);
    final localPath = localImagePath?.trim();
    final networkUrl = avatarUrl?.trim();
    final hasLocal = localPath != null && localPath.isNotEmpty;
    final hasNetwork = networkUrl != null && networkUrl.isNotEmpty;

    return Column(
      children: [
        Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppColors.glass,
            border: Border.all(
              color: AppColors.primaryContainer.withValues(alpha: 0.5),
              width: 2,
            ),
          ),
          clipBehavior: Clip.antiAlias,
          child: hasLocal
              ? Image.file(
                  File(localPath),
                  fit: BoxFit.cover,
                  errorBuilder: (_, error, stackTrace) => hasNetwork
                      ? AppNetworkImage(
                          networkUrl,
                          fit: BoxFit.cover,
                          errorBuilder: (_, error, stackTrace) =>
                              _AvatarPlaceholder(name: displayName, size: size),
                        )
                      : _AvatarPlaceholder(name: displayName, size: size),
                )
              : hasNetwork
              ? AppNetworkImage(
                  networkUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (_, error, stackTrace) =>
                      _AvatarPlaceholder(name: displayName, size: size),
                )
              : _AvatarPlaceholder(name: displayName, size: size),
        ),
        SizedBox(height: context.scaleHeight(12)),
        photoButton,
      ],
    );
  }
}

class _AvatarPlaceholder extends StatelessWidget {
  const _AvatarPlaceholder({required this.name, required this.size});

  final String name;
  final double size;

  @override
  Widget build(BuildContext context) {
    final initial = name.trim().isEmpty ? '?' : name.trim()[0].toUpperCase();

    return ColoredBox(
      color: AppColors.surfaceLow,
      child: Center(
        child: Text(
          initial,
          style: TextStyle(
            color: AppColors.primaryContainer,
            fontSize: size * 0.4,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}

class _InfoRowData {
  const _InfoRowData({required this.title, required this.value});

  final String title;
  final String value;
}

class _InfoCard extends StatelessWidget {
  const _InfoCard({required this.rows});

  final List<_InfoRowData> rows;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        horizontal: context.scaleWidth(20),
        vertical: context.scaleHeight(8),
      ),
      decoration: BoxDecoration(
        color: AppColors.glass,
        borderRadius: BorderRadius.circular(context.scaleWidth(20)),
        border: Border.all(color: AppColors.glassBorder),
      ),
      child: Column(
        children: [
          for (var i = 0; i < rows.length; i++) ...[
            _InfoRow(title: rows[i].title, value: rows[i].value),
            if (i < rows.length - 1)
              Divider(
                height: 1,
                color: AppColors.border.withValues(alpha: 0.5),
              ),
          ],
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.title, required this.value});

  final String title;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: context.scaleHeight(14)),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 4,
            child: Text(
              title,
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: context.fontSize,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          SizedBox(width: context.scaleWidth(12)),
          Expanded(
            flex: 5,
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: context.fontSize,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _BottomCta extends StatelessWidget {
  const _BottomCta({required this.label, required this.onPressed});

  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.paddingOf(context).bottom;

    return Container(
      padding: EdgeInsets.fromLTRB(
        context.defaultPaddingSc,
        context.scaleHeight(40),
        context.defaultPaddingSc,
        bottom > 0 ? bottom : context.defaultPaddingSc,
      ),
      // decoration: BoxDecoration(
      //   gradient: LinearGradient(
      //     begin: Alignment.topCenter,
      //     end: Alignment.bottomCenter,
      //     colors: [
      //       AppColors.appBar.withValues(alpha: 0),
      //       AppColors.appBar.withValues(alpha: 0.6),
      //       AppColors.appBar.withValues(alpha: 0.8),
      //     ],
      //   ),
      // ),
      child: AppButton(
        label: label,
        onPressed: onPressed,
        btnStyle: AppButtonStyle.primary,
      ),
    );
  }
}
