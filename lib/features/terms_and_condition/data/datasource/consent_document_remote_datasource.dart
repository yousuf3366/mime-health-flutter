import 'package:dio/dio.dart';

import '../../../../core/constants/api_endpoints.dart';
import '../model/consent_document_models.dart';

class ConsentDocumentRemoteDatasource {
  ConsentDocumentRemoteDatasource(this._dio);

  final Dio _dio;

  /// GET `/api/v1/consent-documents/{code}?locale={locale}`
  Future<ConsentDocumentResponseModel> getConsentDocument({
    required String code,
    required String locale,
  }) async {
    final response = await _dio.get<Map<String, dynamic>>(
      ApiEndpoints.consentDocument(code),
      queryParameters: {'locale': locale},
    );

    final model = ConsentDocumentResponseModel.fromJson(
      _asJsonMap(response.data),
    );

    if (!model.success || model.document.content.isEmpty) {
      throw DioException(
        requestOptions: response.requestOptions,
        response: response,
        type: DioExceptionType.badResponse,
        message: model.message.isNotEmpty
            ? model.message
            : 'Failed to load consent document',
      );
    }

    return model;
  }

  Map<String, dynamic> _asJsonMap(dynamic data) {
    if (data is Map<String, dynamic>) return data;
    if (data is Map) return Map<String, dynamic>.from(data);
    return <String, dynamic>{};
  }
}
