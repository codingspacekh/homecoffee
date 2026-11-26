// services/Promo.js in Dart. Once orders go to a server, the server checks
// codes again; this copy only gives instant feedback in the app.
import 'dart:math';

class Promo {
  const Promo({this.percent, this.amount, this.minimum = 0})
    : assert((percent == null) != (amount == null));

  final int? percent;
  final int? amount; // cents
  final int minimum; // cents
}

const promos = {
  'WELCOME10': Promo(percent: 10),
  'SAVE2': Promo(amount: 200, minimum: 1000),
};

enum PromoProblem { none, unknown, minimum }

String normalizeCode(String code) => code.trim().toUpperCase();

PromoProblem promoProblem(String code, int amount) {
  final promo = promos[normalizeCode(code)];
  if (promo == null) return PromoProblem.unknown;
  return amount < promo.minimum ? PromoProblem.minimum : PromoProblem.none;
}

/// Never more than the amount, so the total can't go below zero.
int promoDiscount(String code, int amount) {
  if (code.isEmpty || promoProblem(code, amount) != PromoProblem.none) {
    return 0;
  }
  final promo = promos[normalizeCode(code)]!;
  final discount = promo.percent != null
      ? (amount * promo.percent! / 100).round()
      : promo.amount!;
  return min(discount, amount);
}
