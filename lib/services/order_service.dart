// services/order_service.dart

import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/order_model.dart';
import '../models/cart_item_model.dart';
import 'auth_service.dart';

class OrderService {
  final SupabaseClient _supabase = Supabase.instance.client;
  final AuthService _authService = AuthService();

  /// =================== Commande unique ===================

  // Obtenir une commande par ID
// Dans order_service.dart - Méthode getOrderById améliorée
Future<OrderModel> getOrderById(String orderId) async {
  try {
    print('🔍 Récupération de la commande ID: $orderId');
    
    // Requête simplifiée sans jointure complexe
    final response = await _supabase
        .from('orders')
        .select('*')
        .eq('id', orderId)
        .single();
    
    if (response == null) {
      throw Exception('Commande non trouvée');
    }
    
    // Conversion en OrderModel
    print('✅ Commande récupérée avec succès');
    return OrderModel.fromJson(response);
  } catch (e) {
    print('❌ Erreur lors de la récupération de la commande: $e');
    throw Exception('Erreur lors de la récupération de la commande: $e');
  }
}
  /// =================== Récupération de commandes ===================

  // Obtenir toutes les commandes du vendeur
  Future<List<OrderModel>> getBusinessOrders() async {
    try {
      final businessIds = await _getBusinessIds();
      if (businessIds.isEmpty) return [];

      final response = await _supabase
          .from('orders')
          .select('*, clients(*)')
          .inFilter('business_id', businessIds)
          .order('order_date', ascending: false);

      return _mapOrderList(response);
    } catch (e) {
      print('Erreur lors de la récupération des commandes: $e');
      throw Exception('Erreur lors de la récupération des commandes: $e');
    }
  }

  // Obtenir les commandes récentes (par défaut 5)
Future<List<OrderModel>> getRecentOrders({int limit = 5}) async {
  try {
    final businessIds = await _getBusinessIds();
    if (businessIds.isEmpty) {
      print('Aucun commerce trouvé pour cet utilisateur');
      return [];
    }

    print('Recherche des commandes pour les commerces: $businessIds');
    
    // Ajouter des logs détaillés pour le débogage
    final response = await _supabase
        .from('orders')
        .select('*, clients:client_id(*)')  // Utiliser la bonne syntaxe pour la jointure
        .inFilter('business_id', businessIds)
        .order('order_date', ascending: false)
        .limit(limit);
    
    print('Réponse reçue pour les commandes: ${response != null ? 'données trouvées' : 'null'}');
    if (response is List) {
      print('Nombre de commandes trouvées: ${response.length}');
    }
    
    return _mapOrderList(response);
  } catch (e) {
    print('Erreur détaillée lors de la récupération des commandes récentes: $e');
    // Renvoyer une liste vide au lieu de lancer une exception pour éviter le plantage
    return [];
  }
}
  // Obtenir les commandes en attente
  Future<List<OrderModel>> getPendingOrders() async {
    try {
      final businessIds = await _getBusinessIds();
      if (businessIds.isEmpty) return [];

      final response = await _supabase
          .from('orders')
          .select('*, clients(*)')
          .inFilter('business_id', businessIds)
          .eq('status', 'pending')
          .order('order_date', ascending: false);

      return _mapOrderList(response);
    } catch (e) {
      print('Erreur lors de la récupération des commandes en attente: $e');
      throw Exception(
          'Erreur lors de la récupération des commandes en attente: $e');
    }
  }

  /// =================== Mise à jour ===================

  // Mettre à jour le statut d'une commande
  Future<void> updateOrderStatus(String orderId, String status) async {
    try {
      await _supabase
          .from('orders')
          .update({'status': status}).eq('id', orderId);
    } catch (e) {
      print('Erreur lors de la mise à jour du statut: $e');
      throw Exception('Erreur lors de la mise à jour du statut: $e');
    }
  }

  /// =================== Statistiques ===================

  // Obtenir les statistiques sur une période donnée
// Dans order_service.dart - Remplacer la méthode getStatistics

Future<Map<String, dynamic>> getStatistics({
  required String period,
  required String metric,
}) async {
  try {
    print('🔍 Calcul des statistiques (période: $period, métrique: $metric)...');
    
    final businessIds = await _getBusinessIds();
    if (businessIds.isEmpty) {
      print('⚠️ Aucun commerce trouvé');
      return _emptyStatistics();
    }
    
    print('📋 Commerces: $businessIds');
    
    // Déterminer la plage de dates
    final now = DateTime.now();
    DateTime startDate;
    List<String> labels;
    
    switch (period) {
      case 'week':
        startDate = now.subtract(const Duration(days: 7));
        labels = List.generate(7, (i) {
          final date = startDate.add(Duration(days: i));
          return '${date.day}/${date.month}';
        });
        break;
      case 'month':
        startDate = DateTime(now.year, now.month, 1);
        final daysInMonth = DateTime(now.year, now.month + 1, 0).day;
        labels = List.generate(daysInMonth, (i) => '${i + 1}');
        break;
      case 'year':
        startDate = DateTime(now.year, 1, 1);
        labels = ['Jan', 'Fév', 'Mar', 'Avr', 'Mai', 'Juin', 'Juil', 'Août', 'Sep', 'Oct', 'Nov', 'Déc'];
        break;
      default:
        startDate = now.subtract(const Duration(days: 7));
        labels = List.generate(7, (i) {
          final date = startDate.add(Duration(days: i));
          return '${date.day}/${date.month}';
        });
    }
    
    print('📅 Période: ${startDate.toIso8601String()} à ${now.toIso8601String()}');
    
    // Récupérer les commandes
    final response = await _supabase
        .from('orders')
        .select()
        .inFilter('business_id', businessIds)
        .gte('order_date', startDate.toIso8601String())
        .lte('order_date', now.toIso8601String());
    
    if (response == null) {
      print('⚠️ Aucune commande trouvée pour la période');
      return {
        'labels': labels,
        'data': List<double>.filled(labels.length, 0),
        'total': 0,
        'average': 0,
        'growth': '0',
      };
    }
    
    List<OrderModel> orders = [];
    try {
      orders = _mapOrderList(response);
      print('✅ ${orders.length} commandes récupérées');
    } catch (e) {
      print('❌ Erreur lors de la conversion des commandes: $e');
      return _emptyStatistics();
    }
    
    // Initialiser les données
    final data = List<double>.filled(labels.length, 0);
    double total = 0;
    
    // Calculer les statistiques selon la métrique
    for (var order in orders) {
      // Déterminer l'index pour les données
      int index;
      if (period == 'week') {
        index = order.orderDate.difference(startDate).inDays;
      } else if (period == 'month') {
        index = order.orderDate.day - 1;
      } else { // year
        index = order.orderDate.month - 1;
      }
      
      // Ignorer les données hors de la plage
      if (index < 0 || index >= data.length) continue;
      
      // Mettre à jour les données
      if (metric == 'revenue') {
        data[index] += order.total;
        total += order.total;
      } else if (metric == 'orders') {
        data[index] += 1;
        total += 1;
      }
    }
    
    // Calculer la moyenne
    double average = 0;
    if (orders.isNotEmpty) {
      if (metric == 'revenue') {
        average = total / orders.length;
      } else if (metric == 'orders') {
        // Calculer le nombre moyen de commandes par jour
        final days = period == 'week' ? 7 : (period == 'month' ? 30 : 365);
        average = total / days;
      }
    }
    
    // Formater la moyenne à 2 décimales
    average = double.parse(average.toStringAsFixed(2));
    
    // Pour le moment, une croissance fictive
    final growth = '5.2';
    
    return {
      'labels': labels,
      'data': data,
      'total': total,
      'average': average,
      'growth': growth,
    };
  } catch (e) {
    print('❌ Erreur lors du calcul des statistiques: $e');
    return _emptyStatistics();
  }
}

// Méthode pour obtenir les statistiques vides
Map<String, dynamic> _emptyStatistics() {
  return {
    'labels': [],
    'data': [],
    'total': 0,
    'average': 0,
    'growth': '0',
  };
}
  /// =================== Création ===================

  // Créer une nouvelle commande
  Future<OrderModel> createOrder({
    required String businessId,
    required List<CartItemModel> items,
    required String deliveryAddress,
    required String paymentMethod,
  }) async {
    try {
      final currentUser = await _authService.getCurrentUser();
      if (currentUser == null) throw Exception('Utilisateur non connecté');

      final subtotal = items.fold<double>(
        0.0,
        (sum, item) => sum + item.calculateTotalPrice(),
      );

      // (Ici tu dois continuer ta logique de création et d'insertion...)

      throw UnimplementedError('createOrder pas encore totalement implémenté.');
    } catch (e) {
      print('Erreur lors de la création de la commande: $e');
      throw Exception('Erreur lors de la création de la commande: $e');
    }
  }

  /// =================== Utilitaires internes ===================

  Future<List<String>> _getBusinessIds() async {
    final currentUser = await _authService.getCurrentUser();
    if (currentUser == null) throw Exception('Utilisateur non connecté');

    final businesses = await _supabase
        .from('businesses')
        .select('id')
        .eq('user_id', currentUser.id);

    return (businesses as List).map((b) => b['id'] as String).toList();
  }

  List<OrderModel> _mapOrderList(dynamic response) {
    return (response as List).map((item) => OrderModel.fromJson(item)).toList();
  }

  // Obtenir le nombre de commandes en attente
  Future<int> getPendingOrdersCount() async {
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
        return 0;
      }

final response = await _supabase
    .from('orders')
    .select('id')
    .inFilter('business_id', businessIds)
    .eq('status', 'pending');

final count = (response as List).length;
      if (count == null) {
        throw Exception('Erreur lors de la récupération du nombre de commandes');
      }
      if (count == 0) {
        return 0;
      }

      return count;
    } catch (e) {
      print(
          'Erreur lors de la récupération du nombre de commandes en attente: $e');
      throw Exception(
          'Erreur lors de la récupération du nombre de commandes en attente: $e');
    }
  }


// Dans order_service.dart - Ajoutez/modifiez cette méthode
Future<List<OrderModel>> getAllOrders() async {
  try {
    print('🔍 Chargement de toutes les commandes...');
    
    // Même approche que pour getRecentOrders mais sans limite
    final businessIds = await _getBusinessIds();
    if (businessIds.isEmpty) {
      print('⚠️ Aucun commerce trouvé pour ce vendeur');
      return [];
    }
    
    print('📋 Recherche des commandes pour les commerces: $businessIds');
    
    // Requête pour obtenir les commandes sans limite
    final response = await _supabase
        .from('orders')
        .select('*')
        .inFilter('business_id', businessIds)
        .order('order_date', ascending: false);
    
    if (response == null) {
      return [];
    }
    
    List<OrderModel> orders = [];
    try {
      orders = _mapOrderList(response);
      print('✅ ${orders.length} commandes récupérées avec succès');
    } catch (e) {
      print('❌ Erreur lors de la conversion des commandes: $e');
    }
    
    return orders;
  } catch (e) {
    print('❌ Erreur lors de la récupération des commandes: $e');
    return [];
  }
}


Future<void> cancelOrder(String orderId) async {
  final response = await _supabase
      .from('orders')
      .update({
        'status': 'canceled', // Ou 'cancelled' selon ton modèle
        'updated_at': DateTime.now().toIso8601String(),
      })
      .eq('id', orderId);

  if (response.error != null) {
    throw Exception('Erreur lors de l\'annulation de la commande : ${response.error!.message}');
  }
}


  Future<List<OrderModel>> _fetchOrdersBetween(
    List<String> businessIds,
    DateTime startDate,
    DateTime endDate,
  ) async {
    final response = await _supabase
        .from('orders')
        .select()
        .inFilter('business_id', businessIds)
        .gte('order_date', startDate.toIso8601String())
        .lte('order_date', endDate.toIso8601String())
        .order('order_date');

    return _mapOrderList(response);
  }

  _PeriodConfig _getPeriodConfig(DateTime now, String period) {
    late DateTime startDate;
    late List<String> labels;
    late int periodDays;

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
          'Jan',
          'Fév',
          'Mar',
          'Avr',
          'Mai',
          'Juin',
          'Juil',
          'Août',
          'Sep',
          'Oct',
          'Nov',
          'Déc'
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

    return _PeriodConfig(
        startDate: startDate, labels: labels, periodDays: periodDays);
  }

  int _getIndex(DateTime date, DateTime startDate, String period) {
    switch (period) {
      case 'week':
        return date.difference(startDate).inDays;
      case 'month':
        return date.day - 1;
      case 'year':
        return date.month - 1;
      default:
        return date.difference(startDate).inDays;
    }
  }

  Map<String, dynamic> _computeStatistics({
    required List<OrderModel> currentOrders,
    required List<OrderModel> previousOrders,
    required _PeriodConfig periodConfig,
    required String metric,
  }) {
    final data = List<double>.filled(periodConfig.labels.length, 0);
    double total = 0;
    double previousTotal = 0;

    if (metric == 'revenue') {
      for (var order in currentOrders) {
        final index =
            _getIndex(order.orderDate, periodConfig.startDate, metric);
        if (index >= 0 && index < data.length) {
          data[index] += order.total;
          total += order.total;
        }
      }
      for (var order in previousOrders) {
        previousTotal += order.total;
      }
    } else if (metric == 'orders') {
      for (var order in currentOrders) {
        final index =
            _getIndex(order.orderDate, periodConfig.startDate, metric);
        if (index >= 0 && index < data.length) {
          data[index] += 1;
          total += 1;
        }
      }
      previousTotal = previousOrders.length.toDouble();
    } else if (metric == 'customers') {
      Set<String> uniqueCustomers = {};
      Map<int, Set<String>> indexCustomers = {
        for (var i = 0; i < data.length; i++) i: {}
      };

      for (var order in currentOrders) {
        final index =
            _getIndex(order.orderDate, periodConfig.startDate, metric);
        if (index >= 0 && index < data.length) {
          indexCustomers[index]?.add(order.clientId);
          uniqueCustomers.add(order.clientId);
        }
      }

      for (var i = 0; i < data.length; i++) {
        data[i] = indexCustomers[i]?.length.toDouble() ?? 0;
      }
      total = uniqueCustomers.length.toDouble();

      Set<String> previousUniqueCustomers = {};
      for (var order in previousOrders) {
        previousUniqueCustomers.add(order.clientId);
      }
      previousTotal = previousUniqueCustomers.length.toDouble();
    }

    double average = total / data.where((d) => d > 0).length;
    if (average.isNaN) average = 0;

    double growth = 0;
    if (previousTotal > 0) {
      growth = ((total - previousTotal) / previousTotal) * 100;
    }

    return {
      'labels': periodConfig.labels,
      'data': data,
      'total': total,
      'average': average,
      'growth': growth.toStringAsFixed(1),
    };
  }

}

/// Classe interne pour la configuration des périodes
class _PeriodConfig {
  final DateTime startDate;
  final List<String> labels;
  final int periodDays;

  _PeriodConfig({
    required this.startDate,
    required this.labels,
    required this.periodDays,
  });


  
}
