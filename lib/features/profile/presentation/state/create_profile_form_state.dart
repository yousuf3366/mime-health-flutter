import 'package:equatable/equatable.dart';

import '../../domain/entity/profile_entity.dart';

const Object noValue = Object();

enum ProfileSex { male, female }

enum ProfileLifestyle { active, moderate, inactive }

enum ProfileKind { self, family, other }

class CreateProfileFormState extends Equatable {
  const CreateProfileFormState({
    this.displayName,
    this.displayNameError,
    this.phone,
    this.phoneError,
    this.email,
    this.emailError,
    this.bloodGroup,
    this.bloodGroupError,
    this.heightFeet,
    this.heightFeetError,
    this.heightInches,
    this.heightInchesError,
    this.weightKg,
    this.weightKgError,
    this.dateOfBirth,
    this.dateOfBirthError,
    this.sex,
    this.sexError,
    this.lifestyle = ProfileLifestyle.moderate,
    this.lifestyleError,
    this.profileKind = ProfileKind.self,
    this.currentSmoker = false,
    this.diabetes = false,
    this.historyOfHypertension = false,
    this.historyOfHighGlucoseLevels = false,
    this.errorMessage,
    this.isSubmitting = false,
  });

  factory CreateProfileFormState.initial() => const CreateProfileFormState();

  final String? displayName;
  final String? displayNameError;
  final String? phone;
  final String? phoneError;
  final String? email;
  final String? emailError;
  final BloodGroup? bloodGroup;
  final String? bloodGroupError;
  final String? heightFeet;
  final String? heightFeetError;
  final String? heightInches;
  final String? heightInchesError;
  final String? weightKg;
  final String? weightKgError;
  final DateTime? dateOfBirth;
  final String? dateOfBirthError;
  final ProfileSex? sex;
  final String? sexError;
  final ProfileLifestyle lifestyle;
  final String? lifestyleError;
  final ProfileKind profileKind;
  final bool currentSmoker;
  final bool diabetes;
  final bool historyOfHypertension;
  final bool historyOfHighGlucoseLevels;
  final String? errorMessage;
  final bool isSubmitting;

  bool get isLoading => isSubmitting;

  CreateProfileFormState copyWith({
    Object? displayName = noValue,
    Object? displayNameError = noValue,
    Object? phone = noValue,
    Object? phoneError = noValue,
    Object? email = noValue,
    Object? emailError = noValue,
    Object? bloodGroup = noValue,
    Object? bloodGroupError = noValue,
    Object? heightFeet = noValue,
    Object? heightFeetError = noValue,
    Object? heightInches = noValue,
    Object? heightInchesError = noValue,
    Object? weightKg = noValue,
    Object? weightKgError = noValue,
    Object? dateOfBirth = noValue,
    Object? dateOfBirthError = noValue,
    Object? sex = noValue,
    Object? sexError = noValue,
    Object? lifestyle = noValue,
    Object? lifestyleError = noValue,
    Object? profileKind = noValue,
    Object currentSmoker = noValue,
    Object diabetes = noValue,
    Object historyOfHypertension = noValue,
    Object historyOfHighGlucoseLevels = noValue,
    Object? errorMessage = noValue,
    Object isSubmitting = noValue,
  }) {
    return CreateProfileFormState(
      displayName: identical(displayName, noValue)
          ? this.displayName
          : displayName as String?,
      displayNameError: identical(displayNameError, noValue)
          ? this.displayNameError
          : displayNameError as String?,
      phone: identical(phone, noValue) ? this.phone : phone as String?,
      phoneError: identical(phoneError, noValue)
          ? this.phoneError
          : phoneError as String?,
      email: identical(email, noValue) ? this.email : email as String?,
      emailError: identical(emailError, noValue)
          ? this.emailError
          : emailError as String?,
      bloodGroup: identical(bloodGroup, noValue)
          ? this.bloodGroup
          : bloodGroup as BloodGroup?,
      bloodGroupError: identical(bloodGroupError, noValue)
          ? this.bloodGroupError
          : bloodGroupError as String?,
      heightFeet: identical(heightFeet, noValue)
          ? this.heightFeet
          : heightFeet as String?,
      heightFeetError: identical(heightFeetError, noValue)
          ? this.heightFeetError
          : heightFeetError as String?,
      heightInches: identical(heightInches, noValue)
          ? this.heightInches
          : heightInches as String?,
      heightInchesError: identical(heightInchesError, noValue)
          ? this.heightInchesError
          : heightInchesError as String?,
      weightKg: identical(weightKg, noValue)
          ? this.weightKg
          : weightKg as String?,
      weightKgError: identical(weightKgError, noValue)
          ? this.weightKgError
          : weightKgError as String?,
      dateOfBirth: identical(dateOfBirth, noValue)
          ? this.dateOfBirth
          : dateOfBirth as DateTime?,
      dateOfBirthError: identical(dateOfBirthError, noValue)
          ? this.dateOfBirthError
          : dateOfBirthError as String?,
      sex: identical(sex, noValue) ? this.sex : sex as ProfileSex?,
      sexError: identical(sexError, noValue)
          ? this.sexError
          : sexError as String?,
      lifestyle: identical(lifestyle, noValue)
          ? this.lifestyle
          : lifestyle as ProfileLifestyle,
      lifestyleError: identical(lifestyleError, noValue)
          ? this.lifestyleError
          : lifestyleError as String?,
      profileKind: identical(profileKind, noValue)
          ? this.profileKind
          : profileKind as ProfileKind,
      currentSmoker: identical(currentSmoker, noValue)
          ? this.currentSmoker
          : currentSmoker as bool,
      diabetes: identical(diabetes, noValue) ? this.diabetes : diabetes as bool,
      historyOfHypertension: identical(historyOfHypertension, noValue)
          ? this.historyOfHypertension
          : historyOfHypertension as bool,
      historyOfHighGlucoseLevels: identical(historyOfHighGlucoseLevels, noValue)
          ? this.historyOfHighGlucoseLevels
          : historyOfHighGlucoseLevels as bool,
      errorMessage: identical(errorMessage, noValue)
          ? this.errorMessage
          : errorMessage as String?,
      isSubmitting: identical(isSubmitting, noValue)
          ? this.isSubmitting
          : isSubmitting as bool,
    );
  }

  @override
  List<Object?> get props => [
    displayName,
    displayNameError,
    phone,
    phoneError,
    email,
    emailError,
    bloodGroup,
    bloodGroupError,
    heightFeet,
    heightFeetError,
    heightInches,
    heightInchesError,
    weightKg,
    weightKgError,
    dateOfBirth,
    dateOfBirthError,
    sex,
    sexError,
    lifestyle,
    lifestyleError,
    profileKind,
    currentSmoker,
    diabetes,
    historyOfHypertension,
    historyOfHighGlucoseLevels,
    errorMessage,
    isSubmitting,
  ];
}
