import 'package:dio/dio.dart';

/// Where the Laravel API lives. Set per build with
/// `--dart-define=API_URL=https://...`; defaults to a local `php artisan serve`.
/// The Android emulator reaches your computer at 10.0.2.2.
const apiUrl = String.fromEnvironment(
  'API_URL',
  defaultValue: 'http://localhost:8000/api/v1',
);

/// A Dio set up for the HomeCoffee API: JSON in and out, and the customer's
/// Sanctum token on every request once they have signed in.
Dio createApiClient({
  String baseUrl = apiUrl,
  String? Function()? token,
  HttpClientAdapter? adapter,
}) {
  final dio = Dio(
    BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 20),
      headers: {'Accept': 'application/json'},
    ),
  );
  if (adapter != null) dio.httpClientAdapter = adapter;
  dio.interceptors.add(
    InterceptorsWrapper(
      onRequest: (options, handler) {
        final value = token?.call();
        if (value != null) options.headers['Authorization'] = 'Bearer $value';
        handler.next(options);
      },
    ),
  );
  return dio;
}
