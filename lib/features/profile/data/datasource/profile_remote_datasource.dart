import 'package:dio/dio.dart';

import '../../../../core/constants/api_endpoints.dart';
import '../model/profile_models.dart';

/// Remote profile datasource backed by Dio.
class ProfileRemoteDatasource {
  ProfileRemoteDatasource(this._dio);

  final Dio _dio;

  Future<CreateProfileResponseModel> createProfile(
    CreateProfileRequestModel request,
  ) async {
    final response = await _dio.post<Map<String, dynamic>>(
      ApiEndpoints.profiles,
      data: request.toJson(),
    );
    return CreateProfileResponseModel.fromJson(_asJsonMap(response.data));
  }

  Future<CreateProfileResponseModel> updateProfile(
    int profileId,
    CreateProfileRequestModel request,
  ) async {
    final response = await _dio.put<Map<String, dynamic>>(
      ApiEndpoints.profile(profileId),
      data: request.toJson(),
    );
    return CreateProfileResponseModel.fromJson(_asJsonMap(response.data));
  }

  Future<ProfilesListResponseModel> getProfiles() async {
    final response = await _dio.get<dynamic>(ApiEndpoints.profiles);
    return ProfilesListResponseModel.fromJson(_asJsonMap(response.data));
  }

  Future<UploadAvatarResponseModel> uploadAvatar({
    required int profileId,
    required String filePath,
    required String fileName,
    String? mimeType,
  }) async {
    final formData = FormData.fromMap({
      'avatar': await MultipartFile.fromFile(filePath, filename: fileName),
    });

    final response = await _dio.post<Map<String, dynamic>>(
      ApiEndpoints.profileAvatar(profileId),
      data: formData,
    );
    return UploadAvatarResponseModel.fromJson(_asJsonMap(response.data));
  }
}

Map<String, dynamic> _asJsonMap(dynamic data) {
  if (data is Map<String, dynamic>) return data;
  if (data is Map) return Map<String, dynamic>.from(data);
  return <String, dynamic>{};
}
