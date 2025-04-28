// Fichier services/vendor_settings_service.dart
import 'package:supabase_flutter/supabase_flutter.dart';
import 'auth_service.dart';

class VendorSettingsService {
  final SupabaseClient _supabase = Supabase.instance.client;
  final AuthService _authService = AuthService();
  
  // Valeurs par défaut
  final Map<String, dynamic> _defaultSettings = {
    'showWhenClosed': true,
    'newCustomerNotification': true,
    'defaultOpeningTime': '08:00',
    'defaultClosingTime': '18:00',
    'defaultStatsPeriod': 'week',
    'acceptCash': true,
    'acceptCreditCard': false,
    'acceptMobilePayment': false,
  };

  // Charger les paramètres du vendeur
  Future<Map<String, dynamic>> loadSettings() async {
    try {
      // Obtenir l'identifiant de l'utilisateur actuel
      final currentUser = await _authService.getCurrentUser();
      if (currentUser == null || currentUser.userType != 'vendeur') {
        throw Exception('Accès non autorisé');
      }
      
      // Vérifier si des paramètres existent pour cet utilisateur
      final response = await _supabase
          .from('vendor_settings')
          .select()
          .eq('user_id', currentUser.id)
          .maybeSingle();
      
      if (response != null) {
        // Convertir la réponse en map
        Map<String, dynamic> settings = Map<String, dynamic>.from(response);
        return _ensureAllSettings(settings);
      }
      
      // Si aucun paramètre n'existe, retourner les valeurs par défaut
      return _defaultSettings;
    } catch (e) {
      print('Erreur lors du chargement des paramètres: $e');
      // En cas d'erreur, retourner les valeurs par défaut
      return _defaultSettings;
    }
  }
  
  // Enregistrer les paramètres du vendeur
  Future<void> saveSettings(Map<String, dynamic> settings) async {
    try {
      // Obtenir l'identifiant de l'utilisateur actuel
      final currentUser = await _authService.getCurrentUser();
      if (currentUser == null || currentUser.userType != 'vendeur') {
        throw Exception('Accès non autorisé');
      }
      
      // S'assurer que tous les paramètres sont présents
      final completeSettings = _ensureAllSettings(settings);
      
      // Vérifier si des paramètres existent déjà pour cet utilisateur
      final existingSettings = await _supabase
          .from('vendor_settings')
          .select('id')
          .eq('user_id', currentUser.id)
          .maybeSingle();
      
      if (existingSettings != null) {
        // Mettre à jour les paramètres existants
        await _supabase
            .from('vendor_settings')
            .update(completeSettings)
            .eq('user_id', currentUser.id);
      } else {
        // Créer de nouveaux paramètres
        completeSettings['user_id'] = currentUser.id;
        await _supabase
            .from('vendor_settings')
            .insert(completeSettings);
      }
    } catch (e) {
      print('Erreur lors de l\'enregistrement des paramètres: $e');
      throw Exception('Impossible d\'enregistrer les paramètres: $e');
    }
  }
  
  // S'assurer que tous les paramètres nécessaires sont présents
  Map<String, dynamic> _ensureAllSettings(Map<String, dynamic> settings) {
    Map<String, dynamic> completeSettings = Map<String, dynamic>.from(settings);
    
    // Ajouter les valeurs par défaut pour les paramètres manquants
    _defaultSettings.forEach((key, value) {
      if (!completeSettings.containsKey(key)) {
        completeSettings[key] = value;
      }
    });
    
    return completeSettings;
  }
}