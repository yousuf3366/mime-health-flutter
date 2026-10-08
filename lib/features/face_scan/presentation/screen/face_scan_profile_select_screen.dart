import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:mime_health/core/extensions/context_extensions.dart';
import 'package:mime_health/core/theme/app_colors.dart';
import 'package:mime_health/core/widgets/app_button.dart';
import 'package:mime_health/core/widgets/app_network_image.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/localization/l10n_keys.dart';
import '../../../../core/router/route_names.dart';
import '../../../language/presentation/provider/language_provider.dart';
import '../../../profile/domain/entity/profile_entity.dart';
import '../../../profile/presentation/provider/profile_provider.dart';
import '../provider/face_scan_provider.dart';

enum _ProfileFilter { self, family }

/// Lets the user pick which profile the face scan is for.
class FaceScanProfileSelectScreen extends HookConsumerWidget {
  const FaceScanProfileSelectScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = ref.watch(languageControllerProvider);
    final profilesAsync = ref.watch(profilesProvider);
    final filter = useState(_ProfileFilter.self);

    return SafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: EdgeInsets.fromLTRB(
              context.defaultPaddingSc,
              context.scaleHeight(16),
              context.defaultPaddingSc,
              context.scaleHeight(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.t(L10nKeys.faceScanSelectProfileTitle),
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: context.largeFontSize,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                SizedBox(height: context.scaleHeight(4)),
                Text(
                  l10n.t(L10nKeys.faceScanSelectProfileSubtitle),
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: context.fontSize,
                    height: 1.4,
                  ),
                ),
                SizedBox(height: context.scaleHeight(16)),
                _FilterTabs(
                  value: filter.value,
                  selfLabel: l10n.t(L10nKeys.homeSelf),
                  familyLabel: l10n.t(L10nKeys.homeFamily),
                  onChanged: (value) => filter.value = value,
                ),
              ],
            ),
          ),
          Expanded(
            child: profilesAsync.when(
              loading: () => const Center(
                child: CircularProgressIndicator(
                  color: AppColors.primaryContainer,
                ),
              ),
              error: (error, _) => _ErrorBody(
                message: error is AppException ? error.message : '$error',
                retryLabel: l10n.t(L10nKeys.retry),
                onRetry: () => ref.invalidate(profilesProvider),
              ),
              data: (profiles) {
                final filtered = profiles.where((profile) {
                  final isSelf =
                      profile.profileKind == AppConstants.profileKindSelf;
                  return filter.value == _ProfileFilter.self ? isSelf : !isSelf;
                }).toList();

                return RefreshIndicator(
                  color: AppColors.primaryContainer,
                  onRefresh: () => ref.refresh(profilesProvider.future),
                  child: filtered.isEmpty
                      ? ListView(
                          physics: const AlwaysScrollableScrollPhysics(),
                          children: [
                            SizedBox(height: context.scaleHeight(80)),
                            Center(
                              child: Text(
                                l10n.t(L10nKeys.faceScanSelectProfileEmpty),
                                style: TextStyle(
                                  color: AppColors.textSecondary,
                                  fontSize: context.fontSize,
                                ),
                              ),
                            ),
                          ],
                        )
                      : ListView.separated(
                          physics: const AlwaysScrollableScrollPhysics(),
                          padding: EdgeInsets.fromLTRB(
                            context.defaultPaddingSc,
                            context.scaleHeight(4),
                            context.defaultPaddingSc,
                            context.scaleHeight(24),
                          ),
                          itemCount: filtered.length,
                          separatorBuilder: (_, _) =>
                              SizedBox(height: context.scaleHeight(12)),
                          itemBuilder: (context, index) {
                            final profile = filtered[index];
                            return _ProfileTile(
                              profile: profile,
                              bloodGroupLabel: l10n.t(
                                L10nKeys.profileBloodGroup,
                              ),
                              dateOfBirthLabel: l10n.t(
                                L10nKeys.profileDateOfBirth,
                              ),
                              notSetLabel: l10n.t(L10nKeys.profileNotSet),
                              viewLabel: l10n.t(L10nKeys.profileView),
                              onView: () => context.push(
                                RouteNames.profileView,
                                extra: profile,
                              ),
                              onTap: () =>
                                  ref
                                          .read(
                                            faceScanSelectedProfileProvider
                                                .notifier,
                                          )
                                          .state =
                                      profile,
                            );
                          },
                        ),
                );
              },
            ),
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(
              context.defaultPaddingSc,
              context.scaleHeight(8),
              context.defaultPaddingSc,
              context.defaultPaddingSc,
            ),
            child: AppButton(
              label: l10n.t(L10nKeys.profileAddAnother),
              icon: Icons.person_add_alt_1_outlined,
              onPressed: () => context.push(RouteNames.createProfile),
              btnStyle: AppButtonStyle.primary,
            ),
          ),
        ],
      ),
    );
  }
}

class _FilterTabs extends StatelessWidget {
  const _FilterTabs({
    required this.value,
    required this.selfLabel,
    required this.familyLabel,
    required this.onChanged,
  });

  final _ProfileFilter value;
  final String selfLabel;
  final String familyLabel;
  final ValueChanged<_ProfileFilter> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(context.scaleWidth(4)),
      decoration: BoxDecoration(
        color: AppColors.backgroundDeep,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: AppColors.glassBorder, width: 0.5),
      ),
      child: Row(
        children: [
          Expanded(
            child: _FilterSegment(
              label: selfLabel,
              selected: value == _ProfileFilter.self,
              onTap: () => onChanged(_ProfileFilter.self),
            ),
          ),
          Expanded(
            child: _FilterSegment(
              label: familyLabel,
              selected: value == _ProfileFilter.family,
              onTap: () => onChanged(_ProfileFilter.family),
            ),
          ),
        ],
      ),
    );
  }
}

class _FilterSegment extends StatelessWidget {
  const _FilterSegment({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: EdgeInsets.symmetric(vertical: context.scaleHeight(10)),
          decoration: BoxDecoration(
            color: selected ? AppColors.pillSelected : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: TextStyle(
              color: selected ? AppColors.textPrimary : AppColors.textSecondary,
              fontSize: context.fontSize,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}

enum _ProfileMenuAction { view }

class _ProfileTile extends StatelessWidget {
  const _ProfileTile({
    required this.profile,
    required this.bloodGroupLabel,
    required this.dateOfBirthLabel,
    required this.notSetLabel,
    required this.viewLabel,
    required this.onTap,
    required this.onView,
  });

  final ProfileEntity profile;
  final String bloodGroupLabel;
  final String dateOfBirthLabel;
  final String notSetLabel;
  final String viewLabel;
  final VoidCallback onTap;
  final VoidCallback onView;

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(context.scaleWidth(20));
    final bloodGroup = (profile.bloodGroup ?? '').trim();

    return Material(
      color: AppColors.glass,
      borderRadius: radius,
      child: InkWell(
        onTap: onTap,
        borderRadius: radius,
        child: Container(
          padding: EdgeInsets.all(context.scaleWidth(14)),
          decoration: BoxDecoration(
            borderRadius: radius,
            border: Border.all(color: AppColors.glassBorder),
          ),
          child: Row(
            children: [
              ProfileAvatar(
                name: profile.displayName,
                url: profile.avatarPath,
                size: context.scaleWidth(64),
              ),
              SizedBox(width: context.scaleWidth(14)),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      profile.displayName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: context.bodyFontSize,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    SizedBox(height: context.scaleHeight(6)),
                    _InfoLine(
                      label: bloodGroupLabel,
                      value: bloodGroup.isEmpty ? notSetLabel : bloodGroup,
                    ),
                    SizedBox(height: context.scaleHeight(2)),
                    _InfoLine(
                      label: dateOfBirthLabel,
                      value: _formatDob(profile.dateOfBirth) ?? notSetLabel,
                    ),
                  ],
                ),
              ),
              PopupMenuButton<_ProfileMenuAction>(
                icon: Icon(
                  Icons.more_vert,
                  color: AppColors.textSecondary,
                  size: context.scaleWidth(24),
                ),
                color: AppColors.surfaceLow,
                onSelected: (action) {
                  switch (action) {
                    case _ProfileMenuAction.view:
                      onView();
                  }
                },
                itemBuilder: (_) => [
                  PopupMenuItem(
                    value: _ProfileMenuAction.view,
                    child: Row(
                      children: [
                        const Icon(
                          Icons.visibility_outlined,
                          color: AppColors.textPrimary,
                          size: 20,
                        ),
                        const SizedBox(width: 10),
                        Text(
                          viewLabel,
                          style: const TextStyle(color: AppColors.textPrimary),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String? _formatDob(String raw) {
    final date = DateTime.tryParse(raw);
    if (date == null) return raw.trim().isEmpty ? null : raw;
    return DateFormat('dd MMM yyyy').format(date);
  }
}

class _InfoLine extends StatelessWidget {
  const _InfoLine({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Text.rich(
      TextSpan(
        style: TextStyle(
          color: AppColors.textSecondary,
          fontSize: context.smallFontSize,
          height: 1.35,
        ),
        children: [
          TextSpan(text: '$label: '),
          TextSpan(
            text: value,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
    );
  }
}

/// Circular avatar with initials fallback.
class ProfileAvatar extends StatelessWidget {
  const ProfileAvatar({
    super.key,
    required this.name,
    required this.url,
    required this.size,
  });

  final String name;
  final String? url;
  final double size;

  @override
  Widget build(BuildContext context) {
    final trimmedUrl = url?.trim() ?? '';
    final placeholder = _Initials(name: name, size: size);

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: AppColors.surfaceLow,
        border: Border.all(
          color: AppColors.primaryContainer.withValues(alpha: 0.5),
          width: 2,
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: trimmedUrl.isEmpty
          ? placeholder
          : AppNetworkImage(
              trimmedUrl,
              width: size,
              height: size,
              fit: BoxFit.cover,
              errorBuilder: (_, _, _) => placeholder,
            ),
    );
  }
}

class _Initials extends StatelessWidget {
  const _Initials({required this.name, required this.size});

  final String name;
  final double size;

  @override
  Widget build(BuildContext context) {
    final trimmed = name.trim();
    final initial = trimmed.isEmpty ? '?' : trimmed[0].toUpperCase();
    return Center(
      child: Text(
        initial,
        style: TextStyle(
          color: AppColors.primaryContainer,
          fontSize: size * 0.4,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _ErrorBody extends StatelessWidget {
  const _ErrorBody({
    required this.message,
    required this.retryLabel,
    required this.onRetry,
  });

  final String message;
  final String retryLabel;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(context.defaultPaddingSc),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: context.fontSize,
              ),
            ),
            SizedBox(height: context.scaleHeight(16)),
            AppButton(label: retryLabel, expand: false, onPressed: onRetry),
          ],
        ),
      ),
    );
  }
}
