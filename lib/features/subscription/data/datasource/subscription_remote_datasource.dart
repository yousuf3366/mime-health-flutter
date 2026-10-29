import 'package:dio/dio.dart';

import '../../../../core/constants/api_endpoints.dart';
import '../../../../core/error/exceptions.dart';
import '../model/subscription_models.dart';

class SubscriptionRemoteDatasource {
  SubscriptionRemoteDatasource(this._dio);

  final Dio _dio;

  Future<SubscriptionPlansResponseModel> getPlans() async {
    final response = await _dio.get<Map<String, dynamic>>(
      ApiEndpoints.subscriptionPlans,
    );
    return SubscriptionPlansResponseModel.fromJson(_asJsonMap(response.data));
  }

  Future<SelectPlanResponseModel> selectPlan(
    SelectPlanRequestModel request,
  ) async {
    final response = await _dio.post<Map<String, dynamic>>(
      ApiEndpoints.subscriptionSelectPlan,
      data: request.toJson(),
    );
    return SelectPlanResponseModel.fromJson(_asJsonMap(response.data));
  }

  /// GET `/api/v1/subscription/services`
  Future<SubscriptionServicesResponseModel> getServices() async {
    final response = await _dio.get<Map<String, dynamic>>(
      ApiEndpoints.subscriptionServices,
    );
    return SubscriptionServicesResponseModel.fromJson(
      _asJsonMap(response.data),
    );
  }

  /// POST `/api/v1/subscription/checkout`
  Future<CheckoutResponseModel> checkout(CheckoutRequestModel request) async {
    final response = await _dio.post<Map<String, dynamic>>(
      ApiEndpoints.subscriptionCheckout,
      data: request.toJson(),
    );
    return CheckoutResponseModel.fromJson(_asJsonMap(response.data));
  }

  /// GET `/api/v1/subscription/payments?page=&per_page=&from_date=&to_date=`
  /// ([fromDate] / [toDate] as `yyyy-MM-dd`).
  Future<PaymentHistoryResponseModel> getPayments({
    int page = 1,
    int perPage = 10,
    String? fromDate,
    String? toDate,
  }) async {
    final response = await _dio.get<Map<String, dynamic>>(
      ApiEndpoints.subscriptionPayments,
      queryParameters: {
        'page': page,
        'per_page': perPage,
        'from_date': ?fromDate,
        'to_date': ?toDate,
      },
    );
    return PaymentHistoryResponseModel.fromJson(_asJsonMap(response.data));
  }

  /// Downloads an invoice from its (authenticated) [url] to [savePath].
  Future<void> downloadInvoice({
    required String url,
    required String savePath,
  }) async {
    await _dio.download(url, savePath);
  }

  /// GET `/api/v1/subscription/me`
  Future<MySubscriptionResponseModel> getMySubscription() async {
    final response = await _dio.get<Map<String, dynamic>>(
      ApiEndpoints.mySubscribedPlan,
    );
    return MySubscriptionResponseModel.fromJson(_asJsonMap(response.data));
  }

  /// POST `/api/v1/subscription/cancel`; returns the server message.
  Future<String> cancelSubscription({required String reason}) async {
    final response = await _dio.post<Map<String, dynamic>>(
      ApiEndpoints.subscriptionCancel,
      data: {'reason': reason},
    );
    final json = _asJsonMap(response.data);
    final message = json['message']?.toString() ?? '';
    if (json['success'] != true) {
      throw ApiException(
        message.isEmpty ? 'Failed to cancel subscription.' : message,
      );
    }
    return message.isEmpty ? 'Subscription cancelled.' : message;
  }

  Map<String, dynamic> _asJsonMap(dynamic data) {
    if (data is Map<String, dynamic>) return data;
    if (data is Map) return Map<String, dynamic>.from(data);
    return <String, dynamic>{};
  }
}
