import 'package:dio/dio.dart';

import '../../../../core/constants/api_endpoints.dart';
import '../model/login_models.dart';

/// Remote authentication datasource backed by Dio.
class AuthRemoteDatasource {
  AuthRemoteDatasource(this._dio);

  final Dio _dio;

  Future<OtpSentResponseModel> sendOtp(SendOtpRequestModel request) async {
    final response = await _dio.post<Map<String, dynamic>>(
      ApiEndpoints.sendOtp,
      data: request.toJson(),
    );
    return OtpSentResponseModel.fromJson(response.data ?? {});
  }

  Future<OtpSentResponseModel> resendOtp(SendOtpRequestModel request) async {
    final response = await _dio.post<Map<String, dynamic>>(
      ApiEndpoints.resendOtp,
      data: request.toJson(),
    );
    return OtpSentResponseModel.fromJson(response.data ?? {});
  }

  Future<LoginResponseModel> verifyOtp(VerifyOtpRequestModel request) async {
    final response = await _dio.post<Map<String, dynamic>>(
      ApiEndpoints.verifyOtp,
      data: request.toJson(),
    );
    return LoginResponseModel.fromJson(response.data ?? {});
  }

  Future<LoginResponseModel> googleLogin(
    GoogleLoginRequestModel request,
  ) async {
    final response = await _dio.post<Map<String, dynamic>>(
      ApiEndpoints.googleLogin,
      data: request.toJson(),
    );
    return LoginResponseModel.fromJson(response.data ?? {});
  }

  Future<void> logout() async {
    await _dio.post<void>(ApiEndpoints.logout);
  }

  Future<LoginResponseModel> refresh(String refreshToken) async {
    final response = await _dio.post<Map<String, dynamic>>(
      ApiEndpoints.refreshToken,
      data: {'refresh_token': refreshToken},
    );

    return LoginResponseModel.fromJson(response.data ?? {});
  }
}
