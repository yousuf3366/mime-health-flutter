import '../../../../core/error/result.dart';
import '../entity/feedback_result_entity.dart';
import '../repository/feedback_repository.dart';

class SubmitFeedbackUseCase {
  const SubmitFeedbackUseCase(this._repository);

  final FeedbackRepository _repository;

  Future<Result<FeedbackResultEntity>> call({
    String? message,
    String? audioPath,
  }) {
    return _repository.submitFeedback(message: message, audioPath: audioPath);
  }
}
