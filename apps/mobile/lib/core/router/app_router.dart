import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../features/cart/presentation/cart_screen.dart';
import '../../features/menu/presentation/menu_screen.dart';
import '../../features/menu/presentation/product_screen.dart';
import '../../features/shell/app_shell.dart';
import '../../features/shell/placeholder_screen.dart';

/// Router.js, as go_router routes. The four tabs keep their own history
/// (StatefulShellRoute), so leaving Cart and coming back keeps your place.
final appRouter = GoRouter(
  routes: [
    StatefulShellRoute.indexedStack(
      builder: (context, state, shell) => AppShell(shell: shell),
      branches: [
        StatefulShellBranch(
          routes: [GoRoute(path: '/', builder: (_, _) => const MenuScreen())],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/favourites',
              builder: (_, _) => const PlaceholderScreen('Favourites'),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/orders',
              builder: (_, _) => const PlaceholderScreen('Order history'),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(path: '/cart', builder: (_, _) => const CartScreen()),
          ],
        ),
      ],
    ),
    // Outside the shell, so details cover the tab bar like a pushed page
    GoRoute(
      path: '/product/:id',
      builder: (_, state) =>
          ProductScreen(id: int.parse(state.pathParameters['id']!)),
    ),
  ],
  errorBuilder: (_, _) => const PlaceholderScreen('Page not found'),
);

void openProduct(BuildContext context, int id) => context.push('/product/$id');
