import 'package:equatable/equatable.dart';

import '../../domain/entity/share_link_entity.dart';

class ShareLinkState extends Equatable {
  const ShareLinkState({
    this.creatingScanIds = const {},
    this.linksByScanId = const {},
    this.errorMessage,
  });

  /// Scans whose link is being created (drives each share button's spinner).
  final Set<int> creatingScanIds;

  /// Links created this session, reused while still usable.
  final Map<int, ShareLinkEntity> linksByScanId;
  final String? errorMessage;

  bool isCreating(int scanId) => creatingScanIds.contains(scanId);

  ShareLinkState copyWith({
    Set<int>? creatingScanIds,
    Map<int, ShareLinkEntity>? linksByScanId,
    Object? errorMessage = _noValue,
  }) {
    return ShareLinkState(
      creatingScanIds: creatingScanIds ?? this.creatingScanIds,
      linksByScanId: linksByScanId ?? this.linksByScanId,
      errorMessage: identical(errorMessage, _noValue)
          ? this.errorMessage
          : errorMessage as String?,
    );
  }

  @override
  List<Object?> get props => [creatingScanIds, linksByScanId, errorMessage];
}

const Object _noValue = Object();
