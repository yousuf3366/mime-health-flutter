import 'package:equatable/equatable.dart';

/// A shareable public link to one scan result (`POST /share-links`).
class ShareLinkEntity extends Equatable {
  const ShareLinkEntity({
    required this.id,
    required this.profileId,
    required this.scanId,
    required this.isActive,
    required this.copyLink,
    this.expiresAt,
  });

  final int id;
  final int profileId;
  final int scanId;
  final bool isActive;

  /// The URL to share.
  final String copyLink;
  final DateTime? expiresAt;

  /// Still usable: active and not past [expiresAt].
  bool get isUsable =>
      isActive &&
      copyLink.isNotEmpty &&
      (expiresAt == null || expiresAt!.isAfter(DateTime.now()));

  @override
  List<Object?> get props => [
    id,
    profileId,
    scanId,
    isActive,
    copyLink,
    expiresAt,
  ];
}
