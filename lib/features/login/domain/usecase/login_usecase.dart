import '../../../../core/error/result.dart';
import '../entity/user_entity.dart';
import '../repository/auth_repository.dart';

class SendOtpUseCase {
  SendOtpUseCase(this._repository);

  final AuthRepository _repository;

  Future<Result<OtpDispatchResult>> call({required String phone}) {
    return _repository.sendOtp(phone: phone);
  }
}

class ResendOtpUseCase {
  ResendOtpUseCase(this._repository);

  final AuthRepository _repository;

  Future<Result<OtpDispatchResult>> call({required String phone}) {
    return _repository.resendOtp(phone: phone);
  }
}

class VerifyOtpUseCase {
  VerifyOtpUseCase(this._repository);

  final AuthRepository _repository;

  Future<Result<AuthSessionEntity>> call({
    required String phone,
    required String otp,
  }) {
    return _repository.verifyOtp(phone: phone, otp: otp);
  }
}

class GoogleLoginUseCase {
  GoogleLoginUseCase(this._repository);

  final AuthRepository _repository;

  Future<Result<AuthSessionEntity>> call({
    required String idToken,
    String? pushToken,
  }) {
    return _repository.googleLogin(idToken: idToken, pushToken: pushToken);
  }
}

class LogoutUseCase {
  LogoutUseCase(this._repository);

  final AuthRepository _repository;

  Future<Result<void>> call() => _repository.logout();
}

class RefreshTokenUseCase {
  RefreshTokenUseCase(this._repository);

  final AuthRepository _repository;

  Future<Result<AuthTokens>> call() => _repository.refreshToken();
}

class CheckAuthUseCase {
  CheckAuthUseCase(this._repository);

  final AuthRepository _repository;

  Future<bool> call() => _repository.isLoggedIn();
}
