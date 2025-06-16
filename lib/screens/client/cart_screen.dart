// Fichier screens/client/cart_screen.dart
import 'package:flutter/material.dart';
import '../../models/cart_item_model.dart';
import '../../models/business_model.dart';
import '../../services/cart_service.dart';
import '../../services/business_service.dart';
import '../../services/error_handler.dart';
import '../../l10n/translations.dart';
import '../../widgets/common/custom_app_bar.dart';
import '../../widgets/common/loading_indicator.dart';
import 'checkout_screen.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  final CartService _cartService = CartService();
  final BusinessService _businessService = BusinessService();
  
  List<CartItemModel> _cartItems = [];
  BusinessModel? _business;
  bool _isLoading = true;
  double _cartTotal = 0.0;
  
  @override
  void initState() {
    super.initState();
    _loadCart();
  }
  
  Future<void> _loadCart() async {
    setState(() {
      _isLoading = true;
    });
    
    try {
      final cartItems = await _cartService.getCart();
      final cartTotal = await _cartService.getCartTotal();
      
      setState(() {
        _cartItems = cartItems;
        _cartTotal = cartTotal;
      });
      
      if (cartItems.isNotEmpty) {
        await _loadBusinessInfo(cartItems.first.businessId);
      } else {
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      
      if (mounted) {
        ErrorHandler.showErrorSnackBar(
          context, 
          e,
          fallbackMessage: AppTranslations.text(context, 'error_loading_cart'),
          onRetry: _loadCart,
        );
      }
    }
  }
  
  Future<void> _loadBusinessInfo(String businessId) async {
    try {
      final business = await _businessService.getBusinessById(businessId);
      
      setState(() {
        _business = business;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      
      if (mounted) {
        ErrorHandler.showErrorSnackBar(
          context, 
          e,
          fallbackMessage: AppTranslations.text(context, 'error_loading_business_info'),
        );
      }
    }
  }
  
  Future<void> _updateItemQuantity(CartItemModel item, int newQuantity) async {
    if (newQuantity < 1) {
      return;
    }
    
    try {
      setState(() {
        _isLoading = true;
      });
      
      await _cartService.updateCartItemQuantity(item.id, newQuantity);
      await _loadCart();
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      
      if (mounted) {
        ErrorHandler.showErrorSnackBar(
          context, 
          e,
          fallbackMessage: AppTranslations.text(context, 'error_updating_quantity'),
        );
      }
    }
  }
  
  Future<void> _removeItem(CartItemModel item) async {
    try {
      setState(() {
        _isLoading = true;
      });
      
      await _cartService.removeFromCart(item.id);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text("Article supprimé du panier"),
            action: SnackBarAction(
              label: "Annuler",
              onPressed: () async {
                await _cartService.addToCart(item);
                await _loadCart();
              },
            ),
          ),
        );
      }
      
      await _loadCart();
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      
      if (mounted) {
        ErrorHandler.showErrorSnackBar(
          context, 
          e,
          fallbackMessage: AppTranslations.text(context, 'error_removing_item'),
        );
      }
    }
  }
  
  Future<void> _clearCart() async {
    // Confirmer avant de vider le panier
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Vider le panier"),
        content: const Text("Êtes-vous sûr de vouloir vider votre panier ?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text("Annuler"),
          ),
          TextButton(
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text("Vider"),
          ),
        ],
      ),
    );
    
    if (confirm != true) return;
    
    try {
      setState(() {
        _isLoading = true;
      });
      
      await _cartService.clearCart();
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Panier vidé")),
        );
      }
      
      await _loadCart();
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      
      if (mounted) {
        ErrorHandler.showErrorSnackBar(
          context, 
          e,
          fallbackMessage: AppTranslations.text(context, 'error_clearing_cart'),
        );
      }
    }
  }
  
  void _proceedToCheckout() {
    if (_business == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Impossible de traiter la commande")),
      );
      return;
    }
    
    if (!_business!.isOpenNow()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Ce commerce est actuellement fermé")),
      );
      return;
    }
    
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CheckoutScreen(
          cartItems: _cartItems,
          business: _business!,
        ),
      ),
    ).then((_) => _loadCart());
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: "Panier",
        showBackButton: true,
        actions: [
          if (_cartItems.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.delete_outline),
              onPressed: _clearCart,
              tooltip: "Vider le panier",
            ),
        ],
      ),
      body: _isLoading
          ? Center(
              child: LoadingIndicator(
                message: "Chargement du panier...",
                animationType: AnimationType.bounce,
                color: Theme.of(context).primaryColor,
              ),
            )
          : _cartItems.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.shopping_cart_outlined,
                        size: 80,
                        color: Colors.grey[400],
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        "Votre panier est vide",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 32),
                        child: Text(
                          "Ajoutez des articles à votre panier pour commander",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.grey[600],
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton.icon(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.shopping_bag),
                        label: const Text("Continuer vos achats"),
                      ),
                    ],
                  ),
                )
              : Column(
                  children: [
                    // Informations sur le commerce
                    if (_business != null)
                      Container(
                        padding: const EdgeInsets.all(16),
                        color: Colors.grey[100],
                        child: Row(
                          children: [
                            CircleAvatar(
                              backgroundColor: _business!.businessType == 'fixe'
                                  ? Colors.blue
                                  : Colors.green,
                              radius: 20,
                              child: Icon(
                                _business!.businessType == 'fixe'
                                    ? Icons.store
                                    : Icons.delivery_dining,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    _business!.name,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                  Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                        decoration: BoxDecoration(
                                          color: _business!.isOpenNow() ? Colors.green : Colors.red,
                                          borderRadius: BorderRadius.circular(10),
                                        ),
                                        child: Text(
                                          _business!.isOpenNow() ? "Ouvert" : "Fermé",
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 12,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        "${_business!.openingTime} - ${_business!.closingTime}",
                                        style: TextStyle(
                                          color: Colors.grey[700],
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    
                    // Liste des articles
                    Expanded(
                      child: ListView.builder(
                        itemCount: _cartItems.length,
                        itemBuilder: (context, index) {
                          final item = _cartItems[index];
                          return Dismissible(
                            key: Key(item.id),
                            direction: DismissDirection.endToStart,
                            background: Container(
                              color: Colors.red,
                              alignment: Alignment.centerRight,
                              padding: const EdgeInsets.only(right: 16),
                              child: const Icon(
                                Icons.delete,
                                color: Colors.white,
                              ),
                            ),
                            onDismissed: (direction) => _removeItem(item),
                            child: Card(
                              margin: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 8,
                              ),
                              elevation: 2,
                              child: Padding(
                                padding: const EdgeInsets.all(12),
                                child: Row(
                                  children: [
                                    // Image du produit
                                    Container(
                                      width: 70,
                                      height: 70,
                                      decoration: BoxDecoration(
                                        color: Colors.grey[200],
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: item.imageUrl.isNotEmpty
                                          ? ClipRRect(
                                              borderRadius: BorderRadius.circular(8),
                                              child: Image.network(
                                                item.imageUrl,
                                                fit: BoxFit.cover,
                                                errorBuilder: (context, error, stackTrace) {
                                                  return const Icon(
                                                    Icons.image,
                                                    color: Colors.grey,
                                                    size: 30,
                                                  );
                                                },
                                              ),
                                            )
                                          : const Icon(
                                              Icons.image,
                                              color: Colors.grey,
                                              size: 30,
                                            ),
                                    ),
                                    const SizedBox(width: 16),
                                    
                                    // Informations de l'article
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            item.name,
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 16,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            '${item.price.toStringAsFixed(2)} €',
                                            style: TextStyle(
                                              color: Colors.grey[700],
                                            ),
                                          ),
                                          const SizedBox(height: 8),
                                          Row(
                                            children: [
                                              Container(
                                                decoration: BoxDecoration(
                                                  border: Border.all(color: Colors.grey),
                                                  borderRadius: BorderRadius.circular(4),
                                                ),
                                                child: Row(
                                                  children: [
                                                    InkWell(
                                                      onTap: () => _updateItemQuantity(item, item.quantity - 1),
                                                      child: Container(
                                                        padding: const EdgeInsets.all(4),
                                                        child: const Icon(
                                                          Icons.remove,
                                                          size: 16,
                                                        ),
                                                      ),
                                                    ),
                                                    Container(
                                                      padding: const EdgeInsets.symmetric(horizontal: 8),
                                                      child: Text(
                                                        item.quantity.toString(),
                                                        style: const TextStyle(
                                                          fontWeight: FontWeight.bold,
                                                        ),
                                                      ),
                                                    ),
                                                    InkWell(
                                                      onTap: () => _updateItemQuantity(item, item.quantity + 1),
                                                      child: Container(
                                                        padding: const EdgeInsets.all(4),
                                                        child: const Icon(
                                                          Icons.add,
                                                          size: 16,
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              const SizedBox(width: 16),
                                              Text(
                                                '${(item.price * item.quantity).toStringAsFixed(2)} €',
                                                style: const TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                    
                                    // Bouton de suppression
                                    IconButton(
                                      icon: const Icon(Icons.close),
                                      onPressed: () => _removeItem(item),
                                      color: Colors.grey,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
      bottomNavigationBar: _cartItems.isEmpty
          ? null
          : Container(
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
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Résumé du panier
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${_cartItems.length} ${_cartItems.length > 1 ? "articles" : "article"}',
                        style: TextStyle(
                          color: Colors.grey[600],
                        ),
                      ),
                      Text(
                        '${_cartTotal.toStringAsFixed(2)} €',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  
                  // Bouton de commande
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _business != null && _business!.isOpenNow()
                          ? _proceedToCheckout
                          : null,
                      icon: const Icon(Icons.shopping_cart_checkout),
                      label: Text(
                        _business != null && _business!.isOpenNow()
                            ? "Passer commande"
                            : "Restaurant fermé",
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
                ],
              ),
            ),
    );
  }
}