import 'package:dio/dio.dart';

import 'account.dart';
import 'api_problem.dart';

/// Email-code sign-in: the server emails a 6-digit code, and the code buys a
/// token for this phone.
abstract interface class AuthRepository {
  Future<void> sendCode(String email, {String language = 'en'});
  Future<SignIn> verify(String email, String code, {String language = 'en'});
  Future<void> signOut();
}

class ApiAuthRepository implements AuthRepository {
  ApiAuthRepository(this._dio, {this.deviceName = 'phone'});

  final Dio _dio;
  final String deviceName;

  @override
  Future<void> sendCode(String email, {String language = 'en'}) => guard(
    () => _dio.post<void>(
      '/auth/code',
      data: {'email': email, 'language': language},
    ),
  );

  @override
  Future<SignIn> verify(String email, String code, {String language = 'en'}) =>
      guard(() async {
        final response = await _dio.post<Map<String, dynamic>>(
          '/auth/verify',
          data: {
            'email': email,
            'code': code,
            'language': language,
            'device_name': deviceName,
          },
        );
        return SignIn.fromJson(response.data!);
      });

  @override
  Future<void> signOut() => guard(() => _dio.post<void>('/auth/logout'));
}
