import 'package:equatable/equatable.dart';

class FeedbackResultEntity extends Equatable {
  const FeedbackResultEntity({
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

  @override
  List<Object?> get props => [
    id,
    message,
    hasAudio,
    status,
    successMessage,
    createdAt,
    updatedAt,
  ];
}
