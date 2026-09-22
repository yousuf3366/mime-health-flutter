import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/providers/core_providers.dart';
import '../../../language/presentation/provider/language_provider.dart';
import '../../data/datasource/consent_document_remote_datasource.dart';
import '../../data/repository/consent_document_repository_impl.dart';
import '../../domain/entity/consent_document_entity.dart';
import '../../domain/repository/consent_document_repository.dart';
import '../../domain/usecase/get_consent_document_usecase.dart';

final consentDocumentRemoteDatasourceProvider =
    Provider<ConsentDocumentRemoteDatasource>(
  (ref) => ConsentDocumentRemoteDatasource(ref.watch(dioProvider)),
);

final consentDocumentRepositoryProvider = Provider<ConsentDocumentRepository>(
  (ref) => ConsentDocumentRepositoryImpl(
    remoteDatasource: ref.watch(consentDocumentRemoteDatasourceProvider),
    connectivityService: ref.watch(connectivityServiceProvider),
  ),
);

final getConsentDocumentUseCaseProvider = Provider<GetConsentDocumentUseCase>(
  (ref) => GetConsentDocumentUseCase(
    ref.watch(consentDocumentRepositoryProvider),
  ),
);

/// Fetches a consent document by [code] for the currently selected language.
final consentDocumentProvider = FutureProvider.autoDispose
    .family<ConsentDocumentEntity, String>((ref, code) async {
  final locale = ref.watch(languageControllerProvider).entity.code;
  final result = await ref.watch(getConsentDocumentUseCaseProvider).call(
        code: code,
        locale: locale,
      );
  return result.when(
    success: (data) => data,
    failure: (error) => throw error,
  );
});
