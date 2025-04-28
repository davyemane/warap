// Fichier models/cart_item_model.dart
class CartItemModel {
  final String id;
  final String productId;
  final String businessId;
  final String name;
  final double price;
  final int quantity;
  final String imageUrl;
  final Map<String, dynamic>? options;

  CartItemModel({
    required this.id,
    required this.productId,
    required this.businessId,
    required this.name,
    required this.price,
    required this.quantity,
    this.imageUrl = '',
    this.options,
  });

  // Prix total de l'article - implémenté comme méthode plutôt que getter pour éviter des problèmes de null safety
  double calculateTotalPrice() {
    return price * quantity;
  }

  // Factory pour créer à partir de JSON
  factory CartItemModel.fromJson(Map<String, dynamic> json) {
    return CartItemModel(
      id: json['id'] ?? '',
      productId: json['product_id'],
      businessId: json['business_id'],
      name: json['name'],
      price: (json['price'] is int) 
          ? (json['price'] as int).toDouble() 
          : json['price'].toDouble(),
      quantity: json['quantity'],
      imageUrl: json['image_url'] ?? '',
      options: json['options'],
    );
  }

  // Convertir en JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'product_id': productId,
      'business_id': businessId,
      'name': name,
      'price': price,
      'quantity': quantity,
      'image_url': imageUrl,
      'options': options,
    };
  }

  // Créer une copie avec des valeurs modifiées
  CartItemModel copyWith({
    String? id,
    String? productId,
    String? businessId,
    String? name,
    double? price,
    int? quantity,
    String? imageUrl,
    Map<String, dynamic>? options,
  }) {
    return CartItemModel(
      id: id ?? this.id,
      productId: productId ?? this.productId,
      businessId: businessId ?? this.businessId,
      name: name ?? this.name,
      price: price ?? this.price,
      quantity: quantity ?? this.quantity,
      imageUrl: imageUrl ?? this.imageUrl,
      options: options ?? this.options,
    );
  }
}