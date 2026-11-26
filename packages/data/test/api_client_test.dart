import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:homecoffee_data/homecoffee_data.dart';
import 'package:test/test.dart';

/// Answers every request with [body] and remembers what was asked.
class FakeAdapter implements HttpClientAdapter {
  FakeAdapter(this.body);

  final Object body;
  final requests = <RequestOptions>[];

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? _,
    Future<void>? _,
  ) async {
    requests.add(options);
    return ResponseBody.fromString(
      jsonEncode(body),
      200,
      headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}

void main() {
  test('sends JSON headers and the token once signed in', () async {
    String? token;
    final adapter = FakeAdapter({'ok': true});
    final dio = createApiClient(
      baseUrl: 'https://api.test/api/v1',
      token: () => token,
      adapter: adapter,
    );

    await dio.get<void>('/store');
    token = 'abc';
    await dio.get<void>('/me');

    expect(
      adapter.requests.first.uri.toString(),
      'https://api.test/api/v1/store',
    );
    expect(adapter.requests.first.headers['Accept'], 'application/json');
    expect(
      adapter.requests.first.headers.containsKey('Authorization'),
      isFalse,
    );
    expect(adapter.requests.last.headers['Authorization'], 'Bearer abc');
  });

  test('website menu becomes categories with prices in cents', () async {
    final adapter = FakeAdapter([
      {
        'name': 'Coffees',
        'products': [
          {
            'id': 12,
            'name': 'Cappuccino',
            'price': 3.75,
            'drink': true,
            'image': 'cappuccino.png',
          },
        ],
      },
    ]);
    final menu = await WebsiteMenuRepository(createApiClient(adapter: adapter))
        .fetchMenu();

    expect(menu.single.products.single.price, 375);
    expect(
      WebsiteMenuRepository.imageUrl(menu.single.products.single),
      endsWith('/data/images/cappuccino.png'),
    );
  });
}
