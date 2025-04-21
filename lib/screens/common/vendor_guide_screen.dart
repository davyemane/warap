import 'package:flutter/material.dart';

class VendorGuideScreen extends StatelessWidget {
  const VendorGuideScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Guide pour les commerçants')),
      body: const Center(
        child: Text('Guide pour les vendeurs à venir...'),
      ),
    );
  }
}
