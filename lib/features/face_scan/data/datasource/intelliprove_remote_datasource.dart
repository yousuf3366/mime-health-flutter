import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../../../../core/constants/intelliprove_endpoints.dart';
import '../../../../core/error/exceptions.dart';
import '../model/face_scan_models.dart';

/// IntelliProve Engine REST used only for questionnaire answer submission.
class IntelliProveRemoteDatasource {
  IntelliProveRemoteDatasource(this._dio);

  final Dio _dio;

  /// POST /v2/users — idempotent: 400 "already exists" is treated as success.
  Future<void> ensureUser(EnsureUserRequestModel request) async {
    if (kDebugMode) {
      debugPrint(
        '[IntelliProve] ensureUser external_user_id=${request.externalUserId}',
      );
    }

    try {
      await _dio.post<dynamic>(
        IntelliProveEndpoints.users,
        data: request.toJson(),
      );
    } on DioException catch (error) {
      if (_isUserAlreadyExists(error)) {
        if (kDebugMode) {
          debugPrint(
            '[IntelliProve] user already exists, continuing: '
            '${request.externalUserId}',
          );
        }
        return;
      }
      rethrow;
    }
  }

  /// GET /v2/users — IntelliProve internal user_id.
  Future<IntelliProveUserResponseModel> getIntelliProveUserId(
    String externalUserId,
  ) async {
    final response = await _dio.get<dynamic>(
      IntelliProveEndpoints.users,
      queryParameters: {'external_user_id': externalUserId},
    );
    final model = IntelliProveUserResponseModel.fromJson(
      _asJsonMap(response.data),
    );
    if (model.userId.isEmpty) {
      throw const ApiException(
        'IntelliProve user_id missing in get user response.',
      );
    }
    return model;
  }

  /// POST /v2/questions/answer/many
  Future<void> saveQuestionAnswersMany({
    required String userId,
    required List<FaceScanQuestionAnswerRequestModel> answers,
  }) async {
    if (answers.isEmpty) return;

    await _dio.post<dynamic>(
      IntelliProveEndpoints.questionAnswerMany,
      queryParameters: {'external_user_id': userId},
      data: answers.map((a) => a.toJson()).toList(growable: false),
    );
  }

  /// POST /v2/questions/answer — one-by-one fallback.
  Future<void> saveQuestionAnswers({
    required String externalUserId,
    required List<FaceScanQuestionAnswerRequestModel> answers,
  }) async {
    for (final answer in answers) {
      try {
        await _dio.post<dynamic>(
          IntelliProveEndpoints.questionAnswer,
          queryParameters: {'external_user_id': externalUserId},
          data: answer.toJson(),
        );
      } on DioException catch (error) {
        if (kDebugMode) {
          debugPrint(
            '[IntelliProve] answer ${answer.lookupKey} failed '
            '(${error.response?.statusCode}): ${error.response?.data}',
          );
        }
      }
    }
  }

  bool _isUserAlreadyExists(DioException error) {
    if (error.response?.statusCode != 400) return false;
    final body = error.response?.data;
    final text = body is String ? body : body?.toString() ?? '';
    return text.toLowerCase().contains('already exists');
  }
}

Map<String, dynamic> _asJsonMap(dynamic data) {
  if (data is Map<String, dynamic>) return data;
  if (data is Map) return Map<String, dynamic>.from(data);
  return <String, dynamic>{};
}
