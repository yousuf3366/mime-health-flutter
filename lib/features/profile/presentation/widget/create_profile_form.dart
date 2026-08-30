import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:mime_health/core/extensions/context_extensions.dart';
import 'package:mime_health/core/widgets/app_button.dart';
import 'package:mime_health/core/widgets/app_date_picker.dart';
import 'package:mime_health/core/widgets/app_dropdown_field.dart';
import 'package:mime_health/core/widgets/app_text_field1.dart';

import '../../../../core/localization/l10n_keys.dart';
import '../../../../core/router/route_names.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../language/presentation/provider/language_provider.dart';
import '../../../login/domain/entity/user_entity.dart';
import '../../domain/entity/profile_entity.dart';
import '../provider/profile_provider.dart';

class CreateProfileForm extends HookConsumerWidget {
  const CreateProfileForm({super.key, this.profile});

  final ProfileEntity? profile;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = ref.watch(languageControllerProvider);
    final formState = ref.watch(createProfileFormNotifierProvider);
    final formNotifier = ref.read(createProfileFormNotifierProvider.notifier);
    final userAsync = ref.watch(currentUserProvider);
    final isEditing = profile != null;

    useEffect(() {
      Future.microtask(() {
        if (profile != null) {
          formNotifier.seedFromProfile(
            profile!,
            fallbackUser: userAsync.asData?.value,
          );
        } else {
          formNotifier.resetState();
          formNotifier.seedFromUser(userAsync.asData?.value);
        }
      });
      return null;
    }, [profile?.id, userAsync.asData?.value?.id]);

    ref.listen(currentUserProvider, (previous, next) {
      if (!isEditing) {
        next.whenData(formNotifier.seedFromUser);
      }
    });

    return Stack(
      children: [
        userAsync.when(
          loading: () => const Center(
            child: CircularProgressIndicator(color: AppColors.primaryContainer),
          ),
          error: (error, _) => Center(
            child: Text(
              '$error',
              style: const TextStyle(color: AppColors.textPrimary),
            ),
          ),
          data: (user) => Column(
            children: [
              _CreateProfileTopBar(
                onBack: () {
                  if (context.canPop()) {
                    context.pop();
                  } else {
                    context.go(RouteNames.home);
                  }
                },
                onClose: () => formNotifier.logout(context),
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: EdgeInsets.fromLTRB(
                    context.defaultPaddingSc,
                    0,
                    context.defaultPaddingSc,
                    context.scaleHeight(140),
                  ),
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 512),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _WelcomeHeader(
                          user: user,
                          l10nWelcome: l10n.t(L10nKeys.homeWelcome),
                        ),
                        SizedBox(height: context.scaleHeight(8)),
                        Text(
                          l10n.t(
                            isEditing
                                ? L10nKeys.profileEdit
                                : L10nKeys.homeCreateProfile,
                          ),
                          style: TextStyle(
                            color: AppColors.primaryContainer,
                            fontSize: context.bodyFontSize,
                            fontWeight: FontWeight.w700,
                            height: 1.25,
                          ),
                        ),
                        SizedBox(height: context.scaleHeight(24)),
                        AppTextField1(
                          label: l10n.t(L10nKeys.homeDisplayName),
                          initialValue: formState.displayName,
                          mandatory: true,
                          errorText: formState.displayNameError,
                          onChanged: formNotifier.setDisplayName,
                        ),
                        SizedBox(height: context.defaultPaddingSc),
                        AppTextField1(
                          label: l10n.t(L10nKeys.profilePhone),
                          initialValue: formState.phone,
                          keyboardType: TextInputType.phone,
                          errorText: formState.phoneError,
                          onChanged: formNotifier.setPhone,
                        ),
                        SizedBox(height: context.defaultPaddingSc),
                        AppTextField1(
                          label: l10n.t(L10nKeys.profileEmail),
                          initialValue: formState.email,
                          keyboardType: TextInputType.emailAddress,
                          errorText: formState.emailError,
                          onChanged: formNotifier.setEmail,
                        ),
                        SizedBox(height: context.defaultPaddingSc),
                        AppDropdownField<BloodGroup>(
                          label: l10n.t(L10nKeys.profileBloodGroup),
                          value: formState.bloodGroup,
                          items: BloodGroup.values,
                          itemLabelBuilder: (item) => item.apiValue,
                          mandatory: true,
                          errorText: formState.bloodGroupError,
                          onChanged: formNotifier.setBloodGroup,
                        ),
                        SizedBox(height: context.defaultPaddingSc),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: AppTextField1(
                                label: l10n.t(L10nKeys.profileHeightFeet),
                                initialValue: formState.heightFeet,
                                mandatory: true,
                                keyboardType: TextInputType.number,
                                errorText: formState.heightFeetError,
                                onChanged: formNotifier.setHeightFeet,
                              ),
                            ),
                            SizedBox(width: context.defaultPaddingSc),
                            Expanded(
                              child: AppTextField1(
                                label: l10n.t(L10nKeys.profileHeightInches),
                                initialValue: formState.heightInches,
                                keyboardType: TextInputType.number,
                                errorText: formState.heightInchesError,
                                onChanged: formNotifier.setHeightInches,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: context.defaultPaddingSc),
                        AppTextField1(
                          label: l10n.t(L10nKeys.profileWeightKg),
                          initialValue: formState.weightKg,
                          mandatory: true,
                          keyboardType: TextInputType.number,
                          errorText: formState.weightKgError,
                          onChanged: formNotifier.setWeightKg,
                        ),
                        SizedBox(height: context.defaultPaddingSc),
                        AppDatePicker(
                          label: l10n.t(L10nKeys.homeDateOfBirth),
                          selectedDate: formState.dateOfBirth,
                          mandatory: true,
                          errorText: formState.dateOfBirthError,
                          firstDate: DateTime(1900),
                          lastDate: DateTime.now(),
                          onChanged: formNotifier.setDateOfBirth,
                        ),
                        SizedBox(height: context.defaultPaddingSc),
                        _GlassCard(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _SectionLabel(l10n.t(L10nKeys.homeGender)),
                              SizedBox(height: 10),
                              Row(
                                children: [
                                  Expanded(
                                    child: _PillOption(
                                      label: l10n.t(L10nKeys.homeMale),
                                      selected:
                                          formState.sex == ProfileSex.male,
                                      onTap: () =>
                                          formNotifier.setSex(ProfileSex.male),
                                    ),
                                  ),
                                  SizedBox(width: context.defaultPaddingSc),
                                  Expanded(
                                    child: _PillOption(
                                      label: l10n.t(L10nKeys.homeFemale),
                                      selected:
                                          formState.sex == ProfileSex.female,
                                      onTap: () => formNotifier.setSex(
                                        ProfileSex.female,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              if (formState.sexError != null) ...[
                                SizedBox(height: context.scaleHeight(8)),
                                Text(
                                  formState.sexError!,
                                  style: TextStyle(
                                    color: AppColors.error,
                                    fontSize: context.smallFontSize,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                        SizedBox(height: context.defaultPaddingSc),
                        _GlassCard(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _SectionLabel(l10n.t(L10nKeys.homeLifestyle)),
                              SizedBox(height: 10),
                              Row(
                                children: [
                                  Expanded(
                                    child: _LifestyleCard(
                                      icon: Icons.directions_walk,
                                      label: l10n.t(L10nKeys.homeActive),
                                      selected:
                                          formState.lifestyle ==
                                          ProfileLifestyle.active,
                                      onTap: () => formNotifier.setLifestyle(
                                        ProfileLifestyle.active,
                                      ),
                                    ),
                                  ),
                                  SizedBox(width: context.defaultPaddingSc),
                                  Expanded(
                                    child: _LifestyleCard(
                                      icon: Icons.directions_run,
                                      label: l10n.t(L10nKeys.homeModerate),
                                      selected:
                                          formState.lifestyle ==
                                          ProfileLifestyle.moderate,
                                      filledIcon: true,
                                      onTap: () => formNotifier.setLifestyle(
                                        ProfileLifestyle.moderate,
                                      ),
                                    ),
                                  ),
                                  SizedBox(width: context.defaultPaddingSc),
                                  Expanded(
                                    child: _LifestyleCard(
                                      icon: Icons.airline_seat_recline_normal,
                                      label: l10n.t(L10nKeys.homeInactive),
                                      selected:
                                          formState.lifestyle ==
                                          ProfileLifestyle.inactive,
                                      onTap: () => formNotifier.setLifestyle(
                                        ProfileLifestyle.inactive,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: context.defaultPaddingSc),
                        Row(
                          children: [
                            Expanded(
                              child: _PillOption(
                                label: l10n.t(L10nKeys.homeSelf),
                                selected:
                                    formState.profileKind == ProfileKind.self,
                                emphasizeSelected: true,
                                onTap: () => formNotifier.setProfileKind(
                                  ProfileKind.self,
                                ),
                              ),
                            ),
                            SizedBox(width: context.defaultPaddingSc),
                            Expanded(
                              child: _PillOption(
                                label: l10n.t(L10nKeys.homeFamily),
                                selected:
                                    formState.profileKind == ProfileKind.family,
                                emphasizeSelected: true,
                                onTap: () => formNotifier.setProfileKind(
                                  ProfileKind.family,
                                ),
                              ),
                            ),
                            SizedBox(width: context.defaultPaddingSc),
                            Expanded(
                              child: _PillOption(
                                label: l10n.t(L10nKeys.homeOther),
                                selected:
                                    formState.profileKind == ProfileKind.other,
                                emphasizeSelected: true,
                                onTap: () => formNotifier.setProfileKind(
                                  ProfileKind.other,
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: context.defaultPaddingSc),
                        _GlassCard(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _SectionLabel(
                                l10n.t(L10nKeys.homeWellBeingTitle),
                              ),
                              SizedBox(height: context.scaleHeight(8)),
                              _IndicatorSwitch(
                                label: l10n.t(L10nKeys.homeSmoker),
                                value: formState.currentSmoker,
                                onChanged: formNotifier.setCurrentSmoker,
                              ),
                              _IndicatorSwitch(
                                label: l10n.t(L10nKeys.homeDiabetes),
                                value: formState.diabetes,
                                onChanged: formNotifier.setDiabetes,
                              ),
                              _IndicatorSwitch(
                                label: l10n.t(L10nKeys.homeHypertension),
                                value: formState.historyOfHypertension,
                                onChanged:
                                    formNotifier.setHistoryOfHypertension,
                              ),
                              _IndicatorSwitch(
                                label: l10n.t(L10nKeys.homeHighGlucose),
                                value: formState.historyOfHighGlucoseLevels,
                                onChanged:
                                    formNotifier.setHistoryOfHighGlucoseLevels,
                              ),
                            ],
                          ),
                        ),
                        if (formState.errorMessage != null) ...[
                          SizedBox(height: context.scaleHeight(12)),
                          Text(
                            formState.errorMessage!,
                            style: TextStyle(
                              color: AppColors.error,
                              fontSize: context.scaleWidth(13),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        Positioned(
          left: context.defaultPaddingSc,
          right: context.defaultPaddingSc,
          bottom:
              MediaQuery.paddingOf(context).bottom + context.defaultPaddingSc,
          child: AppButton(
            label: l10n.t(
              isEditing ? L10nKeys.profileEdit : L10nKeys.homeStartScan,
            ),
            btnStyle: AppButtonStyle.primary,
            isLoading: formState.isLoading,
            onPressed: formState.isLoading
                ? null
                : () async {
                    final ok = await formNotifier.submit(profile: profile);
                    if (ok && context.mounted) {
                      ref.invalidate(profilesProvider);
                      if (isEditing && context.canPop()) {
                        context.pop();
                      } else if (isEditing) {
                        context.go(RouteNames.home);
                      } else {
                        context.go(RouteNames.faceScan);
                      }
                    }
                  },
          ),
        ),
      ],
    );
  }
}

class _CreateProfileTopBar extends StatelessWidget {
  const _CreateProfileTopBar({required this.onBack, required this.onClose});

  final VoidCallback onBack;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          context.scaleWidth(8),
          context.scaleHeight(8),
          context.scaleWidth(8),
          context.defaultPaddingSc,
        ),
        child: Row(
          children: [
            IconButton(
              onPressed: onBack,
              icon: const Icon(Icons.arrow_back),
              color: AppColors.primaryContainer,
            ),
            const Spacer(),
            Visibility(
              visible: false,
              child: IconButton(
                onPressed: onClose,
                icon: const Icon(Icons.close),
                color: AppColors.primaryContainer,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _WelcomeHeader extends StatelessWidget {
  const _WelcomeHeader({required this.user, required this.l10nWelcome});

  final UserEntity? user;
  final String l10nWelcome;

  @override
  Widget build(BuildContext context) {
    final name = (user?.displayName ?? 'User').toUpperCase();
    final phone = user?.phone ?? '';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text.rich(
          TextSpan(
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: context.scaleWidth(24),
              fontWeight: FontWeight.w700,
              height: 1.33,
              letterSpacing: 0.4,
            ),
            children: [
              TextSpan(text: '${l10nWelcome.toUpperCase()} '),
              TextSpan(
                text: name,
                style: const TextStyle(fontWeight: FontWeight.w800),
              ),
            ],
          ),
        ),
        if (phone.isNotEmpty) ...[
          SizedBox(height: context.scaleHeight(4)),
          Text(
            phone,
            style: TextStyle(
              color: AppColors.textSecondary.withValues(alpha: 0.8),
              fontSize: context.fontSize,
              height: 1.4,
            ),
          ),
        ],
      ],
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text.toUpperCase(),
      style: TextStyle(
        color: AppColors.textPrimary.withValues(alpha: 0.7),
        fontSize: context.smallFontSize,
        fontWeight: FontWeight.w700,
        letterSpacing: 0.6,
        height: 1.33,
      ),
    );
  }
}

class _GlassCard extends StatelessWidget {
  const _GlassCard({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(context.scaleWidth(20)),
      decoration: BoxDecoration(
        color: AppColors.glass,
        borderRadius: BorderRadius.circular(context.scaleWidth(20)),
        border: Border.all(color: AppColors.glassBorder),
      ),
      child: child,
    );
  }
}

class _IndicatorSwitch extends StatelessWidget {
  const _IndicatorSwitch({
    required this.label,
    required this.value,
    required this.onChanged,
  });

  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: context.scaleHeight(4)),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: context.scaleWidth(15),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Switch.adaptive(
            value: value,
            onChanged: onChanged,
            activeThumbColor: AppColors.primaryContainer,
            activeTrackColor: AppColors.pillSelected.withValues(alpha: 0.9),
            inactiveThumbColor: AppColors.textPrimary,
            inactiveTrackColor: AppColors.primaryContainer,
          ),
        ],
      ),
    );
  }
}

class _PillOption extends StatelessWidget {
  const _PillOption({
    required this.label,
    required this.selected,
    required this.onTap,
    this.emphasizeSelected = false,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;
  final bool emphasizeSelected;

  @override
  Widget build(BuildContext context) {
    final textColor = selected
        ? AppColors.textPrimary
        : (emphasizeSelected ? AppColors.textSecondary : AppColors.textPrimary);

    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(999),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(999),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          height: context.scaleHeight(40),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(999),
            color: selected ? AppColors.pillSelected : AppColors.surfaceLow,
            border: Border.all(
              color: selected ? Colors.transparent : AppColors.outlineVariant,
            ),
          ),
          child: Text(
            label,
            style: TextStyle(
              color: textColor,
              fontSize: context.bodyFontSize,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ),
    );
  }
}

class _LifestyleCard extends StatelessWidget {
  const _LifestyleCard({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
    this.filledIcon = false,
  });

  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;
  final bool filledIcon;

  @override
  Widget build(BuildContext context) {
    final bg = selected ? AppColors.pillSelected : AppColors.surfaceLowest;
    final border = selected ? Colors.transparent : AppColors.outlineVariant;
    final radius = context.scaleWidth(18);

    return Material(
      color: bg,
      borderRadius: BorderRadius.circular(radius),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(radius),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          padding: EdgeInsets.symmetric(
            vertical: context.defaultPaddingSc,
            horizontal: context.scaleWidth(8),
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(radius),
            border: Border.all(color: border),
          ),
          child: Column(
            children: [
              Icon(
                icon,
                size: context.scaleWidth(32),
                color: AppColors.textPrimary,
                fill: filledIcon && selected ? 1 : 0,
              ),
              SizedBox(height: context.scaleHeight(12)),
              Text(
                label.toUpperCase(),
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: context.smallFontSize,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.6,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
