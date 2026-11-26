import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:homecoffee_domain/homecoffee_domain.dart';
import 'package:material_ui/material_ui.dart';

import '../../core/l10n.dart';
import '../../core/router/app_router.dart';
import '../cart/presentation/cart_notifier.dart';

/// The four tabs, with the View cart bar floating above them on the menu.
class AppShell extends ConsumerWidget {
  const AppShell({super.key, required this.shell});

  final StatefulNavigationShell shell;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = context.l10n;
    final showCart =
        shell.currentIndex == 0 && ref.watch(cartCountProvider) > 0;
    return Scaffold(
      body: shell,
      // The menu scrolls behind the floating cart bar
      extendBody: true,
      bottomNavigationBar: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (showCart) const CartBar(),
          NavigationBar(
            selectedIndex: shell.currentIndex,
            onDestinationSelected: (i) =>
                shell.goBranch(i, initialLocation: i == shell.currentIndex),
            destinations: [
              NavigationDestination(
                icon: const Icon(Icons.local_cafe_outlined),
                selectedIcon: const Icon(Icons.local_cafe),
                label: t.tabMenu,
              ),
              NavigationDestination(
                icon: const Icon(Icons.receipt_long_outlined),
                selectedIcon: const Icon(Icons.receipt_long),
                label: t.tabOrders,
              ),
              NavigationDestination(
                icon: const Icon(Icons.star_outline),
                selectedIcon: const Icon(Icons.star),
                label: t.tabRewards,
              ),
              NavigationDestination(
                icon: const Icon(Icons.person_outline),
                selectedIcon: const Icon(Icons.person),
                label: t.tabAccount,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// "3  View cart  $11.25", a full-width pill that opens the cart.
class CartBar extends ConsumerWidget {
  const CartBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = context.l10n;
    final scheme = Theme.of(context).colorScheme;
    final count = ref.watch(cartCountProvider);
    final subtotal = orderTotals(ref.watch(cartProvider)).subtotal;
    const bold = TextStyle(fontSize: 16, fontWeight: FontWeight.w700);
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      child: Semantics(
        button: true,
        label: '${t.viewCart}, ${t.itemCount(count)}, ${formatPrice(subtotal)}',
        excludeSemantics: true,
        child: Material(
          color: scheme.primary,
          shape: const StadiumBorder(),
          elevation: 4,
          child: InkWell(
            key: const Key('cart-bar'),
            customBorder: const StadiumBorder(),
            onTap: () => openCart(context),
            child: SizedBox(
              height: 56,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: DefaultTextStyle.merge(
                  style: bold.copyWith(color: scheme.onPrimary),
                  child: Row(
                    children: [
                      Container(
                        constraints: const BoxConstraints(minWidth: 28),
                        height: 28,
                        padding: const EdgeInsets.symmetric(horizontal: 6),
                        alignment: Alignment.center,
                        decoration: ShapeDecoration(
                          color: scheme.onPrimary,
                          shape: const StadiumBorder(),
                        ),
                        child: Text(
                          '$count',
                          style: TextStyle(color: scheme.primary),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(child: Text(t.viewCart)),
                      Text(formatPrice(subtotal)),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
