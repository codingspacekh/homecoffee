import 'package:homecoffee_domain/homecoffee_domain.dart';
import 'package:homecoffee/features/cart/presentation/cart_notifier.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'fixtures.dart';

void main() {
  test('same product and choices merge into one line', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    final cart = container.read(cartProvider.notifier);

    cart.add(createItem(cappuccino));
    cart.add(createItem(cappuccino));
    cart.add(createItem(cappuccino, selection: {'Milk': 'Oat'}));

    expect(container.read(cartProvider), hasLength(2));
    expect(container.read(cartCountProvider), 3);
  });

  test('quantity to zero removes the line', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    final cart = container.read(cartProvider.notifier);

    cart.add(createItem(croissant));
    cart.changeQuantity('41', 1);
    expect(container.read(cartProvider).single.quantity, 2);
    cart.changeQuantity('41', -2);
    expect(container.read(cartProvider), isEmpty);
  });
}
