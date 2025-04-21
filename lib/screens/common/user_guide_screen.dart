import 'package:flutter/material.dart';

class UserGuideScreen extends StatelessWidget {
  const UserGuideScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Guide d\'utilisation')),
      body: const Center(
        child: Text('Guide d\'utilisation de l\'application à venir...'),
      ),
    );
  }
}
