import 'package:flutter/foundation.dart';
import '../../../data_layer/model/auth_model.dart';

@immutable
abstract class AuthState {}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}

class AuthSuccess extends AuthState {
  final AuthResponse response;
  AuthSuccess({required this.response});
}

class AuthError extends AuthState {
  final String error;
  AuthError({required this.error});
}

// Special states for OTP flow
class AuthOtpSent extends AuthState {
  final String phone;
  final bool isPasswordReset;
  AuthOtpSent({required this.phone, this.isPasswordReset = false});
}

// Special state for after verify reset code
class AuthResetCodeVerified extends AuthState {
  final String phone;
  final String code;
  AuthResetCodeVerified({required this.phone, required this.code});
}

class ProfileLoading extends AuthState {}

class ProfileLoaded extends AuthState {
  final AuthResponse response;
  ProfileLoaded({required this.response});
}

class ProfileError extends AuthState {
  final String error;
  ProfileError({required this.error});
}

class UpdateLocationLoading extends AuthState {}

class UpdateLocationSuccess extends AuthState {
  final AuthResponse response;
  UpdateLocationSuccess({required this.response});
}

class UpdateLocationError extends AuthState {
  final String error;
  UpdateLocationError({required this.error});
}

class LogoutSuccess extends AuthState {}
