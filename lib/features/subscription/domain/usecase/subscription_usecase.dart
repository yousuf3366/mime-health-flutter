import '../../../../core/error/result.dart';
import '../entity/subscription_entity.dart';
import '../repository/subscription_repository.dart';

class GetSubscriptionPlansUseCase {
  GetSubscriptionPlansUseCase(this._repository);

  final SubscriptionRepository _repository;

  Future<Result<List<SubscriptionPlanEntity>>> call() => _repository.getPlans();
}

class SelectSubscriptionPlanUseCase {
  SelectSubscriptionPlanUseCase(this._repository);

  final SubscriptionRepository _repository;

  Future<Result<SelectedSubscriptionEntity>> call({
    required String planCode,
    required BillingInterval billingInterval,
  }) {
    return _repository.selectPlan(
      planCode: planCode,
      billingInterval: billingInterval,
    );
  }
}

class GetMySubscriptionUseCase {
  GetMySubscriptionUseCase(this._repository);

  final SubscriptionRepository _repository;

  Future<Result<MySubscriptionEntity?>> call() =>
      _repository.getMySubscription();
}
