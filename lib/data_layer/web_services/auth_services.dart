import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../constants/strings.dart';
import '../../constants/api_routes.dart';

class AuthServices {
  late Dio dio;

  AuthServices({Dio? externalDio}) {
    if (externalDio != null) {
      dio = externalDio;
    } else {
      BaseOptions options = BaseOptions(
        baseUrl: baseUrl1,
        receiveDataWhenStatusError: true,
        connectTimeout: const Duration(seconds: 20),
        receiveTimeout: const Duration(seconds: 20),
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
      );
      dio = Dio(options);
    }

    // Auth Interceptor for dynamic token attachment
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final prefs = await SharedPreferences.getInstance();
          final token = prefs.getString('auth_token');
          print('AuthInterceptor: Checking token for ${options.path}...');
          if (token != null && token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
            print('AuthInterceptor: Token added to headers.');
          } else {
            print('AuthInterceptor: No token found in SharedPreferences.');
          }
          return handler.next(options);
        },
        onError: (e, handler) {
          if (e.response?.statusCode == 401) {
            print(
              'AuthInterceptor: 401 Unauthenticated error detected for ${e.requestOptions.path}',
            );
          }
          return handler.next(e);
        },
      ),
    );

    dio.interceptors.add(
      LogInterceptor(
        requestBody: true,
        responseBody: true,
        requestHeader: true,
      ),
    );
  }

  Future<Map<String, dynamic>> login(String phone, String password) async {
    try {
      Response response = await dio.post(
        'auth/customer/login',
        data: {'phone': phone, 'password': password},
      );
      print('AuthServices: Login Response: ${response.data}'); // Debug logging
      return response.data;
    } catch (e) {
      if (e is DioException && e.response != null) {
        return e.response!.data;
      }
      return {'status': false, 'message': e.toString()};
    }
  }

  Future<Map<String, dynamic>> register({
    required String name,
    required String email,
    required String phone,
    required String password,
    required String passwordConfirmation,
    double? latitude,
    double? longitude,
  }) async {
    try {
      Response response = await dio.post(
        'auth/customer/register',
        data: {
          'name': name,
          'email': email,
          'phone': phone,
          'password': password,
          'password_confirmation': passwordConfirmation,
        },
      );
      return response.data;
    } catch (e) {
      if (e is DioException && e.response != null) {
        return e.response!.data;
      }
      return {'status': false, 'message': e.toString()};
    }
  }

  Future<Map<String, dynamic>> verifyOtp(String phone, String code) async {
    try {
      Response response = await dio.post(
        ApiRoutes.verifyOtp,
        data: {'phone': phone, 'code': code},
      );
      return response.data;
    } catch (e) {
      if (e is DioException && e.response != null) {
        return e.response!.data;
      }
      return {'status': false, 'message': e.toString()};
    }
  }

  Future<Map<String, dynamic>> requestPasswordReset(String phone) async {
    try {
      Response response = await dio.post(
        'auth/password-reset/request',
        data: {'phone': phone},
      );
      return response.data;
    } catch (e) {
      if (e is DioException && e.response != null) {
        return e.response!.data;
      }
      return {'status': false, 'message': e.toString()};
    }
  }

  Future<Map<String, dynamic>> verifyPasswordResetOtp(
    String phone,
    String code,
  ) async {
    try {
      Response response = await dio.post(
        'auth/password-reset/verify',
        data: {'phone': phone, 'code': code},
      );
      return response.data;
    } catch (e) {
      if (e is DioException && e.response != null) {
        return e.response!.data;
      }
      return {'status': false, 'message': e.toString()};
    }
  }

  Future<Map<String, dynamic>> resetPassword(
    String phone,
    String code,
    String password,
    String passwordConfirmation,
  ) async {
    try {
      Response response = await dio.post(
        'auth/password-reset/reset',
        data: {
          'phone': phone,
          'code': code,
          'password': password,
          'password_confirmation': passwordConfirmation,
        },
      );
      return response.data;
    } catch (e) {
      if (e is DioException && e.response != null) {
        return e.response!.data;
      }
      return {'status': false, 'message': e.toString()};
    }
  }

  Future<Map<String, dynamic>> getProfile() async {
    try {
      Response response = await dio.get('customer/profile');
      print(
        'AuthServices: GetProfile Response: ${response.data}',
      ); // Debug logging
      return response.data;
    } catch (e) {
      if (e is DioException && e.response != null) {
        return e.response!.data;
      }
      return {'status': false, 'message': e.toString()};
    }
  }

  Future<void> updateToken(String token) async {
    if (token.isEmpty) {
      print('AuthServices: WARNING: Attempting to save an EMPTY token!');
    } else {
      print(
        'AuthServices: Saving new token to SharedPreferences. Length: ${token.length}',
      );
    }
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('auth_token', token);
  }

  Future<Map<String, dynamic>> updateLocation({
    required double latitude,
    required double longitude,
  }) async {
    try {
      Response response = await dio.post(
        'customer/profile/update',
        data: {'latitude': latitude, 'longitude': longitude},
      );
      return response.data;
    } catch (e) {
      rethrow;
    }
  }

  Future<void> logout() async {
    dio.options.headers.remove('Authorization');
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
  }
}
