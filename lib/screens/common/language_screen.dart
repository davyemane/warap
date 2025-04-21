import 'package:flutter/material.dart';

class LanguageScreen extends StatelessWidget {
  const LanguageScreen({Key? key}) : super(key: key);

  void _changeLanguage(BuildContext context, String languageCode) {
    // Tu pourras ici ajouter ta logique de changement de langue (locale)
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Langue changée en ${languageCode == 'fr' ? 'Français' : 'English'}'),
      ),
    );
    // Exemple de logique à implémenter avec Provider, GetX, etc.
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Choisir la langue')),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          ListTile(
            leading: const Icon(Icons.language),
            title: const Text('Français'),
            onTap: () => _changeLanguage(context, 'fr'),
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.language),
            title: const Text('English'),
            onTap: () => _changeLanguage(context, 'en'),
          ),
        ],
      ),
    );
  }
}
