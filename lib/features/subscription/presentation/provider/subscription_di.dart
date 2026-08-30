import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/providers/core_providers.dart';
import '../../data/datasource/subscription_remote_datasource.dart';
import '../../data/repository/subscription_repository_impl.dart';
import '../../domain/entity/subscription_entity.dart';
import '../../domain/repository/subscription_repository.dart';
import '../../domain/usecase/subscription_usecase.dart';

final subscriptionRemoteDatasourceProvider =
    Provider<SubscriptionRemoteDatasource>(
  (ref) => SubscriptionRemoteDatasource(ref.watch(dioProvider)),
);

final subscriptionRepositoryProvider = Provider<SubscriptionRepository>(
  (ref) => SubscriptionRepositoryImpl(
    remoteDatasource: ref.watch(subscriptionRemoteDatasourceProvider),
    connectivityService: ref.watch(connectivityServiceProvider),
  ),
);

final getSubscriptionPlansUseCaseProvider =
    Provider<GetSubscriptionPlansUseCase>(
  (ref) => GetSubscriptionPlansUseCase(
    ref.watch(subscriptionRepositoryProvider),
  ),
);

final selectSubscriptionPlanUseCaseProvider =
    Provider<SelectSubscriptionPlanUseCase>(
  (ref) => SelectSubscriptionPlanUseCase(
    ref.watch(subscriptionRepositoryProvider),
  ),
);

final getMySubscriptionUseCaseProvider = Provider<GetMySubscriptionUseCase>(
  (ref) => GetMySubscriptionUseCase(
    ref.watch(subscriptionRepositoryProvider),
  ),
);

/// Current subscription from Mime (`GET /subscription/me`). Not cached locally.
final mySubscriptionProvider =
    FutureProvider.autoDispose<MySubscriptionEntity?>((ref) async {
  final result = await ref.watch(getMySubscriptionUseCaseProvider).call();
  return result.when(
    success: (data) => data,
    failure: (error) => throw error,
  );
});
