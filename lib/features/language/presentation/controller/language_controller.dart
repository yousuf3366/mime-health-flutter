import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entity/language_entity.dart';
import '../../domain/usecase/load_language_usecase.dart';
import '../provider/language_di.dart';

class LanguageState extends Equatable {
  const LanguageState({
    required this.entity,
    this.isLoading = false,
    this.errorMessage,
  });

  final LanguageEntity entity;
  final bool isLoading;
  final String? errorMessage;

  String t(String key, {String? fallback}) =>
      entity.translate(key, fallback: fallback);

  LanguageState copyWith({
    LanguageEntity? entity,
    bool? isLoading,
    String? errorMessage,
  }) {
    return LanguageState(
      entity: entity ?? this.entity,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [entity, isLoading, errorMessage];
}

/// Holds the global localization map for the entire app.
class LanguageController extends Notifier<LanguageState> {
  @override
  LanguageState build() {
    final prefsCode =
        ref.read(languageRepositoryProvider).getSavedLanguageCode();
    return LanguageState(
      entity: LanguageEntity(code: prefsCode, strings: const {}),
      isLoading: true,
    );
  }

  LoadLanguageUseCase get _load => ref.read(loadLanguageUseCaseProvider);
  ChangeLanguageUseCase get _change => ref.read(changeLanguageUseCaseProvider);

  Future<void> load([String? code]) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    final result = await _load(code);
    result.when(
      success: (entity) {
        state = LanguageState(entity: entity);
      },
      failure: (error) {
        state = state.copyWith(
          isLoading: false,
          errorMessage: error.message,
        );
      },
    );
  }

  Future<void> changeLanguage(String code) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    final result = await _change(code);
    result.when(
      success: (entity) {
        state = LanguageState(entity: entity);
      },
      failure: (error) {
        state = state.copyWith(
          isLoading: false,
          errorMessage: error.message,
        );
      },
    );
  }
}

final languageControllerProvider =
    NotifierProvider<LanguageController, LanguageState>(LanguageController.new);

/// Convenience provider that exposes the active translation state.
final appLocalizationProvider = Provider<LanguageState>((ref) {
  return ref.watch(languageControllerProvider);
});
