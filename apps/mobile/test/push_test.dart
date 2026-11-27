import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:homecoffee/core/push/push_registration.dart';
import 'package:homecoffee/core/push/push_service.dart';
import 'package:homecoffee/core/session/session.dart';
import 'package:homecoffee/core/settings/settings.dart';

import 'fixtures.dart';

/// Stands in for Firebase: hands out a token, or none when the customer
/// said no, and lets a test tap or receive a notification.
class FakePush implements PushService {
  FakePush({this.allowed = true, this.launchedFrom});

  bool allowed;
  final int? launchedFrom;
  var tokenValue = 'fcm-token-1';
  var asked = 0;
  var stopped = 0;
  final refreshes = StreamController<String>.broadcast();
  final taps = StreamController<int>.broadcast();
  final arrivals = StreamController<PushNotice>.broadcast();

  @override
  bool get available => true;

  @override
  String get platform => 'android';

  @override
  Future<String?> token() async {
    asked++;
    return allowed ? tokenValue : null;
  }

  @override
  Stream<String> get tokenRefreshes => refreshes.stream;

  @override
  Stream<int> get openedOrders => taps.stream;

  @override
  Future<int?> launchOrder() async => launchedFrom;

  @override
  Stream<PushNotice> get notices => arrivals.stream;

  @override
  Future<void> stop() async => stopped++;
}

void main() {
  group('order alerts', () {
    testWidgets('saves this phone once signed in with alerts on', (
      tester,
    ) async {
      final backend = TestBackend();
      final container = await pumpApp(
        tester,
        backend: backend,
        signedIn: true,
        orderAlerts: true,
        push: FakePush(),
      );

      expect(backend.devices, {'fcm-token-1': 'android'});
      expect(
        container
            .read(preferencesProvider)
            .getString(PushRegistration.savedKey),
        'fcm-token-1',
      );
    });

    testWidgets('waits for sign in before asking', (tester) async {
      final backend = TestBackend();
      final push = FakePush();
      await pumpApp(tester, backend: backend, orderAlerts: true, push: push);

      expect(push.asked, 0);
      expect(backend.devices, isEmpty);
    });

    testWidgets('asks when the customer turns alerts on', (tester) async {
      final backend = TestBackend();
      final container = await pumpApp(
        tester,
        backend: backend,
        signedIn: true,
        push: FakePush(),
      );
      expect(backend.devices, isEmpty);

      container.read(settingsProvider.notifier).setOrderAlerts(true);
      await tester.pumpAndSettle();

      expect(backend.devices.keys, ['fcm-token-1']);
    });

    testWidgets('forgets this phone when alerts are turned off', (
      tester,
    ) async {
      final backend = TestBackend();
      final push = FakePush();
      final container = await pumpApp(
        tester,
        backend: backend,
        signedIn: true,
        orderAlerts: true,
        push: push,
      );

      container.read(settingsProvider.notifier).setOrderAlerts(false);
      await tester.pumpAndSettle();

      expect(backend.devices, isEmpty);
      expect(push.stopped, 1);
      expect(
        container
            .read(preferencesProvider)
            .getString(PushRegistration.savedKey),
        isNull,
      );
    });

    testWidgets('forgets this phone before signing out', (tester) async {
      final backend = TestBackend();
      final container = await pumpApp(
        tester,
        backend: backend,
        signedIn: true,
        orderAlerts: true,
        push: FakePush(),
      );

      await container.read(sessionProvider.notifier).signOut();
      await tester.pumpAndSettle();

      expect(backend.deviceCalls, ['save fcm-token-1', 'forget fcm-token-1']);
      expect(backend.signedOut, isTrue);
    });

    testWidgets('saves the new token when Firebase replaces it', (
      tester,
    ) async {
      final backend = TestBackend();
      final push = FakePush();
      await pumpApp(
        tester,
        backend: backend,
        signedIn: true,
        orderAlerts: true,
        push: push,
      );

      push.refreshes.add('fcm-token-2');
      await tester.pumpAndSettle();

      expect(backend.devices.keys, containsAll(['fcm-token-1', 'fcm-token-2']));
    });

    testWidgets('turns the switch back off when notifications are blocked', (
      tester,
    ) async {
      final backend = TestBackend();
      final container = await pumpApp(
        tester,
        backend: backend,
        signedIn: true,
        orderAlerts: true,
        push: FakePush(allowed: false),
      );

      expect(container.read(settingsProvider).orderAlerts, isFalse);
      expect(backend.devices, isEmpty);
      expect(
        find.text(
          'Notifications are off for HomeCoffee. '
          'Turn them on in your phone’s settings.',
        ),
        findsOneWidget,
      );
    });

    testWidgets('builds without Firebase leave the switch alone', (
      tester,
    ) async {
      final container = await pumpApp(
        tester,
        signedIn: true,
        orderAlerts: true,
      );

      expect(container.read(settingsProvider).orderAlerts, isTrue);
    });
  });

  group('tapping a notification', () {
    testWidgets('opens the order while the app is in the background', (
      tester,
    ) async {
      final backend = TestBackend()..addReadyOrder();
      final push = FakePush();
      await pumpApp(
        tester,
        backend: backend,
        signedIn: true,
        orderAlerts: true,
        push: push,
      );

      push.taps.add(42);
      await tester.pumpAndSettle();

      expect(find.text('#1042'), findsOneWidget);
    });

    testWidgets('opens the order when it started the app', (tester) async {
      final backend = TestBackend()..addReadyOrder();
      await pumpApp(
        tester,
        backend: backend,
        signedIn: true,
        orderAlerts: true,
        push: FakePush(launchedFrom: 42),
      );

      expect(find.text('#1042'), findsOneWidget);
    });

    testWidgets('shows one that arrives while the app is open', (tester) async {
      final backend = TestBackend()..addReadyOrder();
      final push = FakePush();
      await pumpApp(
        tester,
        backend: backend,
        signedIn: true,
        orderAlerts: true,
        push: push,
      );

      push.arrivals.add(
        const PushNotice(orderId: 42, title: 'Order #1042 is ready'),
      );
      await tester.pumpAndSettle();
      expect(find.text('Order #1042 is ready'), findsOneWidget);

      await tester.tap(find.text('View'));
      await tester.pumpAndSettle();
      expect(find.text('#1042'), findsOneWidget);
    });
  });
}
