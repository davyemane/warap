// Fichier widgets/client/product_card.dart
import 'package:flutter/material.dart';
import '../../models/product_model.dart';
import '../../models/business_model.dart';
import '../../services/cart_service.dart';
import '../../services/error_handler.dart';
import '../../l10n/translations.dart';
import '../../screens/client/product_detail_screen.dart';
import '../../screens/client/cart_screen.dart';

class ProductCard extends StatefulWidget {
  final ProductModel product;
  final BusinessModel business;
  final VoidCallback? onAddedToCart;
  final VoidCallback onTap;
  
  const ProductCard({
    super.key,
    required this.product,
    required this.business,
    this.onAddedToCart,
    required this.onTap,
  });
  
  @override
  State<ProductCard> createState() => _ProductCardState();
}
class _ProductCardState extends State<ProductCard> {
  final CartService _cartService = CartService();
  bool _isAddingToCart = false;

  Future<void> _addToCart() async {
    if (_isAddingToCart) return; // Éviter les clics multiples
    
    try {
      setState(() {
        _isAddingToCart = true;
      });
      
      // Vérifier si le commerce est ouvert
      if (!widget.business.isOpenNow()) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Ce commerce est actuellement fermé")),
        );
        setState(() {
          _isAddingToCart = false;
        });
        return;
      }

      // Vérifier si le panier contient des produits d'un autre commerce
      final String? currentBusinessId = await _cartService.getCurrentBusinessId();
      if (currentBusinessId != null && currentBusinessId != widget.business.id) {
        // Demander confirmation à l'utilisateur
        final bool? shouldClearCart = await _showConfirmDialog();
        if (shouldClearCart != true) {
          setState(() {
            _isAddingToCart = false;
          });
          return;
        }
        
        // Vider le panier et ajouter le produit
        await _cartService.clearAndAddProduct(widget.product);
      } else {
        // Ajouter normalement
        await _cartService.addToCartQuick(widget.product);
      }
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text("Produit ajouté au panier"),
            action: SnackBarAction(
              label: "Voir le panier",
              onPressed: () {
                Navigator.push(
                  context, 
                  MaterialPageRoute(builder: (context) => const CartScreen())
                );
              },
            ),
          ),
        );
      }
      
      if (widget.onAddedToCart != null) {
        widget.onAddedToCart!();
      }
    } catch (e) {
      if (mounted) {
        String errorMessage = e.toString();
        if (errorMessage.contains("Votre panier contient déjà des articles")) {
          // Gérer le cas spécifique
          _showConfirmDialog();
        } else {
          ErrorHandler.showErrorSnackBar(
            context, 
            e,
            fallbackMessage: "Impossible d'ajouter au panier",
          );
        }
      }
    } finally {
      if (mounted) {
        setState(() {
          _isAddingToCart = false;
        });
      }
    }
  }

  Future<bool?> _showConfirmDialog() {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Vider le panier?"),
        content: const Text(
          "Votre panier contient des articles d'un autre commerce. Voulez-vous vider votre panier et ajouter ce produit?"
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Annuler"),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text("Vider et ajouter"),
          ),
        ],
      ),
    );
  }

  void _viewProductDetails() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ProductDetailScreen(product: widget.product),
      ),
    ).then((_) {
      if (widget.onAddedToCart != null) {
        widget.onAddedToCart!();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      elevation: 3,
      child: InkWell(
        onTap: _viewProductDetails,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image du produit
            Stack(
              children: [
                SizedBox(
                  height: 120,
                  width: double.infinity,
                  child: Hero(
                    tag: 'product-${widget.product.id}',
                    child: widget.product.imageUrl.isNotEmpty
                        ? Image.network(
                            widget.product.imageUrl,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                color: Colors.grey[200],
                                child: const Icon(
                                  Icons.image_not_supported,
                                  size: 40,
                                  color: Colors.grey,
                                ),
                              );
                            },
                          )
                        : Container(
                            color: Colors.grey[200],
                            child: const Icon(
                              Icons.image,
                              size: 40,
                              color: Colors.grey,
                            ),
                          ),
                  ),
                ),
                // Indicateur ouvert/fermé
                Positioned(
                  top: 8,
                  right: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: widget.business.isOpenNow() ? Colors.green : Colors.red,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      widget.business.isOpenNow() ? "Ouvert" : "Fermé",
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 10,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Nom du produit
                  Text(
                    widget.product.name,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  
                  // Prix
                  Text(
                    '${widget.product.price.toStringAsFixed(2)} €',
                    style: TextStyle(
                      color: Theme.of(context).primaryColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  
                  const SizedBox(height: 12),
                  
                  // Bouton d'ajout au panier
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: widget.business.isOpenNow() ? (_isAddingToCart ? null : _addToCart) : null,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        textStyle: const TextStyle(fontSize: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: _isAddingToCart
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            )
                          : const Text("Ajouter"),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}