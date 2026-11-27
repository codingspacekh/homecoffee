import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app.dart';
import 'core/push/firebase_push_service.dart';
import 'core/push/push_service.dart';
import 'core/session/session.dart';
import 'core/session/token_store.dart';
import 'core/settings/settings.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final preferences = await SharedPreferencesWithCache.create(
    cacheOptions: const SharedPreferencesWithCacheOptions(),
  );
  final tokens = await SecureTokenStore.load();
  final push = await FirebasePushService.start();
  runApp(
    ProviderScope(
      overrides: [
        preferencesProvider.overrideWithValue(preferences),
        tokenStoreProvider.overrideWithValue(tokens),
        pushServiceProvider.overrideWithValue(push),
      ],
      child: const HomeCoffeeApp(),
    ),
  );
}
