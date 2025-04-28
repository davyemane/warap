// Fichier services/user_access_service.dart
import 'package:flutter/material.dart';
import '../models/user_model.dart';
import 'auth_service.dart';
import '../screens/client/client_main_screen.dart';
import '../screens/vendor/vendor_main_screen.dart';
import '../screens/auth/login_screen.dart';

class UserAccessService {
  final AuthService _authService = AuthService();
  
  // Dictionnaire des routes par type d'utilisateur
  static const Map<String, List<String>> _allowedRoutes = {
    'client': [
      '/client',
      '/client/map',
      '/client/favorites',
      '/client/search',
      '/client/profile',
      '/client/cart',
      '/client/new-request',
      '/client/service-history',
      '/client/business-detail',
      '/client/product-detail',
      '/client/order-detail',
      '/client/request-detail',
      '/client/checkout',
    ],
    'vendor': [
      '/vendor',
      '/vendor/dashboard',
      '/vendor/businesses',
      '/vendor/add-business',
      '/vendor/orders',
      '/vendor/requests',
      '/vendor/clients',
      '/vendor/profile',
      '/vendor/business-detail',
      '/vendor/order-detail',
      '/vendor/products',
      '/vendor/add-product',
      '/vendor/edit-product',
      '/vendor/request-detail',
    ],
  };
  
  // Routes communes accessibles par tous les types d'utilisateurs
  static const List<String> _commonRoutes = [
    '/login',
    '/register',
    '/language',
    '/settings',
    '/help',
  ];
  
  // Vérifier si un utilisateur peut accéder à une route
  bool canAccessRoute(UserModel? user, String routeName) {
    if (user == null) {
      // Utilisateur non connecté, autoriser uniquement les routes publiques
      return _commonRoutes.contains(routeName);
    }
    
    // Vérifier si la route est commune
    if (_commonRoutes.contains(routeName)) {
      return true;
    }
    
    // Vérifier si la route est autorisée pour ce type d'utilisateur
    final allowedRoutes = _allowedRoutes[user.userType] ?? [];
    return allowedRoutes.contains(routeName) || 
           allowedRoutes.any((route) => routeName.startsWith(route));
  }
  
  // Middleware de route pour MaterialApp
  Route<dynamic>? onGenerateRoute(RouteSettings settings, Route<dynamic>? Function(RouteSettings) generateRoute) {
    // Extraire le nom de la route
    final routeName = settings.name ?? '';
    
    // Vérifier si c'est une route publique
    if (_commonRoutes.contains(routeName)) {
      return generateRoute(settings);
    }
    
    // Pour les routes protégées, vérifier le type d'utilisateur
    return MaterialPageRoute(
      builder: (context) => FutureBuilder<UserModel?>(
        future: _authService.getCurrentUser(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }
          
          final user = snapshot.data;
          
          // Vérifier l'accès
          if (user != null && canAccessRoute(user, routeName)) {
            // Continuer avec la route normale
            final route = generateRoute(settings);
            if (route != null) {
              return (route as MaterialPageRoute).builder(context);
            }
          }
          
          // Rediriger vers la page appropriée
          if (user?.userType == 'client') {
            return const ClientMainScreen();
          } else if (user?.userType == 'vendor') {
            return const VendorMainScreen();
          } else {
            // Rediriger vers la connexion si non connecté
            WidgetsBinding.instance.addPostFrameCallback((_) {
              Navigator.pushReplacementNamed(context, '/login');
            });
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }
        },
      ),
    );
  }
}