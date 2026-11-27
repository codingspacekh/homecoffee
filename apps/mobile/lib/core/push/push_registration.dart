import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:homecoffee_data/homecoffee_data.dart';
import 'package:material_ui/material_ui.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../l10n.dart';
import '../router/app_router.dart';
import '../session/session.dart';
import '../settings/settings.dart';
import 'push_service.dart';

/// Shows snack bars from outside a screen, such as a push that arrives
/// while the app is open.
final messengerKeyProvider = Provider<GlobalKey<ScaffoldMessengerState>>(
  (ref) => GlobalKey<ScaffoldMessengerState>(),
);

/// Keeps the server's list of this customer's phones in step with the
/// order alerts switch: signed in with alerts on means this phone's token
/// is saved; switching alerts off or signing out removes it.
class PushRegistration extends Notifier<void> {
  /// The token last saved on the server, so it can be removed later.
  static const savedKey = 'push.savedToken';

  @override
  void build() {
    final wanted =
        ref.watch(signedInProvider) &&
        ref.watch(settingsProvider.select((s) => s.orderAlerts));
    if (!wanted) {
      Future.microtask(_unregister);
      return;
    }
    // Saved again on every start: the server keeps the newest owner
    Future.microtask(_register);
    final refreshes = ref
        .read(pushServiceProvider)
        .tokenRefreshes
        .listen(_save);
    ref.onDispose(refreshes.cancel);
  }

  PushService get _push => ref.read(pushServiceProvider);

  Future<void> _register() async {
    final token = await _push.token();
    if (!ref.mounted) return;
    if (token != null) return _save(token);
    if (_push.available) {
      // The customer said no on the system prompt: show the switch as off
      ref.read(settingsProvider.notifier).setOrderAlerts(false);
      final messenger = ref.read(messengerKeyProvider).currentState;
      if (messenger == null || !messenger.mounted) return;
      messenger.showSnackBar(
        SnackBar(content: Text(L10n.of(messenger.context).alertsBlocked)),
      );
    }
  }

  Future<void> _save(String token) async {
    try {
      await ref
          .read(deviceRepositoryProvider)
          .save(token, platform: _push.platform);
      if (ref.mounted) {
        await ref.read(preferencesProvider).setString(savedKey, token);
      }
    } on ApiProblem {
      // No signal: saved again on the next start
    }
  }

  Future<void> _unregister() => forgetThisPhone(
    push: _push,
    devices: ref.read(deviceRepositoryProvider),
    preferences: ref.read(preferencesProvider),
    signedIn: ref.read(signedInProvider),
  );
}

/// Stops pushes to this phone: removes its token from the server while the
/// customer is still [signedIn], then drops the token itself. Sign out calls
/// this first, while its request can still be signed.
Future<void> forgetThisPhone({
  required PushService push,
  required DeviceRepository devices,
  required SharedPreferencesWithCache preferences,
  required bool signedIn,
}) async {
  final saved = preferences.getString(PushRegistration.savedKey);
  if (saved == null) return;
  if (signedIn) {
    try {
      await devices.forget(saved);
    } on ApiProblem {
      // The token is dropped below, so Firebase refuses it from now on
    }
  }
  await push.stop();
  await preferences.remove(PushRegistration.savedKey);
}

final pushRegistrationProvider = NotifierProvider<PushRegistration, void>(
  PushRegistration.new,
);

/// Opens the order when the customer taps its notification, and shows a
/// snack bar for one that arrives while the app is open.
final pushTapsProvider = Provider<void>((ref) {
  final push = ref.watch(pushServiceProvider);
  void open(int orderId) => ref.read(routerProvider).push('/order/$orderId');

  final taps = push.openedOrders.listen(open);
  ref.onDispose(taps.cancel);
  push.launchOrder().then((orderId) {
    if (orderId != null && ref.mounted) open(orderId);
  });

  final notices = push.notices.listen((notice) {
    final router = ref.read(routerProvider);
    final here = router.routerDelegate.currentConfiguration.uri.path;
    if (here == '/order/${notice.orderId}') return; // already watching it
    final messenger = ref.read(messengerKeyProvider).currentState;
    if (messenger == null || !messenger.mounted) return;
    final t = L10n.of(messenger.context);
    messenger.showSnackBar(
      SnackBar(
        content: Text(notice.title),
        action: SnackBarAction(
          label: t.viewOrder,
          onPressed: () => open(notice.orderId),
        ),
      ),
    );
  });
  ref.onDispose(notices.cancel);
});
