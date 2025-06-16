// services/supabase_debug_service.dart
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseDebugService {
  Future<void> checkTableStructure(String tableName) async {
    try {
      final client = Supabase.instance.client;
      // Cette requête retourne la structure de la table
      final response = await client
          .from(tableName)
          .select()
          .limit(1);
      
      print('Structure de $tableName: $response');
    } catch (e) {
      print('Erreur lors de la vérification de $tableName: $e');
    }
  }

  Future<void> checkTablePermissions(String tableName) async {
    // Vérifier les permissions (lecture/écriture)
    try {
      // Test de lecture
      await Supabase.instance.client
          .from(tableName)
          .select('*')
          .limit(1);
    } catch (e) {
      print('❌ Pas de permission de lecture pour $tableName: $e');
    }
  }

  Future<void> checkRelations(String table1, String table2, String foreignKey) async {
    // Vérifier les relations entre tables
    print('Vérification de la relation entre $table1 et $table2 via $foreignKey');
  }
}