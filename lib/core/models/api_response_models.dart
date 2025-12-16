// core/models/api_response_models.dart

import 'user_model.dart';

class LoginResponse {
  final String token;
  final UserModel user;

  const LoginResponse({
    required this.token,
    required this.user,
  });

  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    return LoginResponse(
      token: json['token'] as String,
      user: UserModel.fromJson(json['user'] as Map<String, dynamic>),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'token': token,
      'user': user.toJson(),
    };
  }
}

class RegisterResponse {
  final String token;
  final UserModel user;

  const RegisterResponse({
    required this.token,
    required this.user,
  });

  factory RegisterResponse.fromJson(Map<String, dynamic> json) {
    return RegisterResponse(
      token: json['token'] as String,
      user: UserModel.fromJson(json['user'] as Map<String, dynamic>),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'token': token,
      'user': user.toJson(),
    };
  }
}

class ApiError {
  final String message;
  final int? code;

  const ApiError({
    required this.message,
    this.code,
  });

  factory ApiError.fromJson(Map<String, dynamic> json) {
    return ApiError(
      message: json['message'] as String? ?? 'Unknown error',
      code: json['code'] as int?,
    );
  }

  @override
  String toString() => message;
}