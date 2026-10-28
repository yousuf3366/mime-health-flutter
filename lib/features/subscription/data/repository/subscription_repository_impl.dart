import 'package:intl/intl.dart';

import '../../../../core/constants/app_constants.dart';
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
  Future<Result<SubscriptionPlansResultEntity>> getPlans() {
    return safeApiCall(() async {
      final response = await _remote.getPlans();
      if (!response.success) {
        throw ApiException(
          response.message.isEmpty
              ? 'Failed to load subscription plans.'
              : response.message,
        );
      }
      final eligibility = response.eligibility;
      return SubscriptionPlansResultEntity(
        plans: SubscriptionMapper.toPlanEntities(response.plans),
        eligibility: eligibility == null
            ? null
            : SubscriptionMapper.toEligibilityEntity(eligibility),
      );
    });
  }

  @override
  Future<Result<SelectedSubscriptionEntity>> selectPlan({
    required String planCode,
    required BillingInterval billingInterval,
    bool useTrial = false,
  }) {
    return safeApiCall(() async {
      final response = await _remote.selectPlan(
        SelectPlanRequestModel(
          planCode: planCode,
          billingInterval: billingInterval,
          useTrial: useTrial,
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
  Future<Result<List<SubscriptionServiceOfferEntity>>> getServices() {
    return safeApiCall(() async {
      final response = await _remote.getServices();
      if (!response.success) {
        throw ApiException(
          response.message.isEmpty
              ? 'Failed to load add-on services.'
              : response.message,
        );
      }
      return response.services
          .where((s) => s.code.isNotEmpty)
          .map(SubscriptionMapper.toServiceOfferEntity)
          .toList(growable: false);
    });
  }

  @override
  Future<Result<CheckoutEntity>> checkout({
    required BillingInterval billingInterval,
    required PaymentMethod paymentMethod,
    String? planCode,
    String purpose = CheckoutPurpose.subscription,
    List<String> addonCodes = const [],
    List<String> serviceCodes = const [],
  }) {
    return safeApiCall(() async {
      final response = await _remote.checkout(
        CheckoutRequestModel(
          planCode: planCode,
          billingInterval: billingInterval,
          paymentMethod: paymentMethod,
          purpose: purpose,
          addonCodes: addonCodes,
          serviceCodes: serviceCodes,
        ),
      );
      final payment = response.payment;
      final redirectUrl = response.redirectUrl;
      if (!response.success ||
          payment == null ||
          redirectUrl == null ||
          redirectUrl.isEmpty) {
        throw ApiException(
          response.message.isEmpty
              ? 'Failed to create checkout.'
              : response.message,
        );
      }
      return SubscriptionMapper.toCheckoutEntity(payment, redirectUrl);
    });
  }

  @override
  Future<Result<PaymentHistoryPageEntity>> getPayments({
    int page = 1,
    int perPage = 25,
    DateTime? fromDate,
    DateTime? toDate,
  }) {
    final format = DateFormat(AppConstants.serverDateFormat);
    return safeApiCall(() async {
      final response = await _remote.getPayments(
        page: page,
        perPage: perPage,
        fromDate: fromDate == null ? null : format.format(fromDate),
        toDate: toDate == null ? null : format.format(toDate),
      );
      if (!response.success) {
        throw ApiException(
          response.message.isEmpty
              ? 'Failed to load payment history.'
              : response.message,
        );
      }
      return SubscriptionMapper.toPaymentHistoryPage(response);
    });
  }

  @override
  Future<Result<String>> downloadInvoice({
    required String url,
    required String savePath,
  }) {
    return safeApiCall(() async {
      await _remote.downloadInvoice(url: url, savePath: savePath);
      return savePath;
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
