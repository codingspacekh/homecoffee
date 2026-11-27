import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:homecoffee_data/homecoffee_data.dart';
import 'package:homecoffee_domain/homecoffee_domain.dart';
import 'package:material_ui/material_ui.dart';

import '../../core/l10n.dart';
import '../../core/problems.dart';
import '../../core/router/app_router.dart';
import '../../core/session/session.dart';
import '../cart/presentation/cart_notifier.dart';
import '../menu/data/menu_providers.dart';
import 'data/orders_providers.dart';

/// Open orders to track at the top, then past orders to order again.
class OrdersScreen extends ConsumerWidget {
  const OrdersScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = context.l10n;
    final signedIn = ref.watch(signedInProvider);
    final orders = ref.watch(ordersProvider);

    final Widget body;
    if (!signedIn) {
      body = _EmptyState(
        icon: Icons.receipt_long_outlined,
        title: t.noOrders,
        hint: t.signInHint,
        action: FilledButton(
          onPressed: () => context.push('/sign-in'),
          child: Text(t.signIn),
        ),
      );
    } else {
      body = switch (orders) {
        AsyncValue(:final value?) when value.isEmpty => _EmptyState(
          icon: Icons.receipt_long_outlined,
          title: t.noOrders,
          hint: t.noOrdersHint,
        ),
        AsyncValue(:final value?) => _OrderList(orders: value),
        AsyncError(:final error) => _EmptyState(
          icon: Icons.cloud_off_outlined,
          title: error is ApiProblem ? problemText(t, error) : t.errServer,
          action: FilledButton(
            onPressed: () => ref.invalidate(ordersProvider),
            child: Text(t.tryAgain),
          ),
        ),
        _ => const Center(child: CircularProgressIndicator()),
      };
    }

    return Scaffold(
      appBar: AppBar(title: Text(t.tabOrders)),
      body: body,
    );
  }
}

class _OrderList extends ConsumerWidget {
  const _OrderList({required this.orders});

  final List<Order> orders;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = context.l10n;
    final open = orders.where((o) => o.status.isOpen).toList();
    final past = orders.where((o) => !o.status.isOpen).toList();
    final hasMore = ref.watch(ordersProvider.notifier).hasMore;
    final heading = TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.w700,
      color: Theme.of(context).colorScheme.onSurfaceVariant,
    );

    return RefreshIndicator(
      onRefresh: () => ref.refresh(ordersProvider.future),
      child: ListView(
        // Leaves room for the floating tab bar
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 96),
        children: [
          if (open.isNotEmpty) ...[
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Text(t.inProgress, style: heading),
            ),
            for (final order in open) _OpenOrderCard(order: order),
          ],
          Padding(
            padding: const EdgeInsets.only(top: 16, bottom: 8),
            child: Text(t.pastOrders, style: heading),
          ),
          if (past.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Text(t.noOrders, style: const TextStyle(fontSize: 16)),
            ),
          for (final order in past) _PastOrderCard(order: order),
          if (hasMore)
            Center(
              child: TextButton(
                onPressed: () => ref.read(ordersProvider.notifier).loadMore(),
                child: Text(t.loadMore),
              ),
            ),
        ],
      ),
    );
  }
}

String statusLabel(L10n t, OrderStatus status) => switch (status) {
  OrderStatus.received => t.statusReceived,
  OrderStatus.preparing => t.statusPreparing,
  OrderStatus.ready => t.statusReady,
  OrderStatus.collected => t.statusCollected,
  OrderStatus.cancelled => t.statusCancelled,
};

class _OpenOrderCard extends StatelessWidget {
  const _OpenOrderCard({required this.order});

  final Order order;

  @override
  Widget build(BuildContext context) {
    final t = context.l10n;
    final scheme = Theme.of(context).colorScheme;
    final ready = order.status == OrderStatus.ready;
    final (bg, fg) = ready
        ? (scheme.tertiaryContainer, scheme.onTertiaryContainer)
        : (scheme.primaryContainer, scheme.onPrimaryContainer);
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: bg,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '#${order.number}',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: fg,
                      ),
                    ),
                    Text(
                      statusLabel(t, order.status),
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: fg,
                      ),
                    ),
                  ],
                ),
              ),
              FilledButton(
                style: FilledButton.styleFrom(minimumSize: const Size(48, 48)),
                onPressed: () => context.push('/order/${order.id}'),
                child: Text(t.track),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PastOrderCard extends ConsumerWidget {
  const _PastOrderCard({required this.order});

  final Order order;

  void _reorder(BuildContext context, WidgetRef ref) {
    final t = context.l10n;
    final menu = ref.read(menuProvider).value ?? const [];
    final products = {
      for (final product in menu.expand((c) => c.products)) product.id: product,
    };
    final cart = ref.read(cartProvider.notifier);
    var added = 0;
    for (final line in order.lines) {
      final product = products[line.productId];
      if (product == null || !product.available) continue;
      cart.add(
        createItem(
          product,
          selection: line.options,
          quantity: line.quantity,
          note: line.note ?? '',
        ),
      );
      added++;
    }
    final messenger = ScaffoldMessenger.of(context)..hideCurrentSnackBar();
    if (added == 0) {
      messenger.showSnackBar(SnackBar(content: Text(t.reorderMissing)));
      return;
    }
    messenger.showSnackBar(
      SnackBar(
        content: Text(t.reordered(order.number)),
        action: SnackBarAction(
          label: t.viewCart,
          onPressed: () => openCart(context),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = context.l10n;
    final language = context.language;
    final scheme = Theme.of(context).colorScheme;
    final date = MaterialLocalizations.of(context)
        .formatMediumDate(order.createdAt.toLocal());
    final items = [
      for (final line in order.lines)
        '${line.quantity} ${line.nameIn(language)}',
    ].join(', ');
    final cancelled = order.status == OrderStatus.cancelled;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: scheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(16),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: () => context.push('/order/${order.id}'),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        '#${order.number}',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    Text(
                      cancelled ? '${t.statusCancelled}, $date' : date,
                      style: TextStyle(
                        fontSize: 14,
                        color: cancelled
                            ? scheme.error
                            : scheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(items, style: const TextStyle(fontSize: 16)),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        formatPrice(order.totalCents),
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    Semantics(
                      label: t.reorderLabel(order.number),
                      button: true,
                      excludeSemantics: true,
                      child: FilledButton.tonal(
                        style: FilledButton.styleFrom(
                          minimumSize: const Size(48, 48),
                        ),
                        onPressed: () => _reorder(context, ref),
                        child: Text(t.reorder),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({
    required this.icon,
    required this.title,
    this.hint,
    this.action,
  });

  final IconData icon;
  final String title;
  final String? hint;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircleAvatar(
              radius: 36,
              backgroundColor: scheme.primaryContainer,
              foregroundColor: scheme.onPrimaryContainer,
              child: Icon(icon, size: 34),
            ),
            const SizedBox(height: 12),
            Text(
              title,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleLarge
                  ?.copyWith(fontSize: 20),
            ),
            if (hint case final hint?) ...[
              const SizedBox(height: 8),
              Text(
                hint,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: context.extras.bodyText),
              ),
            ],
            if (action case final action?) ...[
              const SizedBox(height: 20),
              action,
            ],
          ],
        ),
      ),
    );
  }
}
