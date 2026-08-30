import '../../domain/entity/feedback_result_entity.dart';

class FeedbackResponseModel {
  const FeedbackResponseModel({
    required this.id,
    required this.message,
    required this.hasAudio,
    required this.status,
    required this.successMessage,
    this.createdAt,
    this.updatedAt,
  });

  final int id;
  final String? message;
  final bool hasAudio;
  final String status;
  final String successMessage;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  factory FeedbackResponseModel.fromJson(Map<String, dynamic> json) {
    final rawData = json['data'];
    final data = rawData is Map
        ? Map<String, dynamic>.from(rawData)
        : <String, dynamic>{};

    return FeedbackResponseModel(
      id: _asInt(data['id']) ?? 0,
      message: _asNullableString(data['message']),
      hasAudio: data['has_audio'] == true,
      status: data['status']?.toString() ?? '',
      successMessage:
          json['message']?.toString() ?? 'Feedback submitted successfully.',
      createdAt: DateTime.tryParse(data['created_at']?.toString() ?? ''),
      updatedAt: DateTime.tryParse(data['updated_at']?.toString() ?? ''),
    );
  }

  FeedbackResultEntity toEntity() => FeedbackResultEntity(
    id: id,
    message: message,
    hasAudio: hasAudio,
    status: status,
    successMessage: successMessage,
    createdAt: createdAt,
    updatedAt: updatedAt,
  );
}

int? _asInt(dynamic value) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  return int.tryParse(value?.toString() ?? '');
}

String? _asNullableString(dynamic value) {
  final text = value?.toString().trim();
  return text == null || text.isEmpty ? null : text;
}
