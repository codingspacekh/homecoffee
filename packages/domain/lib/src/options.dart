// A line-by-line port of services/Options.js.
import 'product.dart';
import 'cart_item.dart';

/// Group name → chosen label, e.g. {'Size': 'Large', 'Milk': 'Oat'}.
typedef Selection = Map<String, String>;

const noteMaxLength = 60;

Choice? _chosen(OptionGroup group, Selection selection) =>
    group.choices.where((c) => c.label == selection[group.name]).firstOrNull;

/// Fills in defaults and drops choices the product doesn't offer.
Selection resolveOptions(Product product, [Selection selection = const {}]) => {
  for (final group in product.options)
    group.name: (_chosen(group, selection) ?? group.choices.first).label,
};

int unitPrice(Product product, Selection selection) =>
    product.price +
    product.options.fold(
      0,
      (sum, group) => sum + (_chosen(group, selection)?.price ?? 0),
    );

List<(String, String)> nonDefaultChoices(
  Product product,
  Selection selection,
) => [
  for (final group in product.options)
    if (selection[group.name] case final label?
        when label != group.choices.first.label)
      (group.name, label),
];

/// Identifies a cart line. The note comes last, so it can't look like a choice.
String itemKey(Product product, Selection selection, [String note = '']) => [
  '${product.id}',
  for (final (group, label) in nonDefaultChoices(product, selection))
    '$group=$label',
  if (note.isNotEmpty) 'note=$note',
].join('|');

String cleanNote(String note) {
  final trimmed = note.trim();
  return trimmed.length > noteMaxLength
      ? trimmed.substring(0, noteMaxLength)
      : trimmed;
}

CartItem createItem(
  Product product, {
  Selection selection = const {},
  int quantity = 1,
  String note = '',
}) {
  final resolved = resolveOptions(product, selection);
  final cleaned = cleanNote(note);
  return CartItem(
    key: itemKey(product, resolved, cleaned),
    product: product,
    options: resolved,
    note: cleaned,
    unitPrice: unitPrice(product, resolved),
    quantity: quantity,
  );
}
