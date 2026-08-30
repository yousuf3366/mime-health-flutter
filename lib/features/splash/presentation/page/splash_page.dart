import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../../core/config/app_config.dart';
import '../../../../core/localization/l10n_keys.dart';
import '../../../../core/router/route_names.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../language/presentation/provider/language_provider.dart';
import '../provider/splash_provider.dart';

class SplashPage extends HookConsumerWidget {
  const SplashPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final splashState = ref.watch(splashControllerProvider);
    final l10n = ref.watch(languageControllerProvider);

    useEffect(() {
      Future.microtask(
        () => ref.read(splashControllerProvider.notifier).initialize(),
      );
      return null;
    }, const []);

    ref.listen(splashControllerProvider, (previous, next) {
      if (next.status == SplashStatus.ready) {
        final target =
            next.isLoggedIn ? RouteNames.home : RouteNames.login;
        context.go(target);
      }
    });

    return Scaffold(
      body: SafeArea(
        child: SizedBox(
          width: double.infinity,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.health_and_safety_rounded,
                size: 88,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(height: 16),
              Text(
                AppConfig.appName,
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurface,
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 32),
              if (splashState.status == SplashStatus.error) ...[
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Text(
                    splashState.errorMessage ?? 'Failed to start',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.error,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                AppButton(
                  label: l10n.t(L10nKeys.retry),
                  onPressed: () =>
                      ref.read(splashControllerProvider.notifier).initialize(),
                ),
              ] else ...[
                CircularProgressIndicator(
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(height: 16),
                Text(
                  l10n.t(
                    L10nKeys.splashLoading,
                    fallback: splashState.progressMessage,
                  ),
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
