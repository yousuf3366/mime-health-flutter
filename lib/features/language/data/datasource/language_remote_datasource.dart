import 'package:dio/dio.dart';

import '../../../../core/constants/api_endpoints.dart';
import '../model/translations_response_model.dart';

/// Remote datasource that fetches localization maps.
class LanguageRemoteDatasource {
  LanguageRemoteDatasource(this._dio);

  final Dio _dio;

  /// Fetches `GET /translations/locales/{code}` and returns `data.items`.
  Future<Map<String, String>> fetchLanguage(String code) async {
    final response = await _dio.get<Map<String, dynamic>>(
      ApiEndpoints.translations(code),
    );

    final model = TranslationsResponseModel.fromJson(response.data ?? {});

    if (!model.success && model.items.isEmpty) {
      throw DioException(
        requestOptions: response.requestOptions,
        response: response,
        type: DioExceptionType.badResponse,
        message: model.message.isNotEmpty
            ? model.message
            : 'Failed to load translations',
      );
    }

    return model.items;
  }
}
