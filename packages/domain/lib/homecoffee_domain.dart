/// HomeCoffee's menu models and the website's price rules: options, promo
/// codes, points and order totals. Pure Dart, shared by the apps.
///
/// The server has the same rules in PHP (backend/app/Domain). Both are tested
/// against fixtures/pricing.json, so they can't drift apart.
library;

export 'src/cart_item.dart';
export 'src/loyalty.dart';
export 'src/money.dart';
export 'src/options.dart';
export 'src/order_totals.dart';
export 'src/product.dart';
export 'src/promo.dart';
