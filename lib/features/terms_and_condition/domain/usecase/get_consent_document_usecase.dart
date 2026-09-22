import '../../../../core/error/result.dart';
import '../entity/consent_document_entity.dart';
import '../repository/consent_document_repository.dart';

class GetConsentDocumentUseCase {
  const GetConsentDocumentUseCase(this._repository);

  final ConsentDocumentRepository _repository;

  Future<Result<ConsentDocumentEntity>> call({
    required String code,
    required String locale,
  }) {
    return _repository.getConsentDocument(code: code, locale: locale);
  }
}
