import '../error/error_handler.dart';
import '../error/exceptions.dart';
import '../error/result.dart';
import '../services/connectivity_service.dart';

/// Generic base class for all feature repositories.
///
/// Provides [safeApiCall] so subclasses never duplicate try/catch logic and
/// never throw exceptions to the presentation layer.
abstract class BaseRepository {
  BaseRepository({required this.connectivityService});

  final ConnectivityService connectivityService;

  /// Executes [action] and wraps the outcome in [Result].
  Future<Result<T>> safeApiCall<T>(Future<T> Function() action) async {
    try {
      final online = await connectivityService.checkConnectivity();
      if (!online) {
        return const Failure(NoInternetException());
      }

      final data = await action();
      return Success(data);
    } catch (error, stackTrace) {
      return Failure(ErrorHandler.handle(error, stackTrace));
    }
  }
}
