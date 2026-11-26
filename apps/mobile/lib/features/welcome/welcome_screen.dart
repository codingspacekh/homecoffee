import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../core/l10n.dart';
import '../../core/settings/settings.dart';
import '../../core/widgets/brand_mark.dart';

/// Four welcome screens on first launch: language, ordering ahead, points,
/// and the one notification we send.
class WelcomeScreen extends ConsumerStatefulWidget {
  const WelcomeScreen({super.key});

  @override
  ConsumerState<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends ConsumerState<WelcomeScreen> {
  static const steps = 4;
  int step = 0;

  SettingsNotifier get settings => ref.read(settingsProvider.notifier);

  void finish({bool alerts = false}) {
    if (ref.read(settingsProvider).language == null) {
      settings.setLanguage(context.language);
    }
    if (alerts) settings.setOrderAlerts(true);
    settings.finishWelcome();
  }

  void next() {
    if (step == 0 && ref.read(settingsProvider).language == null) {
      settings.setLanguage(context.language);
    }
    setState(() => step++);
  }

  @override
  Widget build(BuildContext context) {
    final t = context.l10n;
    final text = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;
    final last = step == steps - 1;
    final (title, body) = switch (step) {
      0 => (t.welcomeTitle, t.welcomeBody),
      1 => (t.orderAheadTitle, t.orderAheadBody),
      2 => (t.pointsTitle, t.pointsBody),
      _ => (t.notifyTitle, t.notifyBody),
    };

    return PopScope(
      canPop: step == 0,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) setState(() => step--);
      },
      child: Scaffold(
        body: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(
                height: 64,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(24, 0, 8, 0),
                  child: Row(
                    children: [
                      Expanded(
                        child: _StepBars(step: step, steps: steps),
                      ),
                      const SizedBox(width: 16),
                      if (!last)
                        TextButton(onPressed: finish, child: Text(t.skip))
                      else
                        const SizedBox(width: 8),
                    ],
                  ),
                ),
              ),
              Expanded(
                child: ListView(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: switch (step) {
                        0 => const _Hero(),
                        1 => const _Photos(),
                        2 => const _PointsPreview(),
                        _ => const _NotificationPreview(),
                      },
                    ),
                    if (step == 0)
                      const Padding(
                        padding: EdgeInsets.fromLTRB(24, 20, 24, 0),
                        child: Row(
                          children: [
                            BrandMark(size: 44),
                            SizedBox(width: 12),
                            Text(
                              'HomeCoffee',
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ],
                        ),
                      ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(24, 24, 24, 8),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Semantics(
                            header: true,
                            child: Text(
                              title,
                              style: text.headlineMedium?.copyWith(
                                fontSize: 30,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            body,
                            style: text.bodyLarge?.copyWith(
                              fontSize: 17,
                              color: context.extras.bodyText,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (step == 0) const _LanguagePicker(),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 12, 24, 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    FilledButton(
                      style: FilledButton.styleFrom(
                        minimumSize: const Size.fromHeight(56),
                        textStyle: context.largeButtonText,
                      ),
                      onPressed: last ? () => finish(alerts: true) : next,
                      child: Text(
                        last ? t.turnOnNotifications : t.continueLabel,
                      ),
                    ),
                    if (last) ...[
                      const SizedBox(height: 4),
                      TextButton(
                        style: TextButton.styleFrom(
                          foregroundColor: scheme.primary,
                          textStyle: context.largeButtonText,
                        ),
                        onPressed: finish,
                        child: Text(t.notNow),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StepBars extends StatelessWidget {
  const _StepBars({required this.step, required this.steps});

  final int step;
  final int steps;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Semantics(
      label: context.l10n.stepOf(step + 1),
      child: Row(
        children: [
          for (var i = 0; i < steps; i++) ...[
            if (i > 0) const SizedBox(width: 6),
            Expanded(
              child: Container(
                height: 4,
                decoration: BoxDecoration(
                  color: i <= step ? scheme.primary : scheme.outlineVariant,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

Widget _photo(String name, {double? height}) => Image.asset(
  'assets/welcome/$name.webp',
  height: height,
  width: double.infinity,
  fit: BoxFit.cover,
  excludeFromSemantics: true,
);

class _Hero extends StatelessWidget {
  const _Hero();

  @override
  Widget build(BuildContext context) => ClipRRect(
    borderRadius: BorderRadius.circular(28),
    child: _photo('cappuccino', height: 210),
  );
}

class _Photos extends StatelessWidget {
  const _Photos();

  @override
  Widget build(BuildContext context) {
    Widget rounded(String name) => ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: SizedBox.expand(child: _photo(name)),
    );
    return SizedBox(
      height: 330,
      child: Row(
        children: [
          Expanded(child: rounded('cappuccino')),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              children: [
                Expanded(child: rounded('icedcoffee')),
                const SizedBox(height: 10),
                Expanded(child: rounded('croissant')),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Panel extends StatelessWidget {
  const _Panel({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) => Container(
    height: 330,
    padding: const EdgeInsets.all(24),
    decoration: BoxDecoration(
      color: Theme.of(context).colorScheme.surfaceContainer,
      borderRadius: BorderRadius.circular(28),
    ),
    child: Center(child: child),
  );
}

class _PointsPreview extends StatelessWidget {
  const _PointsPreview();

  @override
  Widget build(BuildContext context) {
    final t = context.l10n;
    final scheme = Theme.of(context).colorScheme;
    return ExcludeSemantics(
      child: _Panel(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: scheme.primaryContainer,
                borderRadius: BorderRadius.circular(20),
              ),
              child: DefaultTextStyle.merge(
                style: TextStyle(color: scheme.onPrimaryContainer),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      t.yourPoints,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 10),
                    const Row(
                      crossAxisAlignment: CrossAxisAlignment.baseline,
                      textBaseline: TextBaseline.alphabetic,
                      children: [
                        Text(
                          '42',
                          style: TextStyle(
                            fontSize: 44,
                            fontWeight: FontWeight.w800,
                            height: 1.1,
                          ),
                        ),
                        SizedBox(width: 8),
                        Text(
                          '/ 50',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(5),
                      child: LinearProgressIndicator(
                        value: 42 / 50,
                        minHeight: 10,
                        color: scheme.primary,
                        backgroundColor: scheme.surfaceContainerLowest
                            .withValues(alpha: 0.7),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 14),
            Container(
              height: 40,
              padding: const EdgeInsets.symmetric(horizontal: 14),
              decoration: ShapeDecoration(
                color: scheme.tertiaryContainer,
                shape: const StadiumBorder(),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.add, size: 20, color: scheme.onTertiaryContainer),
                  const SizedBox(width: 6),
                  Text(
                    t.pointsSample,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: scheme.onTertiaryContainer,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NotificationPreview extends StatelessWidget {
  const _NotificationPreview();

  @override
  Widget build(BuildContext context) {
    final t = context.l10n;
    final scheme = Theme.of(context).colorScheme;
    return ExcludeSemantics(
      child: _Panel(
        child: Material(
          color: scheme.surface,
          elevation: 6,
          shadowColor: Colors.black38,
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const BrandMark(size: 32),
                    const SizedBox(width: 10),
                    const Expanded(
                      child: Text(
                        'HomeCoffee',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    Text(
                      t.now,
                      style: TextStyle(
                        fontSize: 13,
                        color: scheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  t.sampleNotificationTitle,
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  t.sampleNotificationBody,
                  style: TextStyle(
                    fontSize: 15,
                    color: context.extras.bodyText,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _LanguagePicker extends ConsumerWidget {
  const _LanguagePicker();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scheme = Theme.of(context).colorScheme;
    final current = context.language;
    return RadioGroup<String>(
      groupValue: current,
      onChanged: (value) =>
          ref.read(settingsProvider.notifier).setLanguage(value!),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 8, 24, 16),
        child: Column(
          children: [
            for (final (code, name) in languages) ...[
              if (code != languages.first.$1) const SizedBox(height: 10),
              Material(
                color: code == current
                    ? scheme.secondaryContainer
                    : Colors.transparent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: BorderSide(
                    color: code == current ? scheme.primary : scheme.outline,
                    width: code == current ? 2 : 1,
                  ),
                ),
                clipBehavior: Clip.antiAlias,
                child: RadioListTile<String>(
                  value: code,
                  minTileHeight: 60,
                  title: Text(
                    name,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Each language in its own name, so anyone can find theirs.
const languages = [('en', 'English'), ('km', 'ខ្មែរ')];
