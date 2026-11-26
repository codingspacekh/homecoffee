import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:homecoffee_data/homecoffee_data.dart';
import 'package:test/test.dart';

/// Answers requests from a list of canned replies and remembers what was asked.
class FakeAdapter implements HttpClientAdapter {
  FakeAdapter(this.replies);

  final List<ResponseBody Function()> replies;
  final requests = <RequestOptions>[];

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? _,
    Future<void>? _,
  ) async {
    requests.add(options);
    return replies.removeAt(0)();
  }

  @override
  void close({bool force = false}) {}
}

ResponseBody json(Object body, {String? etag}) => ResponseBody.fromString(
  jsonEncode(body),
  200,
  headers: {
    Headers.contentTypeHeader: [Headers.jsonContentType],
    'etag': ?(etag == null ? null : [etag]),
  },
);

ResponseBody notModified() => ResponseBody.fromString('', 304);

Never offline() => throw DioException.connectionError(
  requestOptions: RequestOptions(),
  reason: 'no signal',
);

const menu = {
  'categories': [
    {
      'id': 1,
      'name': 'Hot coffee',
      'translations': {
        'km': {'name': 'កាហ្វេក្តៅ'},
      },
      'products': [
        {
          'id': 12,
          'name': 'Cappuccino',
          'price_cents': 375,
          'drink': true,
          'available': false,
          'image_url': 'https://api.test/storage/products/cappuccino.webp',
        },
      ],
    },
  ],
};

void main() {
  test('sends JSON headers and the token once signed in', () async {
    String? token;
    final adapter = FakeAdapter([() => json({}), () => json({})]);
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

  group('menu', () {
    late MemoryMenuStore store;
    setUp(() => store = MemoryMenuStore());

    ApiMenuRepository repository(FakeAdapter adapter) => ApiMenuRepository(
      createApiClient(baseUrl: 'https://api.test/api/v1', adapter: adapter),
      store,
    );

    test('reads categories with prices in cents and saves them', () async {
      final adapter = FakeAdapter([() => json(menu, etag: '"v1"')]);
      final categories = await repository(adapter).fetchMenu();

      expect(adapter.requests.single.path, '/menu');
      expect(categories.single.nameIn('km'), 'កាហ្វេក្តៅ');
      expect(categories.single.products.single.price, 375);
      expect(categories.single.products.single.available, isFalse);
      expect(store.saved?.etag, '"v1"');
    });

    test('asks with the saved ETag and reuses the saved menu on 304', () async {
      store.saved = SavedMenu(etag: '"v1"', json: jsonEncode(menu));
      final adapter = FakeAdapter([notModified]);

      final categories = await repository(adapter).fetchMenu();

      expect(adapter.requests.single.headers['If-None-Match'], '"v1"');
      expect(categories.single.products.single.name, 'Cappuccino');
    });

    test('shows the saved menu when there is no signal', () async {
      store.saved = SavedMenu(etag: '"v1"', json: jsonEncode(menu));

      final categories = await repository(FakeAdapter([offline])).fetchMenu();

      expect(categories.single.products.single.id, 12);
    });

    test('fails when there is no signal and nothing saved yet', () async {
      expect(
        repository(FakeAdapter([offline])).fetchMenu(),
        throwsA(isA<DioException>()),
      );
    });
  });

  test('reads the store hours answer', () async {
    final adapter = FakeAdapter([
      () => json({
        'timezone': 'Asia/Phnom_Penh',
        'prep_minutes': 9,
        'open_now': true,
        'can_order_now': false,
      }),
    ]);
    final store = await ApiStoreRepository(
      createApiClient(baseUrl: 'https://api.test/api/v1', adapter: adapter),
    ).fetchStore();

    expect(adapter.requests.single.path, '/store');
    expect(store.prepMinutes, 9);
    expect(store.openNow, isTrue);
    expect(store.canOrderNow, isFalse);
  });
}
