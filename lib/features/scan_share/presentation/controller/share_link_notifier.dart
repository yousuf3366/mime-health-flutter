import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/providers/core_providers.dart';
import '../../domain/entity/share_link_entity.dart';
import '../provider/share_link_di.dart';
import '../state/share_link_state.dart';

/// Creates (and caches per scan) public share links for scan results.
class ShareLinkNotifier extends Notifier<ShareLinkState> {
  @override
  ShareLinkState build() => const ShareLinkState();

  /// Returns a usable link for [scanId], reusing one created earlier this
  /// session. Returns `null` on failure (already shown as a snackbar).
  Future<ShareLinkEntity?> linkFor({
    required int profileId,
    required int scanId,
  }) async {
    final cached = state.linksByScanId[scanId];
    if (cached != null && cached.isUsable) return cached;
    if (state.isCreating(scanId)) return null;

    state = state.copyWith(
      creatingScanIds: {...state.creatingScanIds, scanId},
      errorMessage: null,
    );

    final result = await ref
        .read(createShareLinkUseCaseProvider)
        .call(profileId: profileId, scanId: scanId);

    final creating = {...state.creatingScanIds}..remove(scanId);
    return result.when(
      success: (link) {
        state = state.copyWith(
          creatingScanIds: creating,
          linksByScanId: {...state.linksByScanId, scanId: link},
        );
        return link;
      },
      failure: (error) {
        state = state.copyWith(
          creatingScanIds: creating,
          errorMessage: error.message,
        );
        ref.read(snackbarServiceProvider).showError(error.message);
        return null;
      },
    );
  }
}

final shareLinkNotifierProvider =
    NotifierProvider<ShareLinkNotifier, ShareLinkState>(ShareLinkNotifier.new);
