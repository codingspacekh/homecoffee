import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:homecoffee_ui/homecoffee_ui.dart';
import 'package:material_ui/material_ui.dart';

import 'core/router/app_router.dart';

void main() {
  runApp(const ProviderScope(child: HomeCoffeeApp()));
}

class HomeCoffeeApp extends StatelessWidget {
  const HomeCoffeeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'HomeCoffee',
      routerConfig: appRouter,
      theme: HomeCoffeeTheme.light(),
      darkTheme: HomeCoffeeTheme.dark(),
    );
  }
}
