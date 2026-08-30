import '../../../../core/error/exceptions.dart';
import '../../../../core/error/result.dart';
import '../../../../core/repository/base_repository.dart';
import '../../domain/entity/subscription_entity.dart';
import '../../domain/repository/subscription_repository.dart';
import '../datasource/subscription_remote_datasource.dart';
import '../mapper/subscription_mapper.dart';
import '../model/subscription_models.dart';

class SubscriptionRepositoryImpl extends BaseRepository
    implements SubscriptionRepository {
  SubscriptionRepositoryImpl({
    required SubscriptionRemoteDatasource remoteDatasource,
    required super.connectivityService,
  }) : _remote = remoteDatasource;

  final SubscriptionRemoteDatasource _remote;

  @override
  Future<Result<List<SubscriptionPlanEntity>>> getPlans() {
    return safeApiCall(() async {
      final response = await _remote.getPlans();
      if (!response.success) {
        throw ApiException(
          response.message.isEmpty
              ? 'Failed to load subscription plans.'
              : response.message,
        );
      }
      return SubscriptionMapper.toPlanEntities(response.plans);
    });
  }

  @override
  Future<Result<SelectedSubscriptionEntity>> selectPlan({
    required String planCode,
    required BillingInterval billingInterval,
  }) {
    return safeApiCall(() async {
      final response = await _remote.selectPlan(
        SelectPlanRequestModel(
          planCode: planCode,
          billingInterval: billingInterval,
        ),
      );
      if (!response.success || response.data == null) {
        throw ApiException(
          response.message.isEmpty
              ? 'Failed to save subscription plan.'
              : response.message,
        );
      }
      return SubscriptionMapper.toSelectedEntity(response.data!);
    });
  }

  @override
  Future<Result<MySubscriptionEntity?>> getMySubscription() {
    return safeApiCall(() async {
      final response = await _remote.getMySubscription();
      if (!response.success) {
        throw ApiException(
          response.message.isEmpty
              ? 'Failed to load subscription.'
              : response.message,
        );
      }
      return SubscriptionMapper.toMySubscriptionEntity(response.data);
    });
  }
}
