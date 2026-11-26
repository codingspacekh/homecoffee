import 'package:homecoffee_domain/homecoffee_domain.dart';
import 'package:test/test.dart';

import 'pricing_fixtures.dart';

void main() {
  test('menu.json dollars become cents', () {
    final cappuccino = product(12);
    expect(cappuccino.price, 375);
    expect(cappuccino.options.first.choices.last.price, 100);
    expect(product(41).drink, isFalse);
  });

  test('names fall back to English when there is no Khmer', () {
    expect(product(12).nameIn('km'), 'កាពូឈីណូ');
    expect(product(41).nameIn('km'), 'Croissant');
  });

  test('notes are trimmed and cut at 60 characters', () {
    expect(cleanNote('  less ice  '), 'less ice');
    expect(cleanNote('a' * 80), hasLength(noteMaxLength));
  });
}
