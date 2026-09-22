import '../../../../core/error/result.dart';
import '../entity/consent_document_entity.dart';

abstract interface class ConsentDocumentRepository {
  Future<Result<ConsentDocumentEntity>> getConsentDocument({
    required String code,
    required String locale,
  });
}
