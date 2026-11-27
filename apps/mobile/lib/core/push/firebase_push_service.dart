import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';

import 'push_service.dart';

/// Pushes through Firebase Cloud Messaging. The Firebase settings come from
/// apps/mobile/firebase.json, passed with `--dart-define-from-file`, and
/// the Android build reads the same file (see the README). So no
/// google-services.json or GoogleService-Info.plist is needed.
///
/// It uses FCM registration tokens (getToken), which the server sends to
/// with the HTTP v1 API. firebase_messaging 17 marks them deprecated in
/// favour of installation ids (register), which need a different send API
/// on the server; switch both together when moving.
// ignore_for_file: deprecated_member_use
class FirebasePushService implements PushService {
  FirebasePushService._(this._messaging);

  final FirebaseMessaging _messaging;

  static const _projectId = String.fromEnvironment('FIREBASE_PROJECT_ID');
  static const _senderId = String.fromEnvironment('FIREBASE_SENDER_ID');
  static const _android = (
    apiKey: String.fromEnvironment('FIREBASE_ANDROID_API_KEY'),
    appId: String.fromEnvironment('FIREBASE_ANDROID_APP_ID'),
  );
  static const _ios = (
    apiKey: String.fromEnvironment('FIREBASE_IOS_API_KEY'),
    appId: String.fromEnvironment('FIREBASE_IOS_APP_ID'),
  );

  static bool get _isIos => defaultTargetPlatform == TargetPlatform.iOS;

  /// Firebase when this build has its settings, otherwise no pushes.
  static Future<PushService> start() async {
    final app = _isIos ? _ios : _android;
    final supported =
        !kIsWeb && (defaultTargetPlatform == TargetPlatform.android || _isIos);
    if (!supported ||
        _projectId.isEmpty ||
        _senderId.isEmpty ||
        app.apiKey.isEmpty ||
        app.appId.isEmpty) {
      return const NoPushService();
    }
    try {
      if (_isIos) {
        await Firebase.initializeApp(
          options: FirebaseOptions(
            apiKey: app.apiKey,
            appId: app.appId,
            messagingSenderId: _senderId,
            projectId: _projectId,
          ),
        );
      } else {
        // The Android build already started Firebase from the same file
        // (android/app/build.gradle.kts), so it can show pushes while the
        // app isn't running
        await Firebase.initializeApp();
      }
      return FirebasePushService._(FirebaseMessaging.instance);
    } on Exception catch (error) {
      debugPrint('Pushes are off: Firebase did not start ($error)');
      return const NoPushService();
    }
  }

  @override
  bool get available => true;

  @override
  String get platform => _isIos ? 'ios' : 'android';

  @override
  Future<String?> token() async {
    final permission = await _messaging.requestPermission();
    if (permission.authorizationStatus == AuthorizationStatus.denied) {
      return null;
    }
    if (_isIos) {
      // Firebase can only hand out a token once Apple has given one
      for (var i = 0; i < 5 && await _messaging.getAPNSToken() == null; i++) {
        await Future<void>.delayed(const Duration(seconds: 1));
      }
    }
    try {
      return await _messaging.getToken();
    } on FirebaseException catch (error) {
      debugPrint('No push token yet: ${error.message}');
      return null;
    }
  }

  @override
  Stream<String> get tokenRefreshes => _messaging.onTokenRefresh;

  @override
  Stream<int> get openedOrders => FirebaseMessaging.onMessageOpenedApp
      .map(_orderId)
      .where((id) => id != null)
      .cast<int>();

  @override
  Future<int?> launchOrder() async {
    final message = await _messaging.getInitialMessage();
    return message == null ? null : _orderId(message);
  }

  @override
  Stream<PushNotice> get notices => FirebaseMessaging.onMessage
      .where((message) => _orderId(message) != null)
      .map(
        (message) => PushNotice(
          orderId: _orderId(message)!,
          title: message.notification?.title ?? '',
        ),
      );

  @override
  Future<void> stop() async {
    try {
      await _messaging.deleteToken();
    } on FirebaseException {
      // Offline: the server forgets the token when Firebase rejects it
    }
  }

  static int? _orderId(RemoteMessage message) =>
      message.data['type'] == 'order_ready'
      ? int.tryParse('${message.data['order_id']}')
      : null;
}
