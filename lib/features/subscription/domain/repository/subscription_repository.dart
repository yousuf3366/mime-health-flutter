import '../../../../core/error/result.dart';
import '../entity/subscription_entity.dart';

abstract class SubscriptionRepository {
  Future<Result<List<SubscriptionPlanEntity>>> getPlans();

  Future<Result<SelectedSubscriptionEntity>> selectPlan({
    required String planCode,
    required BillingInterval billingInterval,
  });

  /// Current subscription from Mime (`GET /api/v1/subscription/me`).
  /// Returns `null` when the user has no subscription.
  Future<Result<MySubscriptionEntity?>> getMySubscription();
}
