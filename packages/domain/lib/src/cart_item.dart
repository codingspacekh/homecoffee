import 'package:freezed_annotation/freezed_annotation.dart';

import 'product.dart';

part 'cart_item.freezed.dart';
part 'cart_item.g.dart';

@freezed
abstract class CartItem with _$CartItem {
  const CartItem._();

  const factory CartItem({
    /// Same product + same choices + same note = same line (see itemKey).
    required String key,
    required Product product,
    required Map<String, String> options,
    @Default('') String note,
    required int unitPrice,
    @Default(1) int quantity,
  }) = _CartItem;

  factory CartItem.fromJson(Map<String, dynamic> json) =>
      _$CartItemFromJson(json);

  int get lineTotal => unitPrice * quantity;
}
