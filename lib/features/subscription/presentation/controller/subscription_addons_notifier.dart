import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../provider/subscription_di.dart';
import '../state/subscription_addons_state.dart';

/// Add-ons tab: `GET /subscription/services` and the checkbox selection.
/// Auto-disposed with the plans screen, so the selection resets on leave.
class SubscriptionAddonsNotifier
    extends AutoDisposeNotifier<SubscriptionAddonsState> {
  @override
  SubscriptionAddonsState build() {
    return const SubscriptionAddonsState(isLoading: true);
  }

  /// [showLoading] is false for pull-to-refresh, which keeps the list visible.
  /// Selections that are no longer offered are dropped.
  Future<void> load({bool showLoading = true}) async {
    state = state.copyWith(isLoading: showLoading, errorMessage: null);
    final result = await ref
        .read(getSubscriptionServicesUseCaseProvider)
        .call();
    result.when(
      success: (services) {
        final codes = services.map((s) => s.code).toSet();
        state = state.copyWith(
          services: services,
          selectedCodes: state.selectedCodes.intersection(codes),
          isLoading: false,
        );
      },
      failure: (error) {
        state = state.copyWith(isLoading: false, errorMessage: error.message);
      },
    );
  }

  void toggle(String code) {
    final next = {...state.selectedCodes};
    if (!next.remove(code)) next.add(code);
    state = state.copyWith(selectedCodes: next);
  }

  void clearSelection() => state = state.copyWith(selectedCodes: const {});
}

final subscriptionAddonsNotifierProvider =
    NotifierProvider.autoDispose<
      SubscriptionAddonsNotifier,
      SubscriptionAddonsState
    >(SubscriptionAddonsNotifier.new);
