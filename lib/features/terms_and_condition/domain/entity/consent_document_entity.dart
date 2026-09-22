import 'package:equatable/equatable.dart';

/// Domain model for a consent document (e.g. Terms of Service).
class ConsentDocumentEntity extends Equatable {
  const ConsentDocumentEntity({
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

  @override
  List<Object?> get props => [
        code,
        version,
        locale,
        title,
        content,
        contentHash,
        effectiveFrom,
        updatedAt,
      ];
}
