import 'package:dio/dio.dart';

import '../../../../core/constants/api_endpoints.dart';
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

  /// GET `/api/v1/subscription/me`
  Future<MySubscriptionResponseModel> getMySubscription() async {
    final response = await _dio.get<Map<String, dynamic>>(
      ApiEndpoints.mySubscribedPlan,
    );
    return MySubscriptionResponseModel.fromJson(_asJsonMap(response.data));
  }

  Map<String, dynamic> _asJsonMap(dynamic data) {
    if (data is Map<String, dynamic>) return data;
    if (data is Map) return Map<String, dynamic>.from(data);
    return <String, dynamic>{};
  }
}
