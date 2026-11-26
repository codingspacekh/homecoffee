import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:homecoffee_data/homecoffee_data.dart';
import 'package:homecoffee_domain/homecoffee_domain.dart';

final apiClientProvider = Provider<Dio>((ref) => createApiClient());

/// Where the last downloaded menu is kept. In memory for now, so it lasts
/// until the app closes; the next step keeps it on the phone.
final menuStoreProvider = Provider<MenuStore>((ref) => MemoryMenuStore());

final menuRepositoryProvider = Provider<MenuRepository>(
  (ref) => ApiMenuRepository(
    ref.watch(apiClientProvider),
    ref.watch(menuStoreProvider),
  ),
);

/// Loaded once and shared by every screen.
final menuProvider = FutureProvider<List<Category>>(
  (ref) => ref.watch(menuRepositoryProvider).fetchMenu(),
);

final productProvider = FutureProvider.family<Product?, int>((ref, id) async {
  final menu = await ref.watch(menuProvider.future);
  return menu.expand((c) => c.products).where((p) => p.id == id).firstOrNull;
});
