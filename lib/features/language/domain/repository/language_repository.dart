import '../entity/language_entity.dart';
import '../../../../core/error/result.dart';

/// Contract for loading localization maps from a remote source.
abstract class LanguageRepository {
  Future<Result<LanguageEntity>> loadLanguage(String code);

  Future<void> saveLanguageCode(String code);

  String getSavedLanguageCode();
}
