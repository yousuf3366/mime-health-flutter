import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/error/exceptions.dart';
import '../../../../core/providers/core_providers.dart';
import '../../../login/presentation/provider/login_di.dart';
import '../../data/datasource/profile_remote_datasource.dart';
import '../../data/repository/profile_repository_impl.dart';
import '../../domain/entity/profile_entity.dart';
import '../../domain/repository/profile_repository.dart';
import '../../domain/usecase/profile_usecase.dart';

final profileRemoteDatasourceProvider = Provider<ProfileRemoteDatasource>(
  (ref) => ProfileRemoteDatasource(ref.watch(dioProvider)),
);

final profileRepositoryProvider = Provider<ProfileRepository>(
  (ref) => ProfileRepositoryImpl(
    remoteDatasource: ref.watch(profileRemoteDatasourceProvider),
    connectivityService: ref.watch(connectivityServiceProvider),
  ),
);

final createProfileUseCaseProvider = Provider<CreateProfileUseCase>(
  (ref) => CreateProfileUseCase(ref.watch(profileRepositoryProvider)),
);

final getProfilesUseCaseProvider = Provider<GetProfilesUseCase>(
  (ref) => GetProfilesUseCase(ref.watch(profileRepositoryProvider)),
);

final updateProfileUseCaseProvider = Provider<UpdateProfileUseCase>(
  (ref) => UpdateProfileUseCase(ref.watch(profileRepositoryProvider)),
);

final uploadAvatarUseCaseProvider = Provider<UploadAvatarUseCase>(
  (ref) => UploadAvatarUseCase(ref.watch(profileRepositoryProvider)),
);

/// Cached authenticated user for the create-profile screen.
final currentUserProvider = FutureProvider((ref) {
  return ref.watch(authRepositoryProvider).getCachedUser();
});

/// Fetches profiles for the signed-in user. Invalidate after create/update.
final profilesProvider = FutureProvider<List<ProfileEntity>>((ref) async {
  final result = await ref.watch(getProfilesUseCaseProvider).call();
  return result.when(
    success: (profiles) => profiles,
    failure: (AppException error) => throw error,
  );
});
