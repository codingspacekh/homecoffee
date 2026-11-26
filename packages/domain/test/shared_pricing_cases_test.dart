import 'package:homecoffee_domain/homecoffee_domain.dart';
import 'package:test/test.dart';

import 'pricing_fixtures.dart';

void main() {
  group('cart lines', () {
    for (final c in cases('line_cases')) {
      test(c['name'], () {
        final item = line(c['line'] as Map<String, dynamic>);
        final expected = c['expected'] as Map<String, dynamic>;
        expect(item.options, expected['options']);
        expect(item.unitPrice, expected['unit_cents']);
        expect(item.key, expected['key']);
        expect(formatPrice(item.unitPrice), expected['formatted']);
      });
    }
  });

  group('promo codes', () {
    for (final c in cases('promo_cases')) {
      final code = c['code'] as String;
      final amount = c['amount'] as int;
      test('$code on $amount', () {
        expect(promoProblem(code, amount).name, c['problem']);
        expect(promoDiscount(code, amount), c['discount']);
      });
    }
  });

  group('order totals', () {
    for (final c in cases('order_cases')) {
      test(c['name'], () {
        final cart = [
          for (final l in (c['lines'] as List).cast<Map<String, dynamic>>())
            line(l),
        ];
        final totals = orderTotals(
          cart,
          points: c['points'] as int,
          useReward: c['use_reward'] as bool,
          promoCode: c['promo_code'] as String,
        );
        expect({
          'subtotal': totals.subtotal,
          'discount': totals.discount,
          'promo_amount': totals.promoAmount,
          'total': totals.total,
          'points_earned': pointsFor(totals.total),
        }, c['expected']);
      });
    }
  });
}
