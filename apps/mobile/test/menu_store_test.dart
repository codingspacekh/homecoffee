import 'package:flutter_test/flutter_test.dart';
import 'package:homecoffee/features/menu/data/menu_providers.dart';
import 'package:homecoffee_data/homecoffee_data.dart';

import 'fixtures.dart';

void main() {
  test('the saved menu survives a restart', () async {
    final prefs = await emptyPreferences();
    expect(await PreferencesMenuStore(prefs).read(), isNull);

    await PreferencesMenuStore(prefs)
        .write(const SavedMenu(etag: '"v2"', json: '{"categories":[]}'));

    final saved = await PreferencesMenuStore(prefs).read();
    expect(saved?.etag, '"v2"');
    expect(saved?.json, '{"categories":[]}');
  });
}
