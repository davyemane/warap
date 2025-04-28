// Fichier services/notification_service.dart
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/notification_model.dart';
import 'auth_service.dart';
import 'error_handler.dart';

class NotificationService {
  final SupabaseClient _supabase = Supabase.instance.client;
  final AuthService _authService = AuthService();

  // Obtenir les notifications du client
  Future<List<NotificationModel>> getClientNotifications() async {
    try {
      final currentUser = await _authService.getCurrentUser();

      if (currentUser == null) {
        throw Exception('User not logged in');
      }

      final response = await _supabase
          .from('notifications')
          .select()
          .eq('user_id', currentUser.id)
          .order('created_at', ascending: false);

      return (response as List)
          .map((item) => NotificationModel.fromJson(item))
          .toList();
    } catch (e) {
      throw _handleError(e);
    }
  }

  // Obtenir le nombre de demandes de service non lues pour un vendeur
  Future<int> getVendorRequestsCount() async {
    try {
      final currentUser = await _authService.getCurrentUser();

      if (currentUser == null) {
        throw Exception('User not logged in');
      }

      // Obtenir les commerces du vendeur
      final businesses = await _supabase
          .from('businesses')
          .select('id')
          .eq('user_id', currentUser.id);

      final businessIds = (businesses as List).map((b) => b['id']).toList();

      if (businessIds.isEmpty) {
        return 0;
      }

      // Compter les demandes en attente
      final response = await _supabase
          .from('service_requests')
          .select('id, status')
          .inFilter('business_id', businessIds)
          .eq('status', 'pending');

      return (response as List).length;
    } catch (e) {
      throw _handleError(e);
    }
  }

  // Marquer une notification comme lue
  Future<void> markAsRead(String notificationId) async {
    try {
      await _supabase
          .from('notifications')
          .update({'read': true}).eq('id', notificationId);
    } catch (e) {
      throw _handleError(e);
    }
  }

  // Marquer toutes les notifications comme lues
  Future<void> markAllAsRead() async {
    try {
      final currentUser = await _authService.getCurrentUser();

      if (currentUser == null) {
        throw Exception('User not logged in');
      }

      await _supabase
          .from('notifications')
          .update({'read': true}).eq('user_id', currentUser.id);
    } catch (e) {
      throw _handleError(e);
    }
  }

  // Créer une notification
  Future<NotificationModel> createNotification({
    required String userId,
    required String title,
    required String message,
    required String type,
    String? imageUrl,
    String? relatedId,
  }) async {
    try {
      final response = await _supabase
          .from('notifications')
          .insert({
            'user_id': userId,
            'title': title,
            'message': message,
            'type': type,
            'image_url': imageUrl,
            'related_id': relatedId,
            'read': false,
            'created_at': DateTime.now().toIso8601String(),
          })
          .select()
          .single();

      return NotificationModel.fromJson(response);
    } catch (e) {
      throw _handleError(e);
    }
  }

  // Supprimer une notification
  Future<void> deleteNotification(String notificationId) async {
    try {
      await _supabase.from('notifications').delete().eq('id', notificationId);
    } catch (e) {
      throw _handleError(e);
    }
  }

  // Gérer les erreurs
  Exception _handleError(dynamic error) {
    if (error is PostgrestException) {
      if (error.code == '23503') {
        return Exception('L\'utilisateur associé n\'existe pas');
      }
    }
    return Exception('Erreur lors de la gestion des notifications: $error');
  }
}
