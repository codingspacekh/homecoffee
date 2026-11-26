import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../features/account/account_screen.dart';
import '../../features/cart/presentation/cart_screen.dart';
import '../../features/menu/presentation/menu_screen.dart';
import '../../features/menu/presentation/product_screen.dart';
import '../../features/orders/orders_screen.dart';
import '../../features/rewards/rewards_screen.dart';
import '../../features/shell/app_shell.dart';
import '../../features/welcome/welcome_screen.dart';
import '../settings/settings.dart';

/// The app's pages. The four tabs keep their own history
/// (StatefulShellRoute), so leaving Rewards and coming back keeps your place.
/// Until the welcome screens are done, every page leads to them.
final routerProvider = Provider<GoRouter>((ref) {
  final welcomed = ValueNotifier(ref.read(settingsProvider).welcomed);
  ref.listen(
    settingsProvider.select((s) => s.welcomed),
    (_, value) => welcomed.value = value,
  );

  final router = GoRouter(
    refreshListenable: welcomed,
    redirect: (context, state) {
      final atWelcome = state.matchedLocation == '/welcome';
      if (!welcomed.value && !atWelcome) return '/welcome';
      if (welcomed.value && atWelcome) return '/';
      return null;
    },
    routes: [
      GoRoute(path: '/welcome', builder: (_, _) => const WelcomeScreen()),
      StatefulShellRoute.indexedStack(
        builder: (context, state, shell) => AppShell(shell: shell),
        branches: [
          StatefulShellBranch(
            routes: [GoRoute(path: '/', builder: (_, _) => const MenuScreen())],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(path: '/orders', builder: (_, _) => const OrdersScreen()),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/rewards',
                builder: (_, _) => const RewardsScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/account',
                builder: (_, _) => const AccountScreen(),
              ),
            ],
          ),
        ],
      ),
      // Outside the shell, so they cover the tab bar like a pushed page
      GoRoute(
        path: '/product/:id',
        builder: (_, state) =>
            ProductScreen(id: int.parse(state.pathParameters['id']!)),
      ),
      GoRoute(path: '/cart', builder: (_, _) => const CartScreen()),
    ],
  );
  ref.onDispose(() {
    router.dispose();
    welcomed.dispose();
  });
  return router;
});

/// Opening a page clears any "added to cart" message, so it doesn't cover
/// the new page's buttons.
void openProduct(BuildContext context, int id) {
  ScaffoldMessenger.of(context).hideCurrentSnackBar();
  context.push('/product/$id');
}

void openCart(BuildContext context) {
  ScaffoldMessenger.of(context).hideCurrentSnackBar();
  context.push('/cart');
}
