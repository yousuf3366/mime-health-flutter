class CreateProfileRequestModel {
  const CreateProfileRequestModel({
    required this.profileKind,
    required this.displayName,
    required this.dateOfBirth,
    required this.sex,
    required this.lifeStyle,
    this.phone,
    this.email,
    this.bloodGroup,
    this.heightFeet,
    this.heightInches,
    this.weightKg,
    this.currentSmoker,
    this.diabetes,
    this.historyOfHypertension,
    this.historyOfHighGlucoseLevels,
    this.privacyLevel = 'full_sharing',
  });

  final String profileKind;
  final String displayName;
  final String dateOfBirth;
  final String sex;
  final String lifeStyle;
  final String? phone;
  final String? email;
  final String? bloodGroup;
  final int? heightFeet;
  final int? heightInches;
  final int? weightKg;
  final bool? currentSmoker;
  final bool? diabetes;
  final bool? historyOfHypertension;
  final bool? historyOfHighGlucoseLevels;
  final String privacyLevel;

  Map<String, dynamic> toJson() => {
    'profile_kind': profileKind,
    'display_name': displayName,
    'date_of_birth': dateOfBirth,
    'sex': sex,
    'life_style': lifeStyle,
    if (phone != null) 'phone': phone,
    if (email != null) 'email': email,
    if (bloodGroup != null) 'blood_group': bloodGroup,
    if (heightFeet != null) 'height_ft': heightFeet,
    if (heightInches != null) 'height_in': heightInches,
    if (weightKg != null) 'weight_kg': weightKg,
    if (currentSmoker != null) 'current_smoker': currentSmoker,
    if (diabetes != null) 'diabetes': diabetes,
    if (historyOfHypertension != null)
      'history_of_hypertension': historyOfHypertension,
    if (historyOfHighGlucoseLevels != null)
      'history_of_high_glucose_levels': historyOfHighGlucoseLevels,
    'privacy_level': privacyLevel,
  };
}

class CreateProfileResponseModel {
  const CreateProfileResponseModel({this.id, this.message = 'Profile created'});

  final String? id;
  final String message;

  factory CreateProfileResponseModel.fromJson(Map<String, dynamic> json) {
    final data = _unwrapDataMap(json);
    return CreateProfileResponseModel(
      id: data['id']?.toString() ?? json['id']?.toString(),
      message:
          json['message']?.toString() ??
          data['message']?.toString() ??
          'Profile created',
    );
  }
}

class UploadAvatarResponseModel {
  const UploadAvatarResponseModel({
    this.avatarPath,
    this.message = 'Avatar uploaded successfully.',
  });

  final String? avatarPath;
  final String message;

  factory UploadAvatarResponseModel.fromJson(Map<String, dynamic> json) {
    final data = _unwrapDataMap(json);
    return UploadAvatarResponseModel(
      avatarPath:
          data['avatar_path']?.toString() ??
          data['avatar_url']?.toString() ??
          data['url']?.toString() ??
          json['avatar_path']?.toString(),
      message:
          json['message']?.toString() ??
          data['message']?.toString() ??
          'Avatar uploaded successfully.',
    );
  }
}

class ProfileModel {
  const ProfileModel({
    required this.id,
    required this.displayName,
    required this.dateOfBirth,
    required this.sex,
    required this.lifeStyle,
    required this.profileKind,
    this.userId,
    this.householdId,
    this.phone,
    this.email,
    this.bloodGroup,
    this.heightFeet,
    this.heightInches,
    this.weightKg,
    this.currentSmoker = false,
    this.diabetes = false,
    this.historyOfHypertension = false,
    this.historyOfHighGlucoseLevels = false,
    this.isMinor = false,
    this.privacyLevel,
    this.status,
    this.avatarPath,
  });

  final int id;
  final int? userId;
  final int? householdId;
  final String displayName;
  final String dateOfBirth;
  final String sex;
  final String lifeStyle;
  final String profileKind;
  final String? phone;
  final String? email;
  final String? bloodGroup;
  final int? heightFeet;
  final int? heightInches;
  final int? weightKg;
  final bool currentSmoker;
  final bool diabetes;
  final bool historyOfHypertension;
  final bool historyOfHighGlucoseLevels;
  final bool isMinor;
  final String? privacyLevel;
  final String? status;
  final String? avatarPath;

  factory ProfileModel.fromJson(Map<String, dynamic> json) {
    final user = _asMap(json['user']);
    final contact = _asMap(json['contact']);

    return ProfileModel(
      id: _asInt(json['id']) ?? 0,
      userId: _asInt(json['user_id']),
      householdId: _asInt(json['household_id']),
      displayName: json['display_name']?.toString() ?? '',
      dateOfBirth: json['date_of_birth']?.toString() ?? '',
      sex: json['sex']?.toString() ?? '',
      lifeStyle: json['life_style']?.toString() ?? '',
      profileKind: json['profile_kind']?.toString() ?? '',
      phone: _firstNonEmptyString([
        json['phone'],
        json['phone_number'],
        json['mobile'],
        json['mobile_number'],
        json['contact_phone'],
        contact['phone'],
        contact['phone_number'],
        user['phone'],
        user['phone_number'],
      ]),
      email: _firstNonEmptyString([
        json['email'],
        json['email_address'],
        json['contact_email'],
        contact['email'],
        contact['email_address'],
        user['email'],
        user['email_address'],
      ]),
      bloodGroup: json['blood_group']?.toString(),
      heightFeet: _asInt(json['height_ft']),
      heightInches: _asInt(json['height_in']),
      weightKg: _asInt(json['weight_kg']),
      currentSmoker: json['current_smoker'] == true,
      diabetes: json['diabetes'] == true,
      historyOfHypertension: json['history_of_hypertension'] == true,
      historyOfHighGlucoseLevels:
          json['history_of_high_glucose_levels'] == true,
      isMinor: json['is_minor'] == true,
      privacyLevel: json['privacy_level']?.toString(),
      status: json['status']?.toString(),
      avatarPath:
          json['avatar_path']?.toString() ??
          json['avatar_url']?.toString() ??
          json['avatar']?.toString(),
    );
  }
}

class ProfilesListResponseModel {
  const ProfilesListResponseModel({
    required this.profiles,
    this.message = 'Profiles retrieved successfully.',
  });

  final List<ProfileModel> profiles;
  final String message;

  factory ProfilesListResponseModel.fromJson(Map<String, dynamic> json) {
    final raw = json['data'];
    final list = <ProfileModel>[];
    if (raw is List) {
      for (final item in raw) {
        if (item is Map) {
          list.add(ProfileModel.fromJson(Map<String, dynamic>.from(item)));
        }
      }
    }
    return ProfilesListResponseModel(
      profiles: list,
      message:
          json['message']?.toString() ?? 'Profiles retrieved successfully.',
    );
  }
}

Map<String, dynamic> _unwrapDataMap(Map<String, dynamic> json) {
  final data = json['data'];
  if (data is Map) return Map<String, dynamic>.from(data);
  return json;
}

int? _asInt(dynamic value) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  return int.tryParse(value?.toString() ?? '');
}

Map<String, dynamic> _asMap(dynamic value) {
  if (value is Map) return Map<String, dynamic>.from(value);
  return const {};
}

String? _firstNonEmptyString(Iterable<dynamic> values) {
  for (final value in values) {
    final text = value?.toString().trim();
    if (text != null && text.isNotEmpty) return text;
  }
  return null;
}
