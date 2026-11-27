import 'dart:async';
import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

/// Where Reverb listens, for example `ws://localhost:8080/app/<REVERB_APP_KEY>`.
/// Set per build with `--dart-define=REVERB_URL=...`. Empty means no live
/// updates, and the order screen checks the server every few seconds instead.
const reverbUrl = String.fromEnvironment('REVERB_URL');

/// The server said an order moved on.
class StatusEvent {
  const StatusEvent({required this.orderId, required this.status});

  final int orderId;
  final String status;
}

/// Sends an event whenever the barista moves an order along.
abstract interface class OrderUpdates {
  /// Ends with an error when the connection drops, so the caller can fall
  /// back to asking the server.
  Stream<StatusEvent> watch(int orderId);
}

/// Never sends anything. Used when there is no Reverb URL.
class NoOrderUpdates implements OrderUpdates {
  const NoOrderUpdates();

  @override
  Stream<StatusEvent> watch(int orderId) =>
      Stream.error(StateError('No live updates in this build'));
}

/// Listens to the private channel `orders.{id}` on Laravel Reverb.
///
/// Reverb speaks the Pusher protocol, which is small enough to write here:
/// connect, get a socket id, ask Laravel to sign the channel name for that
/// socket (with the customer's token), then subscribe.
class ReverbOrderUpdates implements OrderUpdates {
  ReverbOrderUpdates(
    this._dio, {
    required String url,
    WebSocketChannel Function(Uri uri)? connect,
  }) : _uri = Uri.parse(url).replace(
         queryParameters: {'protocol': '7', 'client': 'dart', 'version': '1'},
       ),
       _connect = connect ?? WebSocketChannel.connect;

  final Dio _dio;
  final Uri _uri;
  final WebSocketChannel Function(Uri uri) _connect;

  /// Laravel signs private channels at /api/broadcasting/auth, next to v1.
  String get _authUrl =>
      '${_dio.options.baseUrl.replaceFirst(RegExp(r'/v1/?$'), '')}/broadcasting/auth';

  @override
  Stream<StatusEvent> watch(int orderId) {
    final channelName = 'private-orders.$orderId';
    late final StreamController<StatusEvent> controller;
    WebSocketChannel? socket;
    StreamSubscription<dynamic>? messages;

    void send(String event, Map<String, Object?> data) =>
        socket?.sink.add(jsonEncode({'event': event, 'data': data}));

    Future<void> subscribe(String socketId) async {
      final response = await _dio.post<Map<String, dynamic>>(
        _authUrl,
        data: {'socket_id': socketId, 'channel_name': channelName},
      );
      send('pusher:subscribe', {
        'channel': channelName,
        'auth': response.data!['auth'],
      });
    }

    void onMessage(dynamic raw) {
      final message = jsonDecode(raw as String) as Map<String, dynamic>;
      final data = switch (message['data']) {
        final String text when text.isNotEmpty => jsonDecode(text),
        final Map<String, dynamic> map => map,
        _ => const <String, dynamic>{},
      };
      switch (message['event']) {
        case 'pusher:connection_established':
          subscribe(data['socket_id'] as String).catchError((Object error) {
            if (!controller.isClosed) controller.addError(error);
          });
        case 'pusher:ping':
          send('pusher:pong', {});
        case 'pusher:error' || 'pusher:subscription_error':
          controller.addError(StateError('Reverb: $data'));
        case 'status' when message['channel'] == channelName:
          controller.add(
            StatusEvent(
              orderId: data['id'] as int? ?? orderId,
              status: data['status'] as String,
            ),
          );
      }
    }

    controller = StreamController<StatusEvent>(
      onListen: () {
        try {
          socket = _connect(_uri);
        } on Object catch (error) {
          controller
            ..addError(error)
            ..close();
          return;
        }
        messages = socket!.stream.listen(
          onMessage,
          onError: controller.addError,
          onDone: () {
            if (!controller.isClosed) {
              controller
                ..addError(StateError('Reverb connection closed'))
                ..close();
            }
          },
        );
      },
      onCancel: () async {
        await messages?.cancel();
        await socket?.sink.close();
      },
    );
    return controller.stream;
  }
}
