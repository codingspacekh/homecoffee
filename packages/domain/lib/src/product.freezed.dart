// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'product.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$Translation {

 String? get name; String? get description; String? get label;
/// Create a copy of Translation
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TranslationCopyWith<Translation> get copyWith => _$TranslationCopyWithImpl<Translation>(this as Translation, _$identity);

  /// Serializes this Translation to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as Translation;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Translation&&(identical(other.name, _this.name) || other.name == _this.name)&&(identical(other.description, _this.description) || other.description == _this.description)&&(identical(other.label, _this.label) || other.label == _this.label));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as Translation;
  return Object.hash(runtimeType,_this.name,_this.description,_this.label);
}

@override
String toString() {
  final _this = this as Translation;
  return 'Translation(name: ${_this.name}, description: ${_this.description}, label: ${_this.label})';
}


}

/// @nodoc
abstract mixin class $TranslationCopyWith<$Res>  {
  factory $TranslationCopyWith(Translation value, $Res Function(Translation) _then) = _$TranslationCopyWithImpl;
@useResult
$Res call({
 String? name, String? description, String? label
});




}
/// @nodoc
class _$TranslationCopyWithImpl<$Res>
    implements $TranslationCopyWith<$Res> {
  _$TranslationCopyWithImpl(this._self, this._then);

  final Translation _self;
  final $Res Function(Translation) _then;

/// Create a copy of Translation
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? name = freezed,Object? description = freezed,Object? label = freezed,}) {
  return _then(Translation(
name: freezed == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String?,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,label: freezed == label ? _self.label : label // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [Translation].
extension TranslationPatterns on Translation {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Translation value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Translation() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Translation value)  $default,){
final _that = this;
switch (_that) {
case _Translation():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Translation value)?  $default,){
final _that = this;
switch (_that) {
case _Translation() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String? name,  String? description,  String? label)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Translation() when $default != null:
return $default(_that.name,_that.description,_that.label);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String? name,  String? description,  String? label)  $default,) {final _that = this;
switch (_that) {
case _Translation():
return $default(_that.name,_that.description,_that.label);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String? name,  String? description,  String? label)?  $default,) {final _that = this;
switch (_that) {
case _Translation() when $default != null:
return $default(_that.name,_that.description,_that.label);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Translation implements Translation {
  const _Translation({this.name, this.description, this.label});
  factory _Translation.fromJson(Map<String, dynamic> json) => _$TranslationFromJson(json);

@override final  String? name;
@override final  String? description;
@override final  String? label;

/// Create a copy of Translation
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$TranslationCopyWith<_Translation> get copyWith => __$TranslationCopyWithImpl<_Translation>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$TranslationToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _Translation&&(identical(other.name, name) || other.name == name)&&(identical(other.description, description) || other.description == description)&&(identical(other.label, label) || other.label == label));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,name,description,label);
}

@override
String toString() {
    return 'Translation(name: $name, description: $description, label: $label)';
}


}

/// @nodoc
abstract mixin class _$TranslationCopyWith<$Res> implements $TranslationCopyWith<$Res> {
  factory _$TranslationCopyWith(_Translation value, $Res Function(_Translation) _then) = __$TranslationCopyWithImpl;
@override @useResult
$Res call({
 String? name, String? description, String? label
});




}
/// @nodoc
class __$TranslationCopyWithImpl<$Res>
    implements _$TranslationCopyWith<$Res> {
  __$TranslationCopyWithImpl(this._self, this._then);

  final _Translation _self;
  final $Res Function(_Translation) _then;

/// Create a copy of Translation
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? name = freezed,Object? description = freezed,Object? label = freezed,}) {
  return _then(_Translation(
name: freezed == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String?,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,label: freezed == label ? _self.label : label // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}


/// @nodoc
mixin _$Choice {

 String get label;@JsonKey(name: 'price_cents') int get price; Map<String, Translation> get translations;
/// Create a copy of Choice
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ChoiceCopyWith<Choice> get copyWith => _$ChoiceCopyWithImpl<Choice>(this as Choice, _$identity);

  /// Serializes this Choice to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as Choice;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Choice&&(identical(other.label, _this.label) || other.label == _this.label)&&(identical(other.price, _this.price) || other.price == _this.price)&&const DeepCollectionEquality().equals(other.translations, _this.translations));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as Choice;
  return Object.hash(runtimeType,_this.label,_this.price,const DeepCollectionEquality().hash(_this.translations));
}

@override
String toString() {
  final _this = this as Choice;
  return 'Choice(label: ${_this.label}, price: ${_this.price}, translations: ${_this.translations})';
}


}

/// @nodoc
abstract mixin class $ChoiceCopyWith<$Res>  {
  factory $ChoiceCopyWith(Choice value, $Res Function(Choice) _then) = _$ChoiceCopyWithImpl;
@useResult
$Res call({
 String label,@JsonKey(name: 'price_cents') int price, Map<String, Translation> translations
});




}
/// @nodoc
class _$ChoiceCopyWithImpl<$Res>
    implements $ChoiceCopyWith<$Res> {
  _$ChoiceCopyWithImpl(this._self, this._then);

  final Choice _self;
  final $Res Function(Choice) _then;

/// Create a copy of Choice
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? label = null,Object? price = null,Object? translations = null,}) {
  return _then(Choice(
label: null == label ? _self.label : label // ignore: cast_nullable_to_non_nullable
as String,price: null == price ? _self.price : price // ignore: cast_nullable_to_non_nullable
as int,translations: null == translations ? _self.translations : translations // ignore: cast_nullable_to_non_nullable
as Map<String, Translation>,
  ));
}

}


/// Adds pattern-matching-related methods to [Choice].
extension ChoicePatterns on Choice {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Choice value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Choice() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Choice value)  $default,){
final _that = this;
switch (_that) {
case _Choice():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Choice value)?  $default,){
final _that = this;
switch (_that) {
case _Choice() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String label, @JsonKey(name: 'price_cents')  int price,  Map<String, Translation> translations)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Choice() when $default != null:
return $default(_that.label,_that.price,_that.translations);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String label, @JsonKey(name: 'price_cents')  int price,  Map<String, Translation> translations)  $default,) {final _that = this;
switch (_that) {
case _Choice():
return $default(_that.label,_that.price,_that.translations);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String label, @JsonKey(name: 'price_cents')  int price,  Map<String, Translation> translations)?  $default,) {final _that = this;
switch (_that) {
case _Choice() when $default != null:
return $default(_that.label,_that.price,_that.translations);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Choice extends Choice {
  const _Choice({required this.label, @JsonKey(name: 'price_cents') this.price = 0,  Map<String, Translation> translations = const {}}): _translations = translations,super._();
  factory _Choice.fromJson(Map<String, dynamic> json) => _$ChoiceFromJson(json);

@override final  String label;
@override@JsonKey(name: 'price_cents') final  int price;
 final  Map<String, Translation> _translations;
@override@JsonKey() Map<String, Translation> get translations {
  if (_translations is EqualUnmodifiableMapView) return _translations;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_translations);
}


/// Create a copy of Choice
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ChoiceCopyWith<_Choice> get copyWith => __$ChoiceCopyWithImpl<_Choice>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ChoiceToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _Choice&&(identical(other.label, label) || other.label == label)&&(identical(other.price, price) || other.price == price)&&const DeepCollectionEquality().equals(other.translations, _translations));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,label,price,const DeepCollectionEquality().hash(_translations));
}

@override
String toString() {
    return 'Choice(label: $label, price: $price, translations: $translations)';
}


}

/// @nodoc
abstract mixin class _$ChoiceCopyWith<$Res> implements $ChoiceCopyWith<$Res> {
  factory _$ChoiceCopyWith(_Choice value, $Res Function(_Choice) _then) = __$ChoiceCopyWithImpl;
@override @useResult
$Res call({
 String label,@JsonKey(name: 'price_cents') int price, Map<String, Translation> translations
});




}
/// @nodoc
class __$ChoiceCopyWithImpl<$Res>
    implements _$ChoiceCopyWith<$Res> {
  __$ChoiceCopyWithImpl(this._self, this._then);

  final _Choice _self;
  final $Res Function(_Choice) _then;

/// Create a copy of Choice
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? label = null,Object? price = null,Object? translations = null,}) {
  return _then(_Choice(
label: null == label ? _self.label : label // ignore: cast_nullable_to_non_nullable
as String,price: null == price ? _self.price : price // ignore: cast_nullable_to_non_nullable
as int,translations: null == translations ? _self._translations : translations // ignore: cast_nullable_to_non_nullable
as Map<String, Translation>,
  ));
}


}


/// @nodoc
mixin _$OptionGroup {

 String get name; List<Choice> get choices; Map<String, Translation> get translations;
/// Create a copy of OptionGroup
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$OptionGroupCopyWith<OptionGroup> get copyWith => _$OptionGroupCopyWithImpl<OptionGroup>(this as OptionGroup, _$identity);

  /// Serializes this OptionGroup to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as OptionGroup;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is OptionGroup&&(identical(other.name, _this.name) || other.name == _this.name)&&const DeepCollectionEquality().equals(other.choices, _this.choices)&&const DeepCollectionEquality().equals(other.translations, _this.translations));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as OptionGroup;
  return Object.hash(runtimeType,_this.name,const DeepCollectionEquality().hash(_this.choices),const DeepCollectionEquality().hash(_this.translations));
}

@override
String toString() {
  final _this = this as OptionGroup;
  return 'OptionGroup(name: ${_this.name}, choices: ${_this.choices}, translations: ${_this.translations})';
}


}

/// @nodoc
abstract mixin class $OptionGroupCopyWith<$Res>  {
  factory $OptionGroupCopyWith(OptionGroup value, $Res Function(OptionGroup) _then) = _$OptionGroupCopyWithImpl;
@useResult
$Res call({
 String name, List<Choice> choices, Map<String, Translation> translations
});




}
/// @nodoc
class _$OptionGroupCopyWithImpl<$Res>
    implements $OptionGroupCopyWith<$Res> {
  _$OptionGroupCopyWithImpl(this._self, this._then);

  final OptionGroup _self;
  final $Res Function(OptionGroup) _then;

/// Create a copy of OptionGroup
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? name = null,Object? choices = null,Object? translations = null,}) {
  return _then(OptionGroup(
name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,choices: null == choices ? _self.choices : choices // ignore: cast_nullable_to_non_nullable
as List<Choice>,translations: null == translations ? _self.translations : translations // ignore: cast_nullable_to_non_nullable
as Map<String, Translation>,
  ));
}

}


/// Adds pattern-matching-related methods to [OptionGroup].
extension OptionGroupPatterns on OptionGroup {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _OptionGroup value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _OptionGroup() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _OptionGroup value)  $default,){
final _that = this;
switch (_that) {
case _OptionGroup():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _OptionGroup value)?  $default,){
final _that = this;
switch (_that) {
case _OptionGroup() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String name,  List<Choice> choices,  Map<String, Translation> translations)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _OptionGroup() when $default != null:
return $default(_that.name,_that.choices,_that.translations);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String name,  List<Choice> choices,  Map<String, Translation> translations)  $default,) {final _that = this;
switch (_that) {
case _OptionGroup():
return $default(_that.name,_that.choices,_that.translations);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String name,  List<Choice> choices,  Map<String, Translation> translations)?  $default,) {final _that = this;
switch (_that) {
case _OptionGroup() when $default != null:
return $default(_that.name,_that.choices,_that.translations);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _OptionGroup extends OptionGroup {
  const _OptionGroup({required this.name, required  List<Choice> choices,  Map<String, Translation> translations = const {}}): _choices = choices,_translations = translations,super._();
  factory _OptionGroup.fromJson(Map<String, dynamic> json) => _$OptionGroupFromJson(json);

@override final  String name;
 final  List<Choice> _choices;
@override List<Choice> get choices {
  if (_choices is EqualUnmodifiableListView) return _choices;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_choices);
}

 final  Map<String, Translation> _translations;
@override@JsonKey() Map<String, Translation> get translations {
  if (_translations is EqualUnmodifiableMapView) return _translations;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_translations);
}


/// Create a copy of OptionGroup
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$OptionGroupCopyWith<_OptionGroup> get copyWith => __$OptionGroupCopyWithImpl<_OptionGroup>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$OptionGroupToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _OptionGroup&&(identical(other.name, name) || other.name == name)&&const DeepCollectionEquality().equals(other.choices, _choices)&&const DeepCollectionEquality().equals(other.translations, _translations));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,name,const DeepCollectionEquality().hash(_choices),const DeepCollectionEquality().hash(_translations));
}

@override
String toString() {
    return 'OptionGroup(name: $name, choices: $choices, translations: $translations)';
}


}

/// @nodoc
abstract mixin class _$OptionGroupCopyWith<$Res> implements $OptionGroupCopyWith<$Res> {
  factory _$OptionGroupCopyWith(_OptionGroup value, $Res Function(_OptionGroup) _then) = __$OptionGroupCopyWithImpl;
@override @useResult
$Res call({
 String name, List<Choice> choices, Map<String, Translation> translations
});




}
/// @nodoc
class __$OptionGroupCopyWithImpl<$Res>
    implements _$OptionGroupCopyWith<$Res> {
  __$OptionGroupCopyWithImpl(this._self, this._then);

  final _OptionGroup _self;
  final $Res Function(_OptionGroup) _then;

/// Create a copy of OptionGroup
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? name = null,Object? choices = null,Object? translations = null,}) {
  return _then(_OptionGroup(
name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,choices: null == choices ? _self._choices : choices // ignore: cast_nullable_to_non_nullable
as List<Choice>,translations: null == translations ? _self._translations : translations // ignore: cast_nullable_to_non_nullable
as Map<String, Translation>,
  ));
}


}


/// @nodoc
mixin _$Product {

 int get id; String get name;@JsonKey(name: 'price_cents') int get price; bool get drink; bool get available; String get description;@JsonKey(name: 'image_url') String? get imageUrl; List<OptionGroup> get options; Map<String, Translation> get translations;
/// Create a copy of Product
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ProductCopyWith<Product> get copyWith => _$ProductCopyWithImpl<Product>(this as Product, _$identity);

  /// Serializes this Product to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as Product;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Product&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.name, _this.name) || other.name == _this.name)&&(identical(other.price, _this.price) || other.price == _this.price)&&(identical(other.drink, _this.drink) || other.drink == _this.drink)&&(identical(other.available, _this.available) || other.available == _this.available)&&(identical(other.description, _this.description) || other.description == _this.description)&&(identical(other.imageUrl, _this.imageUrl) || other.imageUrl == _this.imageUrl)&&const DeepCollectionEquality().equals(other.options, _this.options)&&const DeepCollectionEquality().equals(other.translations, _this.translations));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as Product;
  return Object.hash(runtimeType,_this.id,_this.name,_this.price,_this.drink,_this.available,_this.description,_this.imageUrl,const DeepCollectionEquality().hash(_this.options),const DeepCollectionEquality().hash(_this.translations));
}

@override
String toString() {
  final _this = this as Product;
  return 'Product(id: ${_this.id}, name: ${_this.name}, price: ${_this.price}, drink: ${_this.drink}, available: ${_this.available}, description: ${_this.description}, imageUrl: ${_this.imageUrl}, options: ${_this.options}, translations: ${_this.translations})';
}


}

/// @nodoc
abstract mixin class $ProductCopyWith<$Res>  {
  factory $ProductCopyWith(Product value, $Res Function(Product) _then) = _$ProductCopyWithImpl;
@useResult
$Res call({
 int id, String name,@JsonKey(name: 'price_cents') int price, bool drink, bool available, String description,@JsonKey(name: 'image_url') String? imageUrl, List<OptionGroup> options, Map<String, Translation> translations
});




}
/// @nodoc
class _$ProductCopyWithImpl<$Res>
    implements $ProductCopyWith<$Res> {
  _$ProductCopyWithImpl(this._self, this._then);

  final Product _self;
  final $Res Function(Product) _then;

/// Create a copy of Product
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = null,Object? price = null,Object? drink = null,Object? available = null,Object? description = null,Object? imageUrl = freezed,Object? options = null,Object? translations = null,}) {
  return _then(Product(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,price: null == price ? _self.price : price // ignore: cast_nullable_to_non_nullable
as int,drink: null == drink ? _self.drink : drink // ignore: cast_nullable_to_non_nullable
as bool,available: null == available ? _self.available : available // ignore: cast_nullable_to_non_nullable
as bool,description: null == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String,imageUrl: freezed == imageUrl ? _self.imageUrl : imageUrl // ignore: cast_nullable_to_non_nullable
as String?,options: null == options ? _self.options : options // ignore: cast_nullable_to_non_nullable
as List<OptionGroup>,translations: null == translations ? _self.translations : translations // ignore: cast_nullable_to_non_nullable
as Map<String, Translation>,
  ));
}

}


/// Adds pattern-matching-related methods to [Product].
extension ProductPatterns on Product {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Product value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Product() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Product value)  $default,){
final _that = this;
switch (_that) {
case _Product():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Product value)?  $default,){
final _that = this;
switch (_that) {
case _Product() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int id,  String name, @JsonKey(name: 'price_cents')  int price,  bool drink,  bool available,  String description, @JsonKey(name: 'image_url')  String? imageUrl,  List<OptionGroup> options,  Map<String, Translation> translations)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Product() when $default != null:
return $default(_that.id,_that.name,_that.price,_that.drink,_that.available,_that.description,_that.imageUrl,_that.options,_that.translations);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int id,  String name, @JsonKey(name: 'price_cents')  int price,  bool drink,  bool available,  String description, @JsonKey(name: 'image_url')  String? imageUrl,  List<OptionGroup> options,  Map<String, Translation> translations)  $default,) {final _that = this;
switch (_that) {
case _Product():
return $default(_that.id,_that.name,_that.price,_that.drink,_that.available,_that.description,_that.imageUrl,_that.options,_that.translations);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int id,  String name, @JsonKey(name: 'price_cents')  int price,  bool drink,  bool available,  String description, @JsonKey(name: 'image_url')  String? imageUrl,  List<OptionGroup> options,  Map<String, Translation> translations)?  $default,) {final _that = this;
switch (_that) {
case _Product() when $default != null:
return $default(_that.id,_that.name,_that.price,_that.drink,_that.available,_that.description,_that.imageUrl,_that.options,_that.translations);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Product extends Product {
  const _Product({required this.id, required this.name, @JsonKey(name: 'price_cents') required this.price, this.drink = false, this.available = true, this.description = '', @JsonKey(name: 'image_url') this.imageUrl,  List<OptionGroup> options = const [],  Map<String, Translation> translations = const {}}): _options = options,_translations = translations,super._();
  factory _Product.fromJson(Map<String, dynamic> json) => _$ProductFromJson(json);

@override final  int id;
@override final  String name;
@override@JsonKey(name: 'price_cents') final  int price;
@override@JsonKey() final  bool drink;
@override@JsonKey() final  bool available;
@override@JsonKey() final  String description;
@override@JsonKey(name: 'image_url') final  String? imageUrl;
 final  List<OptionGroup> _options;
@override@JsonKey() List<OptionGroup> get options {
  if (_options is EqualUnmodifiableListView) return _options;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_options);
}

 final  Map<String, Translation> _translations;
@override@JsonKey() Map<String, Translation> get translations {
  if (_translations is EqualUnmodifiableMapView) return _translations;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_translations);
}


/// Create a copy of Product
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ProductCopyWith<_Product> get copyWith => __$ProductCopyWithImpl<_Product>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ProductToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _Product&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.price, price) || other.price == price)&&(identical(other.drink, drink) || other.drink == drink)&&(identical(other.available, available) || other.available == available)&&(identical(other.description, description) || other.description == description)&&(identical(other.imageUrl, imageUrl) || other.imageUrl == imageUrl)&&const DeepCollectionEquality().equals(other.options, _options)&&const DeepCollectionEquality().equals(other.translations, _translations));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,id,name,price,drink,available,description,imageUrl,const DeepCollectionEquality().hash(_options),const DeepCollectionEquality().hash(_translations));
}

@override
String toString() {
    return 'Product(id: $id, name: $name, price: $price, drink: $drink, available: $available, description: $description, imageUrl: $imageUrl, options: $options, translations: $translations)';
}


}

/// @nodoc
abstract mixin class _$ProductCopyWith<$Res> implements $ProductCopyWith<$Res> {
  factory _$ProductCopyWith(_Product value, $Res Function(_Product) _then) = __$ProductCopyWithImpl;
@override @useResult
$Res call({
 int id, String name,@JsonKey(name: 'price_cents') int price, bool drink, bool available, String description,@JsonKey(name: 'image_url') String? imageUrl, List<OptionGroup> options, Map<String, Translation> translations
});




}
/// @nodoc
class __$ProductCopyWithImpl<$Res>
    implements _$ProductCopyWith<$Res> {
  __$ProductCopyWithImpl(this._self, this._then);

  final _Product _self;
  final $Res Function(_Product) _then;

/// Create a copy of Product
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,Object? price = null,Object? drink = null,Object? available = null,Object? description = null,Object? imageUrl = freezed,Object? options = null,Object? translations = null,}) {
  return _then(_Product(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,price: null == price ? _self.price : price // ignore: cast_nullable_to_non_nullable
as int,drink: null == drink ? _self.drink : drink // ignore: cast_nullable_to_non_nullable
as bool,available: null == available ? _self.available : available // ignore: cast_nullable_to_non_nullable
as bool,description: null == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String,imageUrl: freezed == imageUrl ? _self.imageUrl : imageUrl // ignore: cast_nullable_to_non_nullable
as String?,options: null == options ? _self._options : options // ignore: cast_nullable_to_non_nullable
as List<OptionGroup>,translations: null == translations ? _self._translations : translations // ignore: cast_nullable_to_non_nullable
as Map<String, Translation>,
  ));
}


}


/// @nodoc
mixin _$Category {

 int? get id; String get name; List<Product> get products; Map<String, Translation> get translations;
/// Create a copy of Category
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CategoryCopyWith<Category> get copyWith => _$CategoryCopyWithImpl<Category>(this as Category, _$identity);

  /// Serializes this Category to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as Category;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Category&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.name, _this.name) || other.name == _this.name)&&const DeepCollectionEquality().equals(other.products, _this.products)&&const DeepCollectionEquality().equals(other.translations, _this.translations));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as Category;
  return Object.hash(runtimeType,_this.id,_this.name,const DeepCollectionEquality().hash(_this.products),const DeepCollectionEquality().hash(_this.translations));
}

@override
String toString() {
  final _this = this as Category;
  return 'Category(id: ${_this.id}, name: ${_this.name}, products: ${_this.products}, translations: ${_this.translations})';
}


}

/// @nodoc
abstract mixin class $CategoryCopyWith<$Res>  {
  factory $CategoryCopyWith(Category value, $Res Function(Category) _then) = _$CategoryCopyWithImpl;
@useResult
$Res call({
 int? id, String name, List<Product> products, Map<String, Translation> translations
});




}
/// @nodoc
class _$CategoryCopyWithImpl<$Res>
    implements $CategoryCopyWith<$Res> {
  _$CategoryCopyWithImpl(this._self, this._then);

  final Category _self;
  final $Res Function(Category) _then;

/// Create a copy of Category
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = freezed,Object? name = null,Object? products = null,Object? translations = null,}) {
  return _then(Category(
id: freezed == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int?,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,products: null == products ? _self.products : products // ignore: cast_nullable_to_non_nullable
as List<Product>,translations: null == translations ? _self.translations : translations // ignore: cast_nullable_to_non_nullable
as Map<String, Translation>,
  ));
}

}


/// Adds pattern-matching-related methods to [Category].
extension CategoryPatterns on Category {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Category value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Category() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Category value)  $default,){
final _that = this;
switch (_that) {
case _Category():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Category value)?  $default,){
final _that = this;
switch (_that) {
case _Category() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int? id,  String name,  List<Product> products,  Map<String, Translation> translations)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Category() when $default != null:
return $default(_that.id,_that.name,_that.products,_that.translations);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int? id,  String name,  List<Product> products,  Map<String, Translation> translations)  $default,) {final _that = this;
switch (_that) {
case _Category():
return $default(_that.id,_that.name,_that.products,_that.translations);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int? id,  String name,  List<Product> products,  Map<String, Translation> translations)?  $default,) {final _that = this;
switch (_that) {
case _Category() when $default != null:
return $default(_that.id,_that.name,_that.products,_that.translations);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Category extends Category {
  const _Category({this.id, required this.name, required  List<Product> products,  Map<String, Translation> translations = const {}}): _products = products,_translations = translations,super._();
  factory _Category.fromJson(Map<String, dynamic> json) => _$CategoryFromJson(json);

@override final  int? id;
@override final  String name;
 final  List<Product> _products;
@override List<Product> get products {
  if (_products is EqualUnmodifiableListView) return _products;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_products);
}

 final  Map<String, Translation> _translations;
@override@JsonKey() Map<String, Translation> get translations {
  if (_translations is EqualUnmodifiableMapView) return _translations;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_translations);
}


/// Create a copy of Category
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CategoryCopyWith<_Category> get copyWith => __$CategoryCopyWithImpl<_Category>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$CategoryToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _Category&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&const DeepCollectionEquality().equals(other.products, _products)&&const DeepCollectionEquality().equals(other.translations, _translations));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,id,name,const DeepCollectionEquality().hash(_products),const DeepCollectionEquality().hash(_translations));
}

@override
String toString() {
    return 'Category(id: $id, name: $name, products: $products, translations: $translations)';
}


}

/// @nodoc
abstract mixin class _$CategoryCopyWith<$Res> implements $CategoryCopyWith<$Res> {
  factory _$CategoryCopyWith(_Category value, $Res Function(_Category) _then) = __$CategoryCopyWithImpl;
@override @useResult
$Res call({
 int? id, String name, List<Product> products, Map<String, Translation> translations
});




}
/// @nodoc
class __$CategoryCopyWithImpl<$Res>
    implements _$CategoryCopyWith<$Res> {
  __$CategoryCopyWithImpl(this._self, this._then);

  final _Category _self;
  final $Res Function(_Category) _then;

/// Create a copy of Category
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = freezed,Object? name = null,Object? products = null,Object? translations = null,}) {
  return _then(_Category(
id: freezed == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int?,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,products: null == products ? _self._products : products // ignore: cast_nullable_to_non_nullable
as List<Product>,translations: null == translations ? _self._translations : translations // ignore: cast_nullable_to_non_nullable
as Map<String, Translation>,
  ));
}


}

// dart format on
