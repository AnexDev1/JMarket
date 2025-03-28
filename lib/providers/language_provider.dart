// lib/providers/language_provider.dart
import 'package:flutter/material.dart';

class LanguageProvider extends ChangeNotifier {
  Locale _locale = Locale('en');
  Locale get locale => _locale;
  final Map<String, Locale> availableLocales = {
    'English': const Locale('en'),

    'አማርኛ': const Locale('am'),
    // 'Afan Oromoo': const Locale('om'),
  };

  // Get the display names
  List<String> get availableLanguages => availableLocales.keys.toList();

  // Current language name
  String get currentLanguage => availableLocales.entries
      .firstWhere((entry) => entry.value == _locale,
          orElse: () => const MapEntry('English', Locale('en')))
      .key;

  void setLanguage(String language) {
    if (availableLocales.containsKey(language)) {
      _locale = availableLocales[language]!;
      notifyListeners();
    }
  }
}
