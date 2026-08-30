import 'dart:async';
import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/providers/core_providers.dart';
import '../../../../core/services/dialog_service.dart';
import '../../../../core/services/snackbar_service.dart';
import '../../../../core/storage/secure_storage_service.dart';
import '../../../../core/utils/validators.dart';
import '../../domain/usecase/login_usecase.dart';
import '../provider/login_di.dart';
import '../state/login_form_state.dart';

class LoginFormNotifier extends Notifier<LoginFormState> {
  Timer? _resendTimer;

  @override
  LoginFormState build() {
    ref.onDispose(() => _resendTimer?.cancel());
    return LoginFormState.initial();
  }

  SendOtpUseCase get _sendOtp => ref.read(sendOtpUseCaseProvider);
  ResendOtpUseCase get _resendOtp => ref.read(resendOtpUseCaseProvider);
  VerifyOtpUseCase get _verifyOtp => ref.read(verifyOtpUseCaseProvider);
  GoogleLoginUseCase get _googleLogin => ref.read(googleLoginUseCaseProvider);
  SnackbarService get _snackbar => ref.read(snackbarServiceProvider);
  DialogService get _dialog => ref.read(dialogServiceProvider);
  SecureStorageService get _secureStorage => ref.read(secureStorageProvider);

  void updateField({
    Object? phoneState = noValue,
    Object? phoneErrorState = noValue,
    Object? otpTextState = noValue,
    Object? otpErrorState = noValue,
    Object isButtonSubmit = noValue,
    Object isValidate = noValue,
    Object? errorMessage = noValue,
    Object? step = noValue,
    Object? status = noValue,
    Object? session = noValue,
    Object? resendCooldownSeconds = noValue,
  }) {
    state = state.copyWith(
      phoneState: phoneState,
      phoneErrorState: phoneErrorState,
      otpTextState: otpTextState,
      otpErrorState: otpErrorState,
      isButtonSubmit: isButtonSubmit,
      isValidate: isValidate,
      errorMessage: errorMessage,
      step: step,
      status: status,
      session: session,
      resendCooldownSeconds: resendCooldownSeconds,
    );
  }

  bool validateInfo() {
    if (state.step == LoginStep.phone) {
      final error = Validators.phone(state.phoneState);
      updateField(
        phoneErrorState: error,
        isValidate: error == null && (state.phoneState ?? '').trim().isNotEmpty,
      );
      return error == null;
    }

    final error = Validators.otp(state.otpTextState);
    updateField(
      otpErrorState: error,
      isValidate: error == null && (state.otpTextState ?? '').trim().isNotEmpty,
    );
    return error == null;
  }

  void resetState() {
    _resendTimer?.cancel();
    state = LoginFormState.initial();
  }

  void goBackToPhone() {
    _resendTimer?.cancel();
    state = LoginFormState(phoneState: state.phoneState);
  }

  Future<bool> submit() async {
    if (!validateInfo()) return false;

    final isOtpStep = state.step == LoginStep.otp;

    updateField(
      isButtonSubmit: true,
      status: LoginStatus.loading,
      errorMessage: null,
      isValidate: true,
    );

    final success = isOtpStep
        ? await verifyOtp(otp: state.otpTextState ?? '')
        : await sendOtp();

    updateField(
      isButtonSubmit: false,
      status: success
          ? (isOtpStep ? LoginStatus.success : LoginStatus.initial)
          : LoginStatus.error,
    );

    return success;
  }

  Future<bool> sendOtp() async {
    final normalized = (state.phoneState ?? '').trim().replaceAll(
      RegExp(r'[\s-]'),
      '',
    );
    updateField(
      status: LoginStatus.loading,
      phoneState: normalized,
      errorMessage: null,
    );
    _dialog.showLoading();

    final result = await _sendOtp(phone: normalized);
    _dialog.hideLoading();

    return result.when(
      success: (dispatch) {
        updateField(
          step: LoginStep.otp,
          status: LoginStatus.initial,
          otpTextState: null,
          otpErrorState: null,
          errorMessage: null,
          isValidate: false,
        );
        _startResendCooldown(dispatch.expiresInSeconds);
        _snackbar.showSuccess(dispatch.message);
        return true;
      },
      failure: (error) {
        updateField(status: LoginStatus.error, errorMessage: error.message);
        _snackbar.showError(error.message);
        return false;
      },
    );
  }

  Future<bool> resendOtp() async {
    final phone = state.phoneState ?? '';
    if (!state.canResend || phone.isEmpty) return false;

    updateField(status: LoginStatus.loading, errorMessage: null);
    _dialog.showLoading();

    final result = await _resendOtp(phone: phone);
    _dialog.hideLoading();

    return result.when(
      success: (dispatch) {
        updateField(status: LoginStatus.initial, errorMessage: null);
        _startResendCooldown(dispatch.expiresInSeconds);
        _snackbar.showSuccess(dispatch.message);
        return true;
      },
      failure: (error) {
        updateField(status: LoginStatus.error, errorMessage: error.message);
        _snackbar.showError(error.message);
        return false;
      },
    );
  }

  Future<bool> verifyOtp({required String otp}) async {
    updateField(status: LoginStatus.loading, errorMessage: null);
    _dialog.showLoading();

    final result = await _verifyOtp(
      phone: state.phoneState ?? '',
      otp: otp.trim(),
    );
    _dialog.hideLoading();

    return result.when(
      success: (session) async {
        _resendTimer?.cancel();
        await _secureStorage.saveAccessToken(session.tokens.accessToken);
        await _secureStorage.saveRefreshToken(session.tokens.refreshToken);
        await _secureStorage.saveUserInfo(jsonEncode(session.rawUserInfo));
        await _secureStorage.saveDeviceInfo(jsonEncode(session.rawDeviceInfo));
        // Clear OTP step so a later logout lands on the phone screen.
        resetState();
        _snackbar.showSuccess('Welcome, ${session.user.displayName}!');
        return true;
      },
      failure: (error) {
        updateField(status: LoginStatus.error, errorMessage: error.message);
        _snackbar.showError(error.message);
        return false;
      },
    );
  }

  Future<bool> googleLogin({required String idToken}) async {
    updateField(status: LoginStatus.loading, errorMessage: null);
    _dialog.showLoading();

    final result = await _googleLogin(idToken: idToken);
    _dialog.hideLoading();

    return result.when(
      success: (session) async {
        await _secureStorage.saveAccessToken(session.tokens.accessToken);
        await _secureStorage.saveRefreshToken(session.tokens.refreshToken);
        await _secureStorage.saveUserInfo(jsonEncode(session.rawUserInfo));
        await _secureStorage.saveDeviceInfo(jsonEncode(session.rawDeviceInfo));
        resetState();
        _snackbar.showSuccess('Welcome, ${session.user.displayName}!');
        return true;
      },
      failure: (error) {
        updateField(status: LoginStatus.error, errorMessage: error.message);
        _snackbar.showError(error.message);
        return false;
      },
    );
  }

  void _startResendCooldown(int seconds) {
    _resendTimer?.cancel();
    updateField(resendCooldownSeconds: seconds);

    _resendTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      final next = state.resendCooldownSeconds - 1;
      if (next <= 0) {
        timer.cancel();
        updateField(resendCooldownSeconds: 0);
      } else {
        updateField(resendCooldownSeconds: next);
      }
    });
  }
}

final loginFormNotifierProvider =
    NotifierProvider<LoginFormNotifier, LoginFormState>(LoginFormNotifier.new);
