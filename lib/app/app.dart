// lib/app/app.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:go_router/go_router.dart';
import 'package:jmarket/providers/language_provider.dart';
import 'package:provider/provider.dart';

import '../providers/auth_provider.dart';
import '../providers/theme_provider.dart';
import 'routes.dart';

class App extends StatelessWidget {
  const App({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer2<ThemeProvider, LanguageProvider>(
      builder: (context, themeProvider, languageProvider, _) {
        return MaterialApp.router(
          title: 'JMarket',
          locale: languageProvider.locale,
          supportedLocales: AppLocalizations.supportedLocales,
          localizationsDelegates: [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          debugShowCheckedModeBanner: false,
          themeMode: themeProvider.themeMode,
          theme: _buildLightTheme(),
          darkTheme: _buildDarkTheme(),
          routerConfig: appRouter,
        );
      },
    );
  }

  ThemeData _buildLightTheme() {
    final base = ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: ColorScheme.fromSeed(
        seedColor: Colors.indigo.shade700,
        brightness: Brightness.light,
      ),
    );

    return base.copyWith(
      scaffoldBackgroundColor: Colors.grey.shade50,
      appBarTheme: AppBarTheme(
        elevation: 0,
        centerTitle: true,
        systemOverlayStyle: SystemUiOverlayStyle.dark,
        backgroundColor: Colors.white,
        foregroundColor: Colors.grey.shade800,
        titleTextStyle: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Colors.grey.shade800,
        ),
        iconTheme: IconThemeData(
          color: Colors.grey.shade800,
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        elevation: 8,
        backgroundColor: Colors.white,
        indicatorColor: Colors.indigo.shade50,
        labelTextStyle: MaterialStateProperty.all(
          const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
        iconTheme: MaterialStateProperty.all(
          IconThemeData(
            size: 24,
            color: Colors.grey.shade600,
          ),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 0,
          backgroundColor: Colors.indigo.shade700,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 14,
          ),
        ),
      ),
      cardTheme: CardTheme(
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        clipBehavior: Clip.antiAliasWithSaveLayer,
        shadowColor: Colors.black.withOpacity(0.1),
      ),
      textTheme: TextTheme(
        displayLarge: TextStyle(
          fontWeight: FontWeight.bold,
          color: Colors.grey.shade800,
        ),
        displayMedium: TextStyle(
          fontWeight: FontWeight.bold,
          color: Colors.grey.shade800,
        ),
        displaySmall: TextStyle(
          fontWeight: FontWeight.bold,
          color: Colors.grey.shade800,
        ),
        bodyLarge: TextStyle(
          color: Colors.grey.shade700,
        ),
        bodyMedium: TextStyle(
          color: Colors.grey.shade700,
        ),
      ),
      dividerTheme: DividerThemeData(
        color: Colors.grey.shade200,
        thickness: 1,
      ),
    );
  }

  ThemeData _buildDarkTheme() {
    final base = ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: ColorScheme.fromSeed(
        seedColor: Colors.indigo.shade200,
        brightness: Brightness.dark,
      ),
    );

    return base.copyWith(
      scaffoldBackgroundColor: const Color(0xFF121212),
      appBarTheme: AppBarTheme(
        elevation: 0,
        centerTitle: true,
        systemOverlayStyle: SystemUiOverlayStyle.light,
        backgroundColor: const Color(0xFF1E1E1E),
        titleTextStyle: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        elevation: 8,
        backgroundColor: const Color(0xFF1E1E1E),
        indicatorColor: Colors.indigo.shade900,
        labelTextStyle: WidgetStateProperty.all(
          const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
      cardTheme: CardTheme(
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        clipBehavior: Clip.antiAliasWithSaveLayer,
        color: const Color(0xFF2A2A2A),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 0,
          backgroundColor: Colors.indigo.shade700,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 14,
          ),
        ),
      ),
      dividerTheme: const DividerThemeData(
        color: Color(0xFF3A3A3A),
        thickness: 1,
      ),
    );
  }
}

class MainScreen extends StatefulWidget {
  final Widget child;

  const MainScreen({
    Key? key,
    required this.child,
  }) : super(key: key);

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _controller.forward();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      GoRouter.of(context)
          .routeInformationProvider
          .addListener(_handleRouteChange);
    });
  }

  void _handleRouteChange() {
    if (mounted) {
      setState(() {
        _controller.reset();
        _controller.forward();
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      try {
        GoRouter.of(context)
            .routeInformationProvider
            .removeListener(_handleRouteChange);
      } catch (e) {
        print("Error removing listener: $e");
      }
    });
    super.dispose();
  }

  int _calculateSelectedIndex(bool isAuthenticated) {
    final currentLocation =
        GoRouter.of(context).routeInformationProvider.value.uri.path;

    // First check for exact matches
    if (currentLocation == AppRoutes.home || currentLocation == '/') return 0;
    if (currentLocation == AppRoutes.search) return 1;
    if (currentLocation == AppRoutes.cart) return 2;
    if (currentLocation == AppRoutes.favorites) return 3;
    if (currentLocation == AppRoutes.profile && isAuthenticated) return 4;

    // Then fallback to startsWith for nested routes
    if (currentLocation.startsWith(AppRoutes.home)) return 0;
    if (currentLocation.startsWith(AppRoutes.search)) return 1;
    if (currentLocation.startsWith(AppRoutes.cart)) return 2;
    if (currentLocation.startsWith(AppRoutes.favorites)) return 3;
    if (currentLocation.startsWith(AppRoutes.profile) && isAuthenticated)
      return 4;

    return 0;
  }

  @override
  Widget build(BuildContext context) {
    final isAuthenticated = context.watch<AuthProvider>().isAuthenticated;
    final selectedIndex = _calculateSelectedIndex(isAuthenticated);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: FadeTransition(
        opacity: CurvedAnimation(
          parent: _controller,
          curve: Curves.easeInOut,
        ),
        child: widget.child,
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: selectedIndex,
        backgroundColor: Theme.of(context).navigationBarTheme.backgroundColor,
        elevation: 8,
        shadowColor: Colors.black26,
        indicatorColor: Theme.of(context).navigationBarTheme.indicatorColor,
        height: 68,
        labelBehavior: NavigationDestinationLabelBehavior.onlyShowSelected,
        animationDuration: const Duration(milliseconds: 400),
        onDestinationSelected: (index) {
          HapticFeedback.lightImpact();

          final destinations = [
            AppRoutes.home,
            AppRoutes.search,
            AppRoutes.cart,
            AppRoutes.favorites,
            if (isAuthenticated) AppRoutes.profile,
          ];

          if (index < destinations.length) {
            context.go(destinations[index]);
          }
        },
        destinations: [
          NavigationDestination(
            icon: Icon(
              Icons.home_outlined,
              color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
            ),
            selectedIcon: Icon(
              Icons.home,
              color: Colors.indigo.shade700,
            ),
            label: AppLocalizations.of(context)!.home,
          ),
          NavigationDestination(
            icon: Icon(
              Icons.search_outlined,
              color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
            ),
            selectedIcon: Icon(
              Icons.search,
              color: Colors.indigo.shade700,
            ),
            label: AppLocalizations.of(context)!.search,
          ),
          NavigationDestination(
            icon: Icon(
              Icons.shopping_cart_outlined,
              color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
            ),
            selectedIcon: Icon(
              Icons.shopping_cart,
              color: Colors.indigo.shade700,
            ),
            label: AppLocalizations.of(context)!.cart,
          ),
          NavigationDestination(
            icon: Icon(
              Icons.favorite_outline,
              color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
            ),
            selectedIcon: Icon(
              Icons.favorite,
              color: Colors.indigo.shade700,
            ),
            label: AppLocalizations.of(context)!.favorites,
          ),
          if (isAuthenticated)
            NavigationDestination(
              icon: Icon(
                Icons.person_outline,
                color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
              ),
              selectedIcon: Icon(
                Icons.person,
                color: Colors.indigo.shade700,
              ),
              label: AppLocalizations.of(context)!.profile,
            ),
        ],
      ),
    );
  }
}
