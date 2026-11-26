import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:homecoffee_ui/homecoffee_ui.dart';
import 'package:material_ui/material_ui.dart';

import 'core/l10n.dart';
import 'core/router/app_router.dart';
import 'core/settings/settings.dart';

class HomeCoffeeApp extends ConsumerWidget {
  const HomeCoffeeApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    final language = resolveLanguage(
      settings.language,
      WidgetsBinding.instance.platformDispatcher.locale,
    );
    return MaterialApp.router(
      title: 'HomeCoffee',
      routerConfig: ref.watch(routerProvider),
      theme: HomeCoffeeTheme.light(language: language),
      darkTheme: HomeCoffeeTheme.dark(language: language),
      themeMode: settings.themeMode,
      locale: Locale(language),
      supportedLocales: L10n.supportedLocales,
      localizationsDelegates: const [
        L10n.delegate,
        ...GlobalMaterialLocalizations.delegates,
      ],
    );
  }
}
