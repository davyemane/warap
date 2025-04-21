import 'package:flutter/material.dart';

class FAQScreen extends StatelessWidget {
  const FAQScreen({Key? key}) : super(key: key);

  final List<Map<String, String>> faqData = const [
    {
      'question': 'Comment créer un compte ?',
      'answer':
          'Pour créer un compte, cliquez sur le bouton "S\'inscrire" sur la page d\'accueil et remplissez le formulaire.'
    },
    {
      'question': 'Comment modifier mes informations personnelles ?',
      'answer':
          'Rendez-vous dans la section "Profil", puis appuyez sur "Modifier mes informations".'
    },
    {
      'question': 'Comment ajouter un commerce ?',
      'answer':
          'Allez dans la section "Mes commerces" et cliquez sur "Ajouter un commerce". Suivez ensuite les instructions.'
    },
    {
      'question': 'Puis-je contacter un commerçant directement ?',
      'answer':
          'Oui, chaque fiche commerce contient un bouton pour contacter directement le commerçant par téléphone ou email.'
    },
    {
      'question': 'L’application est-elle gratuite ?',
      'answer':
          'Oui, l’application est entièrement gratuite pour les utilisateurs. Certaines fonctionnalités premium seront disponibles bientôt.'
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Questions fréquentes')),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: faqData.length,
        itemBuilder: (context, index) {
          final item = faqData[index];
          return Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            elevation: 2,
            margin: const EdgeInsets.only(bottom: 12),
            child: ExpansionTile(
              title: Text(
                item['question']!,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    item['answer']!,
                    style: const TextStyle(fontSize: 14),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
