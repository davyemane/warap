// services/client_service.dart
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/user_model.dart';
import 'auth_service.dart';
import 'error_handler.dart';

class ClientService {
  final SupabaseClient _supabase = Supabase.instance.client;
  final AuthService _authService = AuthService();
  
  // Récupérer tous les clients liés aux commerces du vendeur
  Future<List<UserModel>> getBusinessClients() async {
    try {
      // Obtenir l'ID du vendeur actuel
      final currentUser = await _authService.getCurrentUser();
      if (currentUser == null) {
        throw Exception('Utilisateur non connecté');
      }
      
      // Pour le développement, créer quelques utilisateurs fictifs 
      // (plutôt que de risquer une erreur avec la vraie base de données)
      await Future.delayed(const Duration(seconds: 1));
      
      List<UserModel> mockClients = [];
      
      for (int i = 1; i <= 10; i++) {
        mockClients.add(UserModel(
          id: 'client_$i',
          email: 'client$i@example.com',
          name: 'Client $i',
          userType: 'client',
          createdAt: DateTime.now().subtract(Duration(days: i * 10)),
          updatedAt: DateTime.now().subtract(Duration(days: i * 2)),
          hasNotifications: i % 3 == 0,
        ));
      }
      
      return mockClients;
    } catch (e) {
      print('Erreur lors de la récupération des clients: $e');
      // Retourner une liste vide au lieu de planter l'application
      return [];
    }
  }
  
  // Récupérer les détails d'un client spécifique
  Future<UserModel> getClientById(String clientId) async {
    try {
      // Pour le développement, retourner un client fictif
      return UserModel(
        id: clientId,
        email: 'client@example.com',
        name: 'Client ${clientId.substring(clientId.length - 2)}',
        userType: 'client',
        createdAt: DateTime.now().subtract(const Duration(days: 30)),
        updatedAt: DateTime.now().subtract(const Duration(days: 5)),
        hasNotifications: false,
      );
    } catch (e) {
      print('Erreur lors de la récupération du client: $e');
      throw Exception('Erreur lors de la récupération du client: $e');
    }
  }
  
  // Récupérer les statistiques d'un client
  Future<Map<String, dynamic>> getClientStats(String clientId) async {
    try {
      // Pour le développement, retourner des statistiques fictives
      return {
        'ordersCount': 5,
        'totalSpent': 150.50,
        'firstOrderDate': DateTime.now().subtract(const Duration(days: 60)),
        'lastOrderDate': DateTime.now().subtract(const Duration(days: 3)),
      };
    } catch (e) {
      print('Erreur lors de la récupération des statistiques: $e');
      throw Exception('Erreur lors de la récupération des statistiques: $e');
    }
  }
}