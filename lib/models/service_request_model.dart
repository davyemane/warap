// Fichier models/service_request_model.dart
class ServiceRequestModel {
  final String id;
  final String businessId;
  final String clientId;
  final String description;
  final double latitude;
  final double longitude;
  final String address;
  final DateTime requestDate;
  final DateTime preferredDate;
  final String status; // pending, accepted, completed, cancelled

  ServiceRequestModel({
    required this.id,
    required this.businessId,
    required this.clientId,
    required this.description,
    required this.latitude,
    required this.longitude,
    required this.address,
    required this.requestDate,
    required this.preferredDate,
    required this.status,
  });

  // Factory pour créer à partir de JSON
  factory ServiceRequestModel.fromJson(Map<String, dynamic> json) {
    return ServiceRequestModel(
      id: json['id'],
      businessId: json['business_id'],
      clientId: json['client_id'],
      description: json['description'],
      latitude: json['latitude'].toDouble(),
      longitude: json['longitude'].toDouble(),
      address: json['address'],
      requestDate: DateTime.parse(json['request_date']),
      preferredDate: DateTime.parse(json['preferred_date']),
      status: json['status'],
    );
  }

  // Convertir en JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'business_id': businessId,
      'client_id': clientId,
      'description': description,
      'latitude': latitude,
      'longitude': longitude,
      'address': address,
      'request_date': requestDate.toIso8601String(),
      'preferred_date': preferredDate.toIso8601String(),
      'status': status,
    };
  }
}