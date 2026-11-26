// orderTotals() from services/Order.js. A Dart record replaces the JS object.
import 'cart_item.dart';
import 'loyalty.dart';
import 'promo.dart';

typedef OrderTotals = ({
  int subtotal,
  int discount,
  int promoAmount,
  int total,
});

OrderTotals orderTotals(
  List<CartItem> cart, {
  int points = 0,
  bool useReward = false,
  String promoCode = '',
}) {
  final subtotal = cart.fold(0, (sum, item) => sum + item.lineTotal);
  final discount = useReward ? rewardDiscount(cart, points) : 0;
  final afterReward = subtotal - discount;
  final promoAmount = promoDiscount(promoCode, afterReward);
  return (
    subtotal: subtotal,
    discount: discount,
    promoAmount: promoAmount,
    total: afterReward - promoAmount,
  );
}
