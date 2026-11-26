import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:homecoffee_data/homecoffee_data.dart';
import 'package:homecoffee_domain/homecoffee_domain.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/settings/settings.dart';

final apiClientProvider = Provider<Dio>((ref) => createApiClient());

/// Keeps the last downloaded menu on the phone, so the menu opens with no
/// signal and the server can answer 304 when nothing changed.
class PreferencesMenuStore implements MenuStore {
  PreferencesMenuStore(this._prefs);

  static const _etag = 'menu.etag';
  static const _json = 'menu.json';

  final SharedPreferencesWithCache _prefs;

  @override
  Future<SavedMenu?> read() async {
    final etag = _prefs.getString(_etag);
    final json = _prefs.getString(_json);
    return etag == null || json == null
        ? null
        : SavedMenu(etag: etag, json: json);
  }

  @override
  Future<void> write(SavedMenu menu) async {
    await _prefs.setString(_json, menu.json);
    await _prefs.setString(_etag, menu.etag);
  }
}

final menuStoreProvider = Provider<MenuStore>(
  (ref) => PreferencesMenuStore(ref.watch(preferencesProvider)),
);

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

final storeRepositoryProvider = Provider<StoreRepository>(
  (ref) => ApiStoreRepository(ref.watch(apiClientProvider)),
);

/// Opening state and prep time. Null while loading or with no signal, and
/// the menu header then says nothing about pickup.
final storeProvider = FutureProvider<StoreInfo?>((ref) async {
  try {
    return await ref.watch(storeRepositoryProvider).fetchStore();
  } on DioException {
    return null;
  }
});

/// Product ids with a heart, kept on the phone. They move to the account
/// once customers can sign in.
class FavouritesNotifier extends Notifier<Set<int>> {
  static const _key = 'favourites';

  @override
  Set<int> build() => {
    for (final id in ref.watch(preferencesProvider).getStringList(_key) ?? [])
      ?int.tryParse(id),
  };

  void toggle(int id) {
    state = state.contains(id) ? ({...state}..remove(id)) : {...state, id};
    ref.read(preferencesProvider).setStringList(_key, [
      for (final id in state) '$id',
    ]);
  }
}

final favouritesProvider = NotifierProvider<FavouritesNotifier, Set<int>>(
  FavouritesNotifier.new,
);
