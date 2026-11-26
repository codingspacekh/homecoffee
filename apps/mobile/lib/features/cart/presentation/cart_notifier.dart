import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:homecoffee_domain/homecoffee_domain.dart';

/// Replaces app.store.cart and the "appcartchange" event: anything that
/// watches cartProvider rebuilds when the cart changes.
class CartNotifier extends Notifier<List<CartItem>> {
  @override
  List<CartItem> build() => const [];

  /// Adds items, merging with lines that have the same key.
  void add(CartItem item) {
    final existing = state.any((line) => line.key == item.key);
    state = existing
        ? [
            for (final line in state)
              line.key == item.key
                  ? line.copyWith(quantity: line.quantity + item.quantity)
                  : line,
          ]
        : [...state, item];
  }

  /// Removes the line when its quantity drops to zero.
  void changeQuantity(String key, int delta) {
    state = [
      for (final line in state)
        if (line.key != key)
          line
        else if (line.quantity + delta > 0)
          line.copyWith(quantity: line.quantity + delta),
    ];
  }

  void remove(String key) =>
      state = state.where((line) => line.key != key).toList();

  void clear() => state = const [];
}

final cartProvider = NotifierProvider<CartNotifier, List<CartItem>>(
  CartNotifier.new,
);

/// The badge on the Cart tab.
final cartCountProvider = Provider<int>(
  (ref) => ref.watch(cartProvider).fold(0, (n, line) => n + line.quantity),
);
