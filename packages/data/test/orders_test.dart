import 'dart:async';
import 'dart:convert';

import 'package:async/async.dart';
import 'package:dio/dio.dart';
import 'package:homecoffee_data/homecoffee_data.dart';
import 'package:homecoffee_domain/homecoffee_domain.dart';
import 'package:stream_channel/stream_channel.dart';
import 'package:test/test.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

import 'helpers.dart';

final latte = Product.fromJson({
  'id': 12,
  'name': 'Latte',
  'price_cents': 400,
  'drink': true,
  'options': [
    {
      'name': 'Size',
      'choices': [
        {'label': 'Small', 'price_cents': 0},
        {'label': 'Large', 'price_cents': 100},
      ],
    },
  ],
});

const placedOrder = {
  'id': 42,
  'number': 1042,
  'status': 'received',
  'customer_name': 'Dara',
  'payment_method': 'counter',
  'pickup_at': null,
  'estimated_ready_at': '2026-12-02T09:07:00+07:00',
  'created_at': '2026-12-02T09:00:00+07:00',
  'preparing_at': null,
  'ready_at': null,
  'collected_at': null,
  'cancelled_at': null,
  'subtotal_cents': 1000,
  'discount_cents': 0,
  'promo_code': 'WELCOME10',
  'promo_cents': 100,
  'total_cents': 900,
  'points_spent': 0,
  'points_earned': 9,
  'can_cancel': true,
  'lines': [
    {
      'product_id': 12,
      'name': 'Latte',
      'options': {'Size': 'Large'},
      'choices': 'Large',
      'unit_cents': 500,
      'quantity': 2,
      'line_cents': 1000,
      'translations': {
        'km': {'name': 'ឡាតេ', 'choices': 'ធំ'},
      },
    },
  ],
};

Dio client(FakeAdapter adapter) =>
    createApiClient(baseUrl: 'https://api.test/api/v1', adapter: adapter);

void main() {
  group('orders', () {
    test('places an order with a key and choices, never prices', () async {
      final adapter = FakeAdapter([() => json(placedOrder, status: 201)]);
      final repository = ApiOrdersRepository(client(adapter));

      final order = await repository.place(
        Checkout(
          lines: [
            createItem(latte, selection: {'Size': 'Large'}, quantity: 2),
          ],
          promoCode: 'WELCOME10',
          customerName: 'Dara',
          customerPhone: '012 345 678',
        ),
        idempotencyKey: 'abc123def456',
      );

      final request = adapter.requests.single;
      expect(request.path, '/orders');
      expect(request.headers['Idempotency-Key'], 'abc123def456');
      expect(request.data, {
        'lines': [
          {
            'product_id': 12,
            'options': {'Size': 'Large'},
            'quantity': 2,
          },
        ],
        'promo_code': 'WELCOME10',
        'use_free_drink': false,
        'pickup_at': 'asap',
        'customer_name': 'Dara',
        'customer_phone': '012 345 678',
      });
      expect(order.number, 1042);
      expect(order.status, OrderStatus.received);
      expect(order.canCancel, isTrue);
      expect(order.lines.single.nameIn('km'), 'ឡាតេ');
      expect(order.lines.single.choicesIn('en'), 'Large');
      expect(order.estimatedReadyAt, DateTime.utc(2026, 12, 2, 2, 7));
    });

    test('sends a set pickup time in UTC', () {
      final checkout = Checkout(
        lines: [createItem(latte)],
        pickupAt: DateTime.utc(2026, 12, 2, 3, 30),
      );
      expect(checkout.toOrderJson()['pickup_at'], '2026-12-02T03:30:00.000Z');
    });

    test('keys are 32 random hex characters', () {
      final key = newIdempotencyKey();
      expect(key, matches(RegExp(r'^[0-9a-f]{32}$')));
      expect(newIdempotencyKey(), isNot(key));
    });

    test('a broken rule becomes a problem with its code', () async {
      final adapter = FakeAdapter([
        () => json({
          'code': 'promo_minimum',
          'message': 'SAVE2 needs an order of \$10.00 or more.',
          'minimum_cents': 1000,
        }, status: 422),
      ]);
      final repository = ApiOrdersRepository(client(adapter));

      await expectLater(
        repository.quote(Checkout(lines: [createItem(latte)])),
        throwsA(
          isA<ApiProblem>()
              .having((p) => p.code, 'code', 'promo_minimum')
              .having((p) => p.details['minimum_cents'], 'minimum', 1000),
        ),
      );
    });

    test('no signal, field errors and rate limits get their own codes', () {
      final options = RequestOptions();
      ApiProblem problem(int status, [Object? data]) => ApiProblem.fromDio(
        DioException.badResponse(
          statusCode: status,
          requestOptions: options,
          response: Response(
            requestOptions: options,
            statusCode: status,
            data: data,
          ),
        ),
      );

      expect(
        ApiProblem.fromDio(
          DioException.connectionError(
            requestOptions: options,
            reason: 'no signal',
          ),
        ).code,
        'offline',
      );
      final invalid = problem(422, {
        'message': 'The email field must be a valid email address.',
        'errors': {
          'email': ['The email field must be a valid email address.'],
        },
      });
      expect(invalid.code, 'invalid');
      expect(invalid.fields, {'email'});
      expect(problem(429).code, 'too_many');
      expect(problem(401).code, 'signed_out');
      expect(problem(500).code, 'server');
    });
  });

  group('sign-in', () {
    test('a 401 on a signed-in request signs the phone out', () async {
      var signedOut = false;
      final dio = createApiClient(
        baseUrl: 'https://api.test/api/v1',
        token: () => 'old-token',
        onSignedOut: () => signedOut = true,
        adapter: FakeAdapter([
          () => json({'message': 'Unauthenticated.'}, status: 401),
        ]),
      );

      await expectLater(
        ApiProfileRepository(dio).fetchMe(),
        throwsA(isA<ApiProblem>()),
      );
      expect(signedOut, isTrue);
    });

    test('verify returns the token and the account', () async {
      final adapter = FakeAdapter([
        () => json({
          'token': '1|abc',
          'new_account': true,
          'user': {
            'id': 7,
            'name': null,
            'email': 'dara@example.com',
            'phone': null,
            'language': 'km',
            'points': 52,
            'reward_points': 50,
            'has_reward': true,
          },
        }),
      ]);

      final signIn = await ApiAuthRepository(client(adapter))
          .verify('dara@example.com', '123456', language: 'km');

      expect(adapter.requests.single.data, {
        'email': 'dara@example.com',
        'code': '123456',
        'language': 'km',
        'device_name': 'phone',
      });
      expect(signIn.token, '1|abc');
      expect(signIn.newAccount, isTrue);
      expect(signIn.account.hasReward, isTrue);
      expect(signIn.account.language, 'km');
    });
  });

  group('store', () {
    const store = StoreInfo(
      prepMinutes: 7,
      openNow: true,
      canOrderNow: true,
      openingHours: {
        'wed': (open: '07:00', close: '18:00'),
        'thu': (open: '07:00', close: '18:00'),
      },
    );

    test('pickup slots start after the prep time and end at closing', () {
      // Wednesday 2 December 2026, 16:50
      final slots = store.pickupSlots(DateTime(2026, 12, 2, 16, 50));
      expect(slots.map((s) => '${s.hour}:${s.minute}'), [
        '17:0',
        '17:15',
        '17:30',
        '17:45',
        '18:0',
      ]);
    });

    test('no slots on a closed day or while orders are paused', () {
      expect(store.pickupSlots(DateTime(2026, 12, 6, 9)), isEmpty); // Sunday
      const paused = StoreInfo(
        prepMinutes: 7,
        openNow: true,
        canOrderNow: false,
        acceptingOrders: false,
        openingHours: {'wed': (open: '07:00', close: '18:00')},
      );
      expect(paused.pickupSlots(DateTime(2026, 12, 2, 9)), isEmpty);
    });
  });

  group('live status', () {
    test('subscribes with a signed channel and passes status events', () async {
      final server = StreamChannelController<dynamic>();
      final adapter = FakeAdapter([
        () => json({'auth': 'app-key:signature'}),
      ]);
      Uri? connectedTo;
      final updates = ReverbOrderUpdates(
        client(adapter),
        url: 'wss://live.test/app/app-key',
        connect: (uri) {
          connectedTo = uri;
          return FakeSocket(server.local);
        },
      );

      final events = <StatusEvent>[];
      final subscription = updates.watch(42).listen(events.add);
      final sent = StreamQueue(server.foreign.stream);

      server.foreign.sink.add(
        jsonEncode({
          'event': 'pusher:connection_established',
          'data': jsonEncode({'socket_id': '123.456'}),
        }),
      );
      final subscribe = jsonDecode(await sent.next as String);
      expect(subscribe, {
        'event': 'pusher:subscribe',
        'data': {'channel': 'private-orders.42', 'auth': 'app-key:signature'},
      });
      expect(connectedTo!.host, 'live.test');
      expect(connectedTo!.queryParameters['protocol'], '7');
      expect(
        adapter.requests.single.uri.toString(),
        'https://api.test/api/broadcasting/auth',
      );
      expect(adapter.requests.single.data, {
        'socket_id': '123.456',
        'channel_name': 'private-orders.42',
      });

      server.foreign.sink.add(jsonEncode({'event': 'pusher:ping'}));
      expect(jsonDecode(await sent.next as String)['event'], 'pusher:pong');

      server.foreign.sink.add(
        jsonEncode({
          'event': 'status',
          'channel': 'private-orders.42',
          'data': jsonEncode({'id': 42, 'status': 'preparing'}),
        }),
      );
      await pumpEventQueue();
      expect(events.single.status, 'preparing');

      await subscription.cancel();
    });

    test('a dropped connection ends the stream with an error', () async {
      final server = StreamChannelController<dynamic>();
      final updates = ReverbOrderUpdates(
        client(FakeAdapter([])),
        url: 'wss://live.test/app/app-key',
        connect: (_) => FakeSocket(server.local),
      );
      final done = updates.watch(42).toList();
      await server.foreign.sink.close();
      await expectLater(done, throwsStateError);
    });
  });
}

/// A WebSocket that talks to the test instead of a server.
class FakeSocket extends StreamChannelMixin<dynamic>
    implements WebSocketChannel {
  FakeSocket(this._channel);

  final StreamChannel<dynamic> _channel;

  @override
  Stream<dynamic> get stream => _channel.stream;

  @override
  WebSocketSink get sink => _FakeSink(_channel.sink);

  @override
  Future<void> get ready async {}

  @override
  String? get protocol => null;

  @override
  int? get closeCode => null;

  @override
  String? get closeReason => null;
}

class _FakeSink extends DelegatingStreamSink<dynamic> implements WebSocketSink {
  _FakeSink(super.sink);

  @override
  Future<void> close([int? closeCode, String? closeReason]) => super.close();
}
