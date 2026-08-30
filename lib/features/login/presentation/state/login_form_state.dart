import 'package:equatable/equatable.dart';

import '../../domain/entity/user_entity.dart';

const Object noValue = Object();

enum LoginStep { phone, otp }

enum LoginStatus { initial, loading, success, error }

class LoginFormState extends Equatable {
  const LoginFormState({
    this.step = LoginStep.phone,
    this.status = LoginStatus.initial,
    this.session,
    this.phoneState,
    this.phoneErrorState,
    this.otpTextState,
    this.otpErrorState,
    this.isButtonSubmit = false,
    this.isValidate = false,
    this.errorMessage,
    this.resendCooldownSeconds = 0,
  });

  factory LoginFormState.initial() => const LoginFormState();

  final LoginStep step;
  final LoginStatus status;
  final AuthSessionEntity? session;

  /// Phone value for the text field and OTP/resend API calls.
  final String? phoneState;
  final String? phoneErrorState;
  final String? otpTextState;
  final String? otpErrorState;
  final bool isButtonSubmit;
  final bool isValidate;
  final String? errorMessage;
  final int resendCooldownSeconds;

  bool get isLoading => status == LoginStatus.loading || isButtonSubmit;
  bool get canResend => resendCooldownSeconds <= 0 && !isLoading;
  bool get isOtpStep => step == LoginStep.otp;

  LoginFormState copyWith({
    Object? step = noValue,
    Object? status = noValue,
    Object? session = noValue,
    Object? phoneState = noValue,
    Object? phoneErrorState = noValue,
    Object? otpTextState = noValue,
    Object? otpErrorState = noValue,
    Object isButtonSubmit = noValue,
    Object isValidate = noValue,
    Object? errorMessage = noValue,
    Object? resendCooldownSeconds = noValue,
  }) {
    return LoginFormState(
      step: identical(step, noValue) ? this.step : step as LoginStep,
      status:
          identical(status, noValue) ? this.status : status as LoginStatus,
      session: identical(session, noValue)
          ? this.session
          : session as AuthSessionEntity?,
      phoneState: identical(phoneState, noValue)
          ? this.phoneState
          : phoneState as String?,
      phoneErrorState: identical(phoneErrorState, noValue)
          ? this.phoneErrorState
          : phoneErrorState as String?,
      otpTextState: identical(otpTextState, noValue)
          ? this.otpTextState
          : otpTextState as String?,
      otpErrorState: identical(otpErrorState, noValue)
          ? this.otpErrorState
          : otpErrorState as String?,
      isButtonSubmit: identical(isButtonSubmit, noValue)
          ? this.isButtonSubmit
          : isButtonSubmit as bool,
      isValidate:
          identical(isValidate, noValue) ? this.isValidate : isValidate as bool,
      errorMessage: identical(errorMessage, noValue)
          ? this.errorMessage
          : errorMessage as String?,
      resendCooldownSeconds: identical(resendCooldownSeconds, noValue)
          ? this.resendCooldownSeconds
          : resendCooldownSeconds as int,
    );
  }

  @override
  List<Object?> get props => [
        step,
        status,
        session,
        phoneState,
        phoneErrorState,
        otpTextState,
        otpErrorState,
        isButtonSubmit,
        isValidate,
        errorMessage,
        resendCooldownSeconds,
      ];
}
