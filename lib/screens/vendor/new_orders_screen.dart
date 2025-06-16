// Fichier screens/vendor/new_orders_screen.dart
import 'package:flutter/material.dart';
import '../../models/order_model.dart';
import '../../models/service_request_model.dart';
import '../../services/order_service.dart';
import '../../services/service_request_service.dart';
import '../../services/error_handler.dart';
import '../../l10n/translations.dart';
import '../../utils/theme.dart';
import '../../widgets/common/custom_app_bar.dart';
import '../../widgets/common/loading_indicator.dart';
import '../../widgets/common/status_badge.dart';

class NewOrdersScreen extends StatefulWidget {
  const NewOrdersScreen({super.key});

  @override
  State<NewOrdersScreen> createState() => _NewOrdersScreenState();
}

class _NewOrdersScreenState extends State<NewOrdersScreen> with SingleTickerProviderStateMixin {
  final OrderService _orderService = OrderService();
  final ServiceRequestService _requestService = ServiceRequestService();
  
  List<OrderModel> _orders = [];
  List<ServiceRequestModel> _requests = [];
  bool _isLoadingOrders = true;
  bool _isLoadingRequests = true;
  late TabController _tabController;
  
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadData();
  }
  
  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
  
  Future<void> _loadData() async {
    _loadOrders();
    _loadRequests();
  }
  
  Future<void> _loadOrders() async {
    setState(() {
      _isLoadingOrders = true;
    });
    
    try {
      final orders = await _orderService.getPendingOrders();
      
      setState(() {
        _orders = orders;
        _isLoadingOrders = false;
      });
    } catch (e) {
      setState(() {
        _isLoadingOrders = false;
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
  
  Future<void> _loadRequests() async {
    setState(() {
      _isLoadingRequests = true;
    });
    
    try {
      final requests = await _requestService.getPendingRequests();
      
      setState(() {
        _requests = requests;
        _isLoadingRequests = false;
      });
    } catch (e) {
      setState(() {
        _isLoadingRequests = false;
      });
      
      if (mounted) {
        ErrorHandler.showErrorSnackBar(
          context, 
          e,
          fallbackMessage: AppTranslations.text(context, 'error_loading_requests'),
          onRetry: _loadRequests,
        );
      }
    }
  }
  
  Future<void> _acceptOrder(OrderModel order) async {
    try {
      await _orderService.updateOrderStatus(order.id, 'processing');
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppTranslations.text(context, 'order_accepted'))),
        );
      }
      
      await _loadOrders();
    } catch (e) {
      if (mounted) {
        ErrorHandler.showErrorSnackBar(
          context, 
          e,
          fallbackMessage: AppTranslations.text(context, 'error_accepting_order'),
          onRetry: () => _acceptOrder(order),
        );
      }
    }
  }
  
  Future<void> _rejectOrder(OrderModel order) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppTranslations.text(context, 'reject_order')),
        content: Text(AppTranslations.text(context, 'reject_order_confirm')),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(AppTranslations.text(context, 'cancel')),
          ),
          TextButton(
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(AppTranslations.text(context, 'reject')),
          ),
        ],
      ),
    );
    
    if (confirm != true) return;
    
    try {
      await _orderService.updateOrderStatus(order.id, 'cancelled');
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppTranslations.text(context, 'order_rejected'))),
        );
      }
      
      await _loadOrders();
    } catch (e) {
      if (mounted) {
        ErrorHandler.showErrorSnackBar(
          context, 
          e,
          fallbackMessage: AppTranslations.text(context, 'error_rejecting_order'),
          onRetry: () => _rejectOrder(order),
        );
      }
    }
  }
  
  Future<void> _acceptRequest(ServiceRequestModel request) async {
    try {
      await _requestService.updateRequestStatus(request.id, 'accepted');
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppTranslations.text(context, 'request_accepted'))),
        );
      }
      
      await _loadRequests();
    } catch (e) {
      if (mounted) {
        ErrorHandler.showErrorSnackBar(
          context, 
          e,
          fallbackMessage: AppTranslations.text(context, 'error_accepting_request'),
          onRetry: () => _acceptRequest(request),
        );
      }
    }
  }
  
  Future<void> _rejectRequest(ServiceRequestModel request) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppTranslations.text(context, 'reject_request')),
        content: Text(AppTranslations.text(context, 'reject_request_confirm')),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(AppTranslations.text(context, 'cancel')),
          ),
          TextButton(
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(AppTranslations.text(context, 'reject')),
          ),
        ],
      ),
    );
    
    if (confirm != true) return;
    
    try {
      await _requestService.updateRequestStatus(request.id, 'cancelled');
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppTranslations.text(context, 'request_rejected'))),
        );
      }
      
      await _loadRequests();
    } catch (e) {
      if (mounted) {
        ErrorHandler.showErrorSnackBar(
          context, 
          e,
          fallbackMessage: AppTranslations.text(context, 'error_rejecting_request'),
          onRetry: () => _rejectRequest(request),
        );
      }
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: AppTranslations.text(context, 'new_notifications'),
        showBackButton: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadData,
            tooltip: AppTranslations.text(context, 'refresh'),
          ),
        ],
      ),
      body: Column(
        children: [
          // Onglets
          TabBar(
            controller: _tabController,
            labelColor: Theme.of(context).primaryColor,
            tabs: [
              Tab(
                text: '${AppTranslations.text(context, 'orders')} (${_orders.length})',
              ),
              Tab(
                text: '${AppTranslations.text(context, 'requests')} (${_requests.length})',
              ),
            ],
          ),
          
          // Contenu des onglets
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                // Onglet des commandes
                _isLoadingOrders
                    ? Center(
                        child: LoadingIndicator(
                          message: AppTranslations.text(context, 'loading_orders'),
                          animationType: AnimationType.bounce,
                          color: Theme.of(context).primaryColor,
                        ),
                      )
                    : _orders.isEmpty
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
                                  AppTranslations.text(context, 'no_new_orders'),
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 32),
                                  child: Text(
                                    AppTranslations.text(context, 'check_back_later'),
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
                            itemCount: _orders.length,
                            padding: const EdgeInsets.all(16),
                            itemBuilder: (context, index) {
                              final order = _orders[index];
                              return _buildOrderCard(order);
                            },
                          ),
                
                // Onglet des demandes de service
                _isLoadingRequests
                    ? Center(
                        child: LoadingIndicator(
                          message: AppTranslations.text(context, 'loading_requests'),
                          animationType: AnimationType.bounce,
                          color: Theme.of(context).primaryColor,
                        ),
                      )
                    : _requests.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.handyman,
                                  size: 80,
                                  color: Colors.grey[400],
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  AppTranslations.text(context, 'no_new_requests'),
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 32),
                                  child: Text(
                                    AppTranslations.text(context, 'check_back_later'),
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
                            itemCount: _requests.length,
                            padding: const EdgeInsets.all(16),
                            itemBuilder: (context, index) {
                              final request = _requests[index];
                              return _buildRequestCard(request);
                            },
                          ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildOrderCard(OrderModel order) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      elevation: 2,
      child: InkWell(
        onTap: () {
          Navigator.pushNamed(
            context,
            '/vendor/order-detail',
            arguments: order,
          ).then((_) => _loadOrders());
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // En-tête avec numéro de commande et montant
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
                      horizontal: 12,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Theme.of(context).primaryColor,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      '${order.total.toStringAsFixed(2)} €',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              
              // Informations client et date
              Row(
                children: [
                  const Icon(Icons.person, size: 16, color: Colors.grey),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      order.clientId, // Idéalement, vous obtiendriez le nom du client ici
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: Colors.grey[700],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
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
                ],
              ),
              const SizedBox(height: 4),
              Row(
                children: [
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
              
              // Actions
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => _rejectOrder(order),
                    style: TextButton.styleFrom(foregroundColor: Colors.red),
                    child: Text(AppTranslations.text(context, 'reject')),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: () => _acceptOrder(order),
                    child: Text(AppTranslations.text(context, 'accept')),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildRequestCard(ServiceRequestModel request) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      elevation: 2,
      child: InkWell(
        onTap: () {
          Navigator.pushNamed(
            context,
            '/vendor/request-detail',
            arguments: request,
          ).then((_) => _loadRequests());
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Date et badge de statut
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    _formatDate(request.requestDate),
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 14,
                    ),
                  ),
                  StatusBadge.fromStatus(
                    context,
                    request.status,
                    AppTranslations.text(context, 'pending'),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              
              // Description du service
              Text(
                _getTruncatedDescription(request.description, 50),
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              
              // Date préférée et adresse
              Row(
                children: [
                  const Icon(Icons.event, size: 16, color: Colors.grey),
                  const SizedBox(width: 8),
                  Text(
                    '${AppTranslations.text(context, 'preferred_date')}: ${_formatDateTime(request.preferredDate)}',
                    style: TextStyle(
                      color: Colors.grey[700],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  const Icon(Icons.location_on, size: 16, color: Colors.grey),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      request.address,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: Colors.grey[700],
                      ),
                    ),
                  ),
                ],
              ),
              
              // Actions
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => _rejectRequest(request),
                    style: TextButton.styleFrom(foregroundColor: Colors.red),
                    child: Text(AppTranslations.text(context, 'reject')),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: () => _acceptRequest(request),
                    child: Text(AppTranslations.text(context, 'accept')),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
  
  String _formatDateTime(DateTime date) {
    return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }
  
  String _getTruncatedDescription(String text, int maxLength) {
    if (text.length <= maxLength) {
      return text;
    }
    return '${text.substring(0, maxLength)}...';
  }
}