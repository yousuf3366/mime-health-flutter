import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/error/exceptions.dart';
import '../../../../core/providers/core_providers.dart';
import '../../domain/entity/subscription_entity.dart';
import '../provider/subscription_di.dart';
import '../state/subscription_checkout_state.dart';

/// Payment screen: `POST /subscription/checkout` for a plan or for add-on
/// services. Auto-disposed with the payment screen.
class SubscriptionCheckoutNotifier
    extends AutoDisposeNotifier<SubscriptionCheckoutState> {
  @override
  SubscriptionCheckoutState build() => const SubscriptionCheckoutState();

  /// Plan purchase; returns `null` on error (already shown as a snackbar).
  Future<CheckoutEntity?> checkoutPlan({
    required String planCode,
    required BillingInterval billingInterval,
    required PaymentMethod paymentMethod,
    List<String> addonCodes = const [],
  }) {
    return _checkout(
      planCode: planCode,
      billingInterval: billingInterval,
      paymentMethod: paymentMethod,
      addonCodes: addonCodes,
    );
  }

  /// Add-on services bought on their own.
  Future<CheckoutEntity?> checkoutServices({
    required List<String> serviceCodes,
    required BillingInterval billingInterval,
    required PaymentMethod paymentMethod,
  }) {
    if (serviceCodes.isEmpty) return Future.value();
    return _checkout(
      billingInterval: billingInterval,
      paymentMethod: paymentMethod,
      purpose: CheckoutPurpose.serviceSubscription,
      serviceCodes: serviceCodes,
    );
  }

  /// Re-fetches the server subscription after the payment gateway closes.
  void refreshAfterPayment() => ref.invalidate(mySubscriptionProvider);

  Future<CheckoutEntity?> _checkout({
    required BillingInterval billingInterval,
    required PaymentMethod paymentMethod,
    String? planCode,
    String purpose = CheckoutPurpose.subscription,
    List<String> addonCodes = const [],
    List<String> serviceCodes = const [],
  }) async {
    if (state.isSubmitting) return null;
    state = state.copyWith(isSubmitting: true, errorMessage: null);

    final result = await ref
        .read(checkoutSubscriptionUseCaseProvider)
        .call(
          planCode: planCode,
          billingInterval: billingInterval,
          paymentMethod: paymentMethod,
          purpose: purpose,
          addonCodes: addonCodes,
          serviceCodes: serviceCodes,
        );

    return result.when(
      success: (checkout) {
        state = state.copyWith(isSubmitting: false);
        return checkout;
      },
      failure: (AppException error) {
        state = state.copyWith(
          isSubmitting: false,
          errorMessage: error.message,
        );
        ref.read(snackbarServiceProvider).showError(error.message);
        return null;
      },
    );
  }
}

final subscriptionCheckoutNotifierProvider =
    NotifierProvider.autoDispose<
      SubscriptionCheckoutNotifier,
      SubscriptionCheckoutState
    >(SubscriptionCheckoutNotifier.new);
