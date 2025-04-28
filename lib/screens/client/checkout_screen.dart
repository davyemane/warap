// Fichier screens/client/checkout_screen.dart
import 'package:flutter/material.dart';
import '../../models/business_model.dart';
import '../../models/cart_item_model.dart';
import '../../services/order_service.dart';
import '../../services/cart_service.dart';
import '../../services/error_handler.dart';
import '../../l10n/translations.dart';
import '../../widgets/common/custom_app_bar.dart';
import '../../widgets/common/loading_indicator.dart';
import 'order_confirmation_screen.dart';

class CheckoutScreen extends StatefulWidget {
  final List<CartItemModel> cartItems;
  final BusinessModel business;
  
  const CheckoutScreen({
    Key? key,
    required this.cartItems,
    required this.business,
  }) : super(key: key);

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  final OrderService _orderService = OrderService();
  final CartService _cartService = CartService();
  
  String _deliveryAddress = '';
  String _selectedPaymentMethod = 'card';
  bool _isLoading = false;
  
  final _formKey = GlobalKey<FormState>();
  
  // Calculer le sous-total
  double get subtotal => widget.cartItems.fold(
    0.0,
    (sum, item) => sum + item.calculateTotalPrice(),
  );
  
  // Calculer la TVA
  double get tax => subtotal * 0.20;
  
  // Calculer le total
  double get total => subtotal + tax;
  
Future<void> _createOrder() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    
    _formKey.currentState!.save();
    
    setState(() {
      _isLoading = true;
    });
    
    try {
      // Vérifier que l'adresse est bien renseignée
      if (_deliveryAddress.trim().isEmpty) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppTranslations.text(context, 'address_required'))),
        );
        return;
      }
      
      // Créer la commande
      final order = await _orderService.createOrder(
        businessId: widget.business.id,
        items: widget.cartItems,
        deliveryAddress: _deliveryAddress,
        paymentMethod: _selectedPaymentMethod,
      );
      
      // Vider le panier après la commande
      await _cartService.clearCart();
      
      setState(() {
        _isLoading = false;
      });
      
      if (mounted) {
        // Naviguer vers l'écran de confirmation
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => OrderConfirmationScreen(order: order),
          ),
        );
      }
    } catch (e) {
      print("Erreur lors de la création de la commande: $e");
      setState(() {
        _isLoading = false;
      });
      
      if (mounted) {
        ErrorHandler.showErrorSnackBar(
          context, 
          e,
          fallbackMessage: AppTranslations.text(context, 'error_creating_order'),
          onRetry: _createOrder,
        );
      }
    }
  }  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: AppTranslations.text(context, 'checkout'),
        showBackButton: true,
      ),
      body: _isLoading
          ? Center(
              child: LoadingIndicator(
                message: AppTranslations.text(context, 'processing_order'),
                animationType: AnimationType.bounce,
                color: Theme.of(context).primaryColor,
              ),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // En-tête du commerce
                    Card(
                      margin: const EdgeInsets.only(bottom: 16),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          children: [
                            CircleAvatar(
                              backgroundColor: widget.business.businessType == 'fixe'
                                  ? Colors.blue
                                  : Colors.green,
                              radius: 24,
                              child: Icon(
                                widget.business.businessType == 'fixe'
                                    ? Icons.store
                                    : Icons.delivery_dining,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    widget.business.name,
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    widget.business.address,
                                    style: TextStyle(
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    
                    // Récapitulatif de la commande
                    Text(
                      AppTranslations.text(context, 'order_summary'),
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    
                    // Liste des articles
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: widget.cartItems.length,
                      itemBuilder: (context, index) {
                        final item = widget.cartItems[index];
                        return ListTile(
                          contentPadding: EdgeInsets.zero,
                          title: Text(item.name),
                          subtitle: Text('${item.price.toStringAsFixed(2)} € × ${item.quantity}'),
                          trailing: Text(
                            '${item.calculateTotalPrice().toStringAsFixed(2)} €',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        );
                      },
                    ),
                    
                    const Divider(),
                    
                    // Sous-total, taxes et total
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(AppTranslations.text(context, 'subtotal')),
                          Text('${subtotal.toStringAsFixed(2)} €'),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(AppTranslations.text(context, 'tax')),
                          Text('${tax.toStringAsFixed(2)} €'),
                        ],
                      ),
                    ),
                    const Divider(),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            AppTranslations.text(context, 'total'),
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                          Text(
                            '${total.toStringAsFixed(2)} €',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    const SizedBox(height: 24),
                    
                    // Adresse de livraison
                    Text(
                      AppTranslations.text(context, 'delivery_address'),
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      decoration: InputDecoration(
                        hintText: AppTranslations.text(context, 'enter_address'),
                        border: const OutlineInputBorder(),
                      ),
                      maxLines: 3,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return AppTranslations.text(context, 'address_required');
                        }
                        return null;
                      },
                      onSaved: (value) {
                        _deliveryAddress = value!;
                      },
                    ),
                    
                    const SizedBox(height: 24),
                    
                    // Méthode de paiement
                    Text(
                      AppTranslations.text(context, 'payment_method'),
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    
                    // Options de paiement
                    Card(
                      child: Column(
                        children: [
                          RadioListTile<String>(
                            title: Row(
                              children: [
                                const Icon(Icons.credit_card),
                                const SizedBox(width: 8),
                                Text(AppTranslations.text(context, 'credit_card')),
                              ],
                            ),
                            value: 'card',
                            groupValue: _selectedPaymentMethod,
                            onChanged: (value) {
                              setState(() {
                                _selectedPaymentMethod = value!;
                              });
                            },
                          ),
                          RadioListTile<String>(
                            title: Row(
                              children: [
                                const Icon(Icons.payment),
                                const SizedBox(width: 8),
                                Text(AppTranslations.text(context, 'cash_on_delivery')),
                              ],
                            ),
                            value: 'cash',
                            groupValue: _selectedPaymentMethod,
                            onChanged: (value) {
                              setState(() {
                                _selectedPaymentMethod = value!;
                              });
                            },
                          ),
                        ],
                      ),
                    ),
                    
                    const SizedBox(height: 32),
                    
                    // Bouton de commande
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _createOrder,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        child: Text(
                          AppTranslations.text(context, 'place_order'),
                          style: const TextStyle(fontSize: 16),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}