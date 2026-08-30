import 'package:dio/dio.dart';

import '../../../../core/constants/api_endpoints.dart';
import '../model/feedback_response_model.dart';

class FeedbackRemoteDatasource {
  FeedbackRemoteDatasource(this._dio);

  final Dio _dio;

  static const supportedAudioExtensions = {
    'm4a',
    'mp3',
    'wav',
    'aac',
    'ogg',
    'webm',
  };

  Future<FeedbackResponseModel> submitFeedback({
    String? message,
    String? audioPath,
  }) async {
    final normalizedMessage = message?.trim();
    final normalizedAudioPath = audioPath?.trim();
    final fileName = normalizedAudioPath?.split(RegExp(r'[/\\]')).last;

    if (fileName != null) {
      final extension = fileName.split('.').last.toLowerCase();
      if (!supportedAudioExtensions.contains(extension)) {
        throw ArgumentError('Unsupported audio format: .$extension');
      }
    }

    final formData = FormData.fromMap({
      if (normalizedMessage != null && normalizedMessage.isNotEmpty)
        'message': normalizedMessage,
      if (normalizedAudioPath != null &&
          normalizedAudioPath.isNotEmpty &&
          fileName != null)
        'audio': await MultipartFile.fromFile(
          normalizedAudioPath,
          filename: fileName,
        ),
    });

    final response = await _dio.post<Map<String, dynamic>>(
      ApiEndpoints.feedback,
      data: formData,
    );

    return FeedbackResponseModel.fromJson(response.data ?? {});
  }
}
