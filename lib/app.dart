// Fichier app.dart - Configuration de l'application
import 'package:flutter/material.dart';
import 'screens/auth/login_screen.dart';
import 'screens/client/map_screen.dart';  // Ajout de l'import manquant
import 'screens/vendor/business_management_screen.dart';  // Ajout de l'import manquant
import 'services/auth_service.dart';

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Commerce Connect',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: FutureBuilder<bool>(
        future: AuthService().isAuthenticated(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(body: Center(child: CircularProgressIndicator()));
          }
          
          if (snapshot.hasData && snapshot.data == true) {
            // Rediriger vers l'écran approprié en fonction du type d'utilisateur
            return FutureBuilder<String>(
              future: AuthService().getUserType(),
              builder: (context, userTypeSnapshot) {
                if (userTypeSnapshot.connectionState == ConnectionState.waiting) {
                  return const Scaffold(body: Center(child: CircularProgressIndicator()));
                }
                
                if (userTypeSnapshot.hasData) {
                  if (userTypeSnapshot.data == 'client') {
                    return const ClientMapScreen();
                  } else {
                    return const BusinessManagementScreen();
                  }
                }
                
                // Par défaut, rediriger vers la page de connexion
                return const LoginScreen();
              },
            );
          }
          
          // Non authentifié, afficher la page de connexion
          return const LoginScreen();
        },
      ),
    );
  }
}