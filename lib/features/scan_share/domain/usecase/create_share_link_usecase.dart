import '../../../../core/error/result.dart';
import '../entity/share_link_entity.dart';
import '../repository/share_link_repository.dart';

class CreateShareLinkUseCase {
  CreateShareLinkUseCase(this._repository);

  final ShareLinkRepository _repository;

  Future<Result<ShareLinkEntity>> call({
    required int profileId,
    required int scanId,
  }) => _repository.createShareLink(profileId: profileId, scanId: scanId);
}
