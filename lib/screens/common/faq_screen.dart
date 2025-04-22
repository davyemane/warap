import 'package:flutter/material.dart';
import '../../l10n/translations.dart';

class FAQScreen extends StatelessWidget {
  const FAQScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final List<Map<String, String>> faqData = [
      {
        'question': AppTranslations.text(context, 'create_account_question'),
        'answer': AppTranslations.text(context, 'create_account_answer')
      },
      {
        'question': AppTranslations.text(context, 'edit_info_question'),
        'answer': AppTranslations.text(context, 'edit_info_answer')
      },
      {
        'question': AppTranslations.text(context, 'add_business_question'),
        'answer': AppTranslations.text(context, 'add_business_answer')
      },
      {
        'question': AppTranslations.text(context, 'contact_vendor_question'),
        'answer': AppTranslations.text(context, 'contact_vendor_answer')
      },
      {
        'question': AppTranslations.text(context, 'app_free_question'),
        'answer': AppTranslations.text(context, 'app_free_answer')
      },
    ];

    return Scaffold(
      appBar: AppBar(title: Text(AppTranslations.text(context, 'faq'))),
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