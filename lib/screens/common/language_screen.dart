import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/locale_provider.dart';
import '../../l10n/translations.dart';

class LanguageScreen extends StatelessWidget {
  const LanguageScreen({Key? key}) : super(key: key);

  void _changeLanguage(BuildContext context, String languageCode) {
    // Changer la langue en utilisant le provider
    final provider = Provider.of<LocaleProvider>(context, listen: false);
    provider.setLanguage(languageCode);
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(AppTranslations.textWithParams(
          context, 
          'language_changed', 
          [languageCode == 'fr' ? 'Français' : 'English']
        )),
      ),
    );
    
    // Optionnel: retourner à l'écran précédent
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    // Récupérer la langue actuelle pour afficher une coche à côté
    final currentLanguage = Provider.of<LocaleProvider>(context).languageCode;
    
    return Scaffold(
      appBar: AppBar(title: Text(AppTranslations.text(context, 'choose_language'))),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          ListTile(
            leading: const Icon(Icons.language),
            title: Text(AppTranslations.text(context, 'french')),
            trailing: currentLanguage == 'fr' ? const Icon(Icons.check, color: Colors.green) : null,
            onTap: () => _changeLanguage(context, 'fr'),
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.language),
            title: Text(AppTranslations.text(context, 'english')),
            trailing: currentLanguage == 'en' ? const Icon(Icons.check, color: Colors.green) : null,
            onTap: () => _changeLanguage(context, 'en'),
          ),
        ],
      ),
    );
  }
}