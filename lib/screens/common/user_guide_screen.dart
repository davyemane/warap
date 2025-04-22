import 'package:flutter/material.dart';
import '../../l10n/translations.dart';

class UserGuideScreen extends StatelessWidget {
  const UserGuideScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(AppTranslations.text(context, 'user_guide'))),
      body: Center(
        child: Text(AppTranslations.text(context, 'user_guide_coming')),
      ),
    );
  }
}