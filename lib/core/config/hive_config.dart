import 'package:hive_flutter/hive_flutter.dart';

/// Configuration for Hive database
class HiveConfig {
  // Box names
  static const String userBox = 'userBox';
  static const String productsBox = 'productsBox';
  static const String cartBox = 'cartBox';
  static const String ordersBox = 'ordersBox';
  static const String settingsBox = 'settingsBox';

  // Hive type IDs (needed when you create adapters)
  static const int userTypeId = 0;
  static const int productTypeId = 1;
  static const int cartItemTypeId = 2;
  static const int orderTypeId = 3;

  /// Register all Hive adapters
  static Future<void> registerAdapters() async {
    // When you create model classes with Hive annotations:
    // Hive.registerAdapter(UserModelAdapter());
    // Hive.registerAdapter(ProductModelAdapter());
    // Hive.registerAdapter(CartItemAdapter());
    // Hive.registerAdapter(OrderModelAdapter());

    // Open boxes
    await openBoxes();
  }

  /// Open all Hive boxes
  static Future<void> openBoxes() async {
    await Hive.openBox(userBox);
    await Hive.openBox(productsBox);
    await Hive.openBox(cartBox);
    await Hive.openBox(ordersBox);
    await Hive.openBox(settingsBox);
  }

  /// Close all boxes (useful for testing or reset)
  static Future<void> closeBoxes() async {
    await Hive.box(userBox).close();
    await Hive.box(productsBox).close();
    await Hive.box(cartBox).close();
    await Hive.box(ordersBox).close();
    await Hive.box(settingsBox).close();
  }
}
