import 'package:dio/dio.dart';

import 'api_problem.dart';

/// Where "your order is ready" pushes go: this phone's Firebase token,
/// saved on the server while order alerts are on.
abstract interface class DeviceRepository {
  /// [platform] is `android` or `ios`. Saving the same token again is fine.
  Future<void> save(String token, {required String platform});

  /// Stops pushes to this phone. Call it before signing out, while the
  /// request can still be signed.
  Future<void> forget(String token);
}

class ApiDeviceRepository implements DeviceRepository {
  ApiDeviceRepository(this._dio);

  final Dio _dio;

  @override
  Future<void> save(String token, {required String platform}) => guard(
    () => _dio.post<void>(
      '/me/devices',
      data: {'token': token, 'platform': platform},
    ),
  );

  @override
  Future<void> forget(String token) =>
      guard(() => _dio.delete<void>('/me/devices', data: {'token': token}));
}
