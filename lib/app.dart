// Fichier app.dart - Configuration de l'application
import 'package:flutter/material.dart';
import 'screens/auth/login_screen.dart';
import 'screens/client/client_main_screen.dart';
import 'screens/vendor/vendor_main_screen.dart';
import 'services/auth_service.dart';

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Warap',
      debugShowCheckedModeBanner: false, // Supprime le bandeau "Debug"
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        appBarTheme: const AppBarTheme(
          elevation: 0,
          centerTitle: true,
          backgroundColor: Colors.blue,
          foregroundColor: Colors.white,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
        // Couleurs personnalisées
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue,
          primary: Colors.blue,
          secondary: Colors.green,
          background: Colors.white,
        ),
        // Style de carte
        cardTheme: CardTheme(
          elevation: 3,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        // Style de fond d'écran
        scaffoldBackgroundColor: Colors.grey[50],
      ),
      home: FutureBuilder<bool>(
        future: AuthService().isAuthenticated(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(
              body: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 16),
                    Text(
                      'Chargement...',
                      style: TextStyle(fontSize: 16),
                    ),
                  ],
                ),
              ),
            );
          }
          
          if (snapshot.hasData && snapshot.data == true) {
            // Rediriger vers l'écran approprié en fonction du type d'utilisateur
            return FutureBuilder<String>(
              future: AuthService().getUserType(),
              builder: (context, userTypeSnapshot) {
                if (userTypeSnapshot.connectionState == ConnectionState.waiting) {
                  return const Scaffold(
                    body: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CircularProgressIndicator(),
                          SizedBox(height: 16),
                          Text(
                            'Préparation de votre espace...',
                            style: TextStyle(fontSize: 16),
                          ),
                        ],
                      ),
                    ),
                  );
                }
                
                if (userTypeSnapshot.hasData) {
                  if (userTypeSnapshot.data == 'client') {
                    return const ClientMainScreen();
                  } else {
                    return const VendorMainScreen();
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
      routes: {
        '/login': (context) => const LoginScreen(),
        '/client/main': (context) => const ClientMainScreen(),
        '/vendor/main': (context) => const VendorMainScreen(),
      },
      // Gestion des erreurs
      builder: (context, child) {
        return MediaQuery(
          // Empêche le redimensionnement des interfaces quand le clavier apparaît
          data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0),
          child: child!,
        );
      },
    );
  }
}