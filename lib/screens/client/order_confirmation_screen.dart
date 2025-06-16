// Fichier screens/client/order_confirmation_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../models/order_model.dart';
import '../../services/error_handler.dart';
import '../../l10n/translations.dart';
import '../../utils/theme.dart';
import '../../widgets/common/custom_app_bar.dart';
import 'order_details_screen.dart';

class OrderConfirmationScreen extends StatelessWidget {
  final OrderModel order;
  
  const OrderConfirmationScreen({
    super.key,
    required this.order,
  });

  void _copyOrderNumber(BuildContext context) {
    Clipboard.setData(ClipboardData(text: order.orderNumber));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(AppTranslations.text(context, 'order_number_copied'))),
    );
  }
  
  void _viewOrderDetails(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => OrderDetailsScreen(orderId: order.id),
      ),
    );
  }
  
  void _goToHomePage(BuildContext context) {
    // Retourner à l'écran d'accueil (carte)
    Navigator.pushNamedAndRemoveUntil(
      context,
      '/client/map',
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: AppTranslations.text(context, 'order_confirmed'),
        showBackButton: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 32),
            
            // Icône animée de succès
            _buildSuccessAnimation(),
            
            const SizedBox(height: 32),
            
            // Texte de confirmation
            Text(
              AppTranslations.text(context, 'order_placed_successfully'),
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: AppTheme.completedColor,
              ),
              textAlign: TextAlign.center,
            ),
            
            const SizedBox(height: 16),
            
            Text(
              AppTranslations.text(context, 'thank_you_order'),
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[700],
              ),
              textAlign: TextAlign.center,
            ),
            
            const SizedBox(height: 32),
            
            // Numéro de commande
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Text(
                      AppTranslations.text(context, 'order_number'),
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          order.orderNumber,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.copy, size: 18),
                          onPressed: () => _copyOrderNumber(context),
                          tooltip: AppTranslations.text(context, 'copy'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Montant total
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Text(
                      AppTranslations.text(context, 'total_amount'),
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${order.total.toStringAsFixed(2)} €',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.primaryColor,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Résumé de la commande
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      AppTranslations.text(context, 'order_summary'),
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    // Date de commande
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          AppTranslations.text(context, 'order_date'),
                          style: TextStyle(
                            color: Colors.grey[700],
                          ),
                        ),
                        Text(
                          _formatDateTime(order.orderDate),
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const Divider(height: 24),
                    
                    // Nombre d'articles
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          AppTranslations.text(context, 'items'),
                          style: TextStyle(
                            color: Colors.grey[700],
                          ),
                        ),
                        Text(
                          '${order.items.length}',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const Divider(height: 24),
                    
                    // Méthode de paiement
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          AppTranslations.text(context, 'payment_method'),
                          style: TextStyle(
                            color: Colors.grey[700],
                          ),
                        ),
                        Text(
                          _getPaymentMethodName(context, order.paymentMethod),
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const Divider(height: 24),
                    
                    // Statut de la commande
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          AppTranslations.text(context, 'status'),
                          style: TextStyle(
                            color: Colors.grey[700],
                          ),
                        ),
                        _buildStatusChip(context, order.status),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 32),
            
            // Boutons d'action
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => _viewOrderDetails(context),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: Text(AppTranslations.text(context, 'view_details')),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => _goToHomePage(context),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: Text(AppTranslations.text(context, 'go_to_home')),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildSuccessAnimation() {
    return Container(
      width: 100,
      height: 100,
      decoration: BoxDecoration(
        color: AppTheme.completedColor.withOpacity(0.1),
        shape: BoxShape.circle,
      ),
      child: const Icon(
        Icons.check_circle,
        color: AppTheme.completedColor,
        size: 80,
      ),
    );
  }
  
  Widget _buildStatusChip(BuildContext context, String status) {
    String label;
    Color color;
    
    switch (status) {
      case 'pending':
        label = AppTranslations.text(context, 'pending');
        color = AppTheme.pendingColor;
        break;
      case 'processing':
        label = AppTranslations.text(context, 'processing');
        color = AppTheme.processingColor;
        break;
      case 'completed':
        label = AppTranslations.text(context, 'completed');
        color = AppTheme.completedColor;
        break;
      case 'cancelled':
        label = AppTranslations.text(context, 'cancelled');
        color = AppTheme.cancelledColor;
        break;
      default:
        label = status;
        color = Colors.grey;
    }
    
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 6,
      ),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
  
  String _formatDateTime(DateTime date) {
    return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }
  
  String _getPaymentMethodName(BuildContext context, String method) {
    switch (method) {
      case 'card':
        return AppTranslations.text(context, 'credit_card');
      case 'cash':
        return AppTranslations.text(context, 'cash_on_delivery');
      default:
        return method;
    }
  }
}