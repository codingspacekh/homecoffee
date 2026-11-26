import 'package:homecoffee/core/router/app_router.dart';
import 'package:homecoffee/features/menu/data/menu_providers.dart';
import 'package:homecoffee_data/homecoffee_data.dart';
import 'package:homecoffee_domain/homecoffee_domain.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

import 'fixtures.dart';

class FakeMenuRepository implements MenuRepository {
  @override
  Future<List<Category>> fetchMenu() async => [
    Category(name: 'Snacks', products: [croissant]),
  ];
}

void main() {
  testWidgets('Add puts the item in the cart badge', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          menuRepositoryProvider.overrideWithValue(FakeMenuRepository()),
        ],
        child: MaterialApp.router(routerConfig: appRouter),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Croissant'), findsOneWidget);
    await tester.tap(find.text('Add'));
    await tester.pump();

    expect(find.text('Croissant added to cart'), findsOneWidget);
    expect(find.text('1'), findsOneWidget); // the badge
  });
}
