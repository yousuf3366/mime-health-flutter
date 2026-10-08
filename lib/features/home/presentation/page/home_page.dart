import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:mime_health/core/providers/core_providers.dart';
import 'package:mime_health/core/theme/app_colors.dart';
import 'package:mime_health/core/widgets/app_bottom_nav_bar.dart';

import '../../../../core/localization/l10n_keys.dart';
import '../../../face_scan/presentation/provider/face_scan_provider.dart';
import '../../../face_scan/presentation/screen/face_scan_pre_screen.dart';
import '../../../face_scan/presentation/screen/face_scan_profile_select_screen.dart';
import '../../../language/presentation/provider/language_provider.dart';
import '../../../profile/presentation/screen/profile_details_screen.dart';
import '../screen/health_hub_screen.dart';
import '../screen/home_screen.dart';

/// App shell with bottom navigation. Tab bodies live in separate screens.
class HomePage extends HookConsumerWidget {
  const HomePage({super.key, this.showFaceScanInitially = false});

  final bool showFaceScanInitially;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = ref.watch(languageControllerProvider);
    final selectedTab = useState(
      showFaceScanInitially ? AppBottomNavItem.faceScan : AppBottomNavItem.home,
    );

    final destinations = [
      AppBottomNavDestination(
        item: AppBottomNavItem.home,
        label: l10n.t(L10nKeys.homeNavHome),
        icon: Icons.home_outlined,
      ),
      AppBottomNavDestination(
        item: AppBottomNavItem.healthHub,
        label: l10n.t(L10nKeys.homeNavHealthHub),
        icon: Icons.health_and_safety_outlined,
      ),
      AppBottomNavDestination(
        item: AppBottomNavItem.faceScan,
        label: l10n.t(L10nKeys.homeNavFaceScan),
        icon: Icons.face_outlined,
      ),
      AppBottomNavDestination(
        item: AppBottomNavItem.trends,
        label: l10n.t(L10nKeys.homeNavTrends),
        icon: Icons.show_chart,
      ),
      AppBottomNavDestination(
        item: AppBottomNavItem.profile,
        label: l10n.t(L10nKeys.homeNavProfile),
        icon: Icons.person_outline,
      ),
    ];

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Column(
        children: [
          Expanded(child: _bodyFor(selectedTab.value)),
          AppBottomNavBar(
            destinations: destinations,
            selected: selectedTab.value,
            onSelected: (item) {
              if (item == AppBottomNavItem.trends) {
                ref
                    .read(dialogServiceProvider)
                    .showComingSoon(
                      title: l10n.t(L10nKeys.comingSoonTitle),
                      message: l10n.t(L10nKeys.comingSoonMessage),
                      okLabel: l10n.t(L10nKeys.comingSoonOk),
                    );
              }
              if (item == AppBottomNavItem.faceScan) {
                ref.read(faceScanSelectedProfileProvider.notifier).state = null;
              }
              selectedTab.value = item;
            },
          ),
        ],
      ),
    );
  }

  Widget _bodyFor(AppBottomNavItem item) {
    switch (item) {
      case AppBottomNavItem.home:
        return const HomeScreen();
      case AppBottomNavItem.healthHub:
        return const HealthHubScreen();
      case AppBottomNavItem.faceScan:
        return const _FaceScanTab();
      case AppBottomNavItem.trends:
        return const _ComingSoonBody(
          icon: Icons.show_chart,
          titleKey: L10nKeys.homeNavTrends,
        );
      case AppBottomNavItem.profile:
        return const ProfileDetailsScreen();
    }
  }
}

class _FaceScanTab extends ConsumerWidget {
  const _FaceScanTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selected = ref.watch(faceScanSelectedProfileProvider);
    return selected == null
        ? const FaceScanProfileSelectScreen()
        : FaceScanPreScreen(key: ValueKey(selected.id));
  }
}

class _ComingSoonBody extends ConsumerWidget {
  const _ComingSoonBody({required this.icon, required this.titleKey});

  final IconData icon;
  final String titleKey;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = ref.watch(languageControllerProvider);

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 48, color: AppColors.primaryContainer),
            const SizedBox(height: 12),
            Text(
              l10n.t(titleKey),
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w700,
                fontSize: 18,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              l10n.t(L10nKeys.comingSoonTitle),
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: AppColors.primaryContainer,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              l10n.t(L10nKeys.comingSoonMessage),
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: AppColors.textSecondary,
                height: 1.35,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
