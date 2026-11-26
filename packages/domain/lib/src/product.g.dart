// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'product.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Translation _$TranslationFromJson(Map<String, dynamic> json) => _Translation(
  name: json['name'] as String?,
  description: json['description'] as String?,
);

Map<String, dynamic> _$TranslationToJson(_Translation instance) =>
    <String, dynamic>{
      'name': instance.name,
      'description': instance.description,
    };

_Choice _$ChoiceFromJson(Map<String, dynamic> json) => _Choice(
  label: json['label'] as String,
  price: json['price'] == null
      ? 0
      : const CentsConverter().fromJson(json['price'] as num),
);

Map<String, dynamic> _$ChoiceToJson(_Choice instance) => <String, dynamic>{
  'label': instance.label,
  'price': const CentsConverter().toJson(instance.price),
};

_OptionGroup _$OptionGroupFromJson(Map<String, dynamic> json) => _OptionGroup(
  name: json['name'] as String,
  choices: (json['choices'] as List<dynamic>)
      .map((e) => Choice.fromJson(e as Map<String, dynamic>))
      .toList(),
);

Map<String, dynamic> _$OptionGroupToJson(_OptionGroup instance) =>
    <String, dynamic>{
      'name': instance.name,
      'choices': instance.choices.map((e) => e.toJson()).toList(),
    };

_Product _$ProductFromJson(Map<String, dynamic> json) => _Product(
  id: (json['id'] as num).toInt(),
  name: json['name'] as String,
  price: const CentsConverter().fromJson(json['price'] as num),
  drink: json['drink'] as bool? ?? false,
  description: json['description'] as String? ?? '',
  image: json['image'] as String,
  options:
      (json['options'] as List<dynamic>?)
          ?.map((e) => OptionGroup.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
  translations:
      (json['translations'] as Map<String, dynamic>?)?.map(
        (k, e) => MapEntry(k, Translation.fromJson(e as Map<String, dynamic>)),
      ) ??
      const {},
);

Map<String, dynamic> _$ProductToJson(_Product instance) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'price': const CentsConverter().toJson(instance.price),
  'drink': instance.drink,
  'description': instance.description,
  'image': instance.image,
  'options': instance.options.map((e) => e.toJson()).toList(),
  'translations': instance.translations.map((k, e) => MapEntry(k, e.toJson())),
};

_Category _$CategoryFromJson(Map<String, dynamic> json) => _Category(
  name: json['name'] as String,
  products: (json['products'] as List<dynamic>)
      .map((e) => Product.fromJson(e as Map<String, dynamic>))
      .toList(),
  translations:
      (json['translations'] as Map<String, dynamic>?)?.map(
        (k, e) => MapEntry(k, Translation.fromJson(e as Map<String, dynamic>)),
      ) ??
      const {},
);

Map<String, dynamic> _$CategoryToJson(_Category instance) => <String, dynamic>{
  'name': instance.name,
  'products': instance.products.map((e) => e.toJson()).toList(),
  'translations': instance.translations.map((k, e) => MapEntry(k, e.toJson())),
};
