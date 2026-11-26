import 'package:freezed_annotation/freezed_annotation.dart';

part 'product.freezed.dart';
part 'product.g.dart';

/// Words in another language. Each field falls back to English when missing.
@freezed
abstract class Translation with _$Translation {
  const factory Translation({
    String? name,
    String? description,
    String? label,
  }) = _Translation;

  factory Translation.fromJson(Map<String, dynamic> json) =>
      _$TranslationFromJson(json);
}

/// One choice in a group, such as Large. [price] is the extra cost in cents.
@freezed
abstract class Choice with _$Choice {
  const Choice._();

  const factory Choice({
    required String label,
    @JsonKey(name: 'price_cents') @Default(0) int price,
    @Default({}) Map<String, Translation> translations,
  }) = _Choice;

  factory Choice.fromJson(Map<String, dynamic> json) => _$ChoiceFromJson(json);

  String labelIn(String language) => translations[language]?.label ?? label;
}

/// A group of choices such as Size. The first choice is the default.
@freezed
abstract class OptionGroup with _$OptionGroup {
  const OptionGroup._();

  const factory OptionGroup({
    required String name,
    required List<Choice> choices,
    @Default({}) Map<String, Translation> translations,
  }) = _OptionGroup;

  factory OptionGroup.fromJson(Map<String, dynamic> json) =>
      _$OptionGroupFromJson(json);

  String nameIn(String language) => translations[language]?.name ?? name;
}

/// A menu item as GET /api/v1/menu sends it. [price] is in cents.
@freezed
abstract class Product with _$Product {
  const Product._();

  const factory Product({
    required int id,
    required String name,
    @JsonKey(name: 'price_cents') required int price,
    @Default(false) bool drink,
    @Default(true) bool available,
    @Default('') String description,
    @JsonKey(name: 'image_url') String? imageUrl,
    @Default([]) List<OptionGroup> options,
    @Default({}) Map<String, Translation> translations,
  }) = _Product;

  factory Product.fromJson(Map<String, dynamic> json) =>
      _$ProductFromJson(json);

  String nameIn(String language) => translations[language]?.name ?? name;

  String descriptionIn(String language) =>
      translations[language]?.description ?? description;
}

@freezed
abstract class Category with _$Category {
  const Category._();

  const factory Category({
    int? id,
    required String name,
    required List<Product> products,
    @Default({}) Map<String, Translation> translations,
  }) = _Category;

  factory Category.fromJson(Map<String, dynamic> json) =>
      _$CategoryFromJson(json);

  String nameIn(String language) => translations[language]?.name ?? name;
}
