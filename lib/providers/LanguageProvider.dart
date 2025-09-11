import 'package:flutter/material.dart';

class LanguageProvider extends ChangeNotifier {
  static final LanguageProvider _instance = LanguageProvider._internal();
  factory LanguageProvider() => _instance;
  LanguageProvider._internal();

  Locale? _locale;
  
  Locale? get locale => _locale;

  void setLocale(Locale locale) {
    _locale = locale;
    notifyListeners();
  }

  void clearLocale() {
    _locale = null;
    notifyListeners();
  }

  // Supported locales
  static const List<Locale> supportedLocales = [
    Locale('en', ''), // English (default)
    Locale('es', ''), // Spanish
    Locale('fr', ''), // French
  ];

  static bool isSupported(Locale locale) {
    return supportedLocales.any((supportedLocale) =>
        supportedLocale.languageCode == locale.languageCode);
  }
}
