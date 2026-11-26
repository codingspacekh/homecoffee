import 'package:json_annotation/json_annotation.dart';

/// Prices are whole cents. The website keeps dollars as doubles and rounds
/// after every sum; with ints there is nothing to round.
String formatPrice(int cents) {
  final sign = cents < 0 ? '−' : '';
  final abs = cents.abs();
  return '$sign\$${abs ~/ 100}.${(abs % 100).toString().padLeft(2, '0')}';
}

/// menu.json has dollars (3.75); the app works in cents (375).
class CentsConverter implements JsonConverter<int, num> {
  const CentsConverter();

  @override
  int fromJson(num json) => (json * 100).round();

  @override
  num toJson(int cents) => cents / 100;
}
