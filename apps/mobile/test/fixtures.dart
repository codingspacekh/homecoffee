import 'package:homecoffee_domain/homecoffee_domain.dart';

/// Two products in the website's menu.json format.
final cappuccino = Product.fromJson({
  'id': 12,
  'name': 'Cappuccino',
  'price': 3.75,
  'drink': true,
  'image': 'cappuccino.png',
  'options': [
    {
      'name': 'Size',
      'choices': [
        {'label': 'Small', 'price': 0.00},
        {'label': 'Medium', 'price': 0.50},
        {'label': 'Large', 'price': 1.00},
      ],
    },
    {
      'name': 'Milk',
      'choices': [
        {'label': 'Whole', 'price': 0.00},
        {'label': 'Oat', 'price': 0.60},
      ],
    },
  ],
});

final croissant = Product.fromJson({
  'id': 41,
  'name': 'Croissant',
  'price': 2.80,
  'image': 'croissant.png',
});
