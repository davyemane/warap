import 'package:flutter/material.dart';
import '../../l10n/translations.dart';

class VendorGuideScreen extends StatelessWidget {
  const VendorGuideScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(AppTranslations.text(context, 'vendor_guide'))),
      body: Center(
        child: Text(AppTranslations.text(context, 'vendor_guide_coming')),
      ),
    );
  }
}