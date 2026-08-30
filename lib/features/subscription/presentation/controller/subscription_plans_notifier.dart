import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/error/exceptions.dart';
import '../../../../core/providers/core_providers.dart';
import '../../domain/entity/subscription_entity.dart';
import '../provider/subscription_di.dart';
import '../state/subscription_plans_state.dart';

class SubscriptionPlansNotifier extends Notifier<SubscriptionPlansState> {
  @override
  SubscriptionPlansState build() {
    Future.microtask(loadPlans);
    return const SubscriptionPlansState(isLoading: true);
  }

  Future<void> loadPlans() async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    // Prefill selection from server subscription when available.
    String? serverPlanCode;
    BillingInterval serverInterval = BillingInterval.monthly;
    final mySub = await ref.read(getMySubscriptionUseCaseProvider).call();
    mySub.when(
      success: (data) {
        if (data?.hasActivePlan == true) {
          serverPlanCode = data!.subscription.plan.code;
          serverInterval = data.subscription.billingInterval;
        }
      },
      failure: (_) {},
    );

    final result = await ref.read(getSubscriptionPlansUseCaseProvider).call();
    result.when(
      success: (plans) {
        final initialCode = serverPlanCode ??
            (plans.isNotEmpty ? plans.first.code : null);
        state = state.copyWith(
          plans: plans,
          selectedPlanCode: initialCode,
          billingInterval: serverInterval,
          isLoading: false,
          errorMessage: null,
        );
      },
      failure: (error) {
        state = state.copyWith(
          isLoading: false,
          errorMessage: error.message,
        );
      },
    );
  }

  void selectPlanCode(String code) {
    state = state.copyWith(selectedPlanCode: code);
  }

  void setBillingInterval(BillingInterval interval) {
    state = state.copyWith(billingInterval: interval);
  }

  /// Returns `true` when the plan was saved successfully on the server.
  Future<bool> submitSelectedPlan() async {
    final plan = state.selectedPlan;
    if (plan == null || state.isSubmitting) return false;

    state = state.copyWith(isSubmitting: true, errorMessage: null);
    final snackbar = ref.read(snackbarServiceProvider);

    final result = await ref.read(selectSubscriptionPlanUseCaseProvider).call(
          planCode: plan.code,
          billingInterval: state.billingInterval,
        );

    return result.when(
      success: (selected) {
        state = state.copyWith(
          isSubmitting: false,
          selectedPlanCode: selected.plan.code,
          billingInterval: selected.billingInterval,
        );
        ref.invalidate(mySubscriptionProvider);
        snackbar.showSuccess(
          selected.status.isEmpty
              ? 'Subscription saved successfully.'
              : 'Plan “${selected.plan.name}” is ${selected.status}.',
        );
        return true;
      },
      failure: (AppException error) {
        state = state.copyWith(
          isSubmitting: false,
          errorMessage: error.message,
        );
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
