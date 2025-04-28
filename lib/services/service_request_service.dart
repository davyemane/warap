// Fichier services/service_request_service.dart
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/service_request_model.dart';
import 'auth_service.dart';
import 'error_handler.dart';

class ServiceRequestService {
  final SupabaseClient _supabase = Supabase.instance.client;
  final AuthService _authService = AuthService();

  // Créer une nouvelle demande de service
  Future<ServiceRequestModel> createServiceRequest(
      ServiceRequestModel request) async {
    try {
      final currentUser = await _authService.getCurrentUser();

      if (currentUser == null) {
        throw Exception('User not logged in');
      }

      final response = await _supabase
          .from('service_requests')
          .insert({
            'business_id': request.businessId,
            'client_id': currentUser.id,
            'description': request.description,
            'latitude': request.latitude,
            'longitude': request.longitude,
            'address': request.address,
            'request_date': request.requestDate.toIso8601String(),
            'preferred_date': request.preferredDate.toIso8601String(),
            'status': 'pending',
          })
          .select()
          .single();

      return ServiceRequestModel.fromJson(response);
    } catch (e) {
      throw _handleError(e);
    }
  }

  // Obtenir les demandes de service pour le client actuel
  Future<List<ServiceRequestModel>> getClientRequests() async {
    try {
      final currentUser = await _authService.getCurrentUser();

      if (currentUser == null) {
        throw Exception('User not logged in');
      }

      final response = await _supabase
          .from('service_requests')
          .select()
          .eq('client_id', currentUser.id)
          .order('request_date', ascending: false);

      return (response as List)
          .map((item) => ServiceRequestModel.fromJson(item))
          .toList();
    } catch (e) {
      throw _handleError(e);
    }
  }

  // Obtenir les demandes de service pour le vendeur
  Future<List<ServiceRequestModel>> getServiceRequests() async {
    try {
      final currentUser = await _authService.getCurrentUser();

      if (currentUser == null) {
        throw Exception('User not logged in');
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

      // Obtenir les demandes pour ces commerces
      final response = await _supabase
          .from('service_requests')
          .select('*, clients(*)')
          .inFilter('business_id', businessIds)
          .order('request_date', ascending: false);

      return (response as List)
          .map((item) => ServiceRequestModel.fromJson(item))
          .toList();
    } catch (e) {
      throw _handleError(e);
    }
  }

  // Mettre à jour le statut d'une demande
  Future<void> updateRequestStatus(String requestId, String status) async {
    try {
      await _supabase
          .from('service_requests')
          .update({'status': status}).eq('id', requestId);
    } catch (e) {
      throw _handleError(e);
    }
  }

  // Supprimer une demande
  Future<void> deleteServiceRequest(String requestId) async {
    try {
      await _supabase.from('service_requests').delete().eq('id', requestId);
    } catch (e) {
      throw _handleError(e);
    }
  }

  // Gérer les erreurs
  Exception _handleError(dynamic error) {
    if (error is PostgrestException) {
      if (error.code == '23505') {
        return Exception('Une demande similaire existe déjà');
      } else if (error.code == '23503') {
        return Exception('Le commerce ou l\'utilisateur n\'existe pas');
      }
    }
    return Exception('Erreur lors de la gestion de la demande: $error');
  }

  // Ajoutez ces méthodes au service ServiceRequestService

// Obtenir les demandes en attente
  Future<List<ServiceRequestModel>> getPendingRequests() async {
    try {
      final currentUser = await _authService.getCurrentUser();

      if (currentUser == null) {
        throw Exception('User not logged in');
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

      // Obtenir les demandes en attente
      final response = await _supabase
          .from('service_requests')
          .select('*, clients(*)')
          .inFilter('business_id', businessIds)
          .eq('status', 'pending')
          .order('request_date', ascending: false);

      return (response as List)
          .map((item) => ServiceRequestModel.fromJson(item))
          .toList();
    } catch (e) {
      throw _handleError(e);
    }
  }

  // Récupérer les demandes pour un commerce
  Future<List<ServiceRequestModel>> getBusinessRequests() async {
    try {
      final currentUser = await _authService.getCurrentUser();
      if (currentUser == null || currentUser.userType != 'vendeur') {
        throw Exception('Accès non autorisé');
      }

      // Simuler le chargement des données
      await Future.delayed(const Duration(seconds: 1));
      
      // Générer des données de test
      List<ServiceRequestModel> requests = [];
      final now = DateTime.now();
      
      for (int i = 1; i <= 10; i++) {
        requests.add(ServiceRequestModel(
          id: 'request_$i',
          businessId: 'business_1',
          clientId: 'client_${i % 3 + 1}',
          description: 'Demande de service de client $i Lorem ipsum dolor sit amet, consectetur adipiscing elit.',
          latitude: 48.8566 + (i * 0.005),
          longitude: 2.3522 + (i * 0.005),
          address: '$i Avenue des Clients, 75001 Paris',
          requestDate: now.subtract(Duration(days: i)),
          preferredDate: now.add(Duration(days: i % 7 + 1)),
          status: i % 4 == 0 ? 'pending' : (i % 4 == 1 ? 'accepted' : (i % 4 == 2 ? 'completed' : 'cancelled')),
        ));
      }
      
      return requests;
    } catch (e) {
      throw Exception('Erreur lors de la récupération des demandes: $e');
    }
  }
}
