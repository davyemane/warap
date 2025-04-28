// screens/vendor/vendor_dashboard_screen.dart
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../../models/order_model.dart';
import '../../models/business_model.dart';
import '../../models/service_request_model.dart';
import '../../services/order_service.dart';
import '../../services/business_service.dart';
import '../../services/service_request_service.dart';
import '../../services/error_handler.dart';
import '../../l10n/translations.dart';
import '../../utils/theme.dart';
import '../../widgets/vendor/vendor_app_bar.dart';
import '../../widgets/common/loading_indicator.dart';
import 'business_detail_screen.dart';
import 'order_detail_screen.dart';
import 'add_business_screen.dart';
import 'product_list_screen.dart';
import 'orders_screen.dart';
import 'client_list_screen.dart';
import 'service_requests_screen.dart';
import 'vendor_settings_screen.dart';

class VendorDashboardScreen extends StatefulWidget {
  const VendorDashboardScreen({Key? key}) : super(key: key);

  @override
  State<VendorDashboardScreen> createState() => _VendorDashboardScreenState();
}

class _VendorDashboardScreenState extends State<VendorDashboardScreen> {
  final OrderService _orderService = OrderService();
  final BusinessService _businessService = BusinessService();
  final ServiceRequestService _requestService = ServiceRequestService();
  
  List<OrderModel> _recentOrders = [];
  List<BusinessModel> _userBusinesses = [];
  List<ServiceRequestModel> _pendingRequests = [];
  
  bool _isLoadingOrders = true;
  bool _isLoadingBusinesses = true;
  bool _isLoadingRequests = true;
  bool _isLoadingStats = true;
  
  String _selectedPeriod = 'week';
  String _selectedMetric = 'revenue';
  Map<String, dynamic> _statistics = {};
  
  @override
  void initState() {
    super.initState();
    _loadData();
  }
  
  Future<void> _loadData() async {
    _loadBusinesses();
    _loadOrders();
    _loadRequests();
    _loadStatistics();
  }
  
  Future<void> _loadBusinesses() async {
    setState(() {
      _isLoadingBusinesses = true;
    });
    
    try {
      // Récupérer les vrais commerces depuis Supabase
      final businesses = await _businessService.getUserBusinesses();
      
      if (mounted) {
        setState(() {
          _userBusinesses = businesses;
          _isLoadingBusinesses = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoadingBusinesses = false;
        });
        
        ErrorHandler.showErrorSnackBar(
          context, 
          e,
          fallbackMessage: 'Erreur lors du chargement des commerces',
          onRetry: _loadBusinesses,
        );
      }
    }
  }
  
  Future<void> _loadOrders() async {
    setState(() {
      _isLoadingOrders = true;
    });
    
    try {
      // Récupérer les vraies commandes récentes depuis Supabase
      // Utiliser getRecentOrders pour avoir des données réelles
      final orders = await _orderService.getRecentOrders(limit: 5);
      
      if (mounted) {
        setState(() {
          _recentOrders = orders;
          _isLoadingOrders = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoadingOrders = false;
        });
        
        ErrorHandler.showErrorSnackBar(
          context, 
          e,
          fallbackMessage: 'Erreur lors du chargement des commandes',
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
      // Récupérer les vraies demandes de service depuis Supabase
      final requests = await _requestService.getPendingRequests();
      
      if (mounted) {
        setState(() {
          _pendingRequests = requests;
          _isLoadingRequests = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoadingRequests = false;
        });
        
        ErrorHandler.showErrorSnackBar(
          context, 
          e,
          fallbackMessage: 'Erreur lors du chargement des requêtes',
          onRetry: _loadRequests,
        );
      }
    }
  }
  
  Future<void> _loadStatistics() async {
    setState(() {
      _isLoadingStats = true;
    });
    
    try {
      // Récupérer les vraies statistiques depuis Supabase
      final stats = await _orderService.getStatistics(
        period: _selectedPeriod,
        metric: _selectedMetric,
      );
      
      if (mounted) {
        setState(() {
          _statistics = stats;
          _isLoadingStats = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoadingStats = false;
        });
        
        ErrorHandler.showErrorSnackBar(
          context, 
          e,
          fallbackMessage: 'Erreur lors du chargement des statistiques',
          onRetry: _loadStatistics,
        );
      }
    }
  }
  
  void _changePeriod(String period) {
    setState(() {
      _selectedPeriod = period;
    });
    _loadStatistics();
  }
  
  void _changeMetric(String metric) {
    setState(() {
      _selectedMetric = metric;
    });
    _loadStatistics();
  }
  
  void _navigateToBusinessDetail(BusinessModel business) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => BusinessDetailScreen(business: business),
      ),
    ).then((_) => _loadData());
  }
  
  void _navigateToOrderDetail(OrderModel order) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => OrderDetailScreen(orderId: order.id),
      ),
    ).then((_) => _loadData());
  }
  
  void _navigateToAddBusiness() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const AddBusinessScreen(),
      ),
    ).then((_) => _loadData());
  }
  
  void _navigateToProducts() {
    if (_userBusinesses.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Veuillez d\'abord créer un commerce'),
          action: SnackBarAction(
            label: 'Créer',
            onPressed: _navigateToAddBusiness,
          ),
        ),
      );
      return;
    }
    
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ProductListScreen(business: _userBusinesses.first),
      ),
    ).then((_) => _loadData());
  }
  
  void _navigateToOrders() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const OrdersScreen(),
      ),
    ).then((_) => _loadData());
  }
  
  void _navigateToClients() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const ClientListScreen(),
      ),
    ).then((_) => _loadData());
  }
  
  void _navigateToRequests() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const ServiceRequestsScreen(),
      ),
    ).then((_) => _loadData());
  }
  
  void _navigateToSettings() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const VendorSettingsScreen(),
      ),
    );
  }
  
  String _formatDate(DateTime date) {
    final formatter = DateFormat('dd/MM/yyyy');
    return formatter.format(date);
  }
  
  @override
  Widget build(BuildContext context) {
    final bool isLoading = _isLoadingBusinesses || _isLoadingOrders || 
                          _isLoadingRequests || _isLoadingStats;
    
    return Scaffold(
      appBar: VendorAppBar(
        title: 'Tableau de bord',
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadData,
            tooltip: 'Actualiser',
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: _navigateToSettings,
            tooltip: 'Paramètres',
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadData,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Carte de résumé
              _buildSummaryCard(isLoading),
              const SizedBox(height: 24),
              
              // Actions rapides
              _buildQuickActions(),
              const SizedBox(height: 24),
              
              // Commerces
              _buildBusinessesList(),
              const SizedBox(height: 24),
              
              // Commandes récentes
              _buildRecentOrders(),
              const SizedBox(height: 24),
              
              // Requêtes de service en attente
              if (!_isLoadingRequests && _pendingRequests.isNotEmpty) ...[
                _buildPendingRequests(),
                const SizedBox(height: 32),
              ],
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildSummaryCard(bool isLoading) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Statistiques',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                // Sélecteur de période
                DropdownButton<String>(
                  value: _selectedPeriod,
                  underline: Container(),
                  items: const [
                    DropdownMenuItem(
                      value: 'week',
                      child: Text('Cette semaine'),
                    ),
                    DropdownMenuItem(
                      value: 'month',
                      child: Text('Ce mois'),
                    ),
                    DropdownMenuItem(
                      value: 'year',
                      child: Text('Cette année'),
                    ),
                  ],
                  onChanged: (value) {
                    if (value != null) _changePeriod(value);
                  },
                ),
              ],
            ),
            const SizedBox(height: 8),
            
            // Sélecteur de métrique
            Row(
              children: [
                _buildMetricButton('revenue', Icons.euro),
                const SizedBox(width: 8),
                _buildMetricButton('orders', Icons.shopping_bag),
                const SizedBox(width: 8),
                _buildMetricButton('customers', Icons.people),
              ],
            ),
            const SizedBox(height: 16),
            
            // Graphique
            SizedBox(
              height: 200,
              child: isLoading || _isLoadingStats
                  ? const Center(child: CircularProgressIndicator())
                  : _statistics.isEmpty || (_statistics['data'] as List?)?.isEmpty == true
                      ? const Center(
                          child: Text('Aucune donnée disponible pour cette période'),
                        )
                      : LineChart(
                          LineChartData(
                            gridData: FlGridData(show: false),
                            titlesData: FlTitlesData(
                              leftTitles: const AxisTitles(
                                sideTitles: SideTitles(showTitles: false),
                              ),
                              bottomTitles: AxisTitles(
                                sideTitles: SideTitles(
                                  showTitles: true,
                                  getTitlesWidget: (value, meta) {
                                    final labels = _statistics['labels'] as List?;
                                    if (labels != null && value.toInt() >= 0 && value.toInt() < labels.length) {
                                      return Padding(
                                        padding: const EdgeInsets.only(top: 8.0),
                                        child: Text(
                                          labels[value.toInt()].toString(),
                                          style: const TextStyle(fontSize: 10),
                                        ),
                                      );
                                    }
                                    return const Text('');
                                  },
                                  reservedSize: 30,
                                ),
                              ),
                              rightTitles: const AxisTitles(
                                sideTitles: SideTitles(showTitles: false),
                              ),
                              topTitles: const AxisTitles(
                                sideTitles: SideTitles(showTitles: false),
                              ),
                            ),
                            borderData: FlBorderData(show: false),
                            lineBarsData: [
                              LineChartBarData(
                                spots: (_statistics['data'] as List?)?.asMap().entries.map((entry) {
                                  return FlSpot(entry.key.toDouble(), (entry.value ?? 0).toDouble());
                                }).toList() ?? [],
                                isCurved: true,
                                color: Theme.of(context).primaryColor,
                                barWidth: 4,
                                isStrokeCapRound: true,
                                dotData: const FlDotData(show: false),
                                belowBarData: BarAreaData(
                                  show: true,
                                  color: Theme.of(context).primaryColor.withOpacity(0.2),
                                ),
                              ),
                            ],
                          ),
                        ),
            ),
            
            // Résumé des statistiques
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatisticItem(
                  isLoading ? '...' : _statistics['total']?.toString() ?? '0',
                  _selectedMetric == 'revenue' ? '€' : '',
                  'Total',
                ),
                _buildStatisticItem(
                  isLoading ? '...' : _statistics['average']?.toString() ?? '0',
                  _selectedMetric == 'revenue' ? '€' : '',
                  'Moyenne',
                ),
                _buildStatisticItem(
                  isLoading ? '...' : _statistics['growth']?.toString() ?? '0',
                  '%',
                  'Croissance',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildMetricButton(String metric, IconData icon) {
    final isSelected = _selectedMetric == metric;
    
    String metricLabel;
    switch (metric) {
      case 'revenue':
        metricLabel = 'Revenus';
        break;
      case 'orders':
        metricLabel = 'Commandes';
        break;
      case 'customers':
        metricLabel = 'Clients';
        break;
      default:
        metricLabel = metric;
    }
    
    return Expanded(
      child: InkWell(
        onTap: () => _changeMetric(metric),
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: isSelected
                ? Theme.of(context).primaryColor
                : Colors.grey[200],
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            children: [
              Icon(
                icon,
                color: isSelected ? Colors.white : Colors.grey[600],
              ),
              const SizedBox(height: 4),
              Text(
                metricLabel,
                style: TextStyle(
                  color: isSelected ? Colors.white : Colors.grey[600],
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildStatisticItem(String value, String unit, String label) {
    return Column(
      children: [
        RichText(
          text: TextSpan(
            style: DefaultTextStyle.of(context).style.copyWith(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
            children: [
              TextSpan(text: value),
              TextSpan(
                text: unit,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
        Text(
          label,
          style: TextStyle(
            color: Colors.grey[600],
            fontSize: 12,
          ),
        ),
      ],
    );
  }
  
  Widget _buildQuickActions() {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Actions rapides',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildActionButton(
                  Icons.add_business,
                  'Ajouter commerce',
                  _navigateToAddBusiness,
                ),
                _buildActionButton(
                  Icons.inventory,
                  'Produits',
                  _navigateToProducts,
                ),
                _buildActionButton(
                  Icons.list_alt,
                  'Commandes',
                  _navigateToOrders,
                ),
                _buildActionButton(
                  Icons.people,
                  'Clients',
                  _navigateToClients,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildActionButton(IconData icon, String label, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.all(8),
        child: Column(
          children: [
            CircleAvatar(
              radius: 24,
              backgroundColor: Theme.of(context).primaryColor.withOpacity(0.1),
              child: Icon(
                icon,
                color: Theme.of(context).primaryColor,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: const TextStyle(fontSize: 12),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildBusinessesList() {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Mes commerces',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (_userBusinesses.isNotEmpty)
                  TextButton(
                    onPressed: () {
                      Navigator.pushNamed(context, '/vendor/businesses');
                    },
                    child: Text(
                      'Voir tout',
                      style: TextStyle(
                        color: Theme.of(context).primaryColor,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            _isLoadingBusinesses
                ? const Center(
                    child: Padding(
                      padding: EdgeInsets.all(20.0),
                      child: CircularProgressIndicator(),
                    ),
                  )
                : _userBusinesses.isEmpty
                    ? Center(
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            children: [
                              Text(
                                'Vous n\'avez pas encore de commerce',
                                style: TextStyle(color: Colors.grey[600]),
                              ),
                              const SizedBox(height: 16),
                              ElevatedButton.icon(
                                onPressed: _navigateToAddBusiness,
                                icon: const Icon(Icons.add_business),
                                label: const Text('Ajouter un commerce'),
                              ),
                            ],
                          ),
                        ),
                      )
                    : ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: _userBusinesses.length > 3 ? 3 : _userBusinesses.length,
                        itemBuilder: (context, index) {
                          final business = _userBusinesses[index];
                          return Card(
                            margin: const EdgeInsets.only(bottom: 8),
                            child: ListTile(
                              leading: CircleAvatar(
                                backgroundColor: business.businessType == 'fixe'
                                    ? Colors.blue
                                    : Colors.green,
                                child: Icon(
                                  business.businessType == 'fixe'
                                      ? Icons.store
                                      : Icons.delivery_dining,
                                  color: Colors.white,
                                ),
                              ),
                              title: Text(
                                business.name,
                                style: const TextStyle(fontWeight: FontWeight.bold),
                              ),
                              subtitle: Text(
                                business.isOpenNow()
                                    ? 'Ouvert • ${business.address}'
                                    : 'Fermé • ${business.address}',
                              ),
                              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                              onTap: () => _navigateToBusinessDetail(business),
                            ),
                          );
                        },
                      ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildRecentOrders() {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Commandes récentes',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                TextButton(
                  onPressed: () {
                    _navigateToOrders();
                  },
                  child: Text(
                    'Voir tout',
                    style: TextStyle(
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            _isLoadingOrders
                ? const Center(
                    child: Padding(
                      padding: EdgeInsets.all(20.0),
                      child: CircularProgressIndicator(),
                    ),
                  )
                : _recentOrders.isEmpty
                    ? Center(
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Text(
                            'Aucune commande récente',
                            style: TextStyle(color: Colors.grey[600]),
                          ),
                        ),
                      )
                    : ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: _recentOrders.length,
                        itemBuilder: (context, index) {
                          final order = _recentOrders[index];
                          return Card(
                            margin: const EdgeInsets.only(bottom: 8),
                            child: ListTile(
                              leading: CircleAvatar(
                                backgroundColor: _getStatusColor(order.status),
                                child: Text(
                                  order.orderNumber.substring(0, 2),
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              title: Text(
                                'Commande #${order.orderNumber}',
                                style: const TextStyle(fontWeight: FontWeight.bold),
                              ),
                              subtitle: Text(
                                '${order.items.length} articles - ${order.total.toStringAsFixed(2)} €',
                              ),
                              trailing: Chip(
                                label: Text(
                                  _getStatusLabel(order.status),
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                  ),
                                ),
                                backgroundColor: _getStatusColor(order.status),
                              ),
                              onTap: () => _navigateToOrderDetail(order),
                            ),
                          );
                        },
                      ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildPendingRequests() {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Demandes en attente',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                TextButton(
                  onPressed: () {
                    _navigateToRequests();
                  },
                  child: Text(
                    'Voir tout',
                    style: TextStyle(
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            _isLoadingRequests
                ? const Center(
                    child: Padding(
                      padding: EdgeInsets.all(20.0),
                      child: CircularProgressIndicator(),
                    ),
                  )
                : _pendingRequests.isEmpty
                    ? Center(
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Text(
                            'Aucune demande en attente',
                            style: TextStyle(color: Colors.grey[600]),
                          ),
                        ),
                      )
                    : ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: _pendingRequests.length > 2 ? 2 : _pendingRequests.length,
                        itemBuilder: (context, index) {
                          final request = _pendingRequests[index];
                          return Card(
                            margin: const EdgeInsets.only(bottom: 8),
                            child: ListTile(
                              leading: const CircleAvatar(
                                backgroundColor: Colors.orange,
                                child: Icon(
                                  Icons.handyman,
                                  color: Colors.white,
                                ),
                              ),
                              title: Text(
                                'Demande du ${_formatDate(request.requestDate)}',
                                style: const TextStyle(fontWeight: FontWeight.bold),
                              ),
                              subtitle: Text(
                                request.description.length > 50
                                    ? '${request.description.substring(0, 50)}...'
                                    : request.description,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                              onTap: () {
                                Navigator.pushNamed(
                                  context,
                                  '/vendor/request-detail',
                                  arguments: request,
                                ).then((_) => _loadData());
                              },
                            ),
                          );
                        },
                      ),
          ],
        ),
      ),
    );
  }
  
  Color _getStatusColor(String status) {
    switch (status) {
      case 'pending':
        return Colors.orange;
      case 'processing':
        return Colors.blue;
      case 'completed':
        return Colors.green;
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
  
  String _getStatusLabel(String status) {
    switch (status) {
      case 'pending':
        return 'En attente';
      case 'processing':
        return 'En cours';
      case 'completed':
        return 'Terminé';
      case 'cancelled':
        return 'Annulé';
      default:
        return status;
    }
  }
}