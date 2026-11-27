import 'package:dio/dio.dart';

import 'account.dart';
import 'api_problem.dart';

/// The signed-in customer's profile, favourites and points.
abstract interface class ProfileRepository {
  Future<Account> fetchMe();
  Future<Account> update({String? name, String? phone, String? language});

  /// Forget my data: removes the account. Past orders stay for the shop's
  /// books, without the name or phone.
  Future<void> deleteMe();

  Future<Set<int>> fetchFavourites();
  Future<void> setFavourite(int productId, {required bool on});
  Future<Paged<PointEntry>> fetchPoints({int page = 1});
}

class ApiProfileRepository implements ProfileRepository {
  ApiProfileRepository(this._dio);

  final Dio _dio;

  @override
  Future<Account> fetchMe() => guard(() async {
    final response = await _dio.get<Map<String, dynamic>>('/me');
    return Account.fromJson(response.data!);
  });

  @override
  Future<Account> update({String? name, String? phone, String? language}) =>
      guard(() async {
        final response = await _dio.patch<Map<String, dynamic>>(
          '/me',
          data: {'name': ?name, 'phone': ?phone, 'language': ?language},
        );
        return Account.fromJson(response.data!);
      });

  @override
  Future<void> deleteMe() => guard(() => _dio.delete<void>('/me'));

  @override
  Future<Set<int>> fetchFavourites() => guard(() async {
    final response = await _dio.get<Map<String, dynamic>>('/me/favourites');
    return {for (final id in response.data!['product_ids'] as List) id as int};
  });

  @override
  Future<void> setFavourite(int productId, {required bool on}) => guard(
    () => on
        ? _dio.put<void>('/me/favourites/$productId')
        : _dio.delete<void>('/me/favourites/$productId'),
  );

  @override
  Future<Paged<PointEntry>> fetchPoints({int page = 1}) => guard(() async {
    final response = await _dio.get<Map<String, dynamic>>(
      '/me/points',
      queryParameters: {'page': page},
    );
    final data = response.data!;
    return Paged([
      for (final entry in data['data'] as List)
        PointEntry.fromJson(entry as Map<String, dynamic>),
    ], nextPage: data['next_page'] as int?);
  });
}
