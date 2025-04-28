// Fichier screens/vendor/orders_screen.dart
import 'package:flutter/material.dart';
import '../../models/order_model.dart';
import '../../services/order_service.dart';
import '../../services/error_handler.dart';
import '../../l10n/translations.dart';
import '../../utils/theme.dart';
import '../../widgets/common/custom_app_bar.dart';
import '../../widgets/common/loading_indicator.dart';

class OrdersScreen extends StatefulWidget {
  const OrdersScreen({Key? key}) : super(key: key);

  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> with SingleTickerProviderStateMixin {
  final OrderService _orderService = OrderService();
  
  List<OrderModel> _orders = [];
  List<OrderModel> _filteredOrders = [];
  bool _isLoading = true;
  late TabController _tabController;
  String _selectedFilter = 'all';
  
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _tabController.addListener(_handleTabChange);
    _loadOrders();
  }
  
  @override
  void dispose() {
    _tabController.removeListener(_handleTabChange);
    _tabController.dispose();
    super.dispose();
  }
  
  void _handleTabChange() {
    if (!_tabController.indexIsChanging) {
      switch (_tabController.index) {
        case 0:
          _applyFilter('all');
          break;
        case 1:
          _applyFilter('pending');
          break;
        case 2:
          _applyFilter('processing');
          break;
        case 3:
          _applyFilter('completed');
          break;
      }
    }
  }
  
  Future<void> _loadOrders() async {
    setState(() {
      _isLoading = true;
    });
    
    try {
      final orders = await _orderService.getBusinessOrders();
      
      setState(() {
        _orders = orders;
        _applyFilter(_selectedFilter);
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
          fallbackMessage: AppTranslations.text(context, 'error_loading_orders'),
          onRetry: _loadOrders,
        );
      }
    }
  }
  
  void _applyFilter(String filter) {
    setState(() {
      _selectedFilter = filter;
      
      if (filter == 'all') {
        _filteredOrders = _orders;
      } else {
        _filteredOrders = _orders.where((order) => order.status == filter).toList();
      }
      
      // Trier par date décroissante
      _filteredOrders.sort((a, b) => b.orderDate.compareTo(a.orderDate));
    });
  }
  
  void _viewOrderDetail(OrderModel order) {
    Navigator.pushNamed(
      context,
      '/vendor/order-detail',
      arguments: order.id,
    ).then((_) => _loadOrders());
  }
  
  Future<void> _changeOrderStatus(OrderModel order, String newStatus) async {
    try {
      await _orderService.updateOrderStatus(order.id, newStatus);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppTranslations.text(context, 'status_updated'))),
        );
      }
      
      await _loadOrders();
    } catch (e) {
      if (mounted) {
        ErrorHandler.showErrorSnackBar(
          context, 
          e,
          fallbackMessage: AppTranslations.text(context, 'error_updating_status'),
          onRetry: () => _changeOrderStatus(order, newStatus),
        );
      }
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: AppTranslations.text(context, 'orders'),
        showBackButton: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadOrders,
            tooltip: AppTranslations.text(context, 'refresh'),
          ),
        ],
      ),
      body: Column(
        children: [
          // Onglets de filtrage
          Container(
            color: Theme.of(context).primaryColor,
            child: TabBar(
              controller: _tabController,
              indicatorColor: Colors.white,
              labelColor: Colors.white,
              unselectedLabelColor: Colors.white.withOpacity(0.7),
              tabs: [
                Tab(text: AppTranslations.text(context, 'all')),
                Tab(text: AppTranslations.text(context, 'pending')),
                Tab(text: AppTranslations.text(context, 'processing')),
                Tab(text: AppTranslations.text(context, 'completed')),
              ],
            ),
          ),
          
          // Liste des commandes
          Expanded(
            child: _isLoading
                ? Center(
                    child: LoadingIndicator(
                      message: AppTranslations.text(context, 'loading_orders'),
                      animationType: AnimationType.bounce,
                      color: Theme.of(context).primaryColor,
                    ),
                  )
                : _filteredOrders.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.receipt_long,
                              size: 80,
                              color: Colors.grey[400],
                            ),
                            const SizedBox(height: 16),
                            Text(
                              AppTranslations.text(context, 'no_orders_found'),
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 32),
                              child: Text(
                                _selectedFilter == 'all'
                                    ? AppTranslations.text(context, 'no_orders_yet')
                                    : AppTranslations.text(context, 'no_orders_with_status'),
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: Colors.grey[600],
                                ),
                              ),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        itemCount: _filteredOrders.length,
                        padding: const EdgeInsets.all(16),
                        itemBuilder: (context, index) {
                          final order = _filteredOrders[index];
                          return _buildOrderCard(order);
                        },
                      ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildOrderCard(OrderModel order) {
    Color statusColor;
    String statusText;
    
    switch (order.status) {
      case 'pending':
        statusColor = AppTheme.pendingColor;
        statusText = AppTranslations.text(context, 'pending');
        break;
      case 'processing':
        statusColor = AppTheme.processingColor;
        statusText = AppTranslations.text(context, 'processing');
        break;
      case 'completed':
        statusColor = AppTheme.completedColor;
        statusText = AppTranslations.text(context, 'completed');
        break;
      case 'cancelled':
        statusColor = AppTheme.cancelledColor;
        statusText = AppTranslations.text(context, 'cancelled');
        break;
      default:
        statusColor = Colors.grey;
        statusText = order.status;
    }
    
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      elevation: 2,
      child: InkWell(
        onTap: () => _viewOrderDetail(order),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // En-tête avec numéro de commande et statut
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${AppTranslations.text(context, 'order')} #${order.orderNumber}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: statusColor,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      statusText,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              
              // Date et nombre d'articles
              Row(
                children: [
                  const Icon(Icons.event, size: 16, color: Colors.grey),
                  const SizedBox(width: 8),
                  Text(
                    _formatDateTime(order.orderDate),
                    style: TextStyle(
                      color: Colors.grey[700],
                    ),
                  ),
                  const SizedBox(width: 16),
                  const Icon(Icons.shopping_bag, size: 16, color: Colors.grey),
                  const SizedBox(width: 8),
                  Text(
                    '${order.items.length} ${AppTranslations.text(context, 'items')}',
                    style: TextStyle(
                      color: Colors.grey[700],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              
              // Adresse de livraison
              Row(
                children: [
                  const Icon(Icons.location_on, size: 16, color: Colors.grey),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      order.deliveryAddress,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: Colors.grey[700],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              
              // Montant total
              Row(
                children: [
                  const Icon(Icons.euro, size: 16, color: Colors.grey),
                  const SizedBox(width: 8),
                  Text(
                    '${order.total.toStringAsFixed(2)} €',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              
              // Actions pour les commandes en attente ou en cours
              if (order.status == 'pending') ...[
                const Divider(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => _changeOrderStatus(order, 'cancelled'),
                      style: TextButton.styleFrom(foregroundColor: Colors.red),
                      child: Text(AppTranslations.text(context, 'reject')),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: () => _changeOrderStatus(order, 'processing'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                      ),
                      child: Text(AppTranslations.text(context, 'accept')),
                    ),
                  ],
                ),
              ] else if (order.status == 'processing') ...[
                const Divider(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    ElevatedButton(
                      onPressed: () => _changeOrderStatus(order, 'completed'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                      ),
                      child: Text(AppTranslations.text(context, 'mark_completed')),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
  
  String _formatDateTime(DateTime date) {
    return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }
}