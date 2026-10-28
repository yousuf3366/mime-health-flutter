import '../../../../core/error/result.dart';
import '../entity/share_link_entity.dart';

abstract class ShareLinkRepository {
  /// Creates a public share link for [scanId] of [profileId].
  Future<Result<ShareLinkEntity>> createShareLink({
    required int profileId,
    required int scanId,
  });
}
