import '../../../../core/error/result.dart';
import '../../../../core/localization/fallback_strings.dart';
import '../../../../core/repository/base_repository.dart';
import '../../../../core/storage/shared_prefs_service.dart';
import '../../domain/entity/language_entity.dart';
import '../../domain/repository/language_repository.dart';
import '../datasource/language_remote_datasource.dart';

class LanguageRepositoryImpl extends BaseRepository
    implements LanguageRepository {
  LanguageRepositoryImpl({
    required LanguageRemoteDatasource remoteDatasource,
    required SharedPrefsService prefs,
    required super.connectivityService,
  })  : _remote = remoteDatasource,
        _prefs = prefs;

  final LanguageRemoteDatasource _remote;
  final SharedPrefsService _prefs;

  @override
  Future<Result<LanguageEntity>> loadLanguage(String code) async {
    final result = await safeApiCall(() => _remote.fetchLanguage(code));

    return result.when(
      success: (items) => Success(
        LanguageEntity(
          code: code,
          strings: FallbackStrings.mergeWithFallback(code, items),
        ),
      ),
      failure: (_) {
        // Always provide a usable map so the UI never breaks.
        return Success(
          LanguageEntity(
            code: code,
            strings: FallbackStrings.forCode(code),
          ),
        );
      },
    );
  }

  @override
  Future<void> saveLanguageCode(String code) => _prefs.setLanguageCode(code);

  @override
  String getSavedLanguageCode() => _prefs.languageCode;
}
