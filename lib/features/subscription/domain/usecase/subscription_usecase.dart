import '../../../../core/error/result.dart';
import '../entity/subscription_entity.dart';
import '../repository/subscription_repository.dart';

class GetSubscriptionPlansUseCase {
  GetSubscriptionPlansUseCase(this._repository);

  final SubscriptionRepository _repository;

  Future<Result<SubscriptionPlansResultEntity>> call() =>
      _repository.getPlans();
}

class SelectSubscriptionPlanUseCase {
  SelectSubscriptionPlanUseCase(this._repository);

  final SubscriptionRepository _repository;

  Future<Result<SelectedSubscriptionEntity>> call({
    required String planCode,
    required BillingInterval billingInterval,
    bool useTrial = false,
  }) {
    return _repository.selectPlan(
      planCode: planCode,
      billingInterval: billingInterval,
      useTrial: useTrial,
    );
  }
}

class CheckoutSubscriptionUseCase {
  CheckoutSubscriptionUseCase(this._repository);

  final SubscriptionRepository _repository;

  Future<Result<CheckoutEntity>> call({
    required BillingInterval billingInterval,
    required PaymentMethod paymentMethod,
    String? planCode,
    String purpose = CheckoutPurpose.subscription,
    List<String> addonCodes = const [],
    List<String> serviceCodes = const [],
  }) {
    return _repository.checkout(
      planCode: planCode,
      billingInterval: billingInterval,
      paymentMethod: paymentMethod,
      purpose: purpose,
      addonCodes: addonCodes,
      serviceCodes: serviceCodes,
    );
  }
}

class GetSubscriptionServicesUseCase {
  GetSubscriptionServicesUseCase(this._repository);

  final SubscriptionRepository _repository;

  Future<Result<List<SubscriptionServiceOfferEntity>>> call() =>
      _repository.getServices();
}

class GetPaymentHistoryUseCase {
  GetPaymentHistoryUseCase(this._repository);

  final SubscriptionRepository _repository;

  Future<Result<PaymentHistoryPageEntity>> call({
    int page = 1,
    int perPage = 10,
    DateTime? fromDate,
    DateTime? toDate,
  }) => _repository.getPayments(
    page: page,
    perPage: perPage,
    fromDate: fromDate,
    toDate: toDate,
  );
}

class DownloadInvoiceUseCase {
  DownloadInvoiceUseCase(this._repository);

  final SubscriptionRepository _repository;

  Future<Result<String>> call({
    required String url,
    required String savePath,
  }) => _repository.downloadInvoice(url: url, savePath: savePath);
}

class GetMySubscriptionUseCase {
  GetMySubscriptionUseCase(this._repository);

  final SubscriptionRepository _repository;

  Future<Result<MySubscriptionEntity?>> call() =>
      _repository.getMySubscription();
}

class CancelSubscriptionUseCase {
  CancelSubscriptionUseCase(this._repository);

  final SubscriptionRepository _repository;

  Future<Result<String>> call({required String reason}) =>
      _repository.cancelSubscription(reason: reason);
}
