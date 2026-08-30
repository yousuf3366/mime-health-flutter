import '../../../../core/error/result.dart';
import '../entity/language_entity.dart';
import '../repository/language_repository.dart';

class LoadLanguageUseCase {
  LoadLanguageUseCase(this._repository);

  final LanguageRepository _repository;

  Future<Result<LanguageEntity>> call([String? code]) async {
    final languageCode = code ?? _repository.getSavedLanguageCode();
    return _repository.loadLanguage(languageCode);
  }
}

class ChangeLanguageUseCase {
  ChangeLanguageUseCase(this._repository);

  final LanguageRepository _repository;

  Future<Result<LanguageEntity>> call(String code) async {
    await _repository.saveLanguageCode(code);
    return _repository.loadLanguage(code);
  }
}
