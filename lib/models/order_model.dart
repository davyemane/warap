// Fichier models/order_model.dart
import 'package:warap/models/cart_item_model.dart' show CartItemModel;

class OrderModel {
  final String id;
  final String clientId;
  final String businessId;
  final String orderNumber;
  final List<CartItemModel> items;
  final double subtotal;
  final double tax;
  final double total;
  final DateTime orderDate;
  final String status; // pending, processing, completed, cancelled
  final String deliveryAddress;
  final String paymentMethod;

  OrderModel({
    required this.id,
    required this.clientId,
    required this.businessId,
    required this.orderNumber,
    required this.items,
    required this.subtotal,
    required this.tax,
    required this.total,
    required this.orderDate,
    required this.status,
    required this.deliveryAddress,
    required this.paymentMethod,
  });

  // Factory pour créer à partir de JSON
  factory OrderModel.fromJson(Map<String, dynamic> json) {
    return OrderModel(
      id: json['id'],
      clientId: json['client_id'],
      businessId: json['business_id'],
      orderNumber: json['order_number'],
      items: (json['items'] as List)
          .map((item) => CartItemModel.fromJson(item))
          .toList(),
      subtotal: json['subtotal'].toDouble(),
      tax: json['tax'].toDouble(),
      total: json['total'].toDouble(),
      orderDate: DateTime.parse(json['order_date']),
      status: json['status'],
      deliveryAddress: json['delivery_address'],
      paymentMethod: json['payment_method'],
    );
  }

  // Convertir en JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'client_id': clientId,
      'business_id': businessId,
      'order_number': orderNumber,
      'items': items.map((item) => item.toJson()).toList(),
      'subtotal': subtotal,
      'tax': tax,
      'total': total,
      'order_date': orderDate.toIso8601String(),
      'status': status,
      'delivery_address': deliveryAddress,
      'payment_method': paymentMethod,
    };
  }
}