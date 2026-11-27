import 'package:dio/dio.dart';

/// Why a request didn't work, as a code the app can translate.
///
/// The server answers a broken rule with 422 and a code, for example
/// `{"code": "promo_minimum", "minimum_cents": 1000}`. The extra fields stay
/// in [details]. Failures without a code get one here: `offline` (no
/// answer), `signed_out` (401), `too_many` (429), `invalid` (a form field)
/// and `server` (anything else).
class ApiProblem implements Exception {
  const ApiProblem(this.code, {this.details = const {}, this.status});

  factory ApiProblem.fromDio(DioException error) {
    final response = error.response;
    if (response == null) return const ApiProblem('offline');
    final status = response.statusCode;
    final data = response.data;
    final body = data is Map
        ? Map<String, dynamic>.from(data)
        : const <String, dynamic>{};
    if (body['code'] case final String code) {
      return ApiProblem(code, details: body, status: status);
    }
    return ApiProblem(
      switch (status) {
        401 => 'signed_out',
        429 => 'too_many',
        422 => 'invalid',
        _ => 'server',
      },
      details: body,
      status: status,
    );
  }

  final String code;
  final Map<String, dynamic> details;
  final int? status;

  /// Laravel's field errors on a 422 `invalid`: field name to messages.
  Set<String> get fields => {
    if (details['errors'] case final Map errors) ...errors.keys.cast<String>(),
  };

  @override
  String toString() => 'ApiProblem($code)';
}

/// Runs a request and turns a DioException into an [ApiProblem].
Future<T> guard<T>(Future<T> Function() request) async {
  try {
    return await request();
  } on DioException catch (error) {
    throw ApiProblem.fromDio(error);
  }
}
