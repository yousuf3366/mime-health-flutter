import '../../../../core/error/exceptions.dart';
import '../../../../core/error/result.dart';
import '../../../../core/repository/base_repository.dart';
import '../../domain/entity/share_link_entity.dart';
import '../../domain/repository/share_link_repository.dart';
import '../datasource/share_link_remote_datasource.dart';
import '../model/share_link_models.dart';

class ShareLinkRepositoryImpl extends BaseRepository
    implements ShareLinkRepository {
  ShareLinkRepositoryImpl({
    required ShareLinkRemoteDatasource remoteDatasource,
    required super.connectivityService,
  }) : _remote = remoteDatasource;

  final ShareLinkRemoteDatasource _remote;

  @override
  Future<Result<ShareLinkEntity>> createShareLink({
    required int profileId,
    required int scanId,
  }) {
    return safeApiCall(() async {
      final response = await _remote.createShareLink(
        CreateShareLinkRequestModel(profileId: profileId, scanId: scanId),
      );
      final data = response.data;
      if (!response.success || data == null || data.copyLink.isEmpty) {
        throw ApiException(
          response.message.isEmpty
              ? 'Failed to create share link.'
              : response.message,
        );
      }
      return ShareLinkEntity(
        id: data.id,
        profileId: data.profileId,
        scanId: data.scanId,
        isActive: data.isActive,
        copyLink: data.copyLink,
        expiresAt: data.expiresAt == null
            ? null
            : DateTime.tryParse(data.expiresAt!),
      );
    });
  }
}
