import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:homecoffee_data/homecoffee_data.dart';

import '../session/session.dart';

/// A push the phone received while the app was open: Android and iOS don't
/// show it themselves then, so the app does.
class PushNotice {
  const PushNotice({required this.orderId, required this.title});

  final int orderId;
  final String title;
}

/// "Your order is ready" notifications. For now the app uses
/// [NoPushService], so nothing is sent to the phone. Adding Firebase Cloud
/// Messaging later means one class that implements this, created in main().
abstract interface class PushService {
  /// False when this build can't receive pushes at all.
  bool get available;

  /// `android` or `ios`, as the API expects.
  String get platform;

  /// Asks for permission the first time, then returns this phone's token.
  /// Null when the customer said no, or pushes aren't [available].
  Future<String?> token();

  /// Firebase replaces a token now and then; the new one must be saved.
  Stream<String> get tokenRefreshes;

  /// Orders whose notification the customer tapped while the app was in
  /// the background.
  Stream<int> get openedOrders;

  /// The order whose notification started the app, if one did.
  Future<int?> launchOrder();

  /// Pushes that arrived while the app was open.
  Stream<PushNotice> get notices;

  /// Drops this phone's token, so nothing more reaches it.
  Future<void> stop();
}

class NoPushService implements PushService {
  const NoPushService();

  @override
  bool get available => false;

  @override
  String get platform => 'android';

  @override
  Future<String?> token() async => null;

  @override
  Stream<String> get tokenRefreshes => const Stream.empty();

  @override
  Stream<int> get openedOrders => const Stream.empty();

  @override
  Future<int?> launchOrder() async => null;

  @override
  Stream<PushNotice> get notices => const Stream.empty();

  @override
  Future<void> stop() async {}
}

final pushServiceProvider = Provider<PushService>(
  (ref) => const NoPushService(),
);

final deviceRepositoryProvider = Provider<DeviceRepository>(
  (ref) => ApiDeviceRepository(ref.watch(apiClientProvider)),
);
