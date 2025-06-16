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
      print('🔍 Chargement des clients...');

      // Obtenir l'utilisateur connecté
      final currentUser = await _authService.getCurrentUser();
      if (currentUser == null) {
        print('⚠️ Utilisateur non connecté');
        return [];
      }

      // 1. Obtenir les ID des commerces du vendeur
      final businessResponse = await _supabase
          .from('businesses')
          .select('id')
          .eq('user_id', currentUser.id);

      if ((businessResponse as List).isEmpty) {
        print('⚠️ Aucun commerce trouvé');
        return [];
      }

      final businessIds =
          (businessResponse as List).map((b) => b['id'] as String).toList();

      print('📋 Commerces trouvés: $businessIds');

      // Set pour stocker tous les IDs de clients uniques
      final Set<String> clientIdSet = {};

      // 2. Obtenir les clients qui ont passé des commandes
      final orderResponse = await _supabase
          .from('orders')
          .select('client_id')
          .inFilter('business_id', businessIds);

      for (var order in orderResponse) {
        if (order['client_id'] != null) {
          clientIdSet.add(order['client_id'] as String);
        }
      }

      // 3. Obtenir les clients qui ont fait des demandes de service
      final requestResponse = await _supabase
          .from('service_requests')
          .select('client_id')
          .inFilter('business_id', businessIds);

      for (var request in requestResponse) {
        if (request['client_id'] != null) {
          clientIdSet.add(request['client_id'] as String);
        }
      }

      // 4. Obtenir les clients qui ont ajouté le commerce aux favoris
      final favoriteResponse = await _supabase
          .from('favorites')
          .select('user_id')
          .inFilter('business_id', businessIds);

      for (var favorite in favoriteResponse) {
        if (favorite['user_id'] != null) {
          clientIdSet.add(favorite['user_id'] as String);
        }
      }

      // 5. Obtenir les clients qui ont consulté le commerce (optionnel)
      final viewsResponse = await _supabase
          .from('business_views')
          .select('user_id')
          .inFilter('business_id', businessIds);

      for (var view in viewsResponse) {
        if (view['user_id'] != null) {
          clientIdSet.add(view['user_id'] as String);
        }
      }

      final List<String> clientIds = clientIdSet.toList();
      print('👥 IDs de clients trouvés (total: ${clientIds.length}): $clientIds');

      if (clientIds.isEmpty) {
        print('⚠️ Aucun ID client trouvé');
        return [];
      }

      // 6. Récupérer les détails des utilisateurs clients
      final userResponse =
          await _supabase.from('users').select().inFilter('id', clientIds);

      List<UserModel> clients = [];
      try {
        clients = (userResponse as List)
            .map((user) => UserModel.fromJson(user))
            .toList();
        print('✅ ${clients.length} clients convertis avec succès');
      } catch (e) {
        print('❌ Erreur lors de la conversion des clients: $e');
      }

      // 7. S'assurer que tous ces utilisateurs sont marqués comme clients
      await _ensureUserTypeIsClient(clientIds);

      return clients;
    } catch (e) {
      print('❌ Erreur lors de la récupération des clients: $e');
      return [];
    }
  }

  // S'assurer que les utilisateurs sont bien marqués comme clients
  Future<void> _ensureUserTypeIsClient(List<String> userIds) async {
    try {
      if (userIds.isEmpty) return;

      // Mettre à jour tous les utilisateurs pour s'assurer qu'ils sont marqués comme clients
      await _supabase
          .from('users')
          .update({'user_type': 'client'})
          .inFilter('id', userIds)
          .neq('user_type', 'vendeur'); // Ne pas changer le type des vendeurs
      
      print('✅ Statut client mis à jour pour ${userIds.length} utilisateurs');
    } catch (e) {
      print('❌ Erreur lors de la mise à jour du statut client: $e');
    }
  }

  // Marquer automatiquement un utilisateur comme client
  Future<void> registerUserAsClient(String userId) async {
    try {
      await _supabase
          .from('users')
          .update({'user_type': 'client'})
          .eq('id', userId)
          .neq('user_type', 'vendeur'); // Ne pas changer le type des vendeurs
      
      print('✅ Utilisateur $userId enregistré comme client');
    } catch (e) {
      print('❌ Erreur lors de l\'enregistrement de l\'utilisateur comme client: $e');
    }
  }

  // Créer un client fictif pour les tests
  Future<String> createTestClient(String businessId) async {
    try {
      // Générer un ID unique
      final clientId = 'test-client-${DateTime.now().millisecondsSinceEpoch}';
      
      // 1. Créer un utilisateur client
      await _supabase.from('users').insert({
        'id': clientId,
        'email': 'client.test@example.com',
        'name': 'Client Test',
        'user_type': 'client',
        'created_at': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
        'has_notifications': false,
      });
      
      // 2. Créer une commande pour ce client
      final orderId = 'test-order-${DateTime.now().millisecondsSinceEpoch}';
      await _supabase.from('orders').insert({
        'id': orderId,
        'client_id': clientId,
        'business_id': businessId,
        'order_number': 'TEST${DateTime.now().millisecondsSinceEpoch % 10000}',
        'items': [
          {
            'product_id': 'test-product',
            'name': 'Produit Test',
            'price': 25.99,
            'quantity': 2
          }
        ],
        'subtotal': 51.98,
        'tax': 10.40,
        'total': 62.38,
        'order_date': DateTime.now().toIso8601String(),
        'status': 'pending',
        'delivery_address': '123 Rue de Test, Yaoundé',
        'payment_method': 'cash',
      });
      
      print('✅ Client test créé avec succès (ID: $clientId)');
      return clientId;
    } catch (e) {
      print('❌ Erreur lors de la création du client test: $e');
      throw Exception('Erreur lors de la création du client test: $e');
    }
  }

  // Obtenir les statistiques d'un client
  Future<Map<String, dynamic>> getClientStats(String clientId) async {
    try {
      // 1. Récupérer le nombre de commandes
      final ordersResponse = await _supabase
          .from('orders')
          .select('id, total, order_date')
          .eq('client_id', clientId)
          .order('order_date', ascending: false);
      
      final orders = ordersResponse as List;
      
      // 2. Calculer les statistiques
      final ordersCount = orders.length;
      double totalSpent = 0;
      DateTime? firstOrderDate;
      DateTime? lastOrderDate;
      
      if (orders.isNotEmpty) {
        // Calculer le total dépensé
        totalSpent = orders.fold(0.0, (sum, order) => sum + (order['total'] as double));
        
        // Trouver la première et la dernière commande
        lastOrderDate = DateTime.parse(orders.first['order_date']);
        firstOrderDate = DateTime.parse(orders.last['order_date']);
      }
      
      return {
        'ordersCount': ordersCount,
        'totalSpent': totalSpent,
        'firstOrderDate': firstOrderDate,
        'lastOrderDate': lastOrderDate,
      };
    } catch (e) {
      print('❌ Erreur lors de la récupération des statistiques du client: $e');
      return {
        'ordersCount': 0,
        'totalSpent': 0.0,
        'firstOrderDate': null,
        'lastOrderDate': null,
      };
    }
  }
}