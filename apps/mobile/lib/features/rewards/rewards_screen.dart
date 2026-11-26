import 'package:material_ui/material_ui.dart';

import '../../core/l10n.dart';

/// How points work. The customer's own points and member card arrive with
/// accounts.
class RewardsScreen extends StatelessWidget {
  const RewardsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final t = context.l10n;
    final scheme = Theme.of(context).colorScheme;
    final steps = [
      (Icons.payments_outlined, t.how1),
      (Icons.local_cafe_outlined, t.how2),
      (Icons.receipt_long_outlined, t.how3),
    ];
    return Scaffold(
      appBar: AppBar(title: Text(t.tabRewards)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            t.howItWorks,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
          ),
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
        ],
      ),
    );
  }
}
