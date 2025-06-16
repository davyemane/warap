// services/connection_test_service.dart
import 'package:supabase_flutter/supabase_flutter.dart';

class ConnectionTestService {
  Future<bool> testInternetConnection() async {
    try {
      // Exemple simple de test d'internet
      // Dans une vraie app, utiliser une vérification plus robuste
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> testSupabaseConnection() async {
    try {
      // Tester la connexion à Supabase
      final client = Supabase.instance.client;
      await client.auth.currentSession;
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<Map<String, dynamic>> checkSupabaseAuth() async {
    try {
      final client = Supabase.instance.client;
      final session = await client.auth.currentSession;
      
      if (session != null) {
        return {
          'authenticated': true,
          'details': {
            'email': session.user.email ?? 'Non disponible',
            'id': session.user.id ?? 'Non disponible',
          }
        };
      } else {
        return {
          'authenticated': false,
          'message': 'Aucune session active'
        };
      }
    } catch (e) {
      return {
        'authenticated': false,
        'message': 'Erreur: ${e.toString()}'
      };
    }
  }
}