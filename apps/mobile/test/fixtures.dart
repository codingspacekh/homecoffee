import 'package:homecoffee_domain/homecoffee_domain.dart';

/// Two products in the GET /api/v1/menu format, with prices in cents.
final cappuccino = Product.fromJson({
  'id': 12,
  'name': 'Cappuccino',
  'price_cents': 375,
  'drink': true,
  'image_url': 'https://api.test/storage/products/cappuccino.webp',
  'options': [
    {
      'name': 'Size',
      'choices': [
        {'label': 'Small', 'price_cents': 0},
        {'label': 'Medium', 'price_cents': 50},
        {'label': 'Large', 'price_cents': 100},
      ],
    },
    {
      'name': 'Milk',
      'choices': [
        {'label': 'Whole', 'price_cents': 0},
        {'label': 'Oat', 'price_cents': 60},
      ],
    },
  ],
});

final croissant = Product.fromJson({
  'id': 41,
  'name': 'Croissant',
  'price_cents': 280,
});
