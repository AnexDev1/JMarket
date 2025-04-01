import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../core/config/hive_config.dart';

class ThemeProvider extends ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.light;
  bool _isDarkMode = false;

  bool get isDarkMode => _isDarkMode;
  ThemeMode get themeMode => _themeMode;

  ThemeProvider() {
    _loadTheme();
  }

  void setThemeMode(ThemeMode mode) {
    if (_themeMode != mode) {
      _themeMode = mode;
      _isDarkMode = mode == ThemeMode.dark;
      _saveTheme();
      notifyListeners();
    }
  }

  void toggleTheme() {
    final newMode =
        _themeMode == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
    setThemeMode(newMode);
  }

  Future<void> _saveTheme() async {
    final settingsBox = Hive.box(HiveConfig.settingsBox);
    await settingsBox.put('themeMode', _themeMode.index);
  }

  Future<void> _loadTheme() async {
    final settingsBox = Hive.box(HiveConfig.settingsBox);
    final themeModeIndex = settingsBox.get('themeMode');
    if (themeModeIndex != null) {
      _themeMode = ThemeMode.values[themeModeIndex];
      _isDarkMode = _themeMode == ThemeMode.dark;
      notifyListeners();
    }
  }
}
