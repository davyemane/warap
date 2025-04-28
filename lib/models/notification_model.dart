// Fichier models/notification_model.dart
class NotificationModel {
  final String id;
  final String userId;
  final String title;
  final String message;
  final String type; // order, request, system
  final String? imageUrl;
  final String? relatedId;
  final bool read;
  final DateTime createdAt;

  NotificationModel({
    required this.id,
    required this.userId,
    required this.title,
    required this.message,
    required this.type,
    this.imageUrl,
    this.relatedId,
    required this.read,
    required this.createdAt,
  });

  // Factory pour créer à partir de JSON
  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['id'],
      userId: json['user_id'],
      title: json['title'],
      message: json['message'],
      type: json['type'],
      imageUrl: json['image_url'],
      relatedId: json['related_id'],
      read: json['read'] ?? false,
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  // Convertir en JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'title': title,
      'message': message,
      'type': type,
      'image_url': imageUrl,
      'related_id': relatedId,
      'read': read,
      'created_at': createdAt.toIso8601String(),
    };
  }
}