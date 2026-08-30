import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:mime_health/core/constants/app_constants.dart';
import 'package:mime_health/core/extensions/context_extensions.dart';

import '../../../../core/localization/l10n_keys.dart';
import '../../../../core/router/route_names.dart';
import '../../../language/presentation/provider/language_provider.dart';
import '../../../profile/presentation/provider/profile_di.dart';
import '../widget/login_form.dart';

class LoginPage extends ConsumerWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = ref.watch(languageControllerProvider);
    final theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: EdgeInsets.all(context.scaleWidth(24)),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Image.asset(AppConstants.appFullIcon),
                  SizedBox(height: context.defaultPaddingSc),
                  Text(
                    l10n.t(L10nKeys.signIn),
                    textAlign: TextAlign.center,
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  SizedBox(height: context.scaleHeight(32)),
                  LoginForm(
                    onSuccess: () {
                      // Discard an Unauthorized/error result cached by the
                      // previous expired session before entering home.
                      ref.invalidate(profilesProvider);
                      ref.invalidate(currentUserProvider);
                      context.go(RouteNames.home);
                    },
                  ),
                  SizedBox(height: context.scaleHeight(24)),
                  // Row(
                  //   mainAxisAlignment: MainAxisAlignment.center,
                  //   children: [
                  //     Text(l10n.t(L10nKeys.language)),
                  //     const SizedBox(width: 12),
                  //     SegmentedButton<String>(
                  //       segments: [
                  //         ButtonSegment(
                  //           value: 'en',
                  //           label: Text(l10n.t(L10nKeys.languageEn)),
                  //         ),
                  //         ButtonSegment(
                  //           value: 'bn',
                  //           label: Text(l10n.t(L10nKeys.languageBn)),
                  //         ),
                  //       ],
                  //       selected: {l10n.entity.code},
                  //       onSelectionChanged: (values) {
                  //         ref
                  //             .read(languageControllerProvider.notifier)
                  //             .changeLanguage(values.first);
                  //       },
                  //     ),
                  //   ],
                  // ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
