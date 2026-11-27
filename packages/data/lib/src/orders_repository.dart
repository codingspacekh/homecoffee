import 'dart:math';

import 'package:dio/dio.dart';

import 'account.dart';
import 'api_problem.dart';
import 'orders.dart';

abstract interface class OrdersRepository {
  Future<Quote> quote(Checkout checkout);

  /// Sending the same [idempotencyKey] again returns the first order instead
  /// of making a second one, so a retry after a lost answer is safe.
  Future<Order> place(Checkout checkout, {required String idempotencyKey});

  Future<Paged<Order>> fetchOrders({int page = 1});
  Future<Order> fetchOrder(int id);
  Future<Order> cancel(int id);
}

/// A new random key for each order the customer means to place.
String newIdempotencyKey([Random? random]) {
  final source = random ?? Random.secure();
  return List.generate(32, (_) => source.nextInt(16).toRadixString(16)).join();
}

class ApiOrdersRepository implements OrdersRepository {
  ApiOrdersRepository(this._dio);

  final Dio _dio;

  @override
  Future<Quote> quote(Checkout checkout) => guard(() async {
    final response = await _dio.post<Map<String, dynamic>>(
      '/checkout/quote',
      data: checkout.toQuoteJson(),
    );
    return Quote.fromJson(response.data!);
  });

  @override
  Future<Order> place(Checkout checkout, {required String idempotencyKey}) =>
      guard(() async {
        final response = await _dio.post<Map<String, dynamic>>(
          '/orders',
          data: checkout.toOrderJson(),
          options: Options(headers: {'Idempotency-Key': idempotencyKey}),
        );
        return Order.fromJson(response.data!);
      });

  @override
  Future<Paged<Order>> fetchOrders({int page = 1}) => guard(() async {
    final response = await _dio.get<Map<String, dynamic>>(
      '/orders',
      queryParameters: {'page': page},
    );
    final data = response.data!;
    return Paged([
      for (final order in data['data'] as List)
        Order.fromJson(order as Map<String, dynamic>),
    ], nextPage: data['next_page'] as int?);
  });

  @override
  Future<Order> fetchOrder(int id) => guard(() async {
    final response = await _dio.get<Map<String, dynamic>>('/orders/$id');
    return Order.fromJson(response.data!);
  });

  @override
  Future<Order> cancel(int id) => guard(() async {
    final response = await _dio.post<Map<String, dynamic>>(
      '/orders/$id/cancel',
    );
    return Order.fromJson(response.data!);
  });
}
