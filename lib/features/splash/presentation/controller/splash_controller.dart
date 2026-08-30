import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/providers/core_providers.dart';
import '../../../language/presentation/provider/language_provider.dart';
import '../../../login/presentation/provider/login_provider.dart';

enum SplashStatus { initializing, ready, error }

class SplashState extends Equatable {
  const SplashState({
    this.status = SplashStatus.initializing,
    this.isLoggedIn = false,
    this.isOnline = true,
    this.errorMessage,
    this.progressMessage = 'Initializing...',
  });

  final SplashStatus status;
  final bool isLoggedIn;
  final bool isOnline;
  final String? errorMessage;
  final String progressMessage;

  SplashState copyWith({
    SplashStatus? status,
    bool? isLoggedIn,
    bool? isOnline,
    String? errorMessage,
    String? progressMessage,
  }) {
    return SplashState(
      status: status ?? this.status,
      isLoggedIn: isLoggedIn ?? this.isLoggedIn,
      isOnline: isOnline ?? this.isOnline,
      errorMessage: errorMessage,
      progressMessage: progressMessage ?? this.progressMessage,
    );
  }

  @override
  List<Object?> get props =>
      [status, isLoggedIn, isOnline, errorMessage, progressMessage];
}

/// Orchestrates the splash bootstrap sequence defined in the architecture spec.
class SplashController extends Notifier<SplashState> {
  @override
  SplashState build() => const SplashState();

  Future<void> initialize() async {
    state = const SplashState(status: SplashStatus.initializing);

    try {
      state = state.copyWith(progressMessage: 'Checking connectivity...');
      final connectivity = ref.read(connectivityServiceProvider);
      final isOnline = await connectivity.checkConnectivity();
      state = state.copyWith(isOnline: isOnline);

      state = state.copyWith(progressMessage: 'Reading session...');
      final isLoggedIn = await ref.read(checkAuthUseCaseProvider).call();

      state = state.copyWith(progressMessage: 'Loading language...');
      await ref.read(languageControllerProvider.notifier).load();

      state = state.copyWith(
        status: SplashStatus.ready,
        isLoggedIn: isLoggedIn,
        progressMessage: 'Ready',
      );
    } catch (error) {
      state = state.copyWith(
        status: SplashStatus.error,
        errorMessage: error.toString(),
      );
    }
  }
}
