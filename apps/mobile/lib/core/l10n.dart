import 'package:homecoffee_domain/homecoffee_domain.dart';
import 'package:homecoffee_ui/homecoffee_ui.dart';
import 'package:material_ui/material_ui.dart';

import '../l10n/app_localizations.dart';

export '../l10n/app_localizations.dart';

extension L10nContext on BuildContext {
  L10n get l10n => L10n.of(this);

  /// 'en' or 'km', for picking product names from the menu.
  String get language => Localizations.localeOf(this).languageCode;

  HomeCoffeeExtras get extras => Theme.of(this).extension<HomeCoffeeExtras>()!;

  /// Label text for the big 56-high buttons. Starts from the theme, so it
  /// keeps Figtree and the Khmer fallback.
  TextStyle? get largeButtonText =>
      Theme.of(this).textTheme.labelLarge?.copyWith(fontSize: 16);
}

/// The chosen options of a cart line in the customer's language, leaving out
/// the defaults: "Large, Oat".
String describeChoices(CartItem line, String language) => [
  for (final (groupName, label) in nonDefaultChoices(
    line.product,
    line.options,
  ))
    for (final group in line.product.options)
      if (group.name == groupName)
        for (final choice in group.choices)
          if (choice.label == label) choice.labelIn(language),
].join(', ');
