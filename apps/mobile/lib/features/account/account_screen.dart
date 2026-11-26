import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../core/l10n.dart';
import '../../core/settings/settings.dart';
import '../welcome/welcome_screen.dart';

/// Settings for now: language, light or dark, order alerts, and the welcome
/// screens again. Sign-in and profile come with accounts.
class AccountScreen extends ConsumerWidget {
  const AccountScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = context.l10n;
    final scheme = Theme.of(context).colorScheme;
    final settings = ref.watch(settingsProvider);
    final notifier = ref.read(settingsProvider.notifier);
    final label = TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.w600,
      color: scheme.onSurface,
    );

    Widget titled(IconData icon, String title, Widget child) => Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Icon(icon, color: scheme.onSurfaceVariant),
            const SizedBox(width: 12),
            Text(title, style: label),
          ],
        ),
        const SizedBox(height: 10),
        child,
      ],
    );

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 24, bottom: 12),
              child: Semantics(
                header: true,
                child: Text(
                  t.tabAccount,
                  style: Theme.of(context).textTheme.headlineMedium
                      ?.copyWith(fontSize: 30, fontWeight: FontWeight.w800),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Text(
                t.settings,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: scheme.onSurfaceVariant,
                ),
              ),
            ),
            Material(
              color: scheme.surfaceContainerLow,
              borderRadius: BorderRadius.circular(16),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    titled(
                      Icons.language,
                      t.language,
                      SegmentedButton<String>(
                        segments: [
                          for (final (code, name) in languages)
                            ButtonSegment(value: code, label: Text(name)),
                        ],
                        selected: {context.language},
                        onSelectionChanged: (v) =>
                            notifier.setLanguage(v.single),
                      ),
                    ),
                    const SizedBox(height: 16),
                    titled(
                      Icons.dark_mode_outlined,
                      t.appearance,
                      SegmentedButton<ThemeMode>(
                        segments: [
                          ButtonSegment(
                            value: ThemeMode.system,
                            label: Text(t.themeSystem),
                          ),
                          ButtonSegment(
                            value: ThemeMode.light,
                            label: Text(t.themeLight),
                          ),
                          ButtonSegment(
                            value: ThemeMode.dark,
                            label: Text(t.themeDark),
                          ),
                        ],
                        selected: {settings.themeMode},
                        onSelectionChanged: (v) =>
                            notifier.setThemeMode(v.single),
                      ),
                    ),
                    const SizedBox(height: 8),
                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      secondary: Icon(
                        Icons.notifications_outlined,
                        color: scheme.onSurfaceVariant,
                      ),
                      title: Text(t.orderAlerts, style: label),
                      value: settings.orderAlerts,
                      onChanged: notifier.setOrderAlerts,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Material(
              color: scheme.surfaceContainerLow,
              borderRadius: BorderRadius.circular(16),
              clipBehavior: Clip.antiAlias,
              child: ListTile(
                minTileHeight: 56,
                leading: const Icon(Icons.waving_hand_outlined),
                title: Text(t.showWelcomeAgain),
                trailing: const Icon(Icons.chevron_right),
                onTap: notifier.showWelcomeAgain,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
