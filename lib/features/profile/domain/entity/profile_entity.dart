import 'package:equatable/equatable.dart';

enum BloodGroup {
  aPositive('A+'),
  aNegative('A-'),
  bPositive('B+'),
  bNegative('B-'),
  abPositive('AB+'),
  abNegative('AB-'),
  oPositive('O+'),
  oNegative('O-'),
  unknown('Unknown');

  const BloodGroup(this.apiValue);

  final String apiValue;

  static BloodGroup? fromApiValue(String? value) {
    for (final bloodGroup in values) {
      if (bloodGroup.apiValue == value) return bloodGroup;
    }
    return null;
  }
}

/// Draft used to create a health profile.
class ProfileDraftEntity extends Equatable {
  const ProfileDraftEntity({
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

  /// Mandatory. Defaults to `self`.
  final String profileKind;

  /// Mandatory.
  final String displayName;

  final String? phone;
  final String? email;

  /// Mandatory. Format `yyyy-MM-dd`.
  final String dateOfBirth;

  /// Mandatory. `male` | `female`.
  final String sex;

  /// Mandatory. e.g. `Active`, `Moderate`, `Inactive`.
  final String lifeStyle;

  final String? bloodGroup;
  final int? heightFeet;
  final int? heightInches;
  final int? weightKg;
  final bool? currentSmoker;
  final bool? diabetes;
  final bool? historyOfHypertension;
  final bool? historyOfHighGlucoseLevels;
  final String privacyLevel;

  @override
  List<Object?> get props => [
    profileKind,
    displayName,
    phone,
    email,
    dateOfBirth,
    sex,
    lifeStyle,
    bloodGroup,
    heightFeet,
    heightInches,
    weightKg,
    currentSmoker,
    diabetes,
    historyOfHypertension,
    historyOfHighGlucoseLevels,
    privacyLevel,
  ];
}

/// Existing health profile returned by `GET /profiles`.
class ProfileEntity extends Equatable {
  const ProfileEntity({
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

  @override
  List<Object?> get props => [
    id,
    userId,
    householdId,
    displayName,
    dateOfBirth,
    sex,
    lifeStyle,
    profileKind,
    phone,
    email,
    bloodGroup,
    heightFeet,
    heightInches,
    weightKg,
    currentSmoker,
    diabetes,
    historyOfHypertension,
    historyOfHighGlucoseLevels,
    isMinor,
    privacyLevel,
    status,
    avatarPath,
  ];
}

/// Result returned after a successful create-profile call.
class CreateProfileResult extends Equatable {
  const CreateProfileResult({this.id, this.message = 'Profile created'});

  final String? id;
  final String message;

  @override
  List<Object?> get props => [id, message];
}

/// Result returned after uploading a profile avatar.
class UploadAvatarResult extends Equatable {
  const UploadAvatarResult({
    this.avatarPath,
    this.message = 'Avatar uploaded successfully.',
  });

  final String? avatarPath;
  final String message;

  @override
  List<Object?> get props => [avatarPath, message];
}
