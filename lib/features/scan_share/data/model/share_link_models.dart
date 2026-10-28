/// Request body of `POST /share-links`.
class CreateShareLinkRequestModel {
  const CreateShareLinkRequestModel({
    required this.profileId,
    required this.scanId,
  });

  final int profileId;
  final int scanId;

  Map<String, dynamic> toJson() => {'profile_id': profileId, 'scan_id': scanId};
}

/// Response of `POST /share-links`.
class CreateShareLinkResponseModel {
  const CreateShareLinkResponseModel({
    required this.success,
    required this.message,
    this.data,
    this.errors = const [],
  });

  final bool success;
  final String message;
  final ShareLinkModel? data;
  final List<String> errors;

  factory CreateShareLinkResponseModel.fromJson(Map<String, dynamic> json) {
    final data = json['data'];
    final errors = json['errors'];
    return CreateShareLinkResponseModel(
      success: json['success'] == true,
      message: json['message']?.toString() ?? '',
      data: data is Map
          ? ShareLinkModel.fromJson(Map<String, dynamic>.from(data))
          : null,
      errors: errors is List
          ? errors.map((e) => e.toString()).toList(growable: false)
          : const [],
    );
  }
}

/// `data` of the create-share-link response.
class ShareLinkModel {
  const ShareLinkModel({
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
  final String copyLink;
  final String? expiresAt;

  factory ShareLinkModel.fromJson(Map<String, dynamic> json) {
    return ShareLinkModel(
      id: _asInt(json['id']) ?? 0,
      profileId: _asInt(json['profile_id']) ?? 0,
      scanId: _asInt(json['scan_id']) ?? 0,
      isActive: json['is_active'] == true,
      copyLink: json['copy_link']?.toString().trim() ?? '',
      expiresAt: _asNullableString(json['expires_at']),
    );
  }
}

int? _asInt(Object? value) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  return int.tryParse(value?.toString() ?? '');
}

String? _asNullableString(Object? value) {
  final text = value?.toString().trim();
  return text == null || text.isEmpty ? null : text;
}
