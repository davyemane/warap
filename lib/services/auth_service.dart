
// Fichier services/auth_service.dart - méthodes mises à jour
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/user_model.dart';
import 'dart:typed_data'; // Ajoutez cette importation


class AuthService {
  final SupabaseClient _supabaseClient = Supabase.instance.client;

  // Vérifier si l'utilisateur est authentifié
  Future<bool> isAuthenticated() async {
    return _supabaseClient.auth.currentUser != null;
  } 
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
    
    return response['user_type'] ?? 'client'; // Valeur par défaut si null
  } catch (e) {
    print('Erreur lors de la récupération du type d\'utilisateur: $e');
    // Fallback à client par défaut en cas d'erreur
    return 'client';
  }
}
   // Méthode d'inscription qui prend maintenant en compte le nom
  Future<UserModel> signUp({
    required String email,
    required String password,
    required String userType,
    String name = '', // Paramètre optionnel pour le nom
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

      // 2. Ajouter l'utilisateur à la table users avec son type et son nom
      try {
        await _supabaseClient.from('users').insert({
          'id': userId,
          'email': email,
          'user_type': userType,
          'name': name, // Ajout du nom
          'created_at': DateTime.now().toIso8601String(),
          'updated_at': DateTime.now().toIso8601String(),
        });
        print('Données utilisateur insérées avec succès dans la table users');
      } catch (e) {
        print('Erreur d\'insertion dans users: $e');
        throw Exception('Failed to store user data: $e');
      }

      // Reste de la méthode inchangée...
      await Future.delayed(const Duration(milliseconds: 500));

      try {
        final response = await _supabaseClient
            .from('users')
            .select()
            .eq('id', userId)
            .maybeSingle();
        
        if (response == null) {
          print('Aucune donnée utilisateur trouvée après l\'insertion');
          
          return UserModel(
            id: userId,
            email: email,
            userType: userType,
            name: name, // Inclure le nom
            createdAt: DateTime.now(),
          );
        }
        
        print('Données utilisateur récupérées: $response');
        return UserModel.fromJson(response);
      } catch (e) {
        print('Erreur lors de la récupération des données: $e');
        
        return UserModel(
          id: userId,
          email: email,
          userType: userType,
          name: name, // Inclure le nom
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

    // Méthode pour mettre à jour le profil utilisateur
  Future<UserModel> updateUserProfile({
    required String userId,
    String? name,
    String? profileImageUrl,
  }) async {
    try {
      // Préparer les données à mettre à jour
      final Map<String, dynamic> updates = {
        'updated_at': DateTime.now().toIso8601String(),
      };
      
      if (name != null) {
        updates['name'] = name;
      }
      
      if (profileImageUrl != null) {
        updates['profile_image_url'] = profileImageUrl;
      }
      
      // Mettre à jour le profil
      await _supabaseClient
          .from('users')
          .update(updates)
          .eq('id', userId);
      
      // Récupérer le profil mis à jour
      final response = await _supabaseClient
          .from('users')
          .select()
          .eq('id', userId)
          .maybeSingle();
      
      if (response == null) {
        throw Exception('User not found after update');
      }
      
      return UserModel.fromJson(response);
    } catch (e) {
      print('Erreur lors de la mise à jour du profil: $e');
      throw Exception('Failed to update user profile: $e');
    }
  }

    // Méthode pour télécharger une image de profil
Future<String> uploadProfileImage(String userId, List<int> fileBytes, String fileName) async {
  try {
    // Créer un nom de fichier unique
    final extension = fileName.split('.').last;
    final storagePath = 'profile_images/$userId.$extension';
    final Uint8List bytes = Uint8List.fromList(fileBytes);

    // Télécharger le fichier
    await _supabaseClient
        .storage
        .from('profiles')
        .uploadBinary(
          storagePath,
          bytes,
          fileOptions: const FileOptions(contentType: 'image/jpeg'),
        );    
    // Obtenir l'URL publique
    final imageUrl = _supabaseClient
        .storage
        .from('profiles')
        .getPublicUrl(storagePath);
    
    return imageUrl;
  } catch (e) {
    print('Erreur lors du téléchargement de l\'image: $e');
    throw Exception('Failed to upload profile image: $e');
  }
}}