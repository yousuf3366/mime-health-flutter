import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../features/language/presentation/provider/language_provider.dart';
import '../localization/l10n_keys.dart';
import '../theme/app_colors.dart';

/// Global offline indicator shown when connectivity is lost.
class OfflineBanner extends ConsumerWidget {
  const OfflineBanner({super.key, required this.isOffline});

  final bool isOffline;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final message = ref.watch(languageControllerProvider).t(
          L10nKeys.networkError,
          fallback: 'No internet connection',
        );

    return AnimatedSlide(
      duration: const Duration(milliseconds: 250),
      offset: isOffline ? Offset.zero : const Offset(0, -1),
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 250),
        opacity: isOffline ? 1 : 0,
        child: Material(
          color: AppColors.offlineBanner,
          child: SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  const Icon(Icons.wifi_off, color: Colors.white, size: 18),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      message,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
