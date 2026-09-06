import '../../../../core/error/result.dart';
import '../../../../core/repository/base_repository.dart';
import '../../domain/entity/consent_document_entity.dart';
import '../../domain/repository/consent_document_repository.dart';
import '../datasource/consent_document_remote_datasource.dart';

class ConsentDocumentRepositoryImpl extends BaseRepository
    implements ConsentDocumentRepository {
  ConsentDocumentRepositoryImpl({
    required ConsentDocumentRemoteDatasource remoteDatasource,
    required super.connectivityService,
  }) : _remote = remoteDatasource;

  final ConsentDocumentRemoteDatasource _remote;

  @override
  Future<Result<ConsentDocumentEntity>> getConsentDocument({
    required String code,
    required String locale,
  }) {
    return safeApiCall(() async {
      final response = await _remote.getConsentDocument(
        code: code,
        locale: locale,
      );
      return response.document.toEntity();
    });
  }
}
