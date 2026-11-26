import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import 'package:homecoffee_domain/homecoffee_domain.dart';

import '../../menu/presentation/product_image.dart';
import 'cart_notifier.dart';

/// The summary half of OrderPage.js. Checkout (contact, pickup time, promo,
/// reward) becomes its own screen in phase 1.
class CartScreen extends ConsumerWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cart = ref.watch(cartProvider);
    final notifier = ref.read(cartProvider.notifier);
    final totals = orderTotals(cart);

    if (cart.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text('Your order')),
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.shopping_bag_outlined, size: 64),
              const SizedBox(height: 12),
              const Text('Your order is empty'),
              const SizedBox(height: 12),
              FilledButton(
                onPressed: () => context.go('/'),
                child: const Text('Browse the menu'),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Your order')),
      body: ListView(
        children: [
          for (final line in cart)
            ListTile(
              leading: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: ProductImage(line.product, size: 56),
              ),
              title: Text(line.product.nameIn('en')),
              subtitle: Text(
                [
                  for (final (group, label) in nonDefaultChoices(
                    line.product,
                    line.options,
                  ))
                    '$group: $label',
                  if (line.note.isNotEmpty) 'Note: ${line.note}',
                ].join(' · '),
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    tooltip: 'Decrease quantity',
                    onPressed: () => notifier.changeQuantity(line.key, -1),
                    icon: const Icon(Icons.remove),
                  ),
                  Text('${line.quantity}'),
                  IconButton(
                    tooltip: 'Increase quantity',
                    onPressed: () => notifier.changeQuantity(line.key, 1),
                    icon: const Icon(Icons.add),
                  ),
                  // The line total, not the unit price the website shows
                  SizedBox(
                    width: 64,
                    child: Text(
                      formatPrice(line.lineTotal),
                      textAlign: TextAlign.end,
                    ),
                  ),
                ],
              ),
            ),
          const Divider(),
          ListTile(
            title: const Text('Total'),
            trailing: Text(
              formatPrice(totals.total),
              style: Theme.of(context).textTheme.titleLarge,
            ),
          ),
        ],
      ),
    );
  }
}
