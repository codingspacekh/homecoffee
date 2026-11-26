import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:homecoffee_data/homecoffee_data.dart';
import 'package:homecoffee_domain/homecoffee_domain.dart';

final apiClientProvider = Provider<Dio>((ref) => createApiClient());

/// Phase 1 swaps in the Laravel API here; screens don't change.
final menuRepositoryProvider = Provider<MenuRepository>(
  (ref) => WebsiteMenuRepository(ref.watch(apiClientProvider)),
);

/// Loaded once and shared, like loadData() in Menu.js.
final menuProvider = FutureProvider<List<Category>>(
  (ref) => ref.watch(menuRepositoryProvider).fetchMenu(),
);

final productProvider = FutureProvider.family<Product?, int>((ref, id) async {
  final menu = await ref.watch(menuProvider.future);
  return menu.expand((c) => c.products).where((p) => p.id == id).firstOrNull;
});

String imageUrl(Product product) => WebsiteMenuRepository.imageUrl(product);
