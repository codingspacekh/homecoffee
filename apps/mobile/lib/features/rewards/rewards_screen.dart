import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:homecoffee_data/homecoffee_data.dart';
import 'package:material_ui/material_ui.dart';

import '../../core/l10n.dart';
import '../../core/session/session.dart';
import '../orders/data/orders_providers.dart';

/// Your points towards a free drink, how points work, and the history.
class RewardsScreen extends ConsumerWidget {
  const RewardsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = context.l10n;
    final scheme = Theme.of(context).colorScheme;
    final account = ref.watch(accountProvider);
    final steps = [
      (Icons.payments_outlined, t.how1),
      (Icons.local_cafe_outlined, t.how2),
      (Icons.receipt_long_outlined, t.how3),
    ];
    const heading = TextStyle(fontSize: 18, fontWeight: FontWeight.w700);

    return Scaffold(
      appBar: AppBar(title: Text(t.tabRewards)),
      body: RefreshIndicator(
        onRefresh: () => ref.read(sessionProvider.notifier).refresh(),
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 96),
          children: [
            if (account != null)
              PointsCard(account: account)
            else
              Material(
                color: scheme.primaryContainer,
                borderRadius: BorderRadius.circular(24),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        t.signInHint,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: scheme.onPrimaryContainer,
                        ),
                      ),
                      const SizedBox(height: 12),
                      FilledButton(
                        onPressed: () => context.push('/sign-in'),
                        child: Text(t.signIn),
                      ),
                    ],
                  ),
                ),
              ),
            const SizedBox(height: 24),
            Text(t.howItWorks, style: heading),
            const SizedBox(height: 8),
            Material(
              color: scheme.surfaceContainerLow,
              borderRadius: BorderRadius.circular(16),
              clipBehavior: Clip.antiAlias,
              child: Column(
                children: [
                  for (final (i, (icon, text)) in steps.indexed) ...[
                    if (i > 0) Divider(height: 1, color: scheme.outlineVariant),
                    ListTile(
                      minTileHeight: 64,
                      leading: CircleAvatar(
                        backgroundColor: scheme.primaryContainer,
                        foregroundColor: scheme.onPrimaryContainer,
                        child: Icon(icon),
                      ),
                      title: Text(text),
                    ),
                  ],
                ],
              ),
            ),
            if (account != null) ...[
              const SizedBox(height: 24),
              Text(t.pointsHistory, style: heading),
              const SizedBox(height: 4),
              const _PointsHistory(),
            ],
          ],
        ),
      ),
    );
  }
}

/// "42 / 50 points" with a progress bar.
class PointsCard extends StatelessWidget {
  const PointsCard({super.key, required this.account});

  final Account account;

  @override
  Widget build(BuildContext context) {
    final t = context.l10n;
    final scheme = Theme.of(context).colorScheme;
    final fg = scheme.onPrimaryContainer;
    return Material(
      color: scheme.primaryContainer,
      borderRadius: BorderRadius.circular(24),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Text(
                  '${account.points}',
                  style: TextStyle(
                    fontSize: 48,
                    fontWeight: FontWeight.w700,
                    height: 1.1,
                    color: fg,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  t.pointsOutOf(account.rewardPoints),
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: fg,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Semantics(
              label: t.pointsLabel,
              value: '${account.points} / ${account.rewardPoints}',
              child: ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: LinearProgressIndicator(
                  minHeight: 12,
                  value: (account.points / account.rewardPoints).clamp(0, 1),
                  backgroundColor: scheme.surface.withValues(alpha: 0.6),
                ),
              ),
            ),
            const SizedBox(height: 10),
            Text(
              account.hasReward
                  ? t.haveReward
                  : t.remainingPoints(account.pointsToReward),
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: fg,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PointsHistory extends ConsumerWidget {
  const _PointsHistory();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = context.l10n;
    final scheme = Theme.of(context).colorScheme;
    final history = ref.watch(pointsHistoryProvider).value;
    if (history == null) return const SizedBox(height: 56);
    if (history.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Text(
          t.noPointsYet,
          style: TextStyle(fontSize: 16, color: context.extras.bodyText),
        ),
      );
    }
    return Column(
      children: [
        for (final entry in history)
          Container(
            constraints: const BoxConstraints(minHeight: 56),
            padding: const EdgeInsets.symmetric(vertical: 8),
            decoration: BoxDecoration(
              border: Border(bottom: BorderSide(color: scheme.outlineVariant)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(switch (entry.reason) {
                        PointReason.order => t.orderNumber(
                          entry.orderNumber ?? 0,
                        ),
                        PointReason.reward => t.rewardUsed,
                        PointReason.refund => t.rewardRefunded,
                        PointReason.adjustment => t.pointsAdjusted,
                      }, style: const TextStyle(fontSize: 16)),
                      Text(
                        MaterialLocalizations.of(context)
                            .formatMediumDate(entry.createdAt.toLocal()),
                        style: TextStyle(
                          fontSize: 14,
                          color: scheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                Text(
                  entry.change > 0 ? '+${entry.change}' : '−${-entry.change}',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: entry.change > 0
                        ? scheme.tertiary
                        : scheme.onSurface,
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}
