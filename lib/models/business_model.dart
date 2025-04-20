// Fichier models/business_model.dart
class BusinessModel {
  final String id;
  final String userId;
  final String name;
  final String description;
  final String businessType; // 'fixe' ou 'mobile'
  final double latitude;
  final double longitude;
  final String openingTime; // Format: "08:00"
  final String closingTime; // Format: "18:00"
  final String address;
  final String phone;
  final DateTime createdAt;

  BusinessModel({
    required this.id,
    required this.userId,
    required this.name,
    required this.description,
    required this.businessType,
    required this.latitude,
    required this.longitude,
    required this.openingTime,
    required this.closingTime,
    required this.address,
    required this.phone,
    required this.createdAt,
  });

  factory BusinessModel.fromJson(Map<String, dynamic> json) {
    return BusinessModel(
      id: json['id'],
      userId: json['user_id'],
      name: json['name'],
      description: json['description'] ?? '',
      businessType: json['business_type'],
      latitude: json['latitude'].toDouble(),
      longitude: json['longitude'].toDouble(),
      openingTime: json['opening_time'] ?? '08:00',
      closingTime: json['closing_time'] ?? '18:00',
      address: json['address'] ?? '',
      phone: json['phone'] ?? '',
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'name': name,
      'description': description,
      'business_type': businessType,
      'latitude': latitude,
      'longitude': longitude,
      'opening_time': openingTime,
      'closing_time': closingTime,
      'address': address,
      'phone': phone,
      'created_at': createdAt.toIso8601String(),
    };
  }

  // Vérifier si le commerce est ouvert actuellement
  bool isOpenNow() {
    final now = DateTime.now();
    final currentTime = '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';
    
    return currentTime.compareTo(openingTime) >= 0 && 
           currentTime.compareTo(closingTime) <= 0;
  }
}