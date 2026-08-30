import '../../../../core/error/result.dart';
import '../entity/feedback_result_entity.dart';

abstract interface class FeedbackRepository {
  Future<Result<FeedbackResultEntity>> submitFeedback({
    String? message,
    String? audioPath,
  });
}
