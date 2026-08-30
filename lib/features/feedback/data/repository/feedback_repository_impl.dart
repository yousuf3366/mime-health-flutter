import '../../../../core/error/result.dart';
import '../../../../core/repository/base_repository.dart';
import '../../domain/entity/feedback_result_entity.dart';
import '../../domain/repository/feedback_repository.dart';
import '../datasource/feedback_remote_datasource.dart';

class FeedbackRepositoryImpl extends BaseRepository
    implements FeedbackRepository {
  FeedbackRepositoryImpl({
    required FeedbackRemoteDatasource remoteDatasource,
    required super.connectivityService,
  }) : _remote = remoteDatasource;

  final FeedbackRemoteDatasource _remote;

  @override
  Future<Result<FeedbackResultEntity>> submitFeedback({
    String? message,
    String? audioPath,
  }) {
    return safeApiCall(() async {
      final response = await _remote.submitFeedback(
        message: message,
        audioPath: audioPath,
      );
      return response.toEntity();
    });
  }
}
