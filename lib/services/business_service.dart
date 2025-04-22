// Fichier services/business_service.dart
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/business_model.dart';

class BusinessService {
  final SupabaseClient _supabaseClient = Supabase.instance.client;

  // Récupérer tous les commerces
  Future<List<BusinessModel>> getAllBusinesses() async {
    try {
      final response = await _supabaseClient.from('businesses').select();
      
      return (response as List<dynamic>)
          .map((business) => BusinessModel.fromJson(business))
          .toList();
    } catch (e) {
      print('Erreur lors de la récupération de tous les commerces: $e');
      rethrow;
    }
  }

  // Récupérer les commerces en fonction du type
  Future<List<BusinessModel>> getBusinessesByType(String type) async {
    try {
      final response = await _supabaseClient
          .from('businesses')
          .select()
          .eq('business_type', type);
      
      return (response as List<dynamic>)
          .map((business) => BusinessModel.fromJson(business))
          .toList();
    } catch (e) {
      print('Erreur lors de la récupération des commerces par type: $e');
      rethrow;
    }
  }

  // Récupérer les commerces d'un vendeur spécifique
  Future<List<BusinessModel>> getVendorBusinesses(String userId) async {
    try {
      final response = await _supabaseClient
          .from('businesses')
          .select()
          .eq('user_id', userId);
      
      return (response as List<dynamic>)
          .map((business) => BusinessModel.fromJson(business))
          .toList();
    } catch (e) {
      print('Erreur lors de la récupération des commerces du vendeur: $e');
      rethrow;
    }
  }

  // Ajouter un nouveau commerce
  Future<BusinessModel> addBusiness(BusinessModel business) async {
    try {
      // Vérifier l'authentification
      final currentUser = _supabaseClient.auth.currentUser;
      if (currentUser == null) {
        throw Exception('User not authenticated');
      }
      
      // Vérifier que l'utilisateur existe dans la table users
      final userExists = await _supabaseClient
          .from('users')
          .select('id')
          .eq('id', currentUser.id)
          .maybeSingle();
          
      if (userExists == null) {
        throw Exception('User profile not found');
      }
      
      // Préparer les données
      final businessData = {
        'user_id': currentUser.id,
        'name': business.name,
        'description': business.description,
        'business_type': business.businessType,
        'latitude': business.latitude,
        'longitude': business.longitude,
        'opening_time': business.openingTime,
        'closing_time': business.closingTime,
        'address': business.address,
        'phone': business.phone,
        'created_at': DateTime.now().toIso8601String(),
      };
      
      print('Données à insérer: $businessData');
      
      // Insérer les données
      final response = await _supabaseClient
          .from('businesses')
          .insert(businessData)
          .select()
          .maybeSingle();
      
      if (response == null) {
        // Si aucune donnée n'est retournée, utiliser les données fournies
        return business;
      }
      
      return BusinessModel.fromJson(response);
    } catch (e) {
      print('Erreur lors de l\'ajout du commerce: $e');
      rethrow;
    }
  }

  // Mettre à jour un commerce existant
  Future<BusinessModel> updateBusiness(BusinessModel business) async {
    try {
      final response = await _supabaseClient
          .from('businesses')
          .update(business.toJson())
          .eq('id', business.id)
          .select()
          .single();
      
      return BusinessModel.fromJson(response);
    } catch (e) {
      print('Erreur lors de la mise à jour du commerce: $e');
      rethrow;
    }
  }

  // Supprimer un commerce
  Future<void> deleteBusiness(String businessId) async {
    try {
      await _supabaseClient
          .from('businesses')
          .delete()
          .eq('id', businessId);
    } catch (e) {
      print('Erreur lors de la suppression du commerce: $e');
      rethrow;
    }
  }
}