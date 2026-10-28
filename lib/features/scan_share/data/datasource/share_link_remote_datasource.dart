import 'package:dio/dio.dart';

import '../../../../core/constants/api_endpoints.dart';
import '../model/share_link_models.dart';

class ShareLinkRemoteDatasource {
  ShareLinkRemoteDatasource(this._dio);

  final Dio _dio;

  /// POST `/api/v1/share-links`
  Future<CreateShareLinkResponseModel> createShareLink(
    CreateShareLinkRequestModel request,
  ) async {
    final response = await _dio.post<Map<String, dynamic>>(
      ApiEndpoints.shareLinks,
      data: request.toJson(),
    );
    final data = response.data;
    return CreateShareLinkResponseModel.fromJson(
      data is Map<String, dynamic> ? data : <String, dynamic>{},
    );
  }
}
