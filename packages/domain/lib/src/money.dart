/// Prices are whole cents everywhere: in the database, the API and the app.
/// $3.75 is 375, so there is nothing to round after a sum.
String formatPrice(int cents) {
  final sign = cents < 0 ? '−' : '';
  final abs = cents.abs();
  return '$sign\$${abs ~/ 100}.${(abs % 100).toString().padLeft(2, '0')}';
}
