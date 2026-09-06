import '../../domain/entity/consent_document_entity.dart';

class ConsentDocumentResponseModel {
  const ConsentDocumentResponseModel({
    required this.success,
    required this.message,
    required this.document,
  });

  final bool success;
  final String message;
  final ConsentDocumentModel document;

  factory ConsentDocumentResponseModel.fromJson(Map<String, dynamic> json) {
    final rawData = json['data'];
    final data = rawData is Map
        ? Map<String, dynamic>.from(rawData)
        : <String, dynamic>{};

    return ConsentDocumentResponseModel(
      success: json['success'] == true,
      message: json['message']?.toString() ?? '',
      document: ConsentDocumentModel.fromJson(data),
    );
  }
}

class ConsentDocumentModel {
  const ConsentDocumentModel({
    required this.code,
    required this.version,
    required this.locale,
    required this.title,
    required this.content,
    required this.contentHash,
    this.effectiveFrom,
    this.updatedAt,
  });

  final String code;
  final String version;
  final String locale;
  final String title;
  final String content;
  final String contentHash;
  final DateTime? effectiveFrom;
  final DateTime? updatedAt;

  factory ConsentDocumentModel.fromJson(Map<String, dynamic> json) {
    return ConsentDocumentModel(
      code: json['code']?.toString() ?? '',
      version: json['version']?.toString() ?? '',
      locale: json['locale']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      content: json['content']?.toString() ?? '',
      contentHash: json['content_hash']?.toString() ?? '',
      effectiveFrom: DateTime.tryParse(json['effective_from']?.toString() ?? ''),
      updatedAt: DateTime.tryParse(json['updated_at']?.toString() ?? ''),
    );
  }

  ConsentDocumentEntity toEntity() => ConsentDocumentEntity(
        code: code,
        version: version,
        locale: locale,
        title: title,
        content: content,
        contentHash: contentHash,
        effectiveFrom: effectiveFrom,
        updatedAt: updatedAt,
      );
}
