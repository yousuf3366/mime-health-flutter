import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/providers/core_providers.dart';
import '../../data/datasource/language_remote_datasource.dart';
import '../../data/repository/language_repository_impl.dart';
import '../../domain/repository/language_repository.dart';
import '../../domain/usecase/load_language_usecase.dart';

final languageRemoteDatasourceProvider = Provider<LanguageRemoteDatasource>(
  (ref) => LanguageRemoteDatasource(ref.watch(dioProvider)),
);

final languageRepositoryProvider = Provider<LanguageRepository>(
  (ref) => LanguageRepositoryImpl(
    remoteDatasource: ref.watch(languageRemoteDatasourceProvider),
    prefs: ref.watch(sharedPrefsProvider),
    connectivityService: ref.watch(connectivityServiceProvider),
  ),
);

final loadLanguageUseCaseProvider = Provider<LoadLanguageUseCase>(
  (ref) => LoadLanguageUseCase(ref.watch(languageRepositoryProvider)),
);

final changeLanguageUseCaseProvider = Provider<ChangeLanguageUseCase>(
  (ref) => ChangeLanguageUseCase(ref.watch(languageRepositoryProvider)),
);
