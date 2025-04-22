import 'package:flutter/material.dart';

class AppLocalizations {
  final Locale locale;
  
  AppLocalizations(this.locale);
  
  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }
  
  static final Map<String, Map<String, String>> _localizedValues = {
    'fr': {
      'app_title': 'Commerce Connect',
      'login': 'Connexion',
      'register': 'Inscription',
      'slogan': 'Connectez-vous aux commerces près de chez vous',
      'help_title': 'Aide et support',
      'language': 'Choisir la langue',
      'french': 'Français',
      'english': 'Anglais',
      // Ajoutez d'autres traductions ici
    },
    'en': {
      'app_title': 'Commerce Connect',
      'login': 'Login',
      'register': 'Register',
      'slogan': 'Connect with local businesses near you',
      'help_title': 'Help and Support',
      'language': 'Choose language',
      'french': 'French',
      'english': 'English',
      // Ajoutez d'autres traductions ici
    },
  };
  
  String get appTitle => _localizedValues[locale.languageCode]!['app_title']!;
  String get login => _localizedValues[locale.languageCode]!['login']!;
  String get register => _localizedValues[locale.languageCode]!['register']!;
  String get slogan => _localizedValues[locale.languageCode]!['slogan']!;
  String get helpTitle => _localizedValues[locale.languageCode]!['help_title']!;
  String get language => _localizedValues[locale.languageCode]!['language']!;
  String get french => _localizedValues[locale.languageCode]!['french']!;
  String get english => _localizedValues[locale.languageCode]!['english']!;

  // Ajoutez d'autres getters pour vos traductions
}

class AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) => ['fr', 'en'].contains(locale.languageCode);

  @override
  Future<AppLocalizations> load(Locale locale) async {
    return AppLocalizations(locale);
  }

  @override
  bool shouldReload(AppLocalizationsDelegate old) => false;
}