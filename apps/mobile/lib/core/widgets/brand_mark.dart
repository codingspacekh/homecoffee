import 'package:material_ui/material_ui.dart';

/// The cup on a brown rounded square.
class BrandMark extends StatelessWidget {
  const BrandMark({super.key, this.size = 40});

  final double size;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return ExcludeSemantics(
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: scheme.primary,
          borderRadius: BorderRadius.circular(size * 0.3),
        ),
        child: Icon(
          Icons.local_cafe_outlined,
          color: scheme.onPrimary,
          size: size * 0.6,
        ),
      ),
    );
  }
}
