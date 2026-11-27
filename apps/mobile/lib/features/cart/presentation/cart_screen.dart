import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:homecoffee_domain/homecoffee_domain.dart';
import 'package:material_ui/material_ui.dart';

import '../../../core/l10n.dart';
import '../../auth/sign_in_screen.dart';
import '../../menu/presentation/product_image.dart';
import 'cart_notifier.dart';

/// The cart: each line with its choices and a quantity stepper, the points
/// this order earns, and the subtotal, then on to checkout.
class CartScreen extends ConsumerWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = context.l10n;
    final cart = ref.watch(cartProvider);
    final scheme = Theme.of(context).colorScheme;
    final subtotal = orderTotals(cart).subtotal;

    void backToMenu() => context.canPop() ? context.pop() : context.go('/');

    return Scaffold(
      appBar: AppBar(
        title: Text(t.yourCart),
        leading: BackButton(onPressed: backToMenu),
      ),
      body: cart.isEmpty
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircleAvatar(
                      radius: 36,
                      backgroundColor: scheme.primaryContainer,
                      foregroundColor: scheme.onPrimaryContainer,
                      child: const Icon(Icons.shopping_bag_outlined, size: 34),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      t.cartEmpty,
                      style: Theme.of(context).textTheme.titleLarge
                          ?.copyWith(fontSize: 20),
                    ),
                    const SizedBox(height: 20),
                    FilledButton(
                      onPressed: backToMenu,
                      child: Text(t.browseMenu),
                    ),
                  ],
                ),
              ),
            )
          : ListView(
              children: [
                for (final line in cart) _CartLine(line: line),
                Align(
                  alignment: AlignmentDirectional.centerStart,
                  child: Padding(
                    padding: const EdgeInsets.all(8),
                    child: TextButton.icon(
                      onPressed: backToMenu,
                      icon: const Icon(Icons.add),
                      label: Text(t.addMore),
                    ),
                  ),
                ),
                Container(
                  margin: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                  decoration: BoxDecoration(
                    color: scheme.primaryContainer,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.star_outline,
                        color: scheme.onPrimaryContainer,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          t.earnPoints(pointsFor(subtotal)),
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: scheme.onPrimaryContainer,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
      bottomNavigationBar: cart.isEmpty
          ? null
          : DecoratedBox(
              decoration: BoxDecoration(
                color: scheme.surfaceContainer,
                border: Border(top: BorderSide(color: scheme.outlineVariant)),
              ),
              child: SafeArea(
                top: false,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.baseline,
                        textBaseline: TextBaseline.alphabetic,
                        children: [
                          Expanded(
                            child: Text(
                              t.subtotal,
                              style: TextStyle(
                                fontSize: 16,
                                color: scheme.onSurfaceVariant,
                              ),
                            ),
                          ),
                          Text(
                            formatPrice(subtotal),
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      FilledButton(
                        style: FilledButton.styleFrom(
                          minimumSize: const Size.fromHeight(56),
                          textStyle: context.largeButtonText,
                        ),
                        onPressed: () => openCheckout(context, ref),
                        child: Text(t.toCheckout),
                      ),
                    ],
                  ),
                ),
              ),
            ),
    );
  }
}

class _CartLine extends ConsumerWidget {
  const _CartLine({required this.line});

  final CartItem line;

  void remove(BuildContext context, WidgetRef ref, String name) {
    final notifier = ref.read(cartProvider.notifier);
    final index = ref.read(cartProvider).indexOf(line);
    notifier.remove(line.key);
    final t = context.l10n;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(t.removed(name)),
          action: SnackBarAction(
            label: t.undo,
            onPressed: () => notifier.restore(line, index),
          ),
        ),
      );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = context.l10n;
    final language = context.language;
    final scheme = Theme.of(context).colorScheme;
    final name = line.product.nameIn(language);
    final choices = describeChoices(line, language);
    final quiet = TextStyle(fontSize: 14, color: scheme.onSurfaceVariant);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: scheme.outlineVariant)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: ProductImage(line.product, size: 72),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (choices.isNotEmpty) Text(choices, style: quiet),
                if (line.note.isNotEmpty)
                  Text(t.noteLine(line.note), style: quiet),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Container(
                      decoration: ShapeDecoration(
                        color: scheme.surfaceContainer,
                        shape: const StadiumBorder(),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (line.quantity == 1)
                            IconButton(
                              tooltip: t.removeItem(name),
                              color: scheme.error,
                              icon: const Icon(Icons.delete_outline),
                              onPressed: () => remove(context, ref, name),
                            )
                          else
                            IconButton(
                              tooltip: t.decreaseOf(name),
                              icon: const Icon(Icons.remove),
                              onPressed: () => ref
                                  .read(cartProvider.notifier)
                                  .changeQuantity(line.key, -1),
                            ),
                          SizedBox(
                            width: 20,
                            child: Text(
                              '${line.quantity}',
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          IconButton(
                            tooltip: t.increaseOf(name),
                            icon: const Icon(Icons.add),
                            onPressed: () => ref
                                .read(cartProvider.notifier)
                                .changeQuantity(line.key, 1),
                          ),
                        ],
                      ),
                    ),
                    const Spacer(),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          formatPrice(line.lineTotal),
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        if (line.quantity > 1)
                          Text(
                            t.each(formatPrice(line.unitPrice)),
                            style: quiet,
                          ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
