import 'package:flutter_test/flutter_test.dart';
import 'package:homecoffee/core/settings/settings.dart';
import 'package:homecoffee/features/cart/presentation/cart_notifier.dart';
import 'package:homecoffee/features/menu/data/menu_providers.dart';
import 'package:material_ui/material_ui.dart';

import 'fixtures.dart';

void main() {
  group('welcome', () {
    testWidgets('first launch walks through four screens in Khmer', (
      tester,
    ) async {
      final container = await pumpApp(tester, welcomed: false, language: null);
      expect(find.text('Welcome to HomeCoffee'), findsOneWidget);

      await tester.tap(find.text('ខ្មែរ'));
      await tester.pumpAndSettle();
      expect(find.text('សូមស្វាគមន៍មកកាន់ HomeCoffee'), findsOneWidget);

      for (var i = 0; i < 3; i++) {
        await tester.tap(find.text('បន្ត'));
        await tester.pumpAndSettle();
      }
      expect(find.text('ដឹងភ្លាមពេលរួចរាល់'), findsOneWidget);
      await tester.tap(find.text('មិនមែនឥឡូវនេះ'));
      await tester.pumpAndSettle();

      expect(find.text('អរុណសួស្តី'), findsOneWidget); // Good morning
      expect(find.text('កាពូឈីណូ'), findsOneWidget); // Cappuccino
      final settings = container.read(settingsProvider);
      expect(settings.welcomed, isTrue);
      expect(settings.language, 'km');
      expect(settings.orderAlerts, isFalse);
      expect(
        container.read(preferencesProvider).getBool('settings.welcomed'),
        isTrue,
      );
    });

    testWidgets('Skip goes straight to the menu', (tester) async {
      await pumpApp(tester, welcomed: false);
      await tester.tap(find.text('Skip'));
      await tester.pumpAndSettle();
      expect(find.text('Good morning'), findsOneWidget);
    });
  });

  group('menu', () {
    testWidgets('shows sections, prices and the pickup time', (tester) async {
      await pumpApp(tester);
      expect(find.text('Ready for pickup in about 7 min'), findsOneWidget);
      expect(find.text('Hot coffee'), findsWidgets);
      expect(find.text(r'$3.75'), findsOneWidget);
      expect(find.text(r'$1.75'), findsOneWidget);
      expect(find.text('Sold out'), findsOneWidget);
    });

    testWidgets('Add puts the item in the cart bar', (tester) async {
      await pumpApp(tester);
      expect(find.byKey(const Key('cart-bar')), findsNothing);

      await tester.tap(find.byTooltip('Add Croissant'));
      await tester.pumpAndSettle();

      expect(find.text('Croissant added to cart'), findsOneWidget);
      expect(find.byKey(const Key('cart-bar')), findsOneWidget);
      expect(find.text('View cart'), findsOneWidget);
      expect(find.text(r'$2.80'), findsNWidgets(2));
    });

    testWidgets('sold out items cannot be added', (tester) async {
      await pumpApp(tester);
      final add = tester.widget<IconButton>(
        find.widgetWithIcon(IconButton, Icons.add).last,
      );
      expect(add.onPressed, isNull);
    });

    testWidgets('search and chips filter the list', (tester) async {
      await pumpApp(tester);
      await tester.enterText(find.byType(TextField), 'crois');
      await tester.pumpAndSettle();
      expect(find.text('Croissant'), findsOneWidget);
      expect(find.text('Cappuccino'), findsNothing);

      await tester.enterText(find.byType(TextField), 'tea');
      await tester.pumpAndSettle();
      expect(find.text('No items match “tea”'), findsOneWidget);
      await tester.tap(find.text('Clear filters'));
      await tester.pumpAndSettle();

      await tester.tap(find.widgetWithText(ChoiceChip, 'Favourites'));
      await tester.pumpAndSettle();
      expect(find.text('No favourites yet'), findsOneWidget);
    });
  });

  group('product', () {
    testWidgets('options and quantity set the price in the cart', (
      tester,
    ) async {
      final container = await pumpApp(tester);
      await tester.tap(find.text('Cappuccino'));
      await tester.pumpAndSettle();

      await tester.tap(find.byTooltip('Add to favourites'));
      await tester.tap(find.text('Large'));
      await tester.pumpAndSettle();
      await tester.scrollUntilVisible(find.text('Oat'), 100);
      await tester.tap(find.text('Oat'));
      await tester.tap(find.byTooltip('Increase quantity'));
      await tester.pumpAndSettle();
      expect(find.text(r'$10.70'), findsOneWidget);

      await tester.tap(find.text('Add to cart'));
      await tester.pumpAndSettle();

      final line = container.read(cartProvider).single;
      expect(line.options, {'Size': 'Large', 'Milk': 'Oat'});
      expect(line.quantity, 2);
      expect(line.lineTotal, 1070);
      expect(container.read(favouritesProvider), {12});
      expect(find.text('Cappuccino added to cart'), findsOneWidget);
    });
  });

  group('cart', () {
    testWidgets('lines change quantity, and removing can be undone', (
      tester,
    ) async {
      final container = await pumpApp(tester);
      await tester.tap(find.byTooltip('Add Croissant'));
      await tester.tap(find.byTooltip('Add Croissant'));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('cart-bar')));
      await tester.pumpAndSettle();

      expect(find.text('Your cart'), findsOneWidget);
      expect(find.text(r'$2.80 each'), findsOneWidget);
      expect(find.text('You’ll earn 5 points with this order'), findsOneWidget);

      await tester.tap(find.byTooltip('Decrease quantity of Croissant'));
      await tester.pumpAndSettle();
      await tester.tap(find.byTooltip('Remove Croissant'));
      await tester.pumpAndSettle();
      expect(find.text('Your cart is empty'), findsOneWidget);

      await tester.tap(find.text('Undo'));
      await tester.pumpAndSettle();
      expect(container.read(cartProvider).single.quantity, 1);
    });
  });

  testWidgets('Account switches the theme and the language', (tester) async {
    final container = await pumpApp(tester);
    await tester.tap(find.text('Account'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Dark'));
    await tester.pumpAndSettle();
    expect(container.read(settingsProvider).themeMode, ThemeMode.dark);
    expect(
      Theme.of(tester.element(find.text('Settings'))).brightness,
      Brightness.dark,
    );

    await tester.tap(find.text('ខ្មែរ'));
    await tester.pumpAndSettle();
    expect(find.text('ការកំណត់'), findsOneWidget); // Settings
  });
}
