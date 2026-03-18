import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../data_layer/repository/auth_repo.dart';
import 'auth_state.dart';

/// مدير الحالة الخاص بعمليات المصادقة (Cubit)
/// يدير تسجيل الدخول، التسجيل، التحقق من التوكن (Token)، وتغيير كلمة المرور.
class AuthCubit extends Cubit<AuthState> {
  final AuthRepository authRepository;

  AuthCubit(this.authRepository) : super(AuthInitial());

  /// وظيفة للتحقق من حالة المصادقة عند فتح التطبيق
  /// إذا وُجد توكن صالح، يتم الدخول تلقائياً.
  Future<void> checkAuthStatus() async {
    emit(AuthLoading());
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');
      if (token != null && token.isNotEmpty) {
        await authRepository.updateToken(token);

        // جلب بيانات الحساب الفعلية للتأكد من صلاحية التوكن
        final response = await authRepository.getProfile();
        if (response.status) {
          emit(AuthSuccess(response: response));
        } else {
          // التوكن غير صالح أو انتهت صلاحيته
          await authRepository.authServices.logout();
          emit(AuthInitial());
        }
      } else {
        emit(AuthInitial());
      }
    } catch (e) {
      emit(AuthInitial());
    }
  }

  /// وظيفة تسجيل الدخول
  /// تتواصل مع الـ Repository للتحقق من البيانات وإرجاع التوكن.
  Future<void> login(String phone, String password) async {
    emit(AuthLoading());
    try {
      final response = await authRepository.login(phone, password);
      // التحقق من نجاح العملية واستلام التوكن
      if (response.status) {
        print(
          'AuthCubit: Login Response parsed. Status: ${response.status}, Token Found: ${response.token != null}',
        );
        if (response.token != null) {
          await authRepository.updateToken(response.token!);
          print('AuthCubit: Token updated in Repository.');
          emit(AuthSuccess(response: response));
        } else {
          print(
            'AuthCubit: ERROR: No token in Login response despite success status!',
          );
          emit(AuthError(error: 'فشل تسجيل الدخول: لم يتم استلام رمز الجلسة.'));
        }
      } else {
        emit(
          AuthError(
            error:
                response.message ?? 'فشل تسجيل الدخول. يرجى التحقق من بياناتك.',
          ),
        );
      }
    } catch (e) {
      emit(AuthError(error: 'حدث خطأ غير متوقع: $e'));
    }
  }

  Future<void> register({
    required String name,
    required String email,
    required String phone,
    required String password,
    required String passwordConfirmation,
    double? latitude,
    double? longitude,
  }) async {
    emit(AuthLoading());
    try {
      final response = await authRepository.register(
        name: name,
        email: email,
        phone: phone,
        password: password,
        passwordConfirmation: passwordConfirmation,
        latitude: latitude,
        longitude: longitude,
      );
      if (response.status) {
        // According to user requirements: after registration, we need OTP.
        emit(AuthOtpSent(phone: phone, isPasswordReset: false));
      } else {
        emit(AuthError(error: response.message ?? 'فشل إنشاء الحساب.'));
      }
    } catch (e) {
      emit(AuthError(error: 'حدث خطأ أثناء التسجيل: $e'));
    }
  }

  Future<void> verifyOtp(String phone, String code) async {
    emit(AuthLoading());
    try {
      final response = await authRepository.verifyOtp(phone, code);
      if (response.status) {
        if (response.token != null) {
          await authRepository.updateToken(response.token!);
        }
        // User requested: "عند انشاء الحساب والتحقق منه من خلال رمز التحقق الدخول للتطبيق دون عرض تسجيل الدخول"
        emit(AuthSuccess(response: response));
      } else {
        emit(AuthError(error: response.message ?? 'الرمز غير صحيح.'));
      }
    } catch (e) {
      emit(AuthError(error: 'حدث خطأ: $e'));
    }
  }

  Future<void> requestPasswordReset(String phone) async {
    emit(AuthLoading());
    try {
      final response = await authRepository.requestPasswordReset(phone);
      if (response.status) {
        emit(AuthOtpSent(phone: phone, isPasswordReset: true));
      } else {
        emit(
          AuthError(error: response.message ?? 'فشل إرسال طلب إعادة التعيين.'),
        );
      }
    } catch (e) {
      print('$e');
      emit(AuthError(error: 'حدث خطأ: $e'));
    }
  }

  Future<void> verifyPasswordResetOtp(String phone, String code) async {
    emit(AuthLoading());
    try {
      final response = await authRepository.verifyPasswordResetOtp(phone, code);
      if (response.status) {
        emit(AuthResetCodeVerified(phone: phone, code: code));
      } else {
        emit(AuthError(error: response.message ?? 'رمز التحقق غير صحيح.'));
      }
    } catch (e) {
      emit(AuthError(error: 'حدث خطأ: $e'));
    }
  }

  Future<void> resetPassword(
    String phone,
    String code,
    String password,
    String passwordConfirmation,
  ) async {
    emit(AuthLoading());
    try {
      final response = await authRepository.resetPassword(
        phone,
        code,
        password,
        passwordConfirmation,
      );
      if (response.status) {
        print(
          'AuthCubit: ResetPassword Response parsed. Status: ${response.status}, Token Found: ${response.token != null}',
        );
        if (response.token != null) {
          await authRepository.updateToken(response.token!);
          print('AuthCubit: Token updated in Repository.');
        }
        // After successful reset, they can be logged in or sent to login. Let's send them to success so they can be logged in.
        emit(AuthSuccess(response: response));
      } else {
        emit(
          AuthError(error: response.message ?? 'فشل إعادة تعيين كلمة المرور.'),
        );
      }
    } catch (e) {
      emit(AuthError(error: 'حدث خطأ: $e'));
    }
  }

  Future<void> getProfile() async {
    emit(ProfileLoading());
    try {
      final response = await authRepository.getProfile();
      if (response.status) {
        emit(ProfileLoaded(response: response));
      } else {
        emit(
          ProfileError(
            error: response.message ?? 'فشل جلب بيانات الملف الشخصي.',
          ),
        );
      }
    } catch (e) {
      emit(ProfileError(error: 'حدث خطأ: $e'));
    }
  }

  Future<void> updateLocation({
    required double latitude,
    required double longitude,
  }) async {
    print(
      "AuthCubit: updateLocation called with lat: $latitude, long: $longitude",
    );
    emit(UpdateLocationLoading());
    try {
      final response = await authRepository.updateLocation(
        latitude: latitude,
        longitude: longitude,
      );
      print("AuthCubit: updateLocation response status: ${response.status}");
      if (response.status) {
        emit(UpdateLocationSuccess(response: response));
      } else {
        emit(
          UpdateLocationError(error: response.message ?? "فشل تحديث الموقع"),
        );
      }
    } catch (e) {
      print("AuthCubit: updateLocation exception: $e");
      emit(UpdateLocationError(error: e.toString()));
    }
  }

  Future<void> logout() async {
    try {
      await authRepository.logout();
      emit(LogoutSuccess());
    } catch (e) {
      emit(AuthError(error: 'حدث خطأ أثناء تسجيل الخروج: $e'));
    }
  }
}
