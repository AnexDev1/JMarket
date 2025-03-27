import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:go_router/go_router.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:jmarket/providers/auth_provider.dart';
import 'package:jmarket/providers/cart_provider.dart';
import 'package:jmarket/providers/favorites_provider.dart';
import 'package:jmarket/providers/search_provider.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// Local imports
import 'app/app.dart';
import 'core/config/hive_config.dart';
import 'providers/theme_provider.dart';

// BackButtonInterceptor widget
class BackButtonInterceptor extends StatelessWidget {
  final Widget child;
  final GoRouter router;

  const BackButtonInterceptor({
    Key? key,
    required this.child,
    required this.router,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) async {
        if (didPop) return;

        final canPop = router.canPop();

        if (canPop) {
          // Navigate back within the app
          router.pop();
        } else {
          // At the root route - show exit confirmation
          final shouldExit = await _showExitConfirmation(context);
          if (shouldExit && context.mounted) {
            SystemNavigator.pop();
          }
        }
      },
      child: child,
    );
  }

  Future<bool> _showExitConfirmation(BuildContext context) async {
    return await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Exit App'),
            content: const Text('Are you sure you want to exit?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('CANCEL'),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: const Text('EXIT'),
              ),
            ],
          ),
        ) ??
        false;
  }
}

// Modified App class that uses the BackButtonInterceptor
class AppWithBackButtonHandling extends StatelessWidget {
  final GoRouter router;

  const AppWithBackButtonHandling({
    Key? key,
    required this.router,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      routerConfig: router,
      debugShowCheckedModeBanner: false,
      // theme: Provider.of<ThemeProvider>(context).themeData,
      builder: (context, child) {
        return BackButtonInterceptor(
          child: child ?? const SizedBox.shrink(),
          router: router,
        );
      },
    );
  }
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await dotenv.load(fileName: ".env");

  // Initialize Hive
  await Hive.initFlutter();
  await HiveConfig.registerAdapters();

  // Initialize Supabase
  await Supabase.initialize(
    url: dotenv.env['SUPABASE_URL'] ?? '',
    anonKey: dotenv.env['SUPABASE_KEY'] ?? '',
  );

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => CartProvider()),
        ChangeNotifierProvider(create: (_) => FavoritesProvider()),
        ChangeNotifierProvider(create: (_) => SearchProvider()),
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        // Add more providers here
      ],
      child: const App(),
    ),
  );
}
