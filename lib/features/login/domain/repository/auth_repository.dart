import '../../../../core/error/result.dart';
import '../entity/user_entity.dart';

abstract class AuthRepository {
  Future<Result<OtpDispatchResult>> sendOtp({required String identifier});

  Future<Result<OtpDispatchResult>> resendOtp({required String identifier});

  Future<Result<AuthSessionEntity>> verifyOtp({
    required String identifier,
    required String otp,
  });

  Future<Result<AuthSessionEntity>> googleLogin({
    required String idToken,
    String? pushToken,
  });

  Future<Result<void>> logout();

  Future<Result<AuthTokens>> refreshToken();

  Future<bool> isLoggedIn();

  Future<UserEntity?> getCachedUser();
}
