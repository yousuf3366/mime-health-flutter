import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:mime_health/core/constants/app_constants.dart';
import 'package:mime_health/core/theme/app_colors.dart';
import 'package:mime_health/core/widgets/app_app_bar.dart';

import '../../../../core/localization/l10n_keys.dart';
import '../../../language/presentation/provider/language_provider.dart';
import '../../domain/entity/profile_entity.dart';
import '../provider/profile_provider.dart';
import 'profile_details_screen.dart';

/// Standalone details page for any profile (self or family), opened outside
/// the bottom-nav Profile tab.
class ProfileViewScreen extends HookConsumerWidget {
  const ProfileViewScreen({super.key, required this.profile});

  final ProfileEntity profile;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = ref.watch(languageControllerProvider);
    final uploadNotifier = ref.read(
      profileAvatarUploadNotifierProvider.notifier,
    );

    // The avatar upload state is shared with the Profile tab; clear it so one
    // profile's uploaded photo never shows on another.
    useEffect(() {
      Future.microtask(uploadNotifier.reset);
      return () => Future.microtask(uploadNotifier.reset);
    }, const []);

    final latest = ref
        .watch(profilesProvider)
        .maybeWhen(
          data: (profiles) {
            for (final p in profiles) {
              if (p.id == profile.id) return p;
            }
            return null;
          },
          orElse: () => null,
        );
    final current = latest ?? profile;

    final isSelf = current.profileKind == AppConstants.profileKindSelf;
    final user = isSelf ? ref.watch(currentUserProvider).asData?.value : null;
    final phone = (current.phone ?? '').trim().isNotEmpty
        ? current.phone
        : user?.phone;
    final email = (current.email ?? '').trim().isNotEmpty
        ? current.email
        : user?.email;

    return Scaffold(
      backgroundColor: AppColors.backgroundDeep,
      appBar: AppAppBar(title: l10n.t(L10nKeys.profileDetailsTitle)),
      body: ProfileDetailsBody(
        profile: current,
        phoneNumber: phone,
        emailAddress: email,
        showAddAnother: false,
      ),
    );
  }
}
