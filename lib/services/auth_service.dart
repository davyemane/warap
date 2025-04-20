// Fichier services/auth_service.dart
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/user_model.dart';

class AuthService {
  final SupabaseClient _supabaseClient = Supabase.instance.client;

  // Vérifier si l'utilisateur est authentifié
  Future<bool> isAuthenticated() async {
    return _supabaseClient.auth.currentUser != null;
  }

  // Obtenir le type d'utilisateur (client ou vendeur)
  Future<String> getUserType() async {
    try {
      final user = _supabaseClient.auth.currentUser;
      if (user == null) {
        throw Exception('User not authenticated');
      }

      final response = await _supabaseClient
          .from('users')
          .select('user_type')
          .eq('id', user.id)
          .maybeSingle();

      if (response == null) {
        print('Données utilisateur non trouvées, retour au type par défaut');
        return 'client';
      }
      
      return response['user_type'] ?? 'client'; // Default to client if null
    } catch (e) {
      print('Erreur lors de la récupération du type d\'utilisateur: $e');
      // Fallback à client par défaut en cas d'erreur
      return 'client';
    }
  }

  // S'inscrire en tant que nouveau utilisateur
  Future<UserModel> signUp({
    required String email,
    required String password,
    required String userType,
  }) async {
    try {
      print('Tentative d\'inscription pour: $email, type: $userType');
      
      // 1. Création de l'utilisateur dans l'authentification Supabase
      final authResponse = await _supabaseClient.auth.signUp(
        email: email,
        password: password,
      );

      if (authResponse.user == null) {
        print('Échec de création de l\'utilisateur dans Auth');
        throw Exception('Failed to create user in authentication');
      }
      
      final userId = authResponse.user!.id;
      print('Authentification réussie, ID utilisateur: $userId');

      // 2. Ajouter l'utilisateur à la table users avec son type
      try {
        await _supabaseClient.from('users').insert({
          'id': userId,
          'email': email,
          'user_type': userType,
          'created_at': DateTime.now().toIso8601String(),
          'updated_at': DateTime.now().toIso8601String(),
        });
        print('Données utilisateur insérées avec succès dans la table users');
      } catch (e) {
        print('Erreur d\'insertion dans users: $e');
        throw Exception('Failed to store user data: $e');
      }

      // 3. Attendre un court délai pour la propagation des données
      await Future.delayed(const Duration(milliseconds: 500));

      // 4. Récupérer les informations complètes de l'utilisateur avec une approche plus robuste
      try {
        final response = await _supabaseClient
            .from('users')
            .select()
            .eq('id', userId)
            .maybeSingle();
        
        if (response == null) {
          print('Aucune donnée utilisateur trouvée après l\'insertion');
          
          // 5. Si aucune donnée n'est trouvée, créer un modèle utilisateur avec les informations disponibles
          return UserModel(
            id: userId,
            email: email,
            userType: userType,
            createdAt: DateTime.now(),
          );
        }
        
        print('Données utilisateur récupérées: $response');
        return UserModel.fromJson(response);
      } catch (e) {
        print('Erreur lors de la récupération des données: $e');
        
        // 6. En cas d'erreur, retourner également un modèle utilisateur avec les informations disponibles
        return UserModel(
          id: userId,
          email: email,
          userType: userType,
          createdAt: DateTime.now(),
        );
      }
    } catch (e) {
      print('Erreur globale d\'inscription: $e');
      throw Exception('Registration failed: $e');
    }
  }

  // Se connecter avec un compte existant
  Future<UserModel> signIn({
    required String email,
    required String password,
  }) async {
    try {
      print('Tentative de connexion: $email');
      
      // 1. Authentification
      final authResponse = await _supabaseClient.auth.signInWithPassword(
        email: email,
        password: password,
      );

      if (authResponse.user == null) {
        print('Échec d\'authentification');
        throw Exception('Authentication failed');
      }
      
      final userId = authResponse.user!.id;
      print('Connexion réussie, ID utilisateur: $userId');

      // 2. Récupération des données utilisateur
      try {
        final response = await _supabaseClient
            .from('users')
            .select()
            .eq('id', userId)
            .maybeSingle();
        
        if (response == null) {
          print('Données utilisateur non trouvées, création d\'un profil par défaut');
          
          // 3. Si les données utilisateur n'existent pas, créons-les
          await _supabaseClient.from('users').insert({
            'id': userId,
            'email': email,
            'user_type': 'client', // Type par défaut
            'created_at': DateTime.now().toIso8601String(),
            'updated_at': DateTime.now().toIso8601String(),
          });
          
          await Future.delayed(const Duration(milliseconds: 500));
          
          final newResponse = await _supabaseClient
              .from('users')
              .select()
              .eq('id', userId)
              .maybeSingle();
              
          if (newResponse != null) {
            return UserModel.fromJson(newResponse);
          } else {
            return UserModel(
              id: userId,
              email: email,
              userType: 'client',
              createdAt: DateTime.now(),
            );
          }
        }
        
        print('Données utilisateur récupérées: $response');
        return UserModel.fromJson(response);
      } catch (e) {
        print('Erreur lors de la récupération des données utilisateur: $e');
        
        // Si une erreur se produit, créer un modèle par défaut
        return UserModel(
          id: userId,
          email: email,
          userType: 'client', // Type par défaut
          createdAt: DateTime.now(),
        );
      }
  } catch (e) {
    print('Erreur globale de connexion: $e');
    
    if (e.toString().contains('email_not_confirmed')) {
      throw Exception('Veuillez confirmer votre email avant de vous connecter. Vérifiez votre boîte de réception.');
    } else if (e.toString().contains('invalid_credentials')) {
      throw Exception('Email ou mot de passe incorrect');
    } else {
      throw Exception('Échec de connexion: $e');
    }
  }
}

// Méthode pour renvoyer l'email de confirmation
Future<void> resendConfirmationEmail(String email) async {
  try {
    await _supabaseClient.auth.resend(
      email: email,
      type: OtpType.signup,
    );
    print('Email de confirmation renvoyé à $email');
  } catch (e) {
    print('Erreur lors du renvoi de l\'email de confirmation: $e');
    throw Exception('Impossible de renvoyer l\'email de confirmation: $e');
  }
}
  // Se déconnecter
  Future<void> signOut() async {
    try {
      await _supabaseClient.auth.signOut();
      print('Déconnexion réussie');
    } catch (e) {
      print('Erreur lors de la déconnexion: $e');
      throw Exception('Logout failed: $e');
    }
  }

  // Récupérer l'utilisateur courant
  Future<UserModel?> getCurrentUser() async {
    try {
      final user = _supabaseClient.auth.currentUser;
      if (user == null) {
        return null;
      }

      final response = await _supabaseClient
          .from('users')
          .select()
          .eq('id', user.id)
          .maybeSingle();
      
      if (response == null) {
        return null;
      }
      
      return UserModel.fromJson(response);
    } catch (e) {
      print('Erreur lors de la récupération de l\'utilisateur courant: $e');
      return null;
    }
  }

  // Mettre à jour le type d'utilisateur
  Future<void> updateUserType(String userId, String userType) async {
    try {
      await _supabaseClient.from('users').update({
        'user_type': userType,
        'updated_at': DateTime.now().toIso8601String(),
      }).eq('id', userId);
      
      print('Type d\'utilisateur mis à jour avec succès');
    } catch (e) {
      print('Erreur lors de la mise à jour du type d\'utilisateur: $e');
      throw Exception('Failed to update user type: $e');
    }
  }
}