// Fichier screens/client/product_detail_screen.dart
import 'package:flutter/material.dart';
import '../../models/product_model.dart';
import '../../models/cart_item_model.dart';
import '../../services/cart_service.dart';
import '../../services/error_handler.dart';
import '../../l10n/translations.dart';
import '../../widgets/common/custom_app_bar.dart';

class ProductDetailScreen extends StatefulWidget {
  final ProductModel product;
  
  const ProductDetailScreen({Key? key, required this.product}) : super(key: key);

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  final CartService _cartService = CartService();
  int _quantity = 1;
  bool _isAddingToCart = false;
  
  Future<void> _addToCart() async {
    setState(() {
      _isAddingToCart = true;
    });
    
    try {
      final cartItem = CartItemModel(
        id: '', // Sera généré par le service
        productId: widget.product.id,
        businessId: widget.product.businessId,
        name: widget.product.name,
        price: widget.product.price,
        quantity: _quantity,
        imageUrl: widget.product.imageUrl,
      );
      
      await _cartService.addToCart(cartItem);
      
      setState(() {
        _isAddingToCart = false;
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppTranslations.text(context, 'added_to_cart')),
            action: SnackBarAction(
              label: AppTranslations.text(context, 'view_cart'),
              onPressed: () {
                Navigator.pushNamed(context, '/cart');
              },
            ),
          ),
        );
      }
    } catch (e) {
      setState(() {
        _isAddingToCart = false;
      });
      
      if (mounted) {
        ErrorHandler.showErrorSnackBar(
          context, 
          e,
          fallbackMessage: AppTranslations.text(context, 'error_adding_to_cart'),
          onRetry: _addToCart,
        );
      }
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: widget.product.name,
        showBackButton: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.shopping_cart),
            onPressed: () {
              Navigator.pushNamed(context, '/cart');
            },
            tooltip: AppTranslations.text(context, 'cart'),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image du produit
            SizedBox(
              width: double.infinity,
              height: 250,
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
                              size: 80,
                              color: Colors.grey,
                            ),
                          );
                        },
                      )
                    : Container(
                        color: Colors.grey[200],
                        child: const Icon(
                          Icons.image,
                          size: 80,
                          color: Colors.grey,
                        ),
                      ),
              ),
            ),
            
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Nom et prix
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          widget.product.name,
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Theme.of(context).primaryColor,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          '${widget.product.price.toStringAsFixed(2)} €',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                  
                  // Catégorie
                  Container(
                    margin: const EdgeInsets.symmetric(vertical: 12),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      widget.product.category,
                      style: TextStyle(
                        color: Colors.grey[700],
                      ),
                    ),
                  ),
                  
                  const Divider(),
                  
                  // Description
                  Text(
                    AppTranslations.text(context, 'description'),
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    widget.product.description,
                    style: const TextStyle(fontSize: 16),
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Quantité
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.remove_circle_outline),
                        onPressed: _quantity > 1
                            ? () {
                                setState(() {
                                  _quantity--;
                                });
                              }
                            : null,
                        color: Theme.of(context).primaryColor,
                        iconSize: 32,
                      ),
                      Container(
                        margin: const EdgeInsets.symmetric(horizontal: 16),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          _quantity.toString(),
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.add_circle_outline),
                        onPressed: () {
                          setState(() {
                            _quantity++;
                          });
                        },
                        color: Theme.of(context).primaryColor,
                        iconSize: 32,
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Prix total
                  Center(
                    child: Text(
                      '${AppTranslations.text(context, 'total')}: ${(widget.product.price * _quantity).toStringAsFixed(2)} €',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              offset: const Offset(0, -4),
              blurRadius: 8,
            ),
          ],
        ),
        child: ElevatedButton.icon(
          onPressed: _isAddingToCart ? null : _addToCart,
          icon: _isAddingToCart
              ? Container(
                  width: 24,
                  height: 24,
                  padding: const EdgeInsets.all(2.0),
                  child: const CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 3,
                  ),
                )
              : const Icon(Icons.shopping_cart),
          label: Text(
            AppTranslations.text(context, 'add_to_cart'),
            style: const TextStyle(fontSize: 16),
          ),
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
      ),
    );
  }
}