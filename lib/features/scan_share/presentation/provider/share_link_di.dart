import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/providers/core_providers.dart';
import '../../data/datasource/share_link_remote_datasource.dart';
import '../../data/repository/share_link_repository_impl.dart';
import '../../domain/repository/share_link_repository.dart';
import '../../domain/usecase/create_share_link_usecase.dart';

final shareLinkRemoteDatasourceProvider = Provider<ShareLinkRemoteDatasource>(
  (ref) => ShareLinkRemoteDatasource(ref.watch(dioProvider)),
);

final shareLinkRepositoryProvider = Provider<ShareLinkRepository>(
  (ref) => ShareLinkRepositoryImpl(
    remoteDatasource: ref.watch(shareLinkRemoteDatasourceProvider),
    connectivityService: ref.watch(connectivityServiceProvider),
  ),
);

final createShareLinkUseCaseProvider = Provider<CreateShareLinkUseCase>(
  (ref) => CreateShareLinkUseCase(ref.watch(shareLinkRepositoryProvider)),
);
