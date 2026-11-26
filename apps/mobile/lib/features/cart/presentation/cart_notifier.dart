import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:homecoffee_domain/homecoffee_domain.dart';

/// The cart. Anything that watches cartProvider rebuilds when it changes.
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

  /// Puts a removed line back where it was, for Undo.
  void restore(CartItem item, int index) {
    if (state.any((line) => line.key == item.key)) return;
    state = [...state]..insert(index.clamp(0, state.length), item);
  }

  void clear() => state = const [];
}

final cartProvider = NotifierProvider<CartNotifier, List<CartItem>>(
  CartNotifier.new,
);

/// The number on the View cart bar.
final cartCountProvider = Provider<int>(
  (ref) => ref.watch(cartProvider).fold(0, (n, line) => n + line.quantity),
);
