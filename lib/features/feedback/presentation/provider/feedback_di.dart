import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/providers/core_providers.dart';
import '../../data/datasource/feedback_remote_datasource.dart';
import '../../data/repository/feedback_repository_impl.dart';
import '../../domain/repository/feedback_repository.dart';
import '../../domain/usecase/submit_feedback_usecase.dart';

final feedbackRemoteDatasourceProvider = Provider<FeedbackRemoteDatasource>(
  (ref) => FeedbackRemoteDatasource(ref.watch(dioProvider)),
);

final feedbackRepositoryProvider = Provider<FeedbackRepository>(
  (ref) => FeedbackRepositoryImpl(
    remoteDatasource: ref.watch(feedbackRemoteDatasourceProvider),
    connectivityService: ref.watch(connectivityServiceProvider),
  ),
);

final submitFeedbackUseCaseProvider = Provider<SubmitFeedbackUseCase>(
  (ref) => SubmitFeedbackUseCase(ref.watch(feedbackRepositoryProvider)),
);
