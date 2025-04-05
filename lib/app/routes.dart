import 'package:flutter/cupertino.dart';
import 'package:go_router/go_router.dart';
import 'package:jmarket/features/orders/orders_screen.dart';
import 'package:jmarket/features/profile/about_us_screen.dart';
import 'package:jmarket/features/profile/account_deletion_screen.dart';
import 'package:jmarket/features/profile/help_center_screen.dart';
import 'package:jmarket/features/profile/language_screen.dart';
import 'package:jmarket/features/profile/privacy_policy_screen.dart';
import 'package:provider/provider.dart';

import '../features/auth/auth_screen.dart';
import '../features/cart/cart_screen.dart';
import '../features/cart/checkout/checkout_screen.dart';
import '../features/favorites/favorites_screen.dart';
import '../features/home/home_screen.dart';
import '../features/product/product_details_screen.dart';
import '../features/profile/profile_screen.dart';
import '../features/profile/reset_password_screen.dart';
import '../features/search/screens/search_screen.dart';
import '../providers/auth_provider.dart';
import 'app.dart';

class AppRoutes {
  static const String home = '/';
  static const String search = '/search';
  static const String cart = '/cart';
  static const String favorites = '/favorites';
  static const String profile = '/profile';
  static const String privacyPolicy = '/privacy';
  static const String aboutUs = '/about';
  static const String languageSettings = '/language-settings';
  static const String createProduct = '/create-product';

  static const String login = '/login';
  static const String register = '/register';
  static const String auth = '/auth';
  static const String deleteAccount = '/delete-account';

  static const String productDetails = '/product-details';
  static const String checkout = '/checkout';
  static const String orderHistory = '/order-history';
  static const String orderDetails = '/orders';
  static const String help = '/help';
}

final appRouter = GoRouter(
  initialLocation: AppRoutes.home,
  debugLogDiagnostics: true,
  observers: [NavigatorObserver()],
  redirect: (context, state) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    // Skip redirection if loading
    if (authProvider.isLoading) {
      return null;
    }

    final isAuthenticated = authProvider.isAuthenticated;
    final isAuthRoute = state.matchedLocation == AppRoutes.auth;

    // Protected routes that require authentication
    final isProtectedRoute = state.matchedLocation == AppRoutes.checkout ||
        state.matchedLocation == AppRoutes.profile ||
        state.matchedLocation == AppRoutes.createProduct;

    // Redirect to auth if user tries to access protected routes while not authenticated
    if (isProtectedRoute && !isAuthenticated) {
      // Store the original path to return after authentication
      return '${AppRoutes.auth}?redirect=${state.matchedLocation}';
    }

    // Redirect to home if user is on auth page but already authenticated
    if (isAuthRoute && isAuthenticated) {
      // Check if there's a redirect parameter to return to
      final redirectLocation = state.uri.queryParameters['redirect'];
      return redirectLocation ?? AppRoutes.home;
    }

    return null;
  },
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
          path: AppRoutes.help,
          builder: (context, state) => const HelpCenterScreen(),
        ),
        GoRoute(
          path: AppRoutes.profile,
          builder: (context, state) => const ProfileScreen(),
        ),
      ],
      navigatorKey: GlobalKey<NavigatorState>(),
    ),
    GoRoute(
      path: AppRoutes.orderDetails,
      builder: (context, state) => OrdersScreen(),
    ),
    GoRoute(
      path: AppRoutes.languageSettings,
      builder: (context, state) => LanguageScreen(),
    ),
    GoRoute(
      path: AppRoutes.deleteAccount,
      builder: (context, state) => AccountDeletionScreen(),
    ),
    GoRoute(
      path: AppRoutes.privacyPolicy,
      builder: (context, state) => PrivacyPolicyScreen(),
    ),
    GoRoute(
      path: AppRoutes.aboutUs,
      builder: (context, state) => AboutUsScreen(),
    ),
    GoRoute(
      path: '${AppRoutes.productDetails}/:id',
      builder: (context, state) {
        final productId = state.pathParameters['id']!;
        return ProductDetailsScreen(productId: productId);
      },
    ),
    GoRoute(
      path: AppRoutes.checkout,
      builder: (context, state) => const CheckoutScreen(),
    ),
    GoRoute(
      path: '/reset-password',
      builder: (context, state) => ResetPasswordScreen(
        params: state.extra as Map<String, dynamic>,
      ),
    ),
    GoRoute(
      path: AppRoutes.auth,
      builder: (context, state) {
        final redirectLocation = state.uri.queryParameters['redirect'];
        return AuthScreen(redirectLocation: redirectLocation);
      },
    ),
  ],
);
