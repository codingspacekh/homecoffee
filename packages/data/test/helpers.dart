import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';

/// Answers requests from a list of canned replies and remembers what was asked.
class FakeAdapter implements HttpClientAdapter {
  FakeAdapter(this.replies);

  final List<ResponseBody Function()> replies;
  final requests = <RequestOptions>[];

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? _,
    Future<void>? _,
  ) async {
    requests.add(options);
    return replies.removeAt(0)();
  }

  @override
  void close({bool force = false}) {}
}

ResponseBody json(Object body, {String? etag, int status = 200}) =>
    ResponseBody.fromString(
      jsonEncode(body),
      status,
      headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType],
        'etag': ?(etag == null ? null : [etag]),
      },
    );

ResponseBody notModified() => ResponseBody.fromString('', 304);

Never offline() => throw DioException.connectionError(
  requestOptions: RequestOptions(),
  reason: 'no signal',
);
