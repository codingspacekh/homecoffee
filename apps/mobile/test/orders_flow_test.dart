import 'package:flutter_test/flutter_test.dart';
import 'package:homecoffee/core/session/session.dart';
import 'package:homecoffee/features/cart/presentation/cart_notifier.dart';
import 'package:homecoffee/features/menu/data/menu_providers.dart';
import 'package:homecoffee_data/homecoffee_data.dart';
import 'package:material_ui/material_ui.dart';

import 'fixtures.dart';

Future<void> openCheckoutFromCart(WidgetTester tester) async {
  await tester.tap(find.byTooltip('Add Cappuccino'));
  await tester.pumpAndSettle();
  await tester.tap(find.byKey(const Key('cart-bar')));
  await tester.pumpAndSettle();
  await tester.tap(find.text('Go to checkout'));
  await tester.pumpAndSettle();
}

Future<void> placeOrder(WidgetTester tester) async {
  await tester.tap(find.byKey(const Key('place-order')));
  await tester.pumpAndSettle();
}

void main() {
  group('sign-in', () {
    testWidgets('checkout asks for an email code first', (tester) async {
      final backend = TestBackend();
      final container = await pumpApp(tester, backend: backend);
      await openCheckoutFromCart(tester);

      expect(find.text('Sign in to order'), findsOneWidget);
      await tester.enterText(find.byKey(const Key('email')), 'not an email');
      await tester.tap(find.text('Send code'));
      await tester.pumpAndSettle();
      expect(find.text('Please enter a valid email address'), findsOneWidget);

      await tester.enterText(
        find.byKey(const Key('email')),
        ' Dara@Example.com ',
      );
      await tester.tap(find.text('Send code'));
      await tester.pumpAndSettle();
      expect(backend.codesSent, ['dara@example.com']);
      expect(find.text('Check your email'), findsOneWidget);

      await tester.enterText(find.byKey(const Key('code')), '111111');
      await tester.tap(find.text('Sign in'));
      await tester.pumpAndSettle();
      expect(find.text('That code isn’t right. 4 tries left.'), findsOneWidget);

      await tester.enterText(find.byKey(const Key('code')), '123456');
      await tester.tap(find.text('Sign in'));
      await tester.pumpAndSettle();

      expect(find.text('Checkout'), findsOneWidget);
      expect(container.read(accountProvider)?.email, 'dara@example.com');
      // Name and phone come from the account
      expect(find.text('Dara'), findsOneWidget);
      expect(find.text('012 345 678'), findsOneWidget);
    });

    testWidgets('signing out forgets the account on this phone', (
      tester,
    ) async {
      final backend = TestBackend();
      final container = await pumpApp(tester, backend: backend, signedIn: true);
      await tester.tap(find.text('Account'));
      await tester.pumpAndSettle();
      expect(find.text('dara@example.com\n012 345 678'), findsOneWidget);

      await tester.scrollUntilVisible(find.text('Sign out'), 200);
      await tester.tap(find.text('Sign out'));
      await tester.pumpAndSettle();

      expect(backend.signedOut, isTrue);
      expect(container.read(signedInProvider), isFalse);
      expect(container.read(tokenStoreProvider).token, isNull);
      expect(find.text('Sign in'), findsOneWidget);
    });
  });

  group('checkout', () {
    testWidgets('places an order and opens its status', (tester) async {
      final backend = TestBackend();
      final container = await pumpApp(tester, backend: backend, signedIn: true);
      await openCheckoutFromCart(tester);

      expect(find.text('Ready in about 7 min'), findsOneWidget);
      expect(find.text('38 more points for a free drink'), findsOneWidget);
      await placeOrder(tester);

      final placed = backend.placed.single;
      expect(placed.key, matches(RegExp(r'^[0-9a-f]{32}$')));
      expect(placed.checkout.pickupAt, isNull);
      expect(placed.checkout.customerName, 'Dara');
      expect(placed.checkout.lines.single.product.id, cappuccino.id);
      expect(container.read(cartProvider), isEmpty);

      expect(find.text('Order status'), findsOneWidget);
      expect(find.text('#1042'), findsOneWidget);
      expect(
        find.text('We’ve got your order. Ready around 9:07 AM.'),
        findsOneWidget,
      );
      expect(find.text('Pickup as soon as possible'), findsOneWidget);
    });

    testWidgets('name and phone are checked before sending', (tester) async {
      final backend = TestBackend(
        account: const Account(id: 8, email: 'a@b.co'),
      );
      await pumpApp(tester, backend: backend, signedIn: true);
      await openCheckoutFromCart(tester);

      await placeOrder(tester);
      expect(find.text('Please enter your name'), findsOneWidget);
      expect(find.text('Please enter your phone number'), findsOneWidget);

      await tester.enterText(find.byKey(const Key('name')), 'Sophea');
      await tester.enterText(find.byKey(const Key('phone')), '12345');
      await placeOrder(tester);
      expect(find.text('Please enter a valid phone number'), findsOneWidget);
      expect(backend.placed, isEmpty);
    });

    testWidgets('a promo code is checked by the server', (tester) async {
      await pumpApp(tester, signedIn: true);
      await openCheckoutFromCart(tester);

      await tester.enterText(find.byKey(const Key('promo')), 'save2');
      await tester.tap(find.text('Apply'));
      await tester.pumpAndSettle();
      expect(
        find.text(r'SAVE2 needs an order of $10.00 or more'),
        findsOneWidget,
      );

      await tester.enterText(find.byKey(const Key('promo')), 'welcome10');
      await tester.tap(find.text('Apply'));
      await tester.pumpAndSettle();
      expect(find.text('WELCOME10 applied'), findsOneWidget);
      await tester.scrollUntilVisible(
        find.text('Promo WELCOME10'),
        200,
        scrollable: find.byType(Scrollable).first,
      );
      expect(find.text('Promo WELCOME10'), findsOneWidget);
      // 10% of $3.75 is 37.5 cents, rounded to 38 like the website
      expect(find.text(r'−$0.38'), findsOneWidget);
      expect(find.text(r'$3.37'), findsWidgets);
    });

    testWidgets('a closed shop offers pickup times later today', (
      tester,
    ) async {
      final backend = TestBackend();
      await pumpApp(tester, backend: backend, signedIn: true, storeOpen: false);
      await openCheckoutFromCart(tester);

      // 9:00 now, so 9:15 is the first time with 7 minutes to make it
      expect(find.text('9:15 AM'), findsOneWidget);
      await tester.tap(find.text('9:30 AM'));
      await tester.pumpAndSettle();
      await placeOrder(tester);

      expect(
        backend.placed.single.checkout.pickupAt,
        DateTime(2026, 11, 27, 9, 30),
      );
      expect(find.text('Pickup at 9:30 AM'), findsOneWidget);
    });

    testWidgets('a free drink can be used with 50 points', (tester) async {
      final backend = TestBackend(account: dara.copyWith(points: 55));
      await pumpApp(tester, backend: backend, signedIn: true);
      await openCheckoutFromCart(tester);

      await tester.tap(find.text(r'Use my free drink (−$3.75)'));
      await tester.pumpAndSettle();
      expect(find.text(r'$0.00'), findsWidgets);
      await placeOrder(tester);
      expect(backend.placed.single.checkout.useFreeDrink, isTrue);
    });
  });

  group('order status', () {
    testWidgets('moves on live as the barista works', (tester) async {
      final backend = TestBackend();
      await pumpApp(tester, backend: backend, signedIn: true);
      await openCheckoutFromCart(tester);
      await placeOrder(tester);

      backend.advance(42, OrderStatus.preparing);
      await tester.pumpAndSettle();
      expect(
        find.text('We’re making your order. Ready around 9:07 AM.'),
        findsOneWidget,
      );
      expect(find.text('Cancel order'), findsNothing);

      backend.advance(42, OrderStatus.ready);
      await tester.pumpAndSettle();
      expect(find.text('Your order is ready to pick up!'), findsOneWidget);

      backend
        ..account = backend.account.copyWith(points: 15)
        ..advance(42, OrderStatus.collected);
      await tester.pumpAndSettle();
      expect(find.text('Picked up. Enjoy!'), findsOneWidget);
      expect(find.text('+3 points'), findsOneWidget);
      expect(find.text('You now have 15 points.'), findsOneWidget);
      expect(find.text('Notify me when it’s ready'), findsNothing);
    });

    testWidgets('can be cancelled before the barista starts', (tester) async {
      final backend = TestBackend();
      await pumpApp(tester, backend: backend, signedIn: true);
      await openCheckoutFromCart(tester);
      await placeOrder(tester);

      await tester.scrollUntilVisible(find.text('Cancel order'), 200);
      await tester.tap(find.text('Cancel order'));
      await tester.pumpAndSettle();
      expect(find.text('Cancel this order?'), findsOneWidget);
      await tester.tap(find.widgetWithText(TextButton, 'Cancel order').last);
      await tester.pumpAndSettle();

      expect(backend.orders[42]!.status, OrderStatus.cancelled);
      expect(find.text('Order cancelled'), findsOneWidget);
      await tester.scrollUntilVisible(
        find.text('This order was cancelled.'),
        -200,
      );
      expect(find.text('This order was cancelled.'), findsOneWidget);
    });
  });

  group('orders tab', () {
    testWidgets('asks to sign in when signed out', (tester) async {
      await pumpApp(tester);
      await tester.tap(find.text('Orders'));
      await tester.pumpAndSettle();
      expect(find.text('Sign in'), findsOneWidget);
    });

    testWidgets('tracks open orders and reorders past ones', (tester) async {
      final backend = TestBackend();
      final container = await pumpApp(tester, backend: backend, signedIn: true);
      await openCheckoutFromCart(tester);
      await placeOrder(tester);
      backend.advance(42, OrderStatus.collected);
      await tester.pumpAndSettle();
      await tester.tap(find.text('Back to menu'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Orders'));
      await tester.pumpAndSettle();
      expect(find.text('Past orders'), findsOneWidget);
      expect(find.text('#1042'), findsOneWidget);
      expect(find.text('1 Cappuccino'), findsOneWidget);

      await tester.tap(find.text('Reorder'));
      await tester.pumpAndSettle();
      expect(find.text('Order #1042 added to cart'), findsOneWidget);
      expect(container.read(cartCountProvider), 1);
    });
  });

  testWidgets('rewards show points and history', (tester) async {
    await pumpApp(tester, signedIn: true);
    await tester.tap(find.text('Rewards'));
    await tester.pumpAndSettle();
    expect(find.text('12'), findsOneWidget);
    expect(find.text('/ 50 points'), findsOneWidget);
    expect(find.text('38 more points for a free drink'), findsOneWidget);
    await tester.scrollUntilVisible(find.text('Order #1001'), 200);
    expect(find.text('+12'), findsOneWidget);
  });

  testWidgets('favourites move to the account on sign-in', (tester) async {
    final backend = TestBackend()..favourites.add(41);
    final container = await pumpApp(tester, backend: backend);
    container.read(favouritesProvider.notifier).toggle(cappuccino.id);

    await container
        .read(sessionProvider.notifier)
        .verify('dara@example.com', '123456');
    await tester.pumpAndSettle();

    expect(backend.favourites, {12, 41});
    expect(container.read(favouritesProvider), {12, 41});
  });
}
