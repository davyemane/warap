// Fichier models/user_model.dart
class UserModel {
  final String id;
  final String email;
  final String userType; // 'client' ou 'vendeur'
  final String name; // Nom d'utilisateur
  final String? profileImageUrl; // URL de la photo de profil
  final DateTime createdAt;
  final DateTime? updatedAt;

  UserModel({
    required this.id,
    required this.email,
    required this.userType,
    required this.createdAt,
    this.updatedAt,
    this.name = '', // Valeur par défaut vide
    this.profileImageUrl, // Optionnel
  });

  // Créer une copie de l'utilisateur avec des modifications
  UserModel copyWith({
    String? id,
    String? email,
    String? userType,
    String? name,
    String? profileImageUrl,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UserModel(
      id: id ?? this.id,
      email: email ?? this.email,
      userType: userType ?? this.userType,
      name: name ?? this.name,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'],
      email: json['email'],
      userType: json['user_type'] ?? 'client',
      name: json['name'] ?? '', // Récupérer le nom s'il existe
      profileImageUrl: json['profile_image_url'], // Récupérer l'URL de l'image
      createdAt: json['created_at'] != null 
          ? DateTime.parse(json['created_at']) 
          : DateTime.now(),
      updatedAt: json['updated_at'] != null 
          ? DateTime.parse(json['updated_at']) 
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'user_type': userType,
      'name': name,
      'profile_image_url': profileImageUrl,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  // Obtenir les initiales de l'utilisateur pour l'avatar
  String get initials {
    if (name.isEmpty) {
      return email.isNotEmpty ? email[0].toUpperCase() : '?';
    }
    
    final nameParts = name.split(' ');
    if (nameParts.length > 1) {
      return '${nameParts[0][0]}${nameParts[1][0]}'.toUpperCase();
    }
    
    return name.isNotEmpty ? name[0].toUpperCase() : '?';
  }
  
  // Vérifier si l'utilisateur a une photo de profil
  bool get hasProfileImage {
    return profileImageUrl != null && profileImageUrl!.isNotEmpty;
  }
}