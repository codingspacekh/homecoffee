import 'package:material_ui/material_ui.dart';

import '../data/menu_providers.dart';

import 'package:homecoffee_domain/homecoffee_domain.dart';

/// A product photo with a coffee-cup placeholder while offline or broken.
/// Phase 1 swaps Image.network for cached_network_image.
class ProductImage extends StatelessWidget {
  const ProductImage(this.product, {super.key, this.size});

  final Product product;
  final double? size;

  @override
  Widget build(BuildContext context) => Image.network(
    imageUrl(product),
    width: size ?? double.infinity,
    height: size,
    fit: BoxFit.cover,
    semanticLabel: product.name,
    errorBuilder: (context, _, _) => Container(
      width: size,
      height: size,
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
      child: const Icon(Icons.local_cafe_outlined),
    ),
  );
}
