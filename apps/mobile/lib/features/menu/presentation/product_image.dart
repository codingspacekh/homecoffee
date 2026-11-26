import 'package:homecoffee_domain/homecoffee_domain.dart';
import 'package:material_ui/material_ui.dart';

/// A product photo with a coffee-cup placeholder when there is no photo, no
/// signal, or the link is broken.
class ProductImage extends StatelessWidget {
  const ProductImage(this.product, {super.key, this.size});

  final Product product;
  final double? size;

  @override
  Widget build(BuildContext context) {
    final url = product.imageUrl;
    if (url == null) return _placeholder(context);
    return Image.network(
      url,
      width: size ?? double.infinity,
      height: size,
      fit: BoxFit.cover,
      semanticLabel: product.name,
      errorBuilder: (context, _, _) => _placeholder(context),
    );
  }

  Widget _placeholder(BuildContext context) => Container(
    width: size,
    height: size,
    color: Theme.of(context).colorScheme.surfaceContainerHighest,
    child: const Icon(Icons.local_cafe_outlined),
  );
}
