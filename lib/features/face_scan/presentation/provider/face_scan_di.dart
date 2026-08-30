import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/providers/core_providers.dart';
import '../../data/bridge/intelliprove_webview_bridge.dart';
import '../../data/datasource/intelliprove_remote_datasource.dart';
import '../../data/datasource/mime_scan_remote_datasource.dart';
import '../../data/gateway/intelliprove_plugin_gateway.dart';
import '../../data/repository/face_scan_repository_impl.dart';
import '../../domain/entity/face_scan_entity.dart';
import '../../domain/gateway/face_scan_plugin_gateway.dart';
import '../../domain/repository/face_scan_repository.dart';
import '../../domain/usecase/face_scan_usecase.dart';

final intelliProveRemoteDatasourceProvider =
    Provider<IntelliProveRemoteDatasource>(
  (ref) => IntelliProveRemoteDatasource(ref.watch(intelliProveDioProvider)),
);

final mimeScanRemoteDatasourceProvider = Provider<MimeScanRemoteDatasource>(
  (ref) => MimeScanRemoteDatasource(ref.watch(dioProvider)),
);

final intelliProveWebViewBridgeProvider = Provider<IntelliProveWebViewBridge>(
  (ref) => IntelliProveWebViewBridge(),
);

final faceScanPluginGatewayProvider = Provider<FaceScanPluginGateway>(
  (ref) => IntelliProvePluginGateway(
    ref.watch(intelliProveWebViewBridgeProvider),
  ),
);

final faceScanRepositoryProvider = Provider<FaceScanRepository>(
  (ref) => FaceScanRepositoryImpl(
    remoteDatasource: ref.watch(intelliProveRemoteDatasourceProvider),
    mimeScanRemoteDatasource: ref.watch(mimeScanRemoteDatasourceProvider),
    connectivityService: ref.watch(connectivityServiceProvider),
  ),
);

final ensureIntelliProveUserUseCaseProvider =
    Provider<EnsureIntelliProveUserUseCase>(
  (ref) => EnsureIntelliProveUserUseCase(ref.watch(faceScanRepositoryProvider)),
);

final getFaceScanUrlUseCaseProvider = Provider<GetFaceScanUrlUseCase>(
  (ref) => GetFaceScanUrlUseCase(ref.watch(faceScanRepositoryProvider)),
);

final getIntelliProveUserIdUseCaseProvider =
    Provider<GetIntelliProveUserIdUseCase>(
  (ref) =>
      GetIntelliProveUserIdUseCase(ref.watch(faceScanRepositoryProvider)),
);

final saveFaceScanQuestionAnswersManyUseCaseProvider =
    Provider<SaveFaceScanQuestionAnswersManyUseCase>(
  (ref) => SaveFaceScanQuestionAnswersManyUseCase(
    ref.watch(faceScanRepositoryProvider),
  ),
);

final saveFaceScanQuestionAnswersUseCaseProvider =
    Provider<SaveFaceScanQuestionAnswersUseCase>(
  (ref) => SaveFaceScanQuestionAnswersUseCase(
    ref.watch(faceScanRepositoryProvider),
  ),
);

final storeMimeFaceScanUseCaseProvider = Provider<StoreMimeFaceScanUseCase>(
  (ref) => StoreMimeFaceScanUseCase(ref.watch(faceScanRepositoryProvider)),
);

final getLatestMimeScanUseCaseProvider = Provider<GetLatestMimeScanUseCase>(
  (ref) => GetLatestMimeScanUseCase(ref.watch(faceScanRepositoryProvider)),
);

/// Latest Mime scan for the Health Hub tab.
final latestMimeScanProvider =
    FutureProvider.autoDispose<FaceScanVitalsResult?>((ref) async {
  final result = await ref.watch(getLatestMimeScanUseCaseProvider).call();
  return result.when(
    success: (data) => data,
    failure: (error) => throw error,
  );
});
