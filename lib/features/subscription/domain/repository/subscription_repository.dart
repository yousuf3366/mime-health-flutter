import '../../../../core/error/result.dart';
import '../entity/subscription_entity.dart';

abstract class SubscriptionRepository {
  Future<Result<SubscriptionPlansResultEntity>> getPlans();

  /// `POST /subscription/select-plan`; [useTrial] starts the free trial.
  Future<Result<SelectedSubscriptionEntity>> selectPlan({
    required String planCode,
    required BillingInterval billingInterval,
    bool useTrial = false,
  });

  /// Add-on services offered for purchase (`GET /subscription/services`).
  Future<Result<List<SubscriptionServiceOfferEntity>>> getServices();

  Future<Result<CheckoutEntity>> checkout({
    required BillingInterval billingInterval,
    required PaymentMethod paymentMethod,
    String? planCode,
    String purpose = CheckoutPurpose.subscription,
    List<String> addonCodes = const [],
    List<String> serviceCodes = const [],
  });

  /// Current subscription from Mime (`GET /api/v1/subscription/me`).
  /// Returns `null` when the user has no subscription.
  Future<Result<MySubscriptionEntity?>> getMySubscription();
}
