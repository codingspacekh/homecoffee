import 'package:homecoffee_domain/homecoffee_domain.dart';
import 'package:test/test.dart';

import 'pricing_fixtures.dart';

void main() {
  test('reads the API format with prices in cents', () {
    final cappuccino = product(12);
    expect(cappuccino.price, 375);
    expect(cappuccino.options.first.choices.last.price, 100);
    expect(cappuccino.available, isTrue);
    expect(cappuccino.imageUrl, endsWith('/products/cappuccino.webp'));
    expect(product(41).drink, isFalse);
  });

  test('names fall back to English when there is no Khmer', () {
    expect(product(12).nameIn('km'), 'កាពូឈីណូ');
    expect(product(41).nameIn('km'), 'Croissant');
  });

  test('option names and choices have their own translations', () {
    final size = OptionGroup.fromJson({
      'name': 'Size',
      'translations': {
        'km': {'name': 'ទំហំ'},
      },
      'choices': [
        {
          'label': 'Large',
          'price_cents': 100,
          'translations': {
            'km': {'label': 'ធំ'},
          },
        },
        {'label': 'Huge', 'price_cents': 150},
      ],
    });
    expect(size.nameIn('km'), 'ទំហំ');
    expect(size.choices.first.labelIn('km'), 'ធំ');
    expect(size.choices.last.labelIn('km'), 'Huge');
  });

  test('notes are trimmed and cut at 60 characters', () {
    expect(cleanNote('  less ice  '), 'less ice');
    expect(cleanNote('a' * 80), hasLength(noteMaxLength));
  });
}
