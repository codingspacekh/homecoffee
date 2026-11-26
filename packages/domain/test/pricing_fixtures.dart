import 'dart:convert';
import 'dart:io';

import 'package:homecoffee_domain/homecoffee_domain.dart';

/// fixtures/pricing.json at the root of the repo. The Laravel tests read the
/// same file, so the app and the server always price a cart the same way.
final Map<String, dynamic> pricing = jsonDecode(
  File('../../fixtures/pricing.json').readAsStringSync(),
) as Map<String, dynamic>;

List<Map<String, dynamic>> cases(String name) =>
    (pricing[name] as List).cast<Map<String, dynamic>>();

Product product(int id) => Product.fromJson(
  (pricing['products'] as List).cast<Map<String, dynamic>>().singleWhere(
    (p) => p['id'] == id,
  ),
);

CartItem line(Map<String, dynamic> json) => createItem(
  product(json['product_id'] as int),
  selection: Map<String, String>.from(json['options'] as Map? ?? {}),
  quantity: json['quantity'] as int? ?? 1,
  note: json['note'] as String? ?? '',
);
