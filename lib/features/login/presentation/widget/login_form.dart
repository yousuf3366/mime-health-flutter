import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:mime_health/core/extensions/context_extensions.dart';
import 'package:mime_health/core/widgets/app_otp_field.dart';
import 'package:mime_health/core/widgets/app_text_field1.dart';

import '../../../../core/localization/l10n_keys.dart';
import '../../../../core/providers/core_providers.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/apple_sign_in_button.dart';
import '../../../../core/widgets/google_sign_in_button.dart';
import '../../../language/presentation/provider/language_provider.dart';
import '../provider/login_provider.dart';

class LoginForm extends ConsumerWidget {
  const LoginForm({super.key, required this.onSuccess});

  final VoidCallback onSuccess;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final formState = ref.watch(loginFormNotifierProvider);
    final formNotifier = ref.read(loginFormNotifierProvider.notifier);
    final l10n = ref.watch(languageControllerProvider);
    final isOtpStep = formState.isOtpStep;
    final isLoading = formState.isLoading;
    final errorMessage = formState.errorMessage;
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (!isOtpStep) ...[
          AppTextField1(
            label: l10n.t(L10nKeys.phoneOrEmailLabel),
            initialValue: formState.phoneState,
            keyboardType: TextInputType.emailAddress,
            mandatory: true,
            errorText: formState.phoneErrorState,
            onChanged: (value) {
              formNotifier.updateField(
                phoneState: value,
                phoneErrorState: null,
                errorMessage: null,
              );
            },
          ),
        ] else ...[
          Text(
            l10n
                .t(L10nKeys.otpSentTo)
                .replaceAll('{phone}', formState.phoneState ?? ''),
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
              fontSize: context.fontSize,
            ),
          ),
          SizedBox(height: context.defaultPaddingSc),
          Text(
            l10n.t(L10nKeys.otpLabel),
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface,
              fontWeight: FontWeight.w500,
              fontSize: context.fontSize,
            ),
          ),
          SizedBox(height: context.scaleHeight(12)),
          AppOtpField(
            initialValue: formState.otpTextState,
            errorText: formState.otpErrorState,
            enabled: !isLoading,
            onChanged: (value) {
              formNotifier.updateField(
                otpTextState: value,
                otpErrorState: null,
                errorMessage: null,
              );
            },
          ),
          SizedBox(height: context.scaleHeight(8)),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: formState.canResend
                  ? () => formNotifier.resendOtp()
                  : null,
              child: Text(
                formState.canResend
                    ? l10n.t(L10nKeys.resendOtp)
                    : l10n
                          .t(L10nKeys.resendOtpIn)
                          .replaceAll(
                            '{seconds}',
                            '${formState.resendCooldownSeconds}',
                          ),
              ),
            ),
          ),
          Align(
            alignment: Alignment.centerLeft,
            child: TextButton.icon(
              onPressed: isLoading ? null : formNotifier.goBackToPhone,
              icon: Icon(Icons.arrow_back, size: context.scaleWidth(18)),
              label: Text(l10n.t(L10nKeys.changePhone)),
            ),
          ),
        ],
        if (errorMessage != null) ...[
          SizedBox(height: context.scaleHeight(8)),
          Text(
            errorMessage,
            style: TextStyle(color: Theme.of(context).colorScheme.error),
          ),
        ],
        SizedBox(height: context.scaleHeight(24)),
        AppButton(
          label: isOtpStep
              ? l10n.t(L10nKeys.verifyOtp)
              : l10n.t(L10nKeys.sendOtp),
          isLoading: isLoading,
          btnStyle: AppButtonStyle.primary,
          onPressed: () => _submit(context, ref),
        ),
        SizedBox(height: context.scaleHeight(24)),
        if (!isOtpStep) ...[
          // AppButton(
          //   label: l10n.t(L10nKeys.signInAsGuest, fallback: 'Sign in as Guest'),
          //   isLoading: isLoading,
          //   btnStyle: AppButtonStyle.secondary,
          //   onPressed: () => _submit(context, ref),
          // ),
          SizedBox(height: context.scaleHeight(24)),
          Text(
            l10n.t(L10nKeys.orContinueWith, fallback: 'Or continue with'),
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
              fontSize: context.fontSize,
            ),
          ),
          SizedBox(height: context.defaultPaddingSc),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Tooltip(
                message: l10n.t(
                  L10nKeys.continueWithGoogle,
                  fallback: 'Continue with Google',
                ),
                child: GoogleSignInButton(
                  enabled: !isLoading,
                  onPressed: () => _onGoogleSignIn(context, ref),
                ),
              ),
              SizedBox(width: context.scaleWidth(16)),
              Tooltip(
                message: l10n.t(
                  L10nKeys.continueWithApple,
                  fallback: 'Continue with Apple',
                ),
                child: AppleSignInButton(
                  enabled: !isLoading,
                  onPressed: () => _onAppleSignIn(ref),
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }

  void _onAppleSignIn(WidgetRef ref) {
    final l10n = ref.read(languageControllerProvider);
    ref
        .read(dialogServiceProvider)
        .showComingSoon(
          title: l10n.t(L10nKeys.comingSoonTitle),
          message: l10n.t(L10nKeys.comingSoonMessage),
          okLabel: l10n.t(L10nKeys.comingSoonOk),
        );
  }

  Future<void> _onGoogleSignIn(BuildContext context, WidgetRef ref) async {
    try {
      final credential = await GoogleAuthService().signInWithGoogle();
      final idToken = await credential?.user?.getIdToken();

      if (idToken == null || idToken.isEmpty) {
        _showGoogleLoginError(ref);
        return;
      }

      final success = await ref
          .read(loginFormNotifierProvider.notifier)
          .googleLogin(idToken: idToken);
      if (success && context.mounted) {
        onSuccess();
      }
    } catch (_) {
      _showGoogleLoginError(ref);
    }
  }

  void _showGoogleLoginError(WidgetRef ref) {
    ref
        .read(snackbarServiceProvider)
        .showError(
          ref
              .read(languageControllerProvider)
              .t(
                L10nKeys.genericError,
                fallback: 'Failed to login with Google',
              ),
        );
  }

  Future<void> _submit(BuildContext context, WidgetRef ref) async {
    FocusScope.of(context).unfocus();
    final notifier = ref.read(loginFormNotifierProvider.notifier);
    final wasOtpStep = ref.read(loginFormNotifierProvider).isOtpStep;
    final success = await notifier.submit();
    if (success && wasOtpStep && context.mounted) {
      onSuccess();
    }
  }
}

class GoogleAuthService {
  final FirebaseAuth _firebaseAuth;
  final GoogleSignIn _googleSignIn;

  GoogleAuthService({FirebaseAuth? firebaseAuth, GoogleSignIn? googleSignIn})
    : _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance,
      _googleSignIn = googleSignIn ?? GoogleSignIn.instance;

  Future<UserCredential?> signInWithGoogle() async {
    try {
      await _googleSignIn.initialize(
        serverClientId:
            '423901980794-lbg7bar4h4d9d9frbge2d34j4f1nkf8g.apps.googleusercontent.com',
      );
      final GoogleSignInAccount googleUser = await _googleSignIn.authenticate();

      final GoogleSignInAuthentication googleAuth = googleUser.authentication;

      final credential = GoogleAuthProvider.credential(
        idToken: googleAuth.idToken,
      );

      return await _firebaseAuth.signInWithCredential(credential);
    } catch (_) {
      return null;
    }
  }

  Future<void> signOut() async {
    await _googleSignIn.signOut();
    await _firebaseAuth.signOut();
  }
}
