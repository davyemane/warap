import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:image_picker/image_picker.dart';
import '../models/product_model.dart';
import 'auth_service.dart';
import 'image_service.dart';

class ProductService {
  final SupabaseClient _supabase = Supabase.instance.client;
  final AuthService _authService = AuthService();
  final ImageService _imageService = ImageService();

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
      final response = await _supabase
          .from('products')
          .select('category')
          .eq('business_id', businessId)
          .neq('category', '');

      final Set<String> uniqueCategories = {};
      for (final item in response as List) {
        if (item['category'] != null && item['category'].isNotEmpty) {
          uniqueCategories.add(item['category']);
        }
      }

      if (uniqueCategories.isEmpty) {
        return ['Entrées', 'Plats', 'Desserts', 'Boissons'];
      }

      return uniqueCategories.toList();
    } catch (e) {
      print('Erreur lors du chargement des catégories: $e');
      return ['Entrées', 'Plats', 'Desserts', 'Boissons'];
    }
  }

  // Ajouter un nouveau produit AVEC image
  Future<void> addProduct(ProductModel product, {XFile? imageFile}) async {
    try {
      // D'abord insérer le produit pour obtenir l'ID généré
      final response = await _supabase
          .from('products')
          .insert({
            'business_id': product.businessId,
            'name': product.name,
            'description': product.description,
            'price': product.price,
            'category': product.category,
            'image_url': '', // Temporairement vide
            'is_available': product.isAvailable,
            'stock_quantity': product.stockQuantity,
            'created_at': DateTime.now().toIso8601String(),
            'updated_at': DateTime.now().toIso8601String(),
          })
          .select()
          .single();

      final productId = response['id'];
      String imageUrl = '';

      // Si une image est fournie, l'uploader et mettre à jour le produit
      if (imageFile != null) {
        imageUrl = await _imageService.uploadProductImage(imageFile, productId);

        // Mettre à jour le produit avec l'URL de l'image
        await _supabase
            .from('products')
            .update({'image_url': imageUrl}).eq('id', productId);
      }

      print('Produit ajouté avec succès: ${product.name}');
    } catch (e) {
      print('Erreur lors de l\'ajout du produit: $e');
      throw Exception('Erreur lors de l\'ajout du produit: $e');
    }
  }

  // Mettre à jour un produit AVEC gestion d'image
  Future<void> updateProduct(ProductModel product,
      {XFile? newImageFile, bool deleteOldImage = false}) async {
    try {
      String imageUrl = product.imageUrl;

      // Si une nouvelle image est fournie
      if (newImageFile != null) {
        // Supprimer l'ancienne image si elle existe
        if (product.imageUrl.isNotEmpty) {
          await _imageService.deleteProductImage(product.imageUrl);
        }

        // Upload de la nouvelle image
        imageUrl =
            await _imageService.uploadProductImage(newImageFile, product.id);
      } else if (deleteOldImage && product.imageUrl.isNotEmpty) {
        // Supprimer l'image sans la remplacer
        await _imageService.deleteProductImage(product.imageUrl);
        imageUrl = '';
      }

      // Mettre à jour le produit
      await _supabase.from('products').update({
        'name': product.name,
        'description': product.description,
        'price': product.price,
        'category': product.category,
        'image_url': imageUrl,
        'is_available': product.isAvailable,
        'stock_quantity': product.stockQuantity,
        'updated_at': DateTime.now().toIso8601String(),
      }).eq('id', product.id);

      print('Produit mis à jour avec succès: ${product.name}');
    } catch (e) {
      print('Erreur lors de la mise à jour du produit: $e');
      throw Exception('Erreur lors de la mise à jour du produit: $e');
    }
  }

  // Supprimer un produit AVEC suppression de l'image
  Future<void> deleteProduct(String productId) async {
    try {
      // D'abord récupérer l'URL de l'image pour la supprimer
      final response = await _supabase
          .from('products')
          .select('image_url')
          .eq('id', productId)
          .single();

      final imageUrl = response['image_url'] as String?;

      // Supprimer l'image du storage si elle existe
      if (imageUrl != null && imageUrl.isNotEmpty) {
        await _imageService.deleteProductImage(imageUrl);
      }

      // Supprimer le produit de la base de données
      await _supabase.from('products').delete().eq('id', productId);

      print('Produit supprimé avec succès');
    } catch (e) {
      print('Erreur lors de la suppression du produit: $e');
      throw Exception('Erreur lors de la suppression du produit: $e');
    }
  }
}
