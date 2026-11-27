import 'package:dio/dio.dart';
import 'package:homecoffee_data/homecoffee_data.dart';
import 'package:test/test.dart';

import 'helpers.dart';

void main() {
  late FakeAdapter adapter;
  late DeviceRepository devices;

  void replies(List<ResponseBody Function()> list) {
    adapter = FakeAdapter(list);
    devices = ApiDeviceRepository(
      createApiClient(
        baseUrl: 'https://api.test/v1',
        token: () => 't0k',
        adapter: adapter,
      ),
    );
  }

  test('saves the phone with its platform', () async {
    replies([
      () => json({'saved': true}, status: 201),
    ]);

    await devices.save('fcm-token', platform: 'android');

    final request = adapter.requests.single;
    expect(request.method, 'POST');
    expect(request.path, '/me/devices');
    expect(request.data, {'token': 'fcm-token', 'platform': 'android'});
    expect(request.headers['Authorization'], 'Bearer t0k');
  });

  test('forgets the phone by its token', () async {
    replies([
      () => json({'deleted': true}),
    ]);

    await devices.forget('fcm-token');

    final request = adapter.requests.single;
    expect(request.method, 'DELETE');
    expect(request.path, '/me/devices');
    expect(request.data, {'token': 'fcm-token'});
  });

  test('turns no signal into an ApiProblem', () async {
    replies([offline]);

    await expectLater(
      devices.save('fcm-token', platform: 'ios'),
      throwsA(isA<ApiProblem>().having((p) => p.code, 'code', 'offline')),
    );
  });
}
