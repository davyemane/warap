// lib/providers/locale_provider.dart
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocaleProvider extends ChangeNotifier {
  String _languageCode = 'fr';
  
  Locale _locale;
  
  LocaleProvider(this._locale);
  
  Locale get locale => _locale;

  void changeLocale(Locale newLocale) {
    _locale = newLocale;
    notifyListeners();
  }

  void setLocale(Locale locale) {
    _locale = locale;
    notifyListeners();
  }
  
  String get languageCode => _languageCode;
  
  Future<void> _loadSavedLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    final savedCode = prefs.getString('language_code') ?? 'fr';
    setLanguage(savedCode, notify: false);
  }
  
  Future<void> setLanguage(String code, {bool notify = true}) async {
    _languageCode = code;
    
    // Sauvegarder le choix de langue
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('language_code', code);
    
    if (notify) notifyListeners();
  }

  
}