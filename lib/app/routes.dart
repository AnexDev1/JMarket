// dart
import 'package:go_router/go_router.dart';

import '../features/cart/cart_screen.dart';
import '../features/favorites/favorites_screen.dart';
import '../features/home/home_screen.dart';
import '../features/product/product_details_screen.dart';
import '../features/profile/create_product_screen.dart';
import '../features/profile/profile_screen.dart';
import '../features/search/search_screen.dart';
import 'app.dart';

class AppRoutes {
  static const String home = '/';
  static const String search = '/search';
  static const String cart = '/cart';
  static const String favorites = '/favorites';
  static const String profile = '/profile';
  static const String createProduct = '/create-product';

  static const String login = '/login';
  static const String register = '/register';

  static const String productDetails = '/product-details';
  static const String checkout = '/checkout';
  static const String orderHistory = '/order-history';
}

final appRouter = GoRouter(
  initialLocation: AppRoutes.home,
  debugLogDiagnostics: true,
  routes: [
    ShellRoute(
      builder: (context, state, child) {
        return MainScreen(child: child);
      },
      routes: [
        GoRoute(
          path: AppRoutes.home,
          builder: (context, state) => const HomeScreen(),
        ),
        GoRoute(
          path: AppRoutes.search,
          builder: (context, state) => const SearchScreen(),
        ),
        GoRoute(
          path: AppRoutes.cart,
          builder: (context, state) => const CartScreen(),
        ),
        GoRoute(
          path: AppRoutes.favorites,
          builder: (context, state) => const FavoritesScreen(),
        ),
        GoRoute(
          path: AppRoutes.profile,
          builder: (context, state) => const ProfileScreen(),
        ),
      ],
    ),
    GoRoute(
      path: AppRoutes.createProduct,
      builder: (context, state) => const CreateProductScreen(),
    ),
    GoRoute(
      path: '${AppRoutes.productDetails}/:id',
      builder: (context, state) {
        final productId = state.pathParameters['id']!;
        return ProductDetailsScreen(productId: productId);
      },
    ),
  ],
);
