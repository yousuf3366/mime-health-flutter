import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:mime_health/core/theme/app_colors.dart';
import 'package:mime_health/core/widgets/app_bottom_nav_bar.dart';

import '../../../../core/localization/l10n_keys.dart';
import '../../../face_scan/presentation/screen/face_scan_pre_screen.dart';
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
            onSelected: (item) => selectedTab.value = item,
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
        return const FaceScanPreScreen();
      case AppBottomNavItem.trends:
        return const _PlaceholderBody(
          icon: Icons.show_chart,
          labelKey: L10nKeys.homeNavTrends,
        );
      case AppBottomNavItem.profile:
        return const ProfileDetailsScreen();
    }
  }
}

class _PlaceholderBody extends ConsumerWidget {
  const _PlaceholderBody({required this.icon, required this.labelKey});

  final IconData icon;
  final String labelKey;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final label = ref.watch(languageControllerProvider).t(labelKey);

    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 48, color: AppColors.primaryContainer),
          const SizedBox(height: 12),
          Text(
            label,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
