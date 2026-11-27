import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:homecoffee_data/homecoffee_data.dart';
import 'package:homecoffee_domain/homecoffee_domain.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/session/session.dart';
import '../../../core/settings/settings.dart';

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
  } on ApiProblem {
    return null;
  }
});

/// Product ids with a heart. Kept on the phone, and in the account once the
/// customer signs in, so they follow them to a new phone.
class FavouritesNotifier extends Notifier<Set<int>> {
  static const _key = 'favourites';

  @override
  Set<int> build() {
    ref.listen(sessionProvider.select((s) => s?.account.id), (before, after) {
      if (after != null && after != before) _syncWithAccount();
    });
    return {
      for (final id in ref.watch(preferencesProvider).getStringList(_key) ?? [])
        ?int.tryParse(id),
    };
  }

  void toggle(int id) {
    final on = !state.contains(id);
    _save(on ? {...state, id} : ({...state}..remove(id)));
    if (ref.read(signedInProvider)) {
      ref
          .read(profileRepositoryProvider)
          .setFavourite(id, on: on)
          .catchError((Object _) {});
    }
  }

  /// After sign-in: hearts from this phone go up to the account, and the
  /// account's hearts come down to this phone.
  Future<void> _syncWithAccount() async {
    final profile = ref.read(profileRepositoryProvider);
    try {
      final saved = await profile.fetchFavourites();
      for (final id in state.difference(saved)) {
        await profile.setFavourite(id, on: true);
      }
      _save({...state, ...saved});
    } on ApiProblem {
      // No signal: try again next sign-in
    }
  }

  void _save(Set<int> ids) {
    state = ids;
    ref.read(preferencesProvider).setStringList(_key, [
      for (final id in ids) '$id',
    ]);
  }
}

final favouritesProvider = NotifierProvider<FavouritesNotifier, Set<int>>(
  FavouritesNotifier.new,
);
