import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:homecoffee_domain/homecoffee_domain.dart';
import 'package:material_ui/material_ui.dart';

import '../../../core/l10n.dart';
import '../../cart/presentation/cart_notifier.dart';
import '../data/menu_providers.dart';
import 'product_image.dart';

/// One product: a big photo, its options, a note for the barista, and a bar
/// with the quantity and the price.
class ProductScreen extends ConsumerWidget {
  const ProductScreen({super.key, required this.id});

  final int id;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = context.l10n;
    Widget message(String text) => Scaffold(
      appBar: AppBar(),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(text, textAlign: TextAlign.center),
        ),
      ),
    );
    return switch (ref.watch(productProvider(id))) {
      AsyncData(value: final product?) => _ProductForm(product: product),
      AsyncData() => message(t.productMissing),
      AsyncError() => message(t.menuError),
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
  int quantity = 1;
  final note = TextEditingController();

  @override
  void dispose() {
    note.dispose();
    super.dispose();
  }

  void addToCart() {
    final product = widget.product;
    ref
        .read(cartProvider.notifier)
        .add(
          createItem(
            product,
            selection: selection,
            quantity: quantity,
            note: note.text,
          ),
        );
    final messenger = ScaffoldMessenger.of(context);
    final text = context.l10n.added(product.nameIn(context.language));
    context.pop();
    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(text)));
  }

  @override
  Widget build(BuildContext context) {
    final t = context.l10n;
    final product = widget.product;
    final language = context.language;
    final text = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;
    final name = product.nameIn(language);
    final price = unitPrice(product, selection) * quantity;

    return Scaffold(
      body: ListView(
        padding: EdgeInsets.zero,
        children: [
          Stack(
            children: [
              ProductImage(product, height: 260),
              Positioned(
                top: MediaQuery.paddingOf(context).top + 12,
                left: 12,
                child: _RoundButton(
                  tooltip: t.back,
                  icon: const Icon(Icons.arrow_back),
                  onPressed: () => context.pop(),
                ),
              ),
              Positioned(
                top: MediaQuery.paddingOf(context).top + 12,
                right: 12,
                child: _FavouriteButton(productId: product.id),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Semantics(
                  header: true,
                  child: Text(
                    name,
                    style: text.headlineMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  formatPrice(product.price),
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: scheme.primary,
                  ),
                ),
                if (product.descriptionIn(language) case final description
                    when description.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Text(
                    description,
                    style: text.bodyLarge?.copyWith(
                      color: context.extras.bodyText,
                    ),
                  ),
                ],
              ],
            ),
          ),
          for (final group in product.options)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
              child: _OptionPicker(
                group: group,
                selected: selection[group.name],
                onChanged: (label) => setState(
                  () => selection = {...selection, group.name: label},
                ),
              ),
            ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
            child: TextField(
              controller: note,
              maxLength: noteMaxLength,
              textCapitalization: TextCapitalization.sentences,
              decoration: InputDecoration(
                labelText: t.note,
                hintText: t.noteHint,
                floatingLabelBehavior: FloatingLabelBehavior.always,
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: DecoratedBox(
        decoration: BoxDecoration(
          color: scheme.surfaceContainer,
          border: Border(top: BorderSide(color: scheme.outlineVariant)),
        ),
        child: SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
            child: Row(
              children: [
                _QuantityStepper(
                  quantity: quantity,
                  onChanged: (value) => setState(() => quantity = value),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: FilledButton(
                    style: FilledButton.styleFrom(
                      minimumSize: const Size.fromHeight(56),
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      textStyle: context.largeButtonText,
                    ),
                    onPressed: product.available ? addToCart : null,
                    child: product.available
                        ? Row(
                            children: [
                              Expanded(child: Text(t.addToCart)),
                              Text(formatPrice(price)),
                            ],
                          )
                        : Text(t.soldOut),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// A white circle over the photo, so the icon shows on any picture.
class _RoundButton extends StatelessWidget {
  const _RoundButton({
    required this.tooltip,
    required this.icon,
    required this.onPressed,
    this.color,
  });

  final String tooltip;
  final Widget icon;
  final VoidCallback onPressed;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Material(
      color: scheme.surface,
      shape: const CircleBorder(),
      elevation: 2,
      child: IconButton(
        tooltip: tooltip,
        color: color ?? scheme.onSurface,
        icon: icon,
        onPressed: onPressed,
      ),
    );
  }
}

class _FavouriteButton extends ConsumerWidget {
  const _FavouriteButton({required this.productId});

  final int productId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = context.l10n;
    final on = ref.watch(favouritesProvider).contains(productId);
    return Semantics(
      toggled: on,
      child: _RoundButton(
        tooltip: on ? t.removeFavourite : t.addFavourite,
        color: on ? context.extras.favourite : null,
        icon: Icon(on ? Icons.favorite : Icons.favorite_border),
        onPressed: () =>
            ref.read(favouritesProvider.notifier).toggle(productId),
      ),
    );
  }
}

/// Up to three choices sit side by side like the prototype's sizes; more
/// become a list of radio buttons like its milks.
class _OptionPicker extends StatelessWidget {
  const _OptionPicker({
    required this.group,
    required this.selected,
    required this.onChanged,
  });

  final OptionGroup group;
  final String? selected;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    final language = context.language;
    final scheme = Theme.of(context).colorScheme;
    String extra(Choice choice) =>
        choice.price > 0 ? '+${formatPrice(choice.price)}' : '';
    final heading = Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Semantics(
        header: true,
        child: Text(
          group.nameIn(language),
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ),
    );

    if (group.choices.length <= 3) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          heading,
          SegmentedButton<String>(
            showSelectedIcon: true,
            style: SegmentedButton.styleFrom(
              minimumSize: const Size(0, 56),
              selectedBackgroundColor: scheme.secondaryContainer,
              selectedForegroundColor: scheme.onSecondaryContainer,
              side: BorderSide(color: scheme.outline),
            ),
            segments: [
              for (final choice in group.choices)
                ButtonSegment(
                  value: choice.label,
                  label: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        choice.labelIn(language),
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      if (extra(choice).isNotEmpty)
                        Text(
                          extra(choice),
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                    ],
                  ),
                ),
            ],
            selected: {?selected},
            onSelectionChanged: (values) => onChanged(values.single),
          ),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        heading,
        Material(
          color: scheme.surfaceContainerLow,
          borderRadius: BorderRadius.circular(16),
          clipBehavior: Clip.antiAlias,
          child: RadioGroup<String>(
            groupValue: selected,
            onChanged: (value) => onChanged(value!),
            child: Column(
              children: [
                for (final (i, choice) in group.choices.indexed) ...[
                  if (i > 0) Divider(height: 1, color: scheme.outlineVariant),
                  RadioListTile<String>(
                    value: choice.label,
                    minTileHeight: 56,
                    title: Text(choice.labelIn(language)),
                    secondary: Text(
                      extra(choice),
                      style: TextStyle(
                        fontSize: 14,
                        color: scheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _QuantityStepper extends StatelessWidget {
  const _QuantityStepper({required this.quantity, required this.onChanged});

  final int quantity;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    final t = context.l10n;
    final scheme = Theme.of(context).colorScheme;
    return Semantics(
      label: t.quantity,
      container: true,
      child: Container(
        height: 56,
        padding: const EdgeInsets.symmetric(horizontal: 3),
        decoration: ShapeDecoration(
          shape: StadiumBorder(side: BorderSide(color: scheme.outline)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              tooltip: t.decrease,
              icon: const Icon(Icons.remove),
              onPressed: quantity > 1 ? () => onChanged(quantity - 1) : null,
            ),
            SizedBox(
              width: 24,
              child: Text(
                '$quantity',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            IconButton(
              tooltip: t.increase,
              icon: const Icon(Icons.add),
              onPressed: quantity < 20 ? () => onChanged(quantity + 1) : null,
            ),
          ],
        ),
      ),
    );
  }
}
