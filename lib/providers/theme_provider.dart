import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../core/config/hive_config.dart';

class ThemeProvider extends ChangeNotifier {
  // Changed default theme mode to light
  ThemeMode _themeMode = ThemeMode.light;
  bool _isDarkMode = false;

  bool get isDarkMode => _isDarkMode;
  // Constructor - forces light theme
  ThemeProvider() {
    // Force light theme instead of loading saved theme
    setLightMode();
  }

  // Getter for current theme mode
  ThemeMode get themeMode => _themeMode;

  // Setter for theme mode
  void setThemeMode(ThemeMode mode) {
    if (_themeMode != mode) {
      _themeMode = mode;
      _saveTheme();
      notifyListeners();
    }
  }

  // Convenience methods
  void setLightMode() => setThemeMode(ThemeMode.light);
  void setDarkMode() => setThemeMode(ThemeMode.dark);
  void setSystemMode() => setThemeMode(ThemeMode.system);

  // Toggle between light and dark
  void toggleTheme() {
    final newMode =
        _themeMode == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
    setThemeMode(newMode);
  }

  // Save theme preference to Hive
  Future<void> _saveTheme() async {
    final settingsBox = Hive.box(HiveConfig.settingsBox);
    await settingsBox.put('themeMode', _themeMode.index);
  }

  // Load theme preference from Hive - not used currently
  Future<void> _loadTheme() async {
    final settingsBox = Hive.box(HiveConfig.settingsBox);
    final themeModeIndex = settingsBox.get('themeMode');

    if (themeModeIndex != null) {
      _themeMode = ThemeMode.values[themeModeIndex];
      notifyListeners();
    }
  }
}
