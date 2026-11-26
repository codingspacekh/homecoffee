// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'product.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Translation _$TranslationFromJson(Map<String, dynamic> json) => _Translation(
  name: json['name'] as String?,
  description: json['description'] as String?,
  label: json['label'] as String?,
);

Map<String, dynamic> _$TranslationToJson(_Translation instance) =>
    <String, dynamic>{
      'name': instance.name,
      'description': instance.description,
      'label': instance.label,
    };

_Choice _$ChoiceFromJson(Map<String, dynamic> json) => _Choice(
  label: json['label'] as String,
  price: (json['price_cents'] as num?)?.toInt() ?? 0,
  translations:
      (json['translations'] as Map<String, dynamic>?)?.map(
        (k, e) => MapEntry(k, Translation.fromJson(e as Map<String, dynamic>)),
      ) ??
      const {},
);

Map<String, dynamic> _$ChoiceToJson(_Choice instance) => <String, dynamic>{
  'label': instance.label,
  'price_cents': instance.price,
  'translations': instance.translations.map((k, e) => MapEntry(k, e.toJson())),
};

_OptionGroup _$OptionGroupFromJson(Map<String, dynamic> json) => _OptionGroup(
  name: json['name'] as String,
  choices: (json['choices'] as List<dynamic>)
      .map((e) => Choice.fromJson(e as Map<String, dynamic>))
      .toList(),
  translations:
      (json['translations'] as Map<String, dynamic>?)?.map(
        (k, e) => MapEntry(k, Translation.fromJson(e as Map<String, dynamic>)),
      ) ??
      const {},
);

Map<String, dynamic> _$OptionGroupToJson(
  _OptionGroup instance,
) => <String, dynamic>{
  'name': instance.name,
  'choices': instance.choices.map((e) => e.toJson()).toList(),
  'translations': instance.translations.map((k, e) => MapEntry(k, e.toJson())),
};

_Product _$ProductFromJson(Map<String, dynamic> json) => _Product(
  id: (json['id'] as num).toInt(),
  name: json['name'] as String,
  price: (json['price_cents'] as num).toInt(),
  drink: json['drink'] as bool? ?? false,
  available: json['available'] as bool? ?? true,
  description: json['description'] as String? ?? '',
  imageUrl: json['image_url'] as String?,
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
  'price_cents': instance.price,
  'drink': instance.drink,
  'available': instance.available,
  'description': instance.description,
  'image_url': instance.imageUrl,
  'options': instance.options.map((e) => e.toJson()).toList(),
  'translations': instance.translations.map((k, e) => MapEntry(k, e.toJson())),
};

_Category _$CategoryFromJson(Map<String, dynamic> json) => _Category(
  id: (json['id'] as num?)?.toInt(),
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
  'id': instance.id,
  'name': instance.name,
  'products': instance.products.map((e) => e.toJson()).toList(),
  'translations': instance.translations.map((k, e) => MapEntry(k, e.toJson())),
};
