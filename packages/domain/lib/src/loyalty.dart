// services/Loyalty.js in Dart.
import 'cart_item.dart';

const rewardPoints = 50;

/// One point per whole dollar paid.
int pointsFor(int totalCents) => totalCents ~/ 100;

bool hasReward(int points) => points >= rewardPoints;

/// The most expensive drink in the cart, or null when there is no drink.
CartItem? rewardItem(List<CartItem> cart) => cart
    .where((item) => item.product.drink)
    .fold<CartItem?>(
      null,
      (best, item) =>
          best == null || item.unitPrice > best.unitPrice ? item : best,
    );

int rewardDiscount(List<CartItem> cart, int points) =>
    hasReward(points) ? rewardItem(cart)?.unitPrice ?? 0 : 0;
