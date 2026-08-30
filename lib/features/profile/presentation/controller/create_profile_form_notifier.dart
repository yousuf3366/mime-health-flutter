import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/localization/l10n_keys.dart';
import '../../../../core/providers/core_providers.dart';
import '../../../../core/router/route_names.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/services/dialog_service.dart';
import '../../../../core/services/snackbar_service.dart';
import '../../../../core/utils/validators.dart';
import '../../../language/presentation/provider/language_provider.dart';
import '../../../login/domain/entity/user_entity.dart';
import '../../../login/presentation/controller/login_form_notifier.dart';
import '../../../login/presentation/provider/login_di.dart';
import '../../../../core/widgets/app_date_picker.dart';
import '../../domain/entity/profile_entity.dart';
import '../provider/profile_di.dart';
import '../state/create_profile_form_state.dart';

class CreateProfileFormNotifier extends Notifier<CreateProfileFormState> {
  @override
  CreateProfileFormState build() => CreateProfileFormState.initial();

  DialogService get _dialog => ref.read(dialogServiceProvider);

  SnackbarService get _snackbar => ref.read(snackbarServiceProvider);

  void updateField({
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
    state = state.copyWith(
      displayName: displayName,
      displayNameError: displayNameError,
      phone: phone,
      phoneError: phoneError,
      email: email,
      emailError: emailError,
      bloodGroup: bloodGroup,
      bloodGroupError: bloodGroupError,
      heightFeet: heightFeet,
      heightFeetError: heightFeetError,
      heightInches: heightInches,
      heightInchesError: heightInchesError,
      weightKg: weightKg,
      weightKgError: weightKgError,
      dateOfBirth: dateOfBirth,
      dateOfBirthError: dateOfBirthError,
      sex: sex,
      sexError: sexError,
      lifestyle: lifestyle,
      lifestyleError: lifestyleError,
      profileKind: profileKind,
      currentSmoker: currentSmoker,
      diabetes: diabetes,
      historyOfHypertension: historyOfHypertension,
      historyOfHighGlucoseLevels: historyOfHighGlucoseLevels,
      errorMessage: errorMessage,
      isSubmitting: isSubmitting,
    );
  }

  void seedFromUser(UserEntity? user) {
    if (user == null) return;
    final name = user.name?.trim();
    final phone = user.phone.trim();
    final email = user.email?.trim();

    updateField(
      displayName:
          (state.displayName ?? '').trim().isEmpty &&
              name != null &&
              name.isNotEmpty
          ? name
          : noValue,
      displayNameError: null,
      phone: (state.phone ?? '').trim().isEmpty && phone.isNotEmpty
          ? phone
          : noValue,
      phoneError: null,
      email:
          (state.email ?? '').trim().isEmpty &&
              email != null &&
              email.isNotEmpty
          ? email
          : noValue,
      emailError: null,
    );
  }

  void seedFromProfile(ProfileEntity profile, {UserEntity? fallbackUser}) {
    state = CreateProfileFormState(
      displayName: profile.displayName,
      phone: (profile.phone ?? '').trim().isNotEmpty
          ? profile.phone
          : fallbackUser?.phone,
      email: (profile.email ?? '').trim().isNotEmpty
          ? profile.email
          : fallbackUser?.email,
      bloodGroup: BloodGroup.fromApiValue(profile.bloodGroup),
      heightFeet: profile.heightFeet?.toString(),
      heightInches: profile.heightInches?.toString(),
      weightKg: profile.weightKg?.toString(),
      dateOfBirth: DateTime.tryParse(profile.dateOfBirth),
      sex: switch (profile.sex.toLowerCase()) {
        AppConstants.profileSexMale => ProfileSex.male,
        AppConstants.profileSexFemale => ProfileSex.female,
        _ => null,
      },
      lifestyle: switch (profile.lifeStyle.toLowerCase()) {
        'active' => ProfileLifestyle.active,
        'inactive' => ProfileLifestyle.inactive,
        _ => ProfileLifestyle.moderate,
      },
      profileKind: switch (profile.profileKind.toLowerCase()) {
        AppConstants.profileKindFamily => ProfileKind.family,
        AppConstants.profileKindOther => ProfileKind.other,
        _ => ProfileKind.self,
      },
      currentSmoker: profile.currentSmoker,
      diabetes: profile.diabetes,
      historyOfHypertension: profile.historyOfHypertension,
      historyOfHighGlucoseLevels: profile.historyOfHighGlucoseLevels,
    );
  }

  void setDisplayName(String value) {
    final trimmed = value.trim();
    updateField(
      displayName: value,
      displayNameError: trimmed.isEmpty ? 'Display name is required' : null,
      errorMessage: null,
    );
  }

  void setPhone(String value) {
    updateField(
      phone: value,
      phoneError: Validators.optionalPhone(value),
      errorMessage: null,
    );
  }

  void setEmail(String value) {
    updateField(
      email: value,
      emailError: Validators.optionalEmail(value),
      errorMessage: null,
    );
  }

  void setBloodGroup(BloodGroup? value) {
    updateField(
      bloodGroup: value,
      bloodGroupError: value == null ? 'Blood group is required' : null,
      errorMessage: null,
    );
  }

  void setHeightFeet(String value) {
    updateField(
      heightFeet: value,
      heightFeetError: _validateHeightFeet(value),
      errorMessage: null,
    );
  }

  void setHeightInches(String value) {
    updateField(
      heightInches: value,
      heightInchesError: _validateHeightInches(value),
      errorMessage: null,
    );
  }

  void setWeightKg(String value) {
    updateField(
      weightKg: value,
      weightKgError: _validateWeight(value),
      errorMessage: null,
    );
  }

  void setDateOfBirth(DateTime? value) {
    updateField(
      dateOfBirth: value,
      dateOfBirthError: value == null ? 'Date of birth is required' : null,
      errorMessage: null,
    );
  }

  void setSex(ProfileSex value) {
    updateField(sex: value, sexError: null, errorMessage: null);
  }

  void setLifestyle(ProfileLifestyle value) {
    updateField(lifestyle: value, lifestyleError: null, errorMessage: null);
  }

  void setProfileKind(ProfileKind value) {
    updateField(profileKind: value, errorMessage: null);
  }

  void setCurrentSmoker(bool value) {
    updateField(currentSmoker: value, errorMessage: null);
  }

  void setDiabetes(bool value) {
    updateField(diabetes: value, errorMessage: null);
  }

  void setHistoryOfHypertension(bool value) {
    updateField(historyOfHypertension: value, errorMessage: null);
  }

  void setHistoryOfHighGlucoseLevels(bool value) {
    updateField(historyOfHighGlucoseLevels: value, errorMessage: null);
  }

  void resetState() {
    state = CreateProfileFormState.initial();
  }

  bool validate() {
    final displayName = (state.displayName ?? '').trim();
    final displayNameError = displayName.isEmpty
        ? 'Display name is required'
        : null;
    final phoneError = Validators.optionalPhone(state.phone);
    final emailError = Validators.optionalEmail(state.email);
    final bloodGroupError = state.bloodGroup == null
        ? 'Blood group is required'
        : null;
    final heightFeetError = _validateHeightFeet(state.heightFeet);
    final heightInchesError = _validateHeightInches(state.heightInches);
    final weightKgError = _validateWeight(state.weightKg);
    final dateOfBirthError = state.dateOfBirth == null
        ? 'Date of birth is required'
        : null;
    final sexError = state.sex == null ? 'Sex is required' : null;

    updateField(
      displayNameError: displayNameError,
      phoneError: phoneError,
      emailError: emailError,
      bloodGroupError: bloodGroupError,
      heightFeetError: heightFeetError,
      heightInchesError: heightInchesError,
      weightKgError: weightKgError,
      dateOfBirthError: dateOfBirthError,
      sexError: sexError,
      lifestyleError: null,
      errorMessage: null,
    );

    return displayNameError == null &&
        phoneError == null &&
        emailError == null &&
        bloodGroupError == null &&
        heightFeetError == null &&
        heightInchesError == null &&
        weightKgError == null &&
        dateOfBirthError == null &&
        sexError == null;
  }

  String? _validateHeightFeet(String? feetValue) {
    final feet = (feetValue ?? '').trim();
    if (feet.isEmpty) return 'Height in feet is required';

    final parsed = int.tryParse(feet);
    if (parsed == null || parsed < 1 || parsed > 9) {
      return 'Enter feet between 1 and 9';
    }
    return null;
  }

  String? _validateHeightInches(String? inchesValue) {
    final inches = (inchesValue ?? '').trim();
    if (inches.isEmpty) return null;

    final parsed = int.tryParse(inches);
    if (parsed == null || parsed < 0 || parsed > 11) {
      return 'Enter inches between 0 and 11';
    }
    return null;
  }

  String? _validateWeight(String? value) {
    final text = (value ?? '').trim();
    if (text.isEmpty) return 'Weight is required';

    final parsed = int.tryParse(text);
    if (parsed == null || parsed <= 0 || parsed > 500) {
      return 'Enter a valid weight in kg';
    }
    return null;
  }

  ProfileDraftEntity? _toDraft() {
    final dob = state.dateOfBirth;
    final sex = state.sex;
    final displayName = (state.displayName ?? '').trim();
    if (dob == null || sex == null || displayName.isEmpty) return null;

    final dateOfBirth = AppDatePicker.formatForServer(dob)!;

    return ProfileDraftEntity(
      profileKind: switch (state.profileKind) {
        ProfileKind.self => AppConstants.profileKindSelf,
        ProfileKind.family => AppConstants.profileKindFamily,
        ProfileKind.other => AppConstants.profileKindOther,
      },
      displayName: displayName,
      phone: (state.phone ?? '').trim().isEmpty
          ? null
          : state.phone!.trim().replaceAll(RegExp(r'[\s-]'), ''),
      email: (state.email ?? '').trim().isEmpty ? null : state.email!.trim(),
      dateOfBirth: dateOfBirth,
      sex: switch (sex) {
        ProfileSex.male => AppConstants.profileSexMale,
        ProfileSex.female => AppConstants.profileSexFemale,
      },
      lifeStyle: switch (state.lifestyle) {
        ProfileLifestyle.active => AppConstants.profileLifestyleActive,
        ProfileLifestyle.moderate => AppConstants.profileLifestyleModerate,
        ProfileLifestyle.inactive => AppConstants.profileLifestyleInactive,
      },
      bloodGroup: state.bloodGroup?.apiValue,
      heightFeet: int.tryParse((state.heightFeet ?? '').trim()),
      heightInches: int.tryParse((state.heightInches ?? '').trim()),
      weightKg: int.tryParse((state.weightKg ?? '').trim()),
      currentSmoker: state.currentSmoker,
      diabetes: state.diabetes,
      historyOfHypertension: state.historyOfHypertension,
      historyOfHighGlucoseLevels: state.historyOfHighGlucoseLevels,
      privacyLevel: AppConstants.profilePrivacyFullSharing,
    );
  }

  Future<bool> submit({ProfileEntity? profile}) async {
    if (!validate()) {
      _snackbar.showError('Please fill all required fields');
      return false;
    }

    final draft = _toDraft();
    if (draft == null) return false;

    updateField(isSubmitting: true, errorMessage: null);
    _dialog.showLoading();

    final result = profile == null
        ? await ref.read(createProfileUseCaseProvider).call(draft)
        : await ref.read(updateProfileUseCaseProvider).call(profile.id, draft);
    _dialog.hideLoading();
    updateField(isSubmitting: false);

    return result.when(
      success: (created) {
        _snackbar.showSuccess(created.message);
        return true;
      },
      failure: (error) {
        updateField(errorMessage: error.message);
        _snackbar.showError(error.message);
        return false;
      },
    );
  }

  Future<void> logout(BuildContext context) async {
    final l10n = ref.read(languageControllerProvider);
    final confirmed = await _dialog.confirmationDialog(
      title: l10n.t(L10nKeys.logoutConfirmTitle),
      message: l10n.t(L10nKeys.logoutConfirmMessage),
      confirmLabel: l10n.t(L10nKeys.logout),
      isDestructive: true,
    );

    if (!confirmed) return;

    _dialog.showLoading();
    final result = await ref.read(logoutUseCaseProvider).call();
    _dialog.hideLoading();

    result.when(
      success: (_) {
        resetState();
        ref.read(loginFormNotifierProvider.notifier).resetState();
        _snackbar.showInfo(l10n.t(L10nKeys.logout));
        if (context.mounted) context.go(RouteNames.login);
      },
      failure: (error) {
        _snackbar.showError(error.message);
      },
    );
  }
}

final createProfileFormNotifierProvider =
    NotifierProvider<CreateProfileFormNotifier, CreateProfileFormState>(
      CreateProfileFormNotifier.new,
    );
