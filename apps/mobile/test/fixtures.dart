import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

import 'dart:async';
import 'dart:convert';

import 'package:homecoffee/app.dart';
import 'package:homecoffee/core/push/push_service.dart';
import 'package:homecoffee/core/session/session.dart';
import 'package:homecoffee/core/session/token_store.dart';
import 'package:homecoffee/features/orders/data/orders_providers.dart';
import 'package:homecoffee/core/settings/settings.dart';
import 'package:homecoffee/features/menu/data/menu_providers.dart';
import 'package:homecoffee_data/homecoffee_data.dart';
import 'package:homecoffee_domain/homecoffee_domain.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shared_preferences_platform_interface/in_memory_shared_preferences_async.dart';
import 'package:shared_preferences_platform_interface/shared_preferences_async_platform_interface.dart';

/// Products in the GET /api/v1/menu format, with prices in cents.
final cappuccino = Product.fromJson({
  'id': 12,
  'name': 'Cappuccino',
  'description': 'Espresso with steamed milk and foam.',
  'price_cents': 375,
  'drink': true,
  'translations': {
    'km': {'name': 'កាពូឈីណូ'},
  },
  'options': [
    {
      'name': 'Size',
      'translations': {
        'km': {'name': 'ទំហំ'},
      },
      'choices': [
        {'label': 'Small', 'price_cents': 0},
        {'label': 'Medium', 'price_cents': 50},
        {'label': 'Large', 'price_cents': 100},
      ],
    },
    {
      'name': 'Milk',
      'choices': [
        {'label': 'Whole', 'price_cents': 0},
        {'label': 'Skim', 'price_cents': 0},
        {'label': 'Oat', 'price_cents': 60},
        {'label': 'Almond', 'price_cents': 60},
      ],
    },
  ],
});

final croissant = Product.fromJson({
  'id': 41,
  'name': 'Croissant',
  'description': 'Buttery, crescent-shaped French pastry',
  'price_cents': 280,
  'translations': {
    'km': {'name': 'នំក្រូសង់'},
  },
});

final muffin = Product.fromJson({
  'id': 42,
  'name': 'Chocolate Chip Muffin',
  'price_cents': 175,
  'available': false,
});

final testMenu = [
  Category(
    id: 1,
    name: 'Hot coffee',
    translations: {'km': const Translation(name: 'កាហ្វេក្តៅ')},
    products: [cappuccino],
  ),
  Category(id: 4, name: 'Snacks', products: [croissant, muffin]),
];

class FakeMenuRepository implements MenuRepository {
  @override
  Future<List<Category>> fetchMenu() async => testMenu;
}

class FakeStoreRepository implements StoreRepository {
  FakeStoreRepository({this.openNow = true});

  final bool openNow;

  @override
  Future<StoreInfo> fetchStore() async => StoreInfo(
    prepMinutes: 7,
    openNow: openNow,
    canOrderNow: openNow,
    openingHours: {
      for (final day in StoreInfo.days) day: (open: '07:00', close: '18:00'),
    },
  );
}

const dara = Account(
  id: 7,
  email: 'dara@example.com',
  name: 'Dara',
  phone: '012 345 678',
  points: 12,
  memberCode: '48213075',
);

/// The server, in memory: it signs in with code 123456, prices carts with
/// the domain rules and keeps the orders placed.
class TestBackend
    implements
        AuthRepository,
        ProfileRepository,
        OrdersRepository,
        OrderUpdates,
        DeviceRepository {
  TestBackend({this.account = dara});

  Account account;
  final orders = <int, Order>{};
  final placed = <({Checkout checkout, String key})>[];
  final codesSent = <String>[];
  final favourites = <int>{};
  var signedOut = false;

  /// Push tokens saved for this customer, with their platform.
  final devices = <String, String>{};

  /// Each device call, with whether the customer was still signed in.
  final deviceCalls = <String>[];
  final _live = <int, StreamController<StatusEvent>>{};

  // Sign-in

  @override
  Future<void> sendCode(String email, {String language = 'en'}) async =>
      codesSent.add(email);

  @override
  Future<SignIn> verify(
    String email,
    String code, {
    String language = 'en',
  }) async {
    if (code != '123456') {
      throw const ApiProblem('code_invalid', details: {'attempts_left': 4});
    }
    return SignIn(token: '1|test', account: account, newAccount: false);
  }

  @override
  Future<void> signOut() async => signedOut = true;

  // Profile

  @override
  Future<Account> fetchMe() async => account;

  @override
  Future<Account> update({
    String? name,
    String? phone,
    String? language,
  }) async => account = account.copyWith(name: name, phone: phone);

  @override
  Future<void> deleteMe() async {}

  @override
  Future<Set<int>> fetchFavourites() async => {...favourites};

  @override
  Future<void> setFavourite(int productId, {required bool on}) async =>
      on ? favourites.add(productId) : favourites.remove(productId);

  @override
  Future<Paged<PointEntry>> fetchPoints({int page = 1}) async => Paged([
    PointEntry(
      id: 1,
      change: 12,
      reason: PointReason.order,
      orderNumber: 1001,
      createdAt: DateTime.utc(2026, 11, 26, 2),
    ),
    PointEntry(
      id: 2,
      change: 4,
      reason: PointReason.counter,
      createdAt: DateTime.utc(2026, 11, 25, 2),
    ),
  ]);

  // Orders

  @override
  Future<Quote> quote(Checkout checkout) async {
    final code = checkout.promoCode ?? '';
    final totals = orderTotals(
      checkout.lines,
      points: account.points,
      useReward: checkout.useFreeDrink,
      promoCode: code,
    );
    if (code.isNotEmpty) {
      switch (promoProblem(code, totals.subtotal - totals.discount)) {
        case PromoProblem.unknown:
          throw const ApiProblem('promo_invalid');
        case PromoProblem.minimum:
          throw ApiProblem(
            'promo_minimum',
            details: {'minimum_cents': promos[normalizeCode(code)]!.minimum},
          );
        case PromoProblem.none:
      }
    }
    return Quote(
      subtotalCents: totals.subtotal,
      discountCents: totals.discount,
      promoCode: code.isEmpty ? null : normalizeCode(code),
      promoCents: totals.promoAmount,
      totalCents: totals.total,
      pointsEarned: pointsFor(totals.total),
    );
  }

  @override
  Future<Order> place(
    Checkout checkout, {
    required String idempotencyKey,
  }) async {
    placed.add((checkout: checkout, key: idempotencyKey));
    final quote = await this.quote(checkout);
    final id = orders.length + 42;
    return orders[id] = Order(
      id: id,
      number: 1000 + id,
      status: OrderStatus.received,
      customerName: checkout.customerName,
      pickupAt: checkout.pickupAt,
      estimatedReadyAt: DateTime(2026, 11, 27, 9, 7),
      createdAt: DateTime(2026, 11, 27, 9),
      subtotalCents: quote.subtotalCents,
      discountCents: quote.discountCents,
      promoCode: quote.promoCode,
      promoCents: quote.promoCents,
      totalCents: quote.totalCents,
      pointsEarned: quote.pointsEarned,
      canCancel: true,
      lines: [
        for (final line in checkout.lines)
          OrderLine(
            productId: line.product.id,
            name: line.product.name,
            options: line.options,
            unitCents: line.unitPrice,
            quantity: line.quantity,
            lineCents: line.lineTotal,
          ),
      ],
    );
  }

  @override
  Future<Paged<Order>> fetchOrders({int page = 1}) async =>
      Paged(orders.values.toList().reversed.toList());

  @override
  Future<Order> fetchOrder(int id) async =>
      orders[id] ?? (throw const ApiProblem('server', status: 404));

  @override
  Future<Order> cancel(int id) async {
    final order = orders[id]!;
    if (order.status != OrderStatus.received) {
      throw const ApiProblem('order_not_cancellable');
    }
    return orders[id] = _with(order, OrderStatus.cancelled);
  }

  // Phones for pushes

  @override
  Future<void> save(String token, {required String platform}) async {
    deviceCalls.add('save $token${signedOut ? ' (signed out)' : ''}');
    devices[token] = platform;
  }

  @override
  Future<void> forget(String token) async {
    deviceCalls.add('forget $token${signedOut ? ' (signed out)' : ''}');
    devices.remove(token);
  }

  /// An order the customer placed earlier, ready at the counter.
  Order addReadyOrder({int id = 42}) {
    final order = Order(
      id: id,
      number: 1000 + id,
      status: OrderStatus.received,
      customerName: account.name ?? 'Dara',
      estimatedReadyAt: DateTime(2026, 11, 27, 9, 7),
      createdAt: DateTime(2026, 11, 27, 9),
      subtotalCents: 375,
      totalCents: 375,
      lines: [
        OrderLine(
          productId: 12,
          name: 'Cappuccino',
          options: const {'Size': 'Small'},
          unitCents: 375,
          quantity: 1,
          lineCents: 375,
        ),
      ],
    );
    return orders[id] = _with(order, OrderStatus.ready);
  }

  /// The barista moves the order on, and Reverb tells the phone.
  void advance(int id, OrderStatus status) {
    orders[id] = _with(orders[id]!, status);
    _live[id]?.add(StatusEvent(orderId: id, status: status.name));
  }

  Order _with(Order order, OrderStatus status) => Order(
    id: order.id,
    number: order.number,
    status: status,
    customerName: order.customerName,
    pickupAt: order.pickupAt,
    estimatedReadyAt: order.estimatedReadyAt,
    createdAt: order.createdAt,
    preparingAt: status.index >= 1 && status != OrderStatus.cancelled
        ? DateTime(2026, 11, 27, 9, 2)
        : null,
    readyAt: status.index >= 2 && status != OrderStatus.cancelled
        ? DateTime(2026, 11, 27, 9, 6)
        : null,
    collectedAt: status == OrderStatus.collected
        ? DateTime(2026, 11, 27, 9, 10)
        : null,
    subtotalCents: order.subtotalCents,
    discountCents: order.discountCents,
    promoCode: order.promoCode,
    promoCents: order.promoCents,
    totalCents: order.totalCents,
    pointsEarned: order.pointsEarned,
    canCancel: status == OrderStatus.received,
    lines: order.lines,
  );

  // Live status

  @override
  Stream<StatusEvent> watch(int orderId) =>
      (_live[orderId] ??= StreamController.broadcast()).stream;
}

/// Fresh, empty phone storage for each test.
Future<SharedPreferencesWithCache> emptyPreferences([
  Map<String, Object> values = const {},
]) async {
  SharedPreferencesAsyncPlatform.instance =
      InMemorySharedPreferencesAsync.empty();
  final prefs = await SharedPreferencesWithCache.create(
    cacheOptions: const SharedPreferencesWithCacheOptions(),
  );
  for (final MapEntry(:key, :value) in values.entries) {
    switch (value) {
      case final bool v:
        await prefs.setBool(key, v);
      case final String v:
        await prefs.setString(key, v);
    }
  }
  return prefs;
}

/// The whole app with fake API answers, at 9 in the morning.
///
/// [backend] plays the server; with [signedIn] the phone starts signed in
/// as its account.
Future<ProviderContainer> pumpApp(
  WidgetTester tester, {
  bool welcomed = true,
  String? language = 'en',
  TestBackend? backend,
  bool signedIn = false,
  bool storeOpen = true,
  bool orderAlerts = false,
  PushService push = const NoPushService(),
}) async {
  final server = backend ?? TestBackend();
  // A 390 x 844 phone, like the prototype
  tester.view.physicalSize = const Size(1170, 2532);
  tester.view.devicePixelRatio = 3;
  addTearDown(tester.view.reset);
  final prefs = await emptyPreferences({
    'settings.welcomed': welcomed,
    'settings.language': ?language,
    'settings.orderAlerts': orderAlerts,
    if (signedIn) 'account': jsonEncode(server.account.toJson()),
  });
  final container = ProviderContainer(
    overrides: [
      preferencesProvider.overrideWithValue(prefs),
      menuRepositoryProvider.overrideWithValue(FakeMenuRepository()),
      storeRepositoryProvider.overrideWithValue(
        FakeStoreRepository(openNow: storeOpen),
      ),
      tokenStoreProvider.overrideWithValue(
        MemoryTokenStore(signedIn ? '1|test' : null),
      ),
      authRepositoryProvider.overrideWithValue(server),
      profileRepositoryProvider.overrideWithValue(server),
      ordersRepositoryProvider.overrideWithValue(server),
      orderUpdatesProvider.overrideWithValue(server),
      deviceRepositoryProvider.overrideWithValue(server),
      pushServiceProvider.overrideWithValue(push),
      orderPollingProvider.overrideWithValue(null),
      clockProvider.overrideWithValue(() => DateTime(2026, 11, 27, 9)),
    ],
  );
  addTearDown(container.dispose);
  await tester.pumpWidget(
    UncontrolledProviderScope(
      container: container,
      child: const HomeCoffeeApp(),
    ),
  );
  await tester.pumpAndSettle();
  return container;
}
