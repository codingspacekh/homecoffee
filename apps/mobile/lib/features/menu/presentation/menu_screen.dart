import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import 'package:homecoffee_domain/homecoffee_domain.dart';

import '../../../core/router/app_router.dart';
import '../../cart/presentation/cart_notifier.dart';
import '../data/menu_providers.dart';
import 'product_image.dart';

/// Search text and the chosen category; the website keeps these in the URL.
class MenuQuery extends Notifier<String> {
  @override
  String build() => '';

  void set(String text) => state = text;
}

class MenuCategory extends Notifier<String?> {
  @override
  String? build() => null; // null = All

  void set(String? name) => state = name;
}

final menuQueryProvider = NotifierProvider<MenuQuery, String>(MenuQuery.new);
final menuCategoryProvider = NotifierProvider<MenuCategory, String?>(
  MenuCategory.new,
);

class MenuScreen extends ConsumerWidget {
  const MenuScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final menu = ref.watch(menuProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('What would you like today?')),
      body: switch (menu) {
        AsyncData(:final value) => _MenuList(categories: value),
        AsyncError() => Center(
          child: FilledButton(
            onPressed: () => ref.invalidate(menuProvider),
            child: const Text('Couldn’t load the menu. Try again'),
          ),
        ),
        _ => const Center(child: CircularProgressIndicator()),
      },
    );
  }
}

class _MenuList extends ConsumerWidget {
  const _MenuList({required this.categories});

  final List<Category> categories;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final query = ref.watch(menuQueryProvider).trim().toLowerCase();
    final chosen = ref.watch(menuCategoryProvider);
    bool matches(Product p) =>
        query.isEmpty || p.name.toLowerCase().contains(query);

    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
            child: SearchBar(
              hintText: 'Search the menu',
              leading: const Icon(Icons.search),
              onChanged: (text) =>
                  ref.read(menuQueryProvider.notifier).set(text),
            ),
          ),
        ),
        // Chips scroll sideways instead of wrapping onto a second row
        SliverToBoxAdapter(
          child: SizedBox(
            height: 56,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              children: [
                for (final name in [null, ...categories.map((c) => c.name)])
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: ChoiceChip(
                      label: Text(name ?? 'All'),
                      selected: chosen == name,
                      onSelected: (_) =>
                          ref.read(menuCategoryProvider.notifier).set(name),
                    ),
                  ),
              ],
            ),
          ),
        ),
        for (final category in categories)
          if (chosen == null || chosen == category.name)
            if (category.products.where(matches).toList() case final products
                when products.isNotEmpty) ...[
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                  child: Text(
                    category.nameIn('en'),
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                sliver: SliverGrid.builder(
                  gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                    maxCrossAxisExtent: 240,
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 12,
                    childAspectRatio: 0.72,
                  ),
                  itemCount: products.length,
                  itemBuilder: (_, i) => ProductCard(product: products[i]),
                ),
              ),
            ],
        const SliverPadding(padding: EdgeInsets.only(bottom: 24)),
      ],
    );
  }
}

/// The card from ProductItem.js. The card and its Add button are siblings,
/// not a button inside a link (the website's accessibility problem).
class ProductCard extends ConsumerWidget {
  const ProductCard({super.key, required this.product});

  final Product product;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: InkWell(
              onTap: () => openProduct(context, product.id),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(child: ProductImage(product)),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(12, 8, 12, 0),
                    child: Text(
                      product.nameIn('en'),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Text(formatPrice(product.price)),
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8),
            child: FilledButton.icon(
              onPressed: () {
                ref.read(cartProvider.notifier).add(createItem(product));
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('${product.nameIn('en')} added to cart'),
                  ),
                );
              },
              icon: const Icon(Icons.add_shopping_cart),
              label: const Text('Add'),
            ),
          ),
        ],
      ),
    );
  }
}
