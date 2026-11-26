import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import 'package:homecoffee_domain/homecoffee_domain.dart';

import '../../cart/presentation/cart_notifier.dart';
import '../data/menu_providers.dart';
import 'product_image.dart';

/// DetailsPage.js: photo, options, a note and a bar with the price.
class ProductScreen extends ConsumerWidget {
  const ProductScreen({super.key, required this.id});

  final int id;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return switch (ref.watch(productProvider(id))) {
      AsyncData(value: final product?) => _ProductForm(product: product),
      AsyncData() => Scaffold(
        appBar: AppBar(),
        body: const Center(child: Text('Product not found')),
      ),
      AsyncError() => Scaffold(
        appBar: AppBar(),
        body: const Center(child: Text('Couldn’t load the menu')),
      ),
      _ => const Scaffold(body: Center(child: CircularProgressIndicator())),
    };
  }
}

class _ProductForm extends ConsumerStatefulWidget {
  const _ProductForm({required this.product});

  final Product product;

  @override
  ConsumerState<_ProductForm> createState() => _ProductFormState();
}

class _ProductFormState extends ConsumerState<_ProductForm> {
  late Selection selection = resolveOptions(widget.product);
  final note = TextEditingController();

  @override
  void dispose() {
    note.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final product = widget.product;
    final text = Theme.of(context).textTheme;
    return Scaffold(
      appBar: AppBar(title: Text(product.nameIn('en'))),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: AspectRatio(
              aspectRatio: 16 / 10,
              child: ProductImage(product),
            ),
          ),
          const SizedBox(height: 16),
          Text(product.descriptionIn('en'), style: text.bodyLarge),
          for (final group in product.options) ...[
            const SizedBox(height: 20),
            Text(group.name, style: text.titleSmall),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final choice in group.choices)
                  ChoiceChip(
                    label: Text(
                      choice.price > 0
                          ? '${choice.label} +${formatPrice(choice.price)}'
                          : choice.label,
                    ),
                    selected: selection[group.name] == choice.label,
                    onSelected: (_) => setState(
                      () =>
                          selection = {...selection, group.name: choice.label},
                    ),
                  ),
              ],
            ),
          ],
          const SizedBox(height: 20),
          TextField(
            controller: note,
            maxLength: noteMaxLength,
            decoration: const InputDecoration(
              labelText: 'Note for the barista (optional)',
              hintText: 'e.g. extra hot, no lid',
            ),
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Text(
                formatPrice(unitPrice(product, selection)),
                style: text.titleLarge,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: FilledButton(
                  style: FilledButton.styleFrom(
                    minimumSize: const Size.fromHeight(52),
                  ),
                  onPressed: () {
                    ref
                        .read(cartProvider.notifier)
                        .add(
                          createItem(
                            product,
                            selection: selection,
                            note: note.text,
                          ),
                        );
                    context.go('/cart');
                  },
                  child: const Text('Add to cart'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
