import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/error/exceptions.dart';
import '../../../../core/localization/l10n_keys.dart';
import '../../../../core/providers/core_providers.dart';
import '../../../language/presentation/provider/language_provider.dart';
import '../../domain/entity/subscription_entity.dart';
import '../provider/subscription_di.dart';
import '../state/subscription_plans_state.dart';

/// Plans tab: `GET /subscription/plans`, plan selection, billing period and
/// free trial (`POST /subscription/select-plan` with `use_trial`).
class SubscriptionPlansNotifier extends Notifier<SubscriptionPlansState> {
  /// Starts in a loading state; the plans screen calls [loadPlans] every time
  /// it opens so plans and trial eligibility are always fresh.
  @override
  SubscriptionPlansState build() {
    return const SubscriptionPlansState(isLoading: true);
  }

  /// [showLoading] is false for pull-to-refresh, which keeps the current list
  /// on screen under the refresh indicator.
  Future<void> loadPlans({bool showLoading = true}) async {
    state = state.copyWith(isLoading: showLoading, errorMessage: null);

    // Prefill selection from server subscription when available.
    String? serverPlanCode;
    BillingInterval serverInterval = BillingInterval.monthly;
    final mySub = await ref.read(getMySubscriptionUseCaseProvider).call();
    mySub.when(
      success: (data) {
        final subscription = data?.subscription;
        if (data?.hasActivePlan == true && subscription != null) {
          serverPlanCode = subscription.plan.code;
          serverInterval = subscription.billingInterval;
        }
      },
      failure: (_) {},
    );

    final result = await ref.read(getSubscriptionPlansUseCaseProvider).call();
    result.when(
      success: (data) {
        final plans = data.plans;
        final initialCode =
            serverPlanCode ?? (plans.isNotEmpty ? plans.first.code : null);
        state = state.copyWith(
          plans: plans,
          eligibility: data.eligibility,
          selectedPlanCode: initialCode,
          billingInterval: serverInterval,
          isLoading: false,
          errorMessage: null,
        );
      },
      failure: (error) {
        state = state.copyWith(isLoading: false, errorMessage: error.message);
      },
    );
  }

  void selectPlanCode(String code) {
    state = state.copyWith(selectedPlanCode: code);
  }

  void setBillingInterval(BillingInterval interval) {
    state = state.copyWith(billingInterval: interval);
  }

  /// Starts [plan]'s free trial via `select-plan` with `use_trial: true` (no
  /// payment). Returns `true` on success.
  Future<bool> startTrial(SubscriptionPlanEntity plan) async {
    if (state.isStartingTrial) return false;
    state = state.copyWith(
      trialPlanCode: plan.code,
      selectedPlanCode: plan.code,
      errorMessage: null,
    );
    final snackbar = ref.read(snackbarServiceProvider);

    final result = await ref
        .read(selectSubscriptionPlanUseCaseProvider)
        .call(
          planCode: plan.code,
          billingInterval: state.billingInterval,
          useTrial: true,
        );

    return result.when(
      success: (selected) {
        state = state.copyWith(
          trialPlanCode: null,
          // The trial is now consumed; hide trial buttons until reload.
          eligibility: null,
        );
        ref.invalidate(mySubscriptionProvider);
        final name = selected.plan.name.isEmpty
            ? plan.name
            : selected.plan.name;
        snackbar.showSuccess(
          ref
              .read(languageControllerProvider)
              .t(L10nKeys.subscriptionTrialStarted)
              .replaceAll('{name}', name),
        );
        return true;
      },
      failure: (AppException error) {
        state = state.copyWith(trialPlanCode: null);
        snackbar.showError(error.message);
        return false;
      },
    );
  }
}

final subscriptionPlansNotifierProvider =
    NotifierProvider<SubscriptionPlansNotifier, SubscriptionPlansState>(
      SubscriptionPlansNotifier.new,
    );
