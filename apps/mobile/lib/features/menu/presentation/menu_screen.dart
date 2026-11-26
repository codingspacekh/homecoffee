import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:homecoffee_domain/homecoffee_domain.dart';
import 'package:material_ui/material_ui.dart';

import '../../../core/l10n.dart';
import '../../../core/router/app_router.dart';
import '../../../core/settings/settings.dart';
import '../../../core/widgets/brand_mark.dart';
import '../../cart/presentation/cart_notifier.dart';
import '../data/menu_providers.dart';
import 'product_image.dart';

/// The chips under the search bar: everything, favourites, or one category.
sealed class MenuFilter {
  const MenuFilter();
}

class AllItems extends MenuFilter {
  const AllItems();
}

class FavouriteItems extends MenuFilter {
  const FavouriteItems();
}

class CategoryItems extends MenuFilter {
  const CategoryItems(this.categoryId);

  final int? categoryId;

  @override
  bool operator ==(Object other) =>
      other is CategoryItems && other.categoryId == categoryId;

  @override
  int get hashCode => categoryId.hashCode;
}

class MenuQuery extends Notifier<String> {
  @override
  String build() => '';

  void set(String text) => state = text;
}

class MenuFilterNotifier extends Notifier<MenuFilter> {
  @override
  MenuFilter build() => const AllItems();

  void set(MenuFilter filter) => state = filter;
}

final menuQueryProvider = NotifierProvider<MenuQuery, String>(MenuQuery.new);
final menuFilterProvider = NotifierProvider<MenuFilterNotifier, MenuFilter>(
  MenuFilterNotifier.new,
);

/// The menu tab: a greeting, the pickup time, search, category chips and
/// the products in sections.
class MenuScreen extends ConsumerWidget {
  const MenuScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = context.l10n;
    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: switch (ref.watch(menuProvider)) {
          AsyncData(:final value) => _MenuList(categories: value),
          AsyncError() => Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    t.menuError,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  const SizedBox(height: 16),
                  FilledButton(
                    onPressed: () => ref.invalidate(menuProvider),
                    child: Text(t.tryAgain),
                  ),
                ],
              ),
            ),
          ),
          _ => const Center(child: CircularProgressIndicator()),
        },
      ),
    );
  }
}

class _MenuList extends ConsumerWidget {
  const _MenuList({required this.categories});

  final List<Category> categories;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = context.l10n;
    final language = context.language;
    final query = ref.watch(menuQueryProvider).trim().toLowerCase();
    final filter = ref.watch(menuFilterProvider);
    final favourites = ref.watch(favouritesProvider);

    bool matches(Product p) =>
        (filter is! FavouriteItems || favourites.contains(p.id)) &&
        (query.isEmpty ||
            p.name.toLowerCase().contains(query) ||
            p.nameIn(language).toLowerCase().contains(query));

    final sections = [
      for (final category in categories)
        if (filter is! CategoryItems || filter.categoryId == category.id)
          if (category.products.where(matches).toList() case final products
              when products.isNotEmpty)
            (category, products),
    ];

    return CustomScrollView(
      slivers: [
        const SliverToBoxAdapter(child: _Header()),
        const SliverToBoxAdapter(child: _SearchField()),
        SliverToBoxAdapter(child: _FilterChips(categories: categories)),
        for (final (category, products) in sections) ...[
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 24, 16, 4),
              child: Semantics(
                header: true,
                child: Text(
                  category.nameIn(language),
                  style: Theme.of(context).textTheme.titleLarge
                      ?.copyWith(fontSize: 20, fontWeight: FontWeight.w800),
                ),
              ),
            ),
          ),
          SliverList.builder(
            itemCount: products.length,
            itemBuilder: (_, i) => ProductRow(product: products[i]),
          ),
        ],
        if (sections.isEmpty)
          SliverToBoxAdapter(
            child: _EmptyResults(
              title: query.isNotEmpty
                  ? t.noResults(ref.watch(menuQueryProvider).trim())
                  : filter is FavouriteItems
                  ? t.noFavourites
                  : t.noResults(''),
              hint: query.isEmpty && filter is FavouriteItems
                  ? t.noFavouritesHint
                  : t.noResultsHint,
            ),
          ),
        // Room for the floating cart bar and the tabs
        SliverPadding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.paddingOf(context).bottom + 16,
          ),
        ),
      ],
    );
  }
}

class _Header extends ConsumerWidget {
  const _Header();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = context.l10n;
    final scheme = Theme.of(context).colorScheme;
    final hour = ref.watch(clockProvider)().hour;
    final greeting = hour < 12
        ? t.goodMorning
        : hour < 17
        ? t.goodAfternoon
        : t.goodEvening;
    final store = ref.watch(storeProvider).value;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const BrandMark(),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'HomeCoffee',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: scheme.primary,
                      ),
                    ),
                    Semantics(
                      header: true,
                      child: Text(
                        greeting,
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (store != null) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.schedule, color: scheme.primary),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    store.canOrderNow
                        ? t.readyIn(store.prepMinutes)
                        : t.closedNow,
                    style: TextStyle(
                      fontSize: 16,
                      color: context.extras.bodyText,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _SearchField extends ConsumerStatefulWidget {
  const _SearchField();

  @override
  ConsumerState<_SearchField> createState() => _SearchFieldState();
}

class _SearchFieldState extends ConsumerState<_SearchField> {
  late final controller = TextEditingController(
    text: ref.read(menuQueryProvider),
  );

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = context.l10n;
    final scheme = Theme.of(context).colorScheme;
    final hasText = ref.watch(menuQueryProvider).isNotEmpty;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: TextField(
        controller: controller,
        onChanged: ref.read(menuQueryProvider.notifier).set,
        textInputAction: TextInputAction.search,
        style: const TextStyle(fontSize: 16),
        decoration: InputDecoration(
          hintText: t.search,
          filled: true,
          fillColor: scheme.surfaceContainerHighest,
          contentPadding: const EdgeInsets.symmetric(vertical: 16),
          prefixIcon: Padding(
            padding: const EdgeInsets.only(left: 16, right: 4),
            child: Icon(Icons.search, color: scheme.onSurfaceVariant),
          ),
          suffixIcon: hasText
              ? IconButton(
                  tooltip: t.clearSearch,
                  icon: const Icon(Icons.close),
                  onPressed: () {
                    controller.clear();
                    ref.read(menuQueryProvider.notifier).set('');
                  },
                )
              : null,
          border: const OutlineInputBorder(
            borderSide: BorderSide.none,
            borderRadius: BorderRadius.all(Radius.circular(28)),
          ),
          enabledBorder: const OutlineInputBorder(
            borderSide: BorderSide.none,
            borderRadius: BorderRadius.all(Radius.circular(28)),
          ),
        ),
      ),
    );
  }
}

class _FilterChips extends ConsumerWidget {
  const _FilterChips({required this.categories});

  final List<Category> categories;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = context.l10n;
    final chosen = ref.watch(menuFilterProvider);
    final filters = <(MenuFilter, String)>[
      (const AllItems(), t.all),
      (const FavouriteItems(), t.favourites),
      for (final category in categories)
        (CategoryItems(category.id), category.nameIn(context.language)),
    ];
    return Semantics(
      label: t.categories,
      container: true,
      child: SizedBox(
        height: 60,
        // Chips scroll sideways instead of wrapping onto a second row
        child: ListView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.fromLTRB(12, 12, 12, 0),
          children: [
            for (final (filter, label) in filters)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: ChoiceChip(
                  label: Text(label),
                  labelStyle: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                  selected: chosen == filter,
                  onSelected: (_) =>
                      ref.read(menuFilterProvider.notifier).set(filter),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _EmptyResults extends ConsumerWidget {
  const _EmptyResults({required this.title, required this.hint});

  final String title;
  final String hint;

  @override
  Widget build(BuildContext context, WidgetRef ref) => Padding(
    padding: const EdgeInsets.fromLTRB(24, 40, 24, 0),
    child: Column(
      children: [
        Text(
          title,
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 12),
        Text(
          hint,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 16,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 12),
        OutlinedButton(
          onPressed: () {
            ref.read(menuQueryProvider.notifier).set('');
            ref.read(menuFilterProvider.notifier).set(const AllItems());
          },
          child: Text(context.l10n.clearFilters),
        ),
      ],
    ),
  );
}

/// Photo, name, two lines of description and price, with a round Add button
/// beside it. The row and the button are siblings, never one inside the
/// other, so each has its own label for screen readers.
class ProductRow extends ConsumerWidget {
  const ProductRow({super.key, required this.product});

  final Product product;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = context.l10n;
    final language = context.language;
    final scheme = Theme.of(context).colorScheme;
    final name = product.nameIn(language);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: InkWell(
              borderRadius: BorderRadius.circular(16),
              onTap: () => openProduct(context, product.id),
              child: Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: ProductImage(product, size: 88),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          name,
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          product.descriptionIn(language),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 14,
                            color: context.extras.bodyText,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Wrap(
                          crossAxisAlignment: WrapCrossAlignment.center,
                          spacing: 8,
                          runSpacing: 4,
                          children: [
                            Text(
                              formatPrice(product.price),
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: product.available
                                    ? scheme.onSurface
                                    : scheme.onSurfaceVariant,
                              ),
                            ),
                            if (!product.available)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 2,
                                ),
                                decoration: ShapeDecoration(
                                  color: scheme.surfaceContainerHighest,
                                  shape: const StadiumBorder(),
                                ),
                                child: Text(
                                  t.soldOut,
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: scheme.onSurfaceVariant,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 12),
          IconButton.filledTonal(
            tooltip: t.addItem(name),
            iconSize: 24,
            style: IconButton.styleFrom(minimumSize: const Size(48, 48)),
            icon: const Icon(Icons.add),
            onPressed: product.available
                ? () {
                    ref.read(cartProvider.notifier).add(createItem(product));
                    ScaffoldMessenger.of(context)
                      ..hideCurrentSnackBar()
                      ..showSnackBar(SnackBar(content: Text(t.added(name))));
                  }
                : null,
          ),
        ],
      ),
    );
  }
}
