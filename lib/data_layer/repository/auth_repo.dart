import '../model/auth_model.dart';
import '../web_services/auth_services.dart';

class AuthRepository {
  final AuthServices authServices;

  AuthRepository(this.authServices);

  Future<AuthResponse> login(String phone, String password) async {
    final response = await authServices.login(phone, password);
    return AuthResponse.fromJson(response);
  }

  Future<AuthResponse> register({
    required String name,
    required String email,
    required String phone,
    required String password,
    required String passwordConfirmation,
    double? latitude,
    double? longitude,
  }) async {
    final response = await authServices.register(
      name: name,
      email: email,
      phone: phone,
      password: password,
      passwordConfirmation: passwordConfirmation,
      latitude: latitude,
      longitude: longitude,
    );
    return AuthResponse.fromJson(response);
  }

  Future<AuthResponse> verifyOtp(String phone, String code) async {
    final response = await authServices.verifyOtp(phone, code);
    return AuthResponse.fromJson(response);
  }

  Future<AuthResponse> requestPasswordReset(String phone) async {
    final response = await authServices.requestPasswordReset(phone);
    return AuthResponse.fromJson(response);
  }

  Future<AuthResponse> verifyPasswordResetOtp(String phone, String code) async {
    final response = await authServices.verifyPasswordResetOtp(phone, code);
    return AuthResponse.fromJson(response);
  }

  Future<AuthResponse> resetPassword(
    String phone,
    String code,
    String password,
    String passwordConfirmation,
  ) async {
    final response = await authServices.resetPassword(
      phone,
      code,
      password,
      passwordConfirmation,
    );
    return AuthResponse.fromJson(response);
  }

  Future<AuthResponse> getProfile() async {
    final response = await authServices.getProfile();
    return AuthResponse.fromJson(response);
  }

  Future<void> updateToken(String token) async {
    await authServices.updateToken(token);
  }

  Future<AuthResponse> updateLocation({
    required double latitude,
    required double longitude,
  }) async {
    final response = await authServices.updateLocation(
      latitude: latitude,
      longitude: longitude,
    );
    return AuthResponse.fromJson(response);
  }

  Future<void> logout() async {
    await authServices.logout();
  }
}
