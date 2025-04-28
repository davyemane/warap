// services/product_service.dart
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/product_model.dart';
import 'auth_service.dart';
import 'error_handler.dart';

class ProductService {
  final SupabaseClient _supabase = Supabase.instance.client;
  final AuthService _authService = AuthService();

  // Obtenir les produits d'un commerce
  Future<List<ProductModel>> getBusinessProducts(String businessId) async {
    try {
      final response = await _supabase
          .from('products')
          .select()
          .eq('business_id', businessId)
          .order('name');

      return (response as List)
          .map((item) => ProductModel.fromJson(item))
          .toList();
    } catch (e) {
      print('Erreur lors du chargement des produits: $e');
      throw Exception('Erreur lors du chargement des produits: $e');
    }
  }

  // Récupérer toutes les catégories d'un commerce
  Future<List<String>> getBusinessCategories(String businessId) async {
    try {
      // Récupérer les catégories uniques depuis Supabase
      final response = await _supabase
          .from('products')
          .select('category')
          .eq('business_id', businessId)
          .neq('category', '');

      // Extraire les catégories uniques
      final Set<String> uniqueCategories = {};
      for (final item in response as List) {
        if (item['category'] != null && item['category'].isNotEmpty) {
          uniqueCategories.add(item['category']);
        }
      }

      if (uniqueCategories.isEmpty) {
        return ['Entrées', 'Plats', 'Desserts', 'Boissons']; // Catégories par défaut
      }

      return uniqueCategories.toList();
    } catch (e) {
      print('Erreur lors du chargement des catégories: $e');
      // En cas d'erreur, retourner une liste de catégories par défaut
      return ['Entrées', 'Plats', 'Desserts', 'Boissons'];
    }
  }

  // Ajouter un nouveau produit - CORRIGÉ pour l'erreur UUID
  Future<void> addProduct(ProductModel product) async {
    try {
      // Préparer les données du produit SANS l'ID (pour laisser Supabase générer un UUID valide)
      final productData = {
        'business_id': product.businessId,
        'name': product.name,
        'description': product.description,
        'price': product.price,
        'category': product.category,
        'image_url': product.imageUrl,
        'is_available': product.isAvailable,
        'stock_quantity': product.stockQuantity,
        'created_at': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      };
      
      // N'envoyez PAS l'ID - Supabase en générera un automatiquement
      await _supabase.from('products').insert(productData);
      
      print('Produit ajouté avec succès: ${product.name}');
    } catch (e) {
      print('Erreur lors de l\'ajout du produit: $e');
      throw Exception('Erreur lors de l\'ajout du produit: $e');
    }
  }

  // Mettre à jour un produit
  Future<void> updateProduct(ProductModel product) async {
    try {
      await _supabase
          .from('products')
          .update({
            'name': product.name,
            'description': product.description,
            'price': product.price,
            'category': product.category,
            'image_url': product.imageUrl,
            'is_available': product.isAvailable,
            'stock_quantity': product.stockQuantity,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', product.id);
          
      print('Produit mis à jour avec succès: ${product.name}');
    } catch (e) {
      print('Erreur lors de la mise à jour du produit: $e');
      throw Exception('Erreur lors de la mise à jour du produit: $e');
    }
  }

  // Supprimer un produit
  Future<void> deleteProduct(String productId) async {
    try {
      await _supabase
          .from('products')
          .delete()
          .eq('id', productId);
          
      print('Produit supprimé avec succès');
    } catch (e) {
      print('Erreur lors de la suppression du produit: $e');
      throw Exception('Erreur lors de la suppression du produit: $e');
    }
  }
}