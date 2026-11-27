import 'package:homecoffee_data/homecoffee_data.dart';
import 'package:homecoffee_domain/homecoffee_domain.dart';

import 'l10n.dart';

/// What to tell the customer when a request didn't work. Each server code
/// has its own sentence in English and Khmer.
String problemText(
  L10n t,
  ApiProblem problem, {
  String Function(int productId)? productName,
  String promoCode = '',
}) => switch (problem.code) {
  'offline' => t.errOffline,
  'too_many' => t.errTooMany,
  'signed_out' => t.errSignedOut,
  'item_unavailable' => t.errItemUnavailable(
    switch (problem.details['product_id']) {
      final int id => productName?.call(id) ?? '',
      _ => '',
    },
  ),
  'not_enough_points' => t.errNoPoints,
  'promo_invalid' => t.errPromoUnknown,
  'promo_used' => t.errPromoUsed,
  'promo_minimum' => t.errPromoMin(
    promoCode,
    formatPrice(problem.details['minimum_cents'] as int? ?? 0),
  ),
  'store_closed' => t.errStoreClosed,
  'orders_paused' => t.errOrdersPaused,
  'pickup_outside_hours' => t.errPickupTime,
  'order_not_cancellable' => t.errNotCancellable,
  'code_invalid' => t.errCodeWrong(
    problem.details['attempts_left'] as int? ?? 0,
  ),
  'code_expired' => t.errCodeExpired,
  'invalid' => t.checkFields,
  _ => t.errServer,
};
