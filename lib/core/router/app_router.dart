import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../features/home/presentation/page/home_page.dart';
import '../../features/language/presentation/provider/language_provider.dart';
import '../../features/login/presentation/page/login_page.dart';
import '../../features/login/presentation/provider/login_provider.dart';
import '../../features/profile/presentation/page/create_profile_page.dart';
import '../../features/profile/domain/entity/profile_entity.dart';
import '../../features/splash/presentation/page/splash_page.dart';
import '../../features/subscription/presentation/screen/subscription_plans_screen.dart';
import '../localization/l10n_keys.dart';
import '../services/snackbar_service.dart';
import '../widgets/app_button.dart';
import 'route_names.dart';

/// Application router with auth-aware redirects.
final appRouterProvider = Provider<GoRouter>((ref) {
  final refresh = ValueNotifier<int>(0);

  ref.listen(authStateListenableProvider, (previous, next) {
    refresh.value++;
  });

  return GoRouter(
    navigatorKey: rootNavigatorKey,
    initialLocation: RouteNames.splash,
    refreshListenable: refresh,
    debugLogDiagnostics: true,
    routes: [
      GoRoute(
        path: RouteNames.splash,
        name: 'splash',
        builder: (context, state) => const SplashPage(),
      ),
      GoRoute(
        path: RouteNames.login,
        name: 'login',
        builder: (context, state) => const LoginPage(),
      ),
      GoRoute(
        path: RouteNames.home,
        name: 'home',
        builder: (context, state) => HomePage(
          showFaceScanInitially:
              state.uri.queryParameters['tab'] == 'face-scan',
        ),
      ),
      GoRoute(
        path: RouteNames.createProfile,
        name: 'createProfile',
        builder: (context, state) => CreateProfilePage(
          profile: state.extra is ProfileEntity
              ? state.extra! as ProfileEntity
              : null,
        ),
      ),
      GoRoute(
        path: RouteNames.subscriptionPlans,
        name: 'subscriptionPlans',
        builder: (context, state) => const SubscriptionPlansScreen(),
      ),
      GoRoute(
        path: RouteNames.notFound,
        name: 'notFound',
        builder: (context, state) => const _NotFoundPage(),
      ),
    ],
    errorBuilder: (context, state) => const _NotFoundPage(),
    redirect: (context, state) async {
      final location = state.matchedLocation;
      final isSplash = location == RouteNames.splash;
      final isLogin = location == RouteNames.login;

      // Splash owns its own navigation after bootstrap.
      if (isSplash) return null;

      final isLoggedIn = await ref.read(checkAuthUseCaseProvider).call();

      if (!isLoggedIn && !isLogin) {
        return RouteNames.login;
      }

      if (isLoggedIn && isLogin) {
        return RouteNames.home;
      }

      return null;
    },
  );
});

/// Lightweight auth change signal used to refresh GoRouter redirects.
final authStateListenableProvider = Provider<int>((ref) {
  // Incremented manually via invalidation after login/logout.
  return 0;
});

class _NotFoundPage extends ConsumerWidget {
  const _NotFoundPage();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = ref.watch(languageControllerProvider);

    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.search_off, size: 64),
              const SizedBox(height: 16),
              Text(
                l10n.t(L10nKeys.notFoundTitle),
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 8),
              Text(
                l10n.t(L10nKeys.notFoundMessage),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              AppButton(
                label: l10n.t(L10nKeys.goHome),
                onPressed: () => GoRouter.of(context).go(RouteNames.home),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
