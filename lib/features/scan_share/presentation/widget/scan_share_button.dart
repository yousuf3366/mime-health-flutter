import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:mime_health/core/extensions/context_extensions.dart';
import 'package:mime_health/core/providers/core_providers.dart';
import 'package:mime_health/core/theme/app_colors.dart';
import 'package:share_plus/share_plus.dart';

import '../../../../core/localization/l10n_keys.dart';
import '../../../language/presentation/provider/language_provider.dart';
import '../controller/share_link_notifier.dart';

/// Share icon for one scan: creates a public link via `POST /share-links`
/// and opens the system share sheet with it. Hidden when the scan has no ids.
class ScanShareButton extends ConsumerWidget {
  const ScanShareButton({
    super.key,
    required this.profileId,
    required this.scanId,
    this.color = AppColors.primaryContainer,
  });

  final int? profileId;
  final int? scanId;
  final Color color;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileId = this.profileId;
    final scanId = this.scanId;
    if (profileId == null || scanId == null) return const SizedBox.shrink();

    final l10n = ref.watch(languageControllerProvider);
    final isCreating = ref.watch(
      shareLinkNotifierProvider.select((s) => s.isCreating(scanId)),
    );

    Future<void> share() async {
      final link = await ref
          .read(shareLinkNotifierProvider.notifier)
          .linkFor(profileId: profileId, scanId: scanId);
      if (link == null || !context.mounted) return;

      final box = context.findRenderObject() as RenderBox?;
      final origin = box == null
          ? null
          : box.localToGlobal(Offset.zero) & box.size;
      try {
        await SharePlus.instance.share(
          ShareParams(
            text: l10n
                .t(L10nKeys.scanShareMessage)
                .replaceAll('{link}', link.copyLink),
            subject: l10n.t(L10nKeys.scanShareSubject),
            sharePositionOrigin: origin,
          ),
        );
      } catch (error) {
        // No share sheet available: fall back to the clipboard.
        debugPrint('[ScanShare] share sheet failed: $error');
        await Clipboard.setData(ClipboardData(text: link.copyLink));
        ref
            .read(snackbarServiceProvider)
            .showSuccess(l10n.t(L10nKeys.scanShareLinkCopied));
      }
    }

    return IconButton(
      onPressed: isCreating ? null : share,
      tooltip: l10n.t(L10nKeys.scanShare),
      icon: isCreating
          ? SizedBox(
              width: context.scaleWidth(18),
              height: context.scaleWidth(18),
              child: CircularProgressIndicator(strokeWidth: 2, color: color),
            )
          : Icon(Icons.share_outlined, color: color),
    );
  }
}
