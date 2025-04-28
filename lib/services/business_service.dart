// Fichier services/business_service.dart
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/business_model.dart';
import 'auth_service.dart';
import 'error_handler.dart';

class BusinessService {
  final SupabaseClient _supabase = Supabase.instance.client;
  final AuthService _authService = AuthService();

  // Obtenir tous les commerces
  Future<List<BusinessModel>> getAllBusinesses() async {
    try {
      final response = await _supabase
          .from('businesses')
          .select('*')
          .order('name');

      return (response as List)
          .map((item) => BusinessModel.fromJson(item))
          .toList();
    } catch (e) {
      throw _handleError(e);
    }
  }

  // Obtenir un commerce par son ID
  Future<BusinessModel> getBusinessById(String businessId) async {
    try {
      final response = await _supabase
          .from('businesses')
          .select('*')
          .eq('id', businessId)
          .single();

      return BusinessModel.fromJson(response);
    } catch (e) {
      throw _handleError(e);
    }
  }

  // Obtenir les commerces à proximité
  Future<List<BusinessModel>> getNearbyBusinesses(double latitude, double longitude, double radius) async {
    try {
      // Utiliser une requête SQL pour calculer la distance
      final response = await _supabase
          .rpc('nearby_businesses', params: {
            'lat': latitude,
            'lng': longitude,
            'radius_km': radius,
          });

      return (response as List)
          .map((item) => BusinessModel.fromJson(item))
          .toList();
    } catch (e) {
      throw _handleError(e);
    }
  }

  // Obtenir les commerces de l'utilisateur
  Future<List<BusinessModel>> getUserBusinesses() async {
    try {
      final currentUser = await _authService.getCurrentUser();
      
      if (currentUser == null) {
        throw Exception('User not logged in');
      }

      final response = await _supabase
          .from('businesses')
          .select('*')
          .eq('user_id', currentUser.id)
          .order('name');

      return (response as List)
          .map((item) => BusinessModel.fromJson(item))
          .toList();
    } catch (e) {
      throw _handleError(e);
    }
  }

  // Créer un nouveau commerce
  Future<BusinessModel> createBusiness(BusinessModel business) async {
    try {
      final currentUser = await _authService.getCurrentUser();
      
      if (currentUser == null) {
        throw Exception('User not logged in');
      }

      final response = await _supabase
          .from('businesses')
          .insert({
            'name': business.name,
            'description': business.description,
            'business_type': business.businessType,
            'user_id': currentUser.id,
            'latitude': business.latitude,
            'longitude': business.longitude,
            'address': business.address,
            'opening_time': business.openingTime,
            'closing_time': business.closingTime,
            'phone': business.phone,
          })
          .select()
          .single();

      return BusinessModel.fromJson(response);
    } catch (e) {
      throw _handleError(e);
    }
  }

  // Mettre à jour un commerce
  Future<BusinessModel> updateBusiness(BusinessModel business) async {
    try {
      final currentUser = await _authService.getCurrentUser();
      
      if (currentUser == null) {
        throw Exception('User not logged in');
      }

      // Vérifier que l'utilisateur est propriétaire du commerce
      final businessCheck = await _supabase
          .from('businesses')
          .select('user_id')
          .eq('id', business.id)
          .single();

      if (businessCheck['user_id'] != currentUser.id) {
        throw Exception('Vous n\'êtes pas autorisé à modifier ce commerce');
      }

      final response = await _supabase
          .from('businesses')
          .update({
            'name': business.name,
            'description': business.description,
            'business_type': business.businessType,
            'latitude': business.latitude,
            'longitude': business.longitude,
            'address': business.address,
            'opening_time': business.openingTime,
            'closing_time': business.closingTime,
            'phone': business.phone,
          })
          .eq('id', business.id)
          .select()
          .single();

      return BusinessModel.fromJson(response);
    } catch (e) {
      throw _handleError(e);
    }
  }

  // Supprimer un commerce
  Future<void> deleteBusiness(String businessId) async {
    try {
      final currentUser = await _authService.getCurrentUser();
      
      if (currentUser == null) {
        throw Exception('User not logged in');
      }

      // Vérifier que l'utilisateur est propriétaire du commerce
      final businessCheck = await _supabase
          .from('businesses')
          .select('user_id')
          .eq('id', businessId)
          .single();

      if (businessCheck['user_id'] != currentUser.id) {
        throw Exception('Vous n\'êtes pas autorisé à supprimer ce commerce');
      }

      await _supabase
          .from('businesses')
          .delete()
          .eq('id', businessId);
    } catch (e) {
      throw _handleError(e);
    }
  }

  // Gérer les erreurs
  Exception _handleError(dynamic error) {
    if (error is PostgrestException) {
      if (error.code == '23505') {
        return Exception('Un commerce avec ce nom existe déjà');
      } else if (error.code == '23503') {
        return Exception('L\'utilisateur n\'existe pas');
      }
    }
    return Exception('Erreur lors de la gestion du commerce: $error');
  }

  Future<void> addBusiness(BusinessModel business) async {
    // Add your logic to save the business to the database or API
    // Example:
    try {
      final response = await Supabase.instance.client
          .from('businesses')
          .insert(business.toJson());
      if (response.error != null) {
        throw Exception(response.error!.message);
      }
    } catch (e) {
      throw Exception('Failed to add business: $e');
    }
  }

  // Ajouter à services/business_service.dart
Future<List<BusinessModel>> getVendorBusinesses(String userId) async {
  try {
    final response = await _supabase
        .from('businesses')
        .select('*')
        .eq('user_id', userId)
        .order('name');

    return (response as List)
        .map((item) => BusinessModel.fromJson(item))
        .toList();
  } catch (e) {
    throw _handleError(e);
  }
}
}