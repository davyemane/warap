// Fichier screens/vendor/order_detail_screen.dart
import 'package:flutter/material.dart';
import '../../models/order_model.dart';
import '../../services/order_service.dart';
import '../../services/error_handler.dart';
import '../../l10n/translations.dart';
import '../../utils/theme.dart';
import '../../widgets/common/custom_app_bar.dart';
import '../../widgets/common/loading_indicator.dart';

class OrderDetailScreen extends StatefulWidget {
  final String orderId;
  
  const OrderDetailScreen({
    Key? key,
    required this.orderId,
  }) : super(key: key);

  @override
  State<OrderDetailScreen> createState() => _OrderDetailScreenState();
}

class _OrderDetailScreenState extends State<OrderDetailScreen> {
  final OrderService _orderService = OrderService();
  
  OrderModel? _order;
  bool _isLoading = true;
  bool _isUpdating = false;
  
  @override
  void initState() {
    super.initState();
    _loadOrderDetails();
  }
  
  Future<void> _loadOrderDetails() async {
    setState(() {
      _isLoading = true;
    });
    
    try {
      final order = await _orderService.getOrderById(widget.orderId);
      
      setState(() {
        _order = order;
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
          fallbackMessage: AppTranslations.text(context, 'error_loading_order'),
          onRetry: _loadOrderDetails,
        );
      }
    }
  }
  
  Future<void> _updateOrderStatus(String status) async {
    // Confirmer le changement de statut
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppTranslations.text(context, 'update_status')),
        content: Text(AppTranslations.textWithParams(
          context, 'confirm_status_change', [_getStatusLabel(context, status)])),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(AppTranslations.text(context, 'cancel')),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(AppTranslations.text(context, 'confirm')),
          ),
        ],
      ),
    );
    
    if (confirm != true) return;
    
    setState(() {
      _isUpdating = true;
    });
    
    try {
      await _orderService.updateOrderStatus(widget.orderId, status);
      await _loadOrderDetails();
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppTranslations.text(context, 'status_updated'))),
        );
      }
    } catch (e) {
      setState(() {
        _isUpdating = false;
      });
      
      if (mounted) {
        ErrorHandler.showErrorSnackBar(
          context, 
          e,
          fallbackMessage: AppTranslations.text(context, 'error_updating_status'),
          onRetry: () => _updateOrderStatus(status),
        );
      }
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: _order != null 
            ? AppTranslations.textWithParams(context, 'order_number', [_order!.orderNumber])
            : AppTranslations.text(context, 'order_details'),
        showBackButton: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _isLoading || _isUpdating ? null : _loadOrderDetails,
            tooltip: AppTranslations.text(context, 'refresh'),
          ),
        ],
      ),
      body: _isLoading
          ? Center(
              child: LoadingIndicator(
                message: AppTranslations.text(context, 'loading_order'),
                animationType: AnimationType.bounce,
                color: Theme.of(context).primaryColor,
              ),
            )
          : _isUpdating
              ? Center(
                  child: LoadingIndicator(
                    message: AppTranslations.text(context, 'updating_status'),
                    animationType: AnimationType.bounce,
                    color: Theme.of(context).primaryColor,
                  ),
                )
              : _order == null
                  ? Center(
                      child: Text(
                        AppTranslations.text(context, 'order_not_found'),
                        style: const TextStyle(fontSize: 18),
                      ),
                    )
                  : SingleChildScrollView(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // En-tête
                          Card(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 2,
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            AppTranslations.text(context, 'order_date'),
                                            style: TextStyle(
                                              color: Colors.grey[600],
                                              fontSize: 14,
                                            ),
                                          ),
                                          Text(
                                            _formatDateTime(_order!.orderDate),
                                            style: const TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ],
                                      ),
                                      _buildStatusChip(context, _order!.status),
                                    ],
                                  ),
                                  const SizedBox(height: 16),
                                  
                                  // Informations client
                                  Text(
                                    AppTranslations.text(context, 'client_info'),
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(_order!.clientId),
                                  const SizedBox(height: 16),
                                  
                                  // Adresse de livraison
                                  Text(
                                    AppTranslations.text(context, 'delivery_address'),
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(_order!.deliveryAddress),
                                  const SizedBox(height: 16),
                                  
                                  // Méthode de paiement
                                  Text(
                                    AppTranslations.text(context, 'payment_method'),
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(_getPaymentMethodName(context, _order!.paymentMethod)),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 24),
                          
                          // Liste des articles
                          Text(
                            AppTranslations.text(context, 'order_items'),
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Card(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 2,
                            child: ListView.separated(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: _order!.items.length,
                              separatorBuilder: (context, index) => const Divider(height: 1),
                              itemBuilder: (context, index) {
                                final item = _order!.items[index];
                                return ListTile(
                                  title: Text(item.name),
                                  subtitle: Text('${item.price.toStringAsFixed(2)} € × ${item.quantity}'),
                                  trailing: Text(
                                    '${(item.price * item.quantity).toStringAsFixed(2)} €',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                          const SizedBox(height: 24),
                          
                          // Récapitulatif du paiement
                          Text(
                            AppTranslations.text(context, 'payment_summary'),
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Card(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 2,
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(AppTranslations.text(context, 'subtotal')),
                                      Text('${_order!.subtotal.toStringAsFixed(2)} €'),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(AppTranslations.text(context, 'tax')),
                                      Text('${_order!.tax.toStringAsFixed(2)} €'),
                                    ],
                                  ),
                                  const Divider(height: 24),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        AppTranslations.text(context, 'total'),
                                        style: const TextStyle(fontWeight: FontWeight.bold),
                                      ),
                                      Text(
                                        '${_order!.total.toStringAsFixed(2)} €',
                                        style: const TextStyle(fontWeight: FontWeight.bold),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 32),
                          
                          // Actions selon statut
                          if (_order!.status == 'pending') ...[
                            Row(
                              children: [
                                Expanded(
                                  child: OutlinedButton.icon(
                                    onPressed: () => _updateOrderStatus('cancelled'),
                                    icon: const Icon(Icons.cancel),
                                    label: Text(AppTranslations.text(context, 'cancel_order')),
                                    style: OutlinedButton.styleFrom(
                                      foregroundColor: Colors.red,
                                      padding: const EdgeInsets.symmetric(vertical: 12),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: ElevatedButton.icon(
                                    onPressed: () => _updateOrderStatus('processing'),
                                    icon: const Icon(Icons.check),
                                    label: Text(AppTranslations.text(context, 'accept_order')),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.green,
                                      padding: const EdgeInsets.symmetric(vertical: 12),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ] else if (_order!.status == 'processing') ...[
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton.icon(
                                onPressed: () => _updateOrderStatus('completed'),
                                icon: const Icon(Icons.done_all),
                                label: Text(AppTranslations.text(context, 'mark_completed')),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.green,
                                  padding: const EdgeInsets.symmetric(vertical: 12),
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
    );
  }
  
  Widget _buildStatusChip(BuildContext context, String status) {
    Color color;
    String label;
    
    switch (status) {
      case 'pending':
        color = AppTheme.pendingColor;
        label = AppTranslations.text(context, 'pending');
        break;
      case 'processing':
        color = AppTheme.processingColor;
        label = AppTranslations.text(context, 'processing');
        break;
      case 'completed':
        color = AppTheme.completedColor;
        label = AppTranslations.text(context, 'completed');
        break;
      case 'cancelled':
        color = AppTheme.cancelledColor;
        label = AppTranslations.text(context, 'cancelled');
        break;
      default:
        color = Colors.grey;
        label = status;
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
  
  String _getStatusLabel(BuildContext context, String status) {
    switch (status) {
      case 'pending':
        return AppTranslations.text(context, 'pending');
      case 'processing':
        return AppTranslations.text(context, 'processing');
      case 'completed':
        return AppTranslations.text(context, 'completed');
      case 'cancelled':
        return AppTranslations.text(context, 'cancelled');
      default:
        return status;
    }
  }
}