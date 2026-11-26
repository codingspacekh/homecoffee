import 'package:freezed_annotation/freezed_annotation.dart';

import 'money.dart';

part 'product.freezed.dart';
part 'product.g.dart';

@freezed
abstract class Translation with _$Translation {
  const factory Translation({String? name, String? description}) = _Translation;

  factory Translation.fromJson(Map<String, dynamic> json) =>
      _$TranslationFromJson(json);
}

@freezed
abstract class Choice with _$Choice {
  const factory Choice({
    required String label,
    @CentsConverter() @Default(0) int price,
  }) = _Choice;

  factory Choice.fromJson(Map<String, dynamic> json) => _$ChoiceFromJson(json);
}

/// A group of choices such as Size. The first choice is the default.
@freezed
abstract class OptionGroup with _$OptionGroup {
  const factory OptionGroup({
    required String name,
    required List<Choice> choices,
  }) = _OptionGroup;

  factory OptionGroup.fromJson(Map<String, dynamic> json) =>
      _$OptionGroupFromJson(json);
}

@freezed
abstract class Product with _$Product {
  const Product._();

  const factory Product({
    required int id,
    required String name,
    @CentsConverter() required int price,
    @Default(false) bool drink,
    @Default('') String description,
    required String image,
    @Default([]) List<OptionGroup> options,
    @Default({}) Map<String, Translation> translations,
  }) = _Product;

  factory Product.fromJson(Map<String, dynamic> json) =>
      _$ProductFromJson(json);

  /// The job localized() does in I18n.js.
  String nameIn(String language) => translations[language]?.name ?? name;

  String descriptionIn(String language) =>
      translations[language]?.description ?? description;
}

@freezed
abstract class Category with _$Category {
  const Category._();

  const factory Category({
    required String name,
    required List<Product> products,
    @Default({}) Map<String, Translation> translations,
  }) = _Category;

  factory Category.fromJson(Map<String, dynamic> json) =>
      _$CategoryFromJson(json);

  String nameIn(String language) => translations[language]?.name ?? name;
}
