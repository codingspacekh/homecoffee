import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:homecoffee_data/homecoffee_data.dart';

import '../../../core/session/session.dart';

final ordersRepositoryProvider = Provider<OrdersRepository>(
  (ref) => ApiOrdersRepository(ref.watch(apiClientProvider)),
);

/// Live status from Reverb when the build has a REVERB_URL.
final orderUpdatesProvider = Provider<OrderUpdates>(
  (ref) => reverbUrl.isEmpty
      ? const NoOrderUpdates()
      : ReverbOrderUpdates(ref.watch(apiClientProvider), url: reverbUrl),
);

/// How often an open order asks the server for news: often when there are
/// no live updates, rarely as a safety net when there are. Null in tests.
final orderPollingProvider =
    Provider<({Duration withoutLive, Duration withLive})?>(
      (ref) => (
        withoutLive: const Duration(seconds: 10),
        withLive: const Duration(minutes: 1),
      ),
    );

/// The customer's orders, newest first, a page at a time. Empty when signed
/// out.
class OrdersNotifier extends AsyncNotifier<List<Order>> {
  int? _nextPage;

  bool get hasMore => _nextPage != null;

  @override
  Future<List<Order>> build() async {
    final accountId = ref.watch(sessionProvider.select((s) => s?.account.id));
    if (accountId == null) return const [];
    final page = await ref.read(ordersRepositoryProvider).fetchOrders();
    _nextPage = page.nextPage;
    return page.items;
  }

  Future<void> loadMore() async {
    final next = _nextPage;
    final current = state.value;
    if (next == null || current == null) return;
    final page = await ref
        .read(ordersRepositoryProvider)
        .fetchOrders(page: next);
    _nextPage = page.nextPage;
    state = AsyncData([...current, ...page.items]);
  }

  /// Puts a changed order in the list without loading it again.
  void replace(Order order) {
    final current = state.value;
    if (current == null) return;
    final known = current.any((o) => o.id == order.id);
    state = AsyncData(
      known
          ? [for (final o in current) o.id == order.id ? order : o]
          : [order, ...current],
    );
  }
}

final ordersProvider = AsyncNotifierProvider<OrdersNotifier, List<Order>>(
  OrdersNotifier.new,
);

/// One order, kept up to date while it is open: Reverb tells the app when
/// the barista moves it on, and the app also asks the server now and then
/// in case a message was missed or there is no live connection.
class OrderTracker extends AsyncNotifier<Order> {
  OrderTracker(this.id);

  final int id;

  StreamSubscription<StatusEvent>? _live;
  Timer? _poll;

  @override
  Future<Order> build() async {
    ref.onDispose(_stop);
    final order = await ref.read(ordersRepositoryProvider).fetchOrder(id);
    if (order.status.isOpen) _start();
    return order;
  }

  Future<void> reload() async {
    try {
      _apply(await ref.read(ordersRepositoryProvider).fetchOrder(id));
    } on ApiProblem {
      // No signal: the next check tries again
    }
  }

  /// Throws an [ApiProblem] (order_not_cancellable) once the barista has
  /// started.
  Future<void> cancel() async {
    _apply(await ref.read(ordersRepositoryProvider).cancel(id));
  }

  void _apply(Order order) {
    final before = state.value;
    state = AsyncData(order);
    ref.read(ordersProvider.notifier).replace(order);
    if (before?.status != order.status &&
        (order.status == OrderStatus.collected ||
            order.status == OrderStatus.cancelled)) {
      // Points were added or given back
      ref.read(sessionProvider.notifier).refresh();
    }
    if (!order.status.isOpen) _stop();
  }

  void _start() {
    _live = ref
        .read(orderUpdatesProvider)
        .watch(id)
        .listen(
          (_) => reload(),
          onError: (Object _) {
            _live?.cancel();
            _live = null;
            _schedulePolling();
          },
        );
    _schedulePolling();
  }

  void _schedulePolling() {
    final polling = ref.read(orderPollingProvider);
    if (polling == null) return;
    _poll?.cancel();
    _poll = Timer.periodic(
      _live == null ? polling.withoutLive : polling.withLive,
      (_) => reload(),
    );
  }

  void _stop() {
    _live?.cancel();
    _live = null;
    _poll?.cancel();
    _poll = null;
  }
}

final orderProvider = AsyncNotifierProvider.autoDispose
    .family<OrderTracker, Order, int>(OrderTracker.new);

/// The points history, newest first.
final pointsHistoryProvider = FutureProvider.autoDispose<List<PointEntry>>((
  ref,
) async {
  final account = ref.watch(accountProvider);
  if (account == null) return const [];
  // Load again when the balance changes
  ref.watch(accountProvider.select((a) => a?.points));
  final page = await ref.read(profileRepositoryProvider).fetchPoints();
  return page.items;
});
