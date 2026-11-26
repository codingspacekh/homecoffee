// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'cart_item.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_CartItem _$CartItemFromJson(Map<String, dynamic> json) => _CartItem(
  key: json['key'] as String,
  product: Product.fromJson(json['product'] as Map<String, dynamic>),
  options: Map<String, String>.from(json['options'] as Map),
  note: json['note'] as String? ?? '',
  unitPrice: (json['unitPrice'] as num).toInt(),
  quantity: (json['quantity'] as num?)?.toInt() ?? 1,
);

Map<String, dynamic> _$CartItemToJson(_CartItem instance) => <String, dynamic>{
  'key': instance.key,
  'product': instance.product.toJson(),
  'options': instance.options,
  'note': instance.note,
  'unitPrice': instance.unitPrice,
  'quantity': instance.quantity,
};
