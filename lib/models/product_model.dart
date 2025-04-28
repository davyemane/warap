// Fichier models/product_model.dart
class ProductModel {
  final String id;
  final String businessId;
  final String name;
  final String description;
  final double price;
  final String category;
  final String imageUrl;
  final bool isAvailable;
  final int stockQuantity;
  final List<String>? options;
  final DateTime createdAt;
  final DateTime updatedAt;

  ProductModel({
    required this.id,
    required this.businessId,
    required this.name,
    required this.description,
    required this.price,
    required this.category,
    this.imageUrl = '',
    this.isAvailable = true,
    this.stockQuantity = 0,
    this.options,
    required this.createdAt,
    required this.updatedAt,
  });

  // Factory pour créer à partir de JSON
  factory ProductModel.fromJson(Map<String, dynamic> json) {
    return ProductModel(
      id: json['id'],
      businessId: json['business_id'],
      name: json['name'],
      description: json['description'],
      price: (json['price'] is int) 
          ? (json['price'] as int).toDouble() 
          : json['price'].toDouble(),
      category: json['category'],
      imageUrl: json['image_url'] ?? '',
      isAvailable: json['is_available'] ?? true,
      stockQuantity: json['stock_quantity'] ?? 0,
      options: json['options'] != null 
          ? List<String>.from(json['options']) 
          : null,
      createdAt: json['created_at'] != null 
          ? DateTime.parse(json['created_at']) 
          : DateTime.now(),
      updatedAt: json['updated_at'] != null 
          ? DateTime.parse(json['updated_at']) 
          : DateTime.now(),
    );
  }

  // Convertir en JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'business_id': businessId,
      'name': name,
      'description': description,
      'price': price,
      'category': category,
      'image_url': imageUrl,
      'is_available': isAvailable,
      'stock_quantity': stockQuantity,
      'options': options,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  // Créer une copie avec des valeurs modifiées
  ProductModel copyWith({
    String? id,
    String? businessId,
    String? name,
    String? description,
    double? price,
    String? category,
    String? imageUrl,
    bool? isAvailable,
    int? stockQuantity,
    List<String>? options,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ProductModel(
      id: id ?? this.id,
      businessId: businessId ?? this.businessId,
      name: name ?? this.name,
      description: description ?? this.description,
      price: price ?? this.price,
      category: category ?? this.category,
      imageUrl: imageUrl ?? this.imageUrl,
      isAvailable: isAvailable ?? this.isAvailable,
      stockQuantity: stockQuantity ?? this.stockQuantity,
      options: options ?? this.options,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}