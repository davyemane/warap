// services/order_service.dart
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/order_model.dart';
import '../models/cart_item_model.dart';
import 'auth_service.dart';
import 'error_handler.dart';

class OrderService {
  final SupabaseClient _supabase = Supabase.instance.client;
  final AuthService _authService = AuthService();

  // Obtenir une commande par ID
  Future<OrderModel> getOrderById(String orderId) async {
    try {
      final response = await _supabase
          .from('orders')
          .select('*, clients(*)')
          .eq('id', orderId)
          .single();

      return OrderModel.fromJson(response);
    } catch (e) {
      print('Erreur lors de la récupération de la commande: $e');
      throw Exception('Erreur lors de la récupération de la commande: $e');
    }
  }

  // Obtenir les commandes du vendeur
  Future<List<OrderModel>> getBusinessOrders() async {
    try {
      final currentUser = await _authService.getCurrentUser();
      if (currentUser == null) {
        throw Exception('Utilisateur non connecté');
      }

      // Obtenir d'abord les commerces du vendeur
      final businesses = await _supabase
          .from('businesses')
          .select('id')
          .eq('user_id', currentUser.id);

      final businessIds = (businesses as List).map((b) => b['id']).toList();

      if (businessIds.isEmpty) {
        return [];
      }

      // Obtenir les commandes pour ces commerces
      final response = await _supabase
          .from('orders')
          .select('*, clients(*)')
          .inFilter('business_id', businessIds)
          .order('order_date', ascending: false);

      return (response as List)
          .map((item) => OrderModel.fromJson(item))
          .toList();
    } catch (e) {
      print('Erreur lors de la récupération des commandes: $e');
      throw Exception('Erreur lors de la récupération des commandes: $e');
    }
  }

  // Obtenir les commandes récentes
  Future<List<OrderModel>> getRecentOrders({int limit = 5}) async {
    try {
      final currentUser = await _authService.getCurrentUser();
      if (currentUser == null) {
        throw Exception('Utilisateur non connecté');
      }

      // Obtenir d'abord les commerces du vendeur
      final businesses = await _supabase
          .from('businesses')
          .select('id')
          .eq('user_id', currentUser.id);

      final businessIds = (businesses as List).map((b) => b['id']).toList();

      if (businessIds.isEmpty) {
        return [];
      }

      // Obtenir les commandes récentes pour ces commerces
      final response = await _supabase
          .from('orders')
          .select('*, clients(*)')
          .inFilter('business_id', businessIds)
          .order('order_date', ascending: false)
          .limit(limit);

      return (response as List)
          .map((item) => OrderModel.fromJson(item))
          .toList();
    } catch (e) {
      print('Erreur lors de la récupération des commandes récentes: $e');
      throw Exception('Erreur lors de la récupération des commandes récentes: $e');
    }
  }

  // Obtenir les commandes en attente
  Future<List<OrderModel>> getPendingOrders() async {
    try {
      final currentUser = await _authService.getCurrentUser();
      if (currentUser == null) {
        throw Exception('Utilisateur non connecté');
      }

      // Obtenir d'abord les commerces du vendeur
      final businesses = await _supabase
          .from('businesses')
          .select('id')
          .eq('user_id', currentUser.id);

      final businessIds = (businesses as List).map((b) => b['id']).toList();

      if (businessIds.isEmpty) {
        return [];
      }

      // Obtenir les commandes en attente pour ces commerces
      final response = await _supabase
          .from('orders')
          .select('*, clients(*)')
          .inFilter('business_id', businessIds)
          .eq('status', 'pending')
          .order('order_date', ascending: false);

      return (response as List)
          .map((item) => OrderModel.fromJson(item))
          .toList();
    } catch (e) {
      print('Erreur lors de la récupération des commandes en attente: $e');
      throw Exception('Erreur lors de la récupération des commandes en attente: $e');
    }
  }

  // Mettre à jour le statut d'une commande
  Future<void> updateOrderStatus(String orderId, String status) async {
    try {
      await _supabase
          .from('orders')
          .update({'status': status})
          .eq('id', orderId);
    } catch (e) {
      print('Erreur lors de la mise à jour du statut: $e');
      throw Exception('Erreur lors de la mise à jour du statut: $e');
    }
  }

  // Obtenir les statistiques
  Future<Map<String, dynamic>> getStatistics({
    required String period,
    required String metric,
  }) async {
    try {
      final currentUser = await _authService.getCurrentUser();
      if (currentUser == null) {
        throw Exception('Utilisateur non connecté');
      }

      // Obtenir d'abord les commerces du vendeur
      final businesses = await _supabase
          .from('businesses')
          .select('id')
          .eq('user_id', currentUser.id);

      final businessIds = (businesses as List).map((b) => b['id']).toList();

      if (businessIds.isEmpty) {
        return {
          'labels': [],
          'data': [],
          'total': 0,
          'average': 0,
          'growth': '0',
        };
      }

      // Définir la période
      final DateTime now = DateTime.now();
      DateTime startDate;
      List<String> labels;
      int periodDays;

      switch (period) {
        case 'week':
          startDate = now.subtract(const Duration(days: 7));
          labels = List.generate(7, (i) {
            final date = now.subtract(Duration(days: 6 - i));
            return '${date.day}/${date.month}';
          });
          periodDays = 7;
          break;
        case 'month':
          startDate = DateTime(now.year, now.month, 1);
          final daysInMonth = DateTime(now.year, now.month + 1, 0).day;
          labels = List.generate(daysInMonth, (i) => '${i + 1}');
          periodDays = daysInMonth;
          break;
        case 'year':
          startDate = DateTime(now.year, 1, 1);
          labels = [
            'Jan', 'Fév', 'Mar', 'Avr', 'Mai', 'Juin',
            'Juil', 'Août', 'Sep', 'Oct', 'Nov', 'Déc'
          ];
          periodDays = 12;
          break;
        default:
          startDate = now.subtract(const Duration(days: 7));
          labels = List.generate(7, (i) {
            final date = now.subtract(Duration(days: 6 - i));
            return '${date.day}/${date.month}';
          });
          periodDays = 7;
      }

      // Obtenir les commandes pour la période actuelle
      final currentResponse = await _supabase
          .from('orders')
          .select()
          .inFilter('business_id', businessIds)
          .gte('order_date', startDate.toIso8601String())
          .lte('order_date', now.toIso8601String())
          .order('order_date');

      final currentPeriodOrders = (currentResponse as List)
          .map((item) => OrderModel.fromJson(item))
          .toList();

      // Obtenir les commandes pour la période précédente
      final previousStartDate = startDate.subtract(Duration(days: periodDays));
      
      final previousResponse = await _supabase
          .from('orders')
          .select()
          .inFilter('business_id', businessIds)
          .gte('order_date', previousStartDate.toIso8601String())
          .lt('order_date', startDate.toIso8601String())
          .order('order_date');

      final previousPeriodOrders = (previousResponse as List)
          .map((item) => OrderModel.fromJson(item))
          .toList();

      // Initialiser les données
      List<double> data = List.filled(labels.length, 0);
      double total = 0;
      double previousTotal = 0;

      // Calculer les statistiques en fonction de la métrique choisie
      if (metric == 'revenue') {
        // Revenus par jour/mois
        for (var order in currentPeriodOrders) {
          final int index = _getIndex(order.orderDate, startDate, period);
          if (index >= 0 && index < data.length) {
            data[index] += order.total;
            total += order.total;
          }
        }
        
        // Total période précédente
        for (var order in previousPeriodOrders) {
          previousTotal += order.total;
        }
      } 
      else if (metric == 'orders') {
        // Nombre de commandes par jour/mois
        for (var order in currentPeriodOrders) {
          final int index = _getIndex(order.orderDate, startDate, period);
          if (index >= 0 && index < data.length) {
            data[index] += 1;
            total += 1;
          }
        }
        
        // Total période précédente
        previousTotal = previousPeriodOrders.length.toDouble();
      } 
      else if (metric == 'customers') {
        // Nombre de clients uniques par jour/mois
        Set<String> uniqueCustomers = {};
        Map<int, Set<String>> indexCustomers = {};
        
        for (var i = 0; i < data.length; i++) {
          indexCustomers[i] = {};
        }
        
        for (var order in currentPeriodOrders) {
          final int index = _getIndex(order.orderDate, startDate, period);
          if (index >= 0 && index < data.length) {
            indexCustomers[index]?.add(order.clientId);
            uniqueCustomers.add(order.clientId);
          }
        }
        
        // Mettre à jour les données
        for (var i = 0; i < data.length; i++) {
          data[i] = indexCustomers[i]?.length.toDouble() ?? 0;
        }
        
        total = uniqueCustomers.length.toDouble();
        
        // Total période précédente
        Set<String> previousUniqueCustomers = {};
        for (var order in previousPeriodOrders) {
          previousUniqueCustomers.add(order.clientId);
        }
        previousTotal = previousUniqueCustomers.length.toDouble();
      }

      // Calculer la moyenne
      double average = total / data.where((d) => d > 0).length;
      if (average.isNaN) average = 0;

      // Calculer la croissance
      double growth = 0;
      if (previousTotal > 0) {
        growth = ((total - previousTotal) / previousTotal) * 100;
      }

      return {
        'labels': labels,
        'data': data,
        'total': total,
        'average': average,
        'growth': growth.toStringAsFixed(1),
      };
    } catch (e) {
      print('Erreur lors du calcul des statistiques: $e');
      
      // En cas d'erreur, retourner des statistiques vides
      return {
        'labels': [],
        'data': [],
        'total': 0,
        'average': 0,
        'growth': '0',
      };
    }
  }
  
  // Fonction utilitaire pour obtenir l'index dans les données en fonction de la date
  int _getIndex(DateTime date, DateTime startDate, String period) {
    switch (period) {
      case 'week':
        return date.difference(startDate).inDays;
      case 'month':
        return date.day - 1; // Jour du mois (0-indexé)
      case 'year':
        return date.month - 1; // Mois de l'année (0-indexé)
      default:
        return date.difference(startDate).inDays;
    }
  }

  // Créer une nouvelle commande
  Future<OrderModel> createOrder({
    required String businessId,
    required List<CartItemModel> items,
    required String deliveryAddress,
    required String paymentMethod,
  }) async {
    try {
      final currentUser = await _authService.getCurrentUser();
      if (currentUser == null) {
        throw Exception('Utilisateur non connecté');
      }

      // Calculer les montants
      final subtotal = items.fold<double>(0.0,
          (double sum, item) => sum + (item.calculateTotalPrice()));
      final tax = subtotal * 0.20; // TVA à 20%
      final total = subtotal + tax;
      
      // Générer un numéro de commande
      final orderNumber = 'ORD${DateTime.now().millisecondsSinceEpoch % 100000}';
      
      // Préparation des données pour insertion
      final orderData = {
        'client_id': currentUser.id,
        'business_id': businessId,
        'order_number': orderNumber,
        'items': items.map((item) => item.toJson()).toList(),
        'subtotal': subtotal,
        'tax': tax,
        'total': total,
        'order_date': DateTime.now().toIso8601String(),
        'status': 'pending',
        'delivery_address': deliveryAddress,
        'payment_method': paymentMethod,
      };

      final response = await _supabase
          .from('orders')
          .insert(orderData)
          .select()
          .single();

      return OrderModel.fromJson(response);
    } catch (e) {
      print('Erreur lors de la création de la commande: $e');
      throw Exception('Erreur lors de la création de la commande: $e');
    }
  }

    Future<void> cancelOrder(String orderId) async {
    try {
      final currentUser = await _authService.getCurrentUser();

      if (currentUser == null) {
        throw Exception('User not logged in');
      }

      // Vérifier que l'utilisateur est autorisé à annuler la commande
      final orderCheck = await _supabase
          .from('orders')
          .select('client_id, business_id, status')
          .eq('id', orderId)
          .single();

      final isClient = orderCheck['client_id'] == currentUser.id;

      if (!isClient) {
        // Vérifier si l'utilisateur est le propriétaire du commerce
        final businessCheck = await _supabase
            .from('businesses')
            .select('user_id')
            .eq('id', orderCheck['business_id'])
            .single();

        if (businessCheck['user_id'] != currentUser.id) {
          throw Exception('Vous n\'êtes pas autorisé à annuler cette commande');
        }
      }

      // Vérifier que la commande peut être annulée
      if (orderCheck['status'] == 'completed' ||
          orderCheck['status'] == 'cancelled') {
        throw Exception(
            'Cette commande ne peut pas être annulée car son statut est ${orderCheck['status']}');
      }

      await _supabase
          .from('orders')
          .update({'status': 'cancelled'}).eq('id', orderId);
    } catch (e) {
  throw Exception('Erreur lors de l\'annulation de la commande.');    }
  }

  getPendingOrdersCount() {}

}