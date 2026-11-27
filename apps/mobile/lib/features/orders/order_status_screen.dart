import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:homecoffee_data/homecoffee_data.dart';
import 'package:homecoffee_domain/homecoffee_domain.dart';
import 'package:material_ui/material_ui.dart';

import '../../core/l10n.dart';
import '../../core/problems.dart';
import '../../core/session/session.dart';
import '../../core/settings/settings.dart';
import '../checkout/checkout_screen.dart' show formatTime;
import 'data/orders_providers.dart';

/// "#1042, show this number at the counter", where the order is, and what
/// was in it. Moves on by itself as the barista works.
class OrderStatusScreen extends ConsumerWidget {
  const OrderStatusScreen({super.key, required this.id});

  final int id;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = context.l10n;
    final order = ref.watch(orderProvider(id));
    void close() => context.canPop() ? context.pop() : context.go('/');

    return Scaffold(
      appBar: AppBar(
        leading: CloseButton(onPressed: close),
        title: Text(t.statusTitle),
      ),
      body: switch (order) {
        AsyncValue(:final value?) => _OrderDetails(order: value),
        AsyncError() => Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(t.orderMissing, style: const TextStyle(fontSize: 16)),
                const SizedBox(height: 16),
                FilledButton(
                  onPressed: () => ref.invalidate(orderProvider(id)),
                  child: Text(t.tryAgain),
                ),
              ],
            ),
          ),
        ),
        _ => const Center(child: CircularProgressIndicator()),
      },
      bottomNavigationBar: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
          child: OutlinedButton(
            style: OutlinedButton.styleFrom(
              minimumSize: const Size.fromHeight(56),
              textStyle: context.largeButtonText,
            ),
            onPressed: () => context.go('/'),
            child: Text(t.backToMenu),
          ),
        ),
      ),
    );
  }
}

class _OrderDetails extends ConsumerWidget {
  const _OrderDetails({required this.order});

  final Order order;

  Future<void> _cancel(BuildContext context, WidgetRef ref) async {
    final t = context.l10n;
    final sure = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(t.cancelOrderTitle),
        content: Text(t.cancelOrderBody),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(t.keepOrder),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(t.cancelOrder),
          ),
        ],
      ),
    );
    if (sure != true || !context.mounted) return;
    final messenger = ScaffoldMessenger.of(context);
    try {
      await ref.read(orderProvider(order.id).notifier).cancel();
      messenger.showSnackBar(SnackBar(content: Text(t.orderCancelled)));
    } on ApiProblem catch (problem) {
      messenger.showSnackBar(SnackBar(content: Text(problemText(t, problem))));
      ref.read(orderProvider(order.id).notifier).reload();
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = context.l10n;
    final language = context.language;
    final scheme = Theme.of(context).colorScheme;
    final settings = ref.watch(settingsProvider);
    final account = ref.watch(accountProvider);
    final status = order.status;
    final readyAround = formatTime(context, order.estimatedReadyAt);

    final (heroBg, heroFg) = switch (status) {
      OrderStatus.ready => (
        scheme.tertiaryContainer,
        scheme.onTertiaryContainer,
      ),
      OrderStatus.cancelled => (
        scheme.surfaceContainerHighest,
        scheme.onSurface,
      ),
      _ => (scheme.primaryContainer, scheme.onPrimaryContainer),
    };
    final statusText = switch (status) {
      OrderStatus.received => t.receivedText(readyAround),
      OrderStatus.preparing => t.preparingText(readyAround),
      OrderStatus.ready => t.readyText,
      OrderStatus.collected => t.collectedText,
      OrderStatus.cancelled => t.cancelledText,
    };
    final pickupText = switch (order.pickupAt) {
      final at? => t.pickupAt(formatTime(context, at)),
      null => t.pickupAsap,
    };

    final steps = [
      (OrderStatus.received, t.statusReceived, order.createdAt),
      (OrderStatus.preparing, t.statusPreparing, order.preparingAt),
      (OrderStatus.ready, t.statusReady, order.readyAt),
      (OrderStatus.collected, t.statusCollected, order.collectedAt),
    ];
    final reached = OrderStatus.values.indexOf(status);

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
      children: [
        Material(
          color: heroBg,
          borderRadius: BorderRadius.circular(24),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: DefaultTextStyle.merge(
              style: TextStyle(color: heroFg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    t.showNumber,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    '#${order.number}',
                    style: TextStyle(
                      fontSize: 44,
                      fontWeight: FontWeight.w700,
                      height: 1.15,
                      color: heroFg,
                    ),
                  ),
                  Semantics(
                    liveRegion: true,
                    child: Text(
                      statusText,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Icon(Icons.schedule, size: 20, color: heroFg),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          pickupText,
                          style: const TextStyle(fontSize: 14),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),
        if (status != OrderStatus.cancelled)
          for (final (i, (step, label, at)) in steps.indexed)
            _Step(
              label: label,
              time: at == null ? null : formatTime(context, at),
              done: i < reached || status == OrderStatus.collected,
              current: i == reached && status != OrderStatus.collected,
              last: i == steps.length - 1,
              ready: step == OrderStatus.ready,
            ),
        if (status.isOpen) ...[
          Material(
            color: scheme.surfaceContainerLow,
            borderRadius: BorderRadius.circular(16),
            clipBehavior: Clip.antiAlias,
            child: SwitchListTile(
              secondary: Icon(
                Icons.notifications_outlined,
                color: scheme.onSurfaceVariant,
              ),
              title: Text(t.notifyMe),
              value: settings.orderAlerts,
              onChanged: ref.read(settingsProvider.notifier).setOrderAlerts,
            ),
          ),
          const SizedBox(height: 16),
        ],
        if (status == OrderStatus.collected && order.pointsEarned > 0) ...[
          Material(
            color: scheme.primaryContainer,
            borderRadius: BorderRadius.circular(16),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.star_outline, color: scheme.onPrimaryContainer),
                  const SizedBox(width: 12),
                  Expanded(
                    child: DefaultTextStyle.merge(
                      style: TextStyle(color: scheme.onPrimaryContainer),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            t.earnedTitle(order.pointsEarned),
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          if (account != null) ...[
                            Text(
                              t.earnedBody(account.points),
                              style: const TextStyle(fontSize: 14),
                            ),
                            if (account.hasReward)
                              Text(
                                t.rewardReady,
                                style: const TextStyle(fontSize: 14),
                              ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
        ],
        Text(
          t.items,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 4),
        for (final line in order.lines)
          Container(
            padding: const EdgeInsets.symmetric(vertical: 8),
            decoration: BoxDecoration(
              border: Border(bottom: BorderSide(color: scheme.outlineVariant)),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${line.quantity} × ${line.nameIn(language)}',
                        style: const TextStyle(fontSize: 16),
                      ),
                      if (line.choicesIn(language).isNotEmpty)
                        Text(
                          line.choicesIn(language),
                          style: TextStyle(
                            fontSize: 14,
                            color: scheme.onSurfaceVariant,
                          ),
                        ),
                      if (line.note case final note? when note.isNotEmpty)
                        Text(
                          t.noteLine(note),
                          style: TextStyle(
                            fontSize: 14,
                            color: scheme.onSurfaceVariant,
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  formatPrice(line.lineCents),
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        if (order.discountCents > 0)
          _TotalRow(
            t.freeDrink,
            formatPrice(-order.discountCents),
            color: scheme.tertiary,
          ),
        if (order.promoCents > 0)
          _TotalRow(
            t.promoLine(order.promoCode ?? ''),
            formatPrice(-order.promoCents),
            color: scheme.tertiary,
          ),
        _TotalRow(t.total, formatPrice(order.totalCents), bold: true),
        Text(
          t.payCounter,
          style: TextStyle(fontSize: 14, color: scheme.onSurfaceVariant),
        ),
        if (order.canCancel) ...[
          const SizedBox(height: 16),
          Align(
            alignment: AlignmentDirectional.centerStart,
            child: TextButton.icon(
              style: TextButton.styleFrom(
                foregroundColor: scheme.error,
                minimumSize: const Size(48, 48),
              ),
              onPressed: () => _cancel(context, ref),
              icon: const Icon(Icons.close),
              label: Text(t.cancelOrder),
            ),
          ),
        ],
      ],
    );
  }
}

class _TotalRow extends StatelessWidget {
  const _TotalRow(this.label, this.value, {this.color, this.bold = false});

  final String label;
  final String value;
  final Color? color;
  final bool bold;

  @override
  Widget build(BuildContext context) {
    final style = TextStyle(
      fontSize: 16,
      color: color,
      fontWeight: bold ? FontWeight.w700 : FontWeight.w400,
    );
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Expanded(child: Text(label, style: style)),
          Text(value, style: style),
        ],
      ),
    );
  }
}

/// One step of the timeline: a dot (with a tick once done) and a line down
/// to the next step.
class _Step extends StatelessWidget {
  const _Step({
    required this.label,
    required this.time,
    required this.done,
    required this.current,
    required this.last,
    required this.ready,
  });

  final String label;
  final String? time;
  final bool done;
  final bool current;
  final bool last;
  final bool ready;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final accent = ready && (done || current)
        ? scheme.tertiary
        : scheme.primary;
    final ring = done || current ? accent : scheme.outline;
    return Semantics(
      selected: current,
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(
              width: 32,
              child: Column(
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: done ? accent : Colors.transparent,
                      border: Border.all(color: ring, width: 2),
                    ),
                    child: done
                        ? Icon(Icons.check, size: 18, color: scheme.surface)
                        : current
                        ? Center(
                            child: Container(
                              width: 12,
                              height: 12,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: accent,
                              ),
                            ),
                          )
                        : null,
                  ),
                  if (!last)
                    Expanded(
                      child: Container(
                        width: 2,
                        constraints: const BoxConstraints(minHeight: 24),
                        color: done ? accent : scheme.outlineVariant,
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(top: 4, bottom: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: current ? FontWeight.w700 : FontWeight.w500,
                        color: done || current
                            ? scheme.onSurface
                            : scheme.onSurfaceVariant,
                      ),
                    ),
                    if (time case final time?)
                      Text(
                        time,
                        style: TextStyle(
                          fontSize: 14,
                          color: scheme.onSurfaceVariant,
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
