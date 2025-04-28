// Fichier services/cart_service.dart
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/cart_item_model.dart';
import '../models/product_model.dart';
import 'auth_service.dart';

class CartService {
  final SupabaseClient _supabase = Supabase.instance.client;
  final AuthService _authService = AuthService();
  
  // Clé pour le stockage local (pour garder le panier en mémoire)
  static const String _cartKey = 'user_cart';
  
  // Récupérer le panier de l'utilisateur
  Future<List<CartItemModel>> getCart() async {
    try {
      final currentUser = await _authService.getCurrentUser();
      if (currentUser == null) {
        throw Exception('Utilisateur non connecté');
      }
      
      // Vérifie si nous avons des articles en BD
      final List<dynamic> response = await _supabase
          .from('cart_items')
          .select()
          .eq('user_id', currentUser.id);
      
      List<CartItemModel> cartItems = [];
      
      for (var item in response) {
        cartItems.add(CartItemModel.fromJson(item));
      }
      
      return cartItems;
    } catch (e) {
      print('Erreur de récupération du panier: $e');
      // En cas d'erreur, retourner un panier vide plutôt que de planter l'app
      return [];
    }
  }
  
  // Ajouter un article au panier
  Future<void> addToCart(CartItemModel item) async {
    try {
      final currentUser = await _authService.getCurrentUser();
      if (currentUser == null) {
        throw Exception('Utilisateur non connecté.');
      }

      // Vérifier si l'article existe déjà dans le panier
      final existingItems = await _supabase
          .from('cart_items')
          .select()
          .eq('user_id', currentUser.id)
          .eq('product_id', item.productId);

      if (existingItems.isNotEmpty) {
        // Mise à jour de la quantité de l'article existant
        final existingItem = existingItems.first;
        final newQuantity = (existingItem['quantity'] as int) + item.quantity;

        await _supabase
            .from('cart_items')
            .update({'quantity': newQuantity})
            .eq('id', existingItem['id']);
            
        print('Quantité mise à jour avec succès: $newQuantity');
      } else {
        // Ajout d'un nouvel article
        final itemData = item.toJson()
          ..remove('id') // ID généré par la base
          ..['user_id'] = currentUser.id;

        await _supabase
            .from('cart_items')
            .insert(itemData);
            
        print('Nouvel article ajouté au panier');
      }
    } catch (e) {
      print('Erreur lors de l\'ajout au panier: $e');
      throw Exception('Erreur lors de l\'ajout au panier.');
    }
  }
  
  // Ajouter rapidement un produit au panier
  Future<void> addToCartQuick(ProductModel product) async {
    try {
      final currentUser = await _authService.getCurrentUser();
      if (currentUser == null) {
        print('Erreur: Utilisateur non connecté.');
        throw Exception('Utilisateur non connecté.');
      }

      // Vérifier que le produit contient bien toutes les données nécessaires
      if (product.id.isEmpty || product.businessId.isEmpty) {
        print('Erreur: Produit invalide (id: ${product.id}, businessId: ${product.businessId})');
        throw Exception('Produit invalide ou incomplet.');
      }

      print('Ajout au panier - Produit: ${product.name}, ID: ${product.id}, Prix: ${product.price}');

      // Créer un élément de panier à partir du produit
      final cartItem = CartItemModel(
        id: '', // ID généré par la base de données
        productId: product.id,
        businessId: product.businessId,
        name: product.name,
        price: product.price,
        quantity: 1, // Quantité par défaut
        imageUrl: product.imageUrl,
      );

      // Vérifier si le panier contient déjà des articles d'un autre commerce
      final String? currentBusinessId = await getCurrentBusinessId();
      if (currentBusinessId != null && currentBusinessId != product.businessId) {
        print('Erreur: Tentative d\'ajouter un produit d\'un autre commerce (actuel: $currentBusinessId, nouveau: ${product.businessId})');
        
        // Demander confirmation avant de vider le panier
        throw Exception('Votre panier contient déjà des articles d\'un autre commerce. Voulez-vous vider votre panier?');
      }

      // Ajouter au panier
      await addToCart(cartItem);
      print('Produit ajouté au panier avec succès.');
    } catch (e) {
      print('Erreur lors de l\'ajout au panier: $e');
      throw Exception('$e');
    }
  }

  // Ajouter une méthode pour vider et remplacer le panier
  Future<void> clearAndAddProduct(ProductModel product) async {
    try {
      print('Vidage du panier et ajout du nouveau produit');
      
      // Vider le panier
      await clearCart();
      
      // Ajouter le nouveau produit
      await addToCartQuick(product);
    } catch (e) {
      print('Erreur lors du vidage et de l\'ajout au panier: $e');
      throw Exception('Erreur lors de la modification du panier: $e');
    }
  }
    
  // Mettre à jour la quantité d'un article
  Future<void> updateCartItemQuantity(String itemId, int quantity) async {
    try {
      if (quantity <= 0) {
        // Si la quantité est inférieure ou égale à 0, supprimer l'article
        await removeFromCart(itemId);
        return;
      }
      
      final currentUser = await _authService.getCurrentUser();
      if (currentUser == null) {
        throw Exception('Utilisateur non connecté');
      }
      
      await _supabase
          .from('cart_items')
          .update({'quantity': quantity})
          .eq('id', itemId)
          .eq('user_id', currentUser.id);
          
      print('Quantité mise à jour: $quantity');
    } catch (e) {
      print('Erreur lors de la mise à jour de la quantité: $e');
      throw Exception('Erreur lors de la mise à jour de la quantité: $e');
    }
  }
  
  // Supprimer un article du panier
  Future<void> removeFromCart(String itemId) async {
    try {
      final currentUser = await _authService.getCurrentUser();
      if (currentUser == null) {
        throw Exception('Utilisateur non connecté');
      }
      
      await _supabase
          .from('cart_items')
          .delete()
          .eq('id', itemId)
          .eq('user_id', currentUser.id);
          
      print('Article supprimé du panier: $itemId');
    } catch (e) {
      print('Erreur lors de la suppression de l\'article: $e');
      throw Exception('Erreur lors de la suppression de l\'article: $e');
    }
  }
  
  // Vider le panier
  Future<void> clearCart() async {
    try {
      final currentUser = await _authService.getCurrentUser();
      if (currentUser == null) {
        throw Exception('Utilisateur non connecté');
      }
      
      await _supabase
          .from('cart_items')
          .delete()
          .eq('user_id', currentUser.id);
          
      print('Panier vidé avec succès');
    } catch (e) {
      print('Erreur lors du vidage du panier: $e');
      throw Exception('Erreur lors du vidage du panier: $e');
    }
  }
  
  // Obtenir le total du panier
  Future<double> getCartTotal() async {
    try {
      final cartItems = await getCart();
      
      double total = 0;
      for (var item in cartItems) {
        total += item.calculateTotalPrice();
      }
      
      return total;
    } catch (e) {
      print('Erreur lors du calcul du total: $e');
      throw Exception('Erreur lors du calcul du total: $e');
    }
  }
  
  // Vérifier si le panier contient des articles d'un commerce différent
  Future<bool> hasItemsFromDifferentBusiness(String businessId) async {
    try {
      final cartItems = await getCart();
      
      if (cartItems.isEmpty) {
        return false;
      }
      
      return cartItems.any((item) => item.businessId != businessId);
    } catch (e) {
      print('Erreur lors de la vérification du panier: $e');
      throw Exception('Erreur lors de la vérification du panier: $e');
    }
  }
  
  // Obtenir le commerce du panier actuel
  Future<String?> getCurrentBusinessId() async {
    try {
      final cartItems = await getCart();
      
      if (cartItems.isEmpty) {
        return null;
      }
      
      return cartItems.first.businessId;
    } catch (e) {
      print('Erreur lors de la récupération du commerce: $e');
      throw Exception('Erreur lors de la récupération du commerce: $e');
    }
  }
}