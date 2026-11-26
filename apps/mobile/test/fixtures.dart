import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:homecoffee/app.dart';
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
  @override
  Future<StoreInfo> fetchStore() async =>
      const StoreInfo(prepMinutes: 7, openNow: true, canOrderNow: true);
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
Future<ProviderContainer> pumpApp(
  WidgetTester tester, {
  bool welcomed = true,
  String? language = 'en',
}) async {
  // A 390 x 844 phone, like the prototype
  tester.view.physicalSize = const Size(1170, 2532);
  tester.view.devicePixelRatio = 3;
  addTearDown(tester.view.reset);
  final prefs = await emptyPreferences({
    'settings.welcomed': welcomed,
    'settings.language': ?language,
  });
  final container = ProviderContainer(
    overrides: [
      preferencesProvider.overrideWithValue(prefs),
      menuRepositoryProvider.overrideWithValue(FakeMenuRepository()),
      storeRepositoryProvider.overrideWithValue(FakeStoreRepository()),
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
