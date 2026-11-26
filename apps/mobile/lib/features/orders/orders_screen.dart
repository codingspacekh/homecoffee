import 'package:material_ui/material_ui.dart';

import '../../core/l10n.dart';

/// Order history arrives with accounts and checkout. Until then, an empty
/// state that says what will be here.
class OrdersScreen extends StatelessWidget {
  const OrdersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final t = context.l10n;
    final scheme = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(title: Text(t.tabOrders)),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircleAvatar(
                radius: 36,
                backgroundColor: scheme.primaryContainer,
                foregroundColor: scheme.onPrimaryContainer,
                child: const Icon(Icons.receipt_long_outlined, size: 34),
              ),
              const SizedBox(height: 12),
              Text(
                t.noOrders,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleLarge
                    ?.copyWith(fontSize: 20),
              ),
              const SizedBox(height: 8),
              Text(
                t.noOrdersHint,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: context.extras.bodyText),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
