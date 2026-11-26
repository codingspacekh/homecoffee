import 'package:cached_network_image/cached_network_image.dart';
import 'package:homecoffee_domain/homecoffee_domain.dart';
import 'package:material_ui/material_ui.dart';

/// A product photo, kept on the phone after the first download so the menu
/// still has pictures with no signal. A coffee cup stands in when there is
/// no photo or it can't load.
class ProductImage extends StatelessWidget {
  const ProductImage(this.product, {super.key, this.size, this.height});

  final Product product;

  /// Width and height of a square photo; null fills the width.
  final double? size;
  final double? height;

  @override
  Widget build(BuildContext context) {
    final url = product.imageUrl;
    final width = size ?? double.infinity;
    final h = size ?? height;
    Widget placeholder(BuildContext context, [Object? _, Object? _]) =>
        Container(
          width: width,
          height: h,
          color: Theme.of(context).colorScheme.surfaceContainerHighest,
          child: Icon(
            Icons.local_cafe_outlined,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        );
    if (url == null) return placeholder(context);
    return CachedNetworkImage(
      imageUrl: url,
      width: width,
      height: h,
      fit: BoxFit.cover,
      placeholder: (context, _) => placeholder(context),
      errorWidget: placeholder,
    );
  }
}
