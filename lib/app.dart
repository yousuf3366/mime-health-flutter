import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:talker_flutter/talker_flutter.dart';

import 'core/constants/app_constants.dart';
import 'core/providers/core_providers.dart';
import 'core/router/app_router.dart';
import 'core/services/snackbar_service.dart';
import 'core/theme/app_theme.dart';
import 'core/widgets/offline_banner.dart';
import 'core/localization/l10n_keys.dart';
import 'features/language/presentation/provider/language_provider.dart';

/// Root application widget.
class MimeHealthApp extends ConsumerWidget {
  const MimeHealthApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(appRouterProvider);
    final l10n = ref.watch(languageControllerProvider);
    final isOnline = ref.watch(isOnlineProvider);

    return MaterialApp.router(
      title: l10n.t(L10nKeys.appName, fallback: 'Mime Health'),
      debugShowCheckedModeBanner: false,
      theme: AppTheme.dark,
      darkTheme: AppTheme.dark,
      themeMode: ThemeMode.dark,
      scaffoldMessengerKey: rootScaffoldMessengerKey,
      routerConfig: router,
      builder: (context, child) {
        return DecoratedBox(
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: AssetImage(AppConstants.appBackgroundImage),
              fit: BoxFit.cover,
            ),
          ),
          child: Stack(
            children: [
              child ?? const SizedBox.shrink(),
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: OfflineBanner(isOffline: !isOnline),
              ),
              if (kDebugMode)
                Visibility(
                  visible: false,
                  child: Positioned(
                    right: 16,
                    bottom: 24,
                    child: Material(
                      elevation: 4,
                      color: Theme.of(context).colorScheme.primaryContainer,
                      shape: const CircleBorder(),
                      child: InkWell(
                        customBorder: const CircleBorder(),
                        onTap: () {
                          final navContext = rootNavigatorKey.currentContext;
                          if (navContext == null) return;
                          Navigator.of(navContext).push(
                            MaterialPageRoute<void>(
                              builder: (_) =>
                                  TalkerScreen(talker: ref.read(talkerProvider)),
                            ),
                          );
                        },
                        child: const Padding(
                          padding: EdgeInsets.all(12),
                          child: Icon(Icons.bug_report_outlined),
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}
