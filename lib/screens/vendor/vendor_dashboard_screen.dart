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
  const VendorDashboardScreen({super.key});

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
  bool _hasError = false;
  String _errorMessage = '';

  String _selectedPeriod = 'week';
  String _selectedMetric = 'revenue';
  Map<String, dynamic> _statistics = {};

  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey =
      GlobalKey<RefreshIndicatorState>();

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _navigateToNotifications() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const OrdersScreen(),
      ),
    ).then((_) => _loadData());
  }

  Future<void> _loadData() async {
    setState(() {
      _hasError = false;
      _errorMessage = '';
    });

    await Future.wait([
      _loadBusinesses(),
      _loadOrders(),
      _loadRequests(),
      _loadStatistics(),
    ]);
  }

  Future<void> _loadBusinesses() async {
    try {
      setState(() {
        _isLoadingBusinesses = true;
      });

      print('🔍 Chargement des commerces...');

      // Récupérer les vrais commerces depuis Supabase
      final businesses = await _businessService.getUserBusinesses();

      print('✅ ${businesses.length} commerces récupérés');

      if (mounted) {
        setState(() {
          _userBusinesses = businesses;
          _isLoadingBusinesses = false;
        });
      }
    } catch (e) {
      print('❌ Erreur lors du chargement des commerces: $e');

      if (mounted) {
        setState(() {
          _isLoadingBusinesses = false;
          _hasError = true;
          _errorMessage = 'Erreur lors du chargement des commerces: $e';
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
    try {
      setState(() {
        _isLoadingOrders = true;
      });

      print('🔍 Chargement des commandes récentes...');

      // Récupérer les vraies commandes récentes depuis Supabase
      final orders = await _orderService.getRecentOrders(limit: 5);

      print('✅ ${orders.length} commandes récupérées');

      if (mounted) {
        setState(() {
          _recentOrders = orders;
          _isLoadingOrders = false;
        });
      }
    } catch (e) {
      print('❌ Erreur lors du chargement des commandes: $e');

      if (mounted) {
        setState(() {
          _isLoadingOrders = false;
          _hasError = true;
          _errorMessage = 'Erreur lors du chargement des commandes: $e';
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
    try {
      setState(() {
        _isLoadingRequests = true;
      });

      print('🔍 Chargement des demandes de service...');

      // Récupérer les vraies demandes de service depuis Supabase
      final requests = await _requestService.getPendingRequests();

      print('✅ ${requests.length} demandes récupérées');

      if (mounted) {
        setState(() {
          _pendingRequests = requests;
          _isLoadingRequests = false;
        });
      }
    } catch (e) {
      print('❌ Erreur lors du chargement des requêtes: $e');

      if (mounted) {
        setState(() {
          _isLoadingRequests = false;
          _hasError = true;
          _errorMessage = 'Erreur lors du chargement des requêtes: $e';
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
    try {
      setState(() {
        _isLoadingStats = true;
      });

      print(
          '🔍 Chargement des statistiques (période: $_selectedPeriod, métrique: $_selectedMetric)...');

      // Récupérer les vraies statistiques depuis Supabase
      final stats = await _orderService.getStatistics(
        period: _selectedPeriod,
        metric: _selectedMetric,
      );

      print('✅ Statistiques récupérées: ${stats.keys.join(', ')}');

      if (mounted) {
        setState(() {
          _statistics = stats;
          _isLoadingStats = false;
        });
      }
    } catch (e) {
      print('❌ Erreur lors du chargement des statistiques: $e');

      if (mounted) {
        setState(() {
          _isLoadingStats = false;
          _hasError = true;
          _errorMessage = 'Erreur lors du chargement des statistiques: $e';
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
        builder: (context) => OrderDetailScreenVendor(orderId: order.id),
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
        builder: (context) =>
            ProductListScreen(business: _userBusinesses.first),
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
    final bool isLoading = _isLoadingBusinesses ||
        _isLoadingOrders ||
        _isLoadingRequests ||
        _isLoadingStats;

    return Scaffold(
      appBar: VendorAppBar(
        title: 'Tableau de bord',
        onNotificationPressed: _navigateToNotifications,
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
      body: _hasError
          ? _buildErrorView()
          : RefreshIndicator(
              key: _refreshIndicatorKey,
              onRefresh: _loadData,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Résumé général
                    _buildSummaryHeader(),
                    const SizedBox(height: 16),

                    // Carte de statistiques
                    _buildSummaryCard(isLoading),
                    const SizedBox(height: 24),

                    // Actions rapides
                    _buildQuickActionsScrollable(),
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

  Widget _buildErrorView() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.red,
            ),
            const SizedBox(height: 16),
            Text(
              'Oops, quelque chose s\'est mal passé',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.error,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              _errorMessage.isNotEmpty
                  ? _errorMessage
                  : 'Nous n\'avons pas pu charger vos données. Veuillez réessayer.',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _loadData,
              icon: const Icon(Icons.refresh),
              label: const Text('Réessayer'),
              style: ElevatedButton.styleFrom(
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: Theme.of(context).primaryColor.withOpacity(0.1),
            radius: 24,
            child: Icon(
              Icons.trending_up,
              color: Theme.of(context).primaryColor,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Bonjour,',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[600],
                  ),
                ),
                Text(
                  'Bienvenue sur votre tableau de bord',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
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
                Container(
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  child: DropdownButton<String>(
                    value: _selectedPeriod,
                    underline: Container(),
                    icon: const Icon(Icons.arrow_drop_down, size: 20),
                    style: TextStyle(
                      color: Colors.grey[800],
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
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
                    onChanged: isLoading
                        ? null
                        : (value) {
                            if (value != null) _changePeriod(value);
                          },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Sélecteur de métrique
            Row(
              children: [
                _buildMetricButton('revenue', Icons.euro, 'Revenus'),
                const SizedBox(width: 12),
                _buildMetricButton('orders', Icons.shopping_bag, 'Commandes'),
                const SizedBox(width: 12),
                _buildMetricButton('customers', Icons.people, 'Clients'),
              ],
            ),
            const SizedBox(height: 24),

            // Graphique
            SizedBox(
              height: 200,
              child: isLoading || _isLoadingStats
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const CircularProgressIndicator(),
                          const SizedBox(height: 16),
                          Text(
                            'Chargement des données...',
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    )
                  : _statistics.isEmpty ||
                          (_statistics['data'] as List?)?.isEmpty == true
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.analytics_outlined,
                                size: 48,
                                color: Colors.grey[400],
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'Aucune donnée disponible pour cette période',
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: 14,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        )
                      : _buildChart(),
            ),

            // Résumé des statistiques
            const SizedBox(height: 24),
            _buildStatsSummary(isLoading),
          ],
        ),
      ),
    );
  }

  Widget _buildChart() {
    if (_statistics['data'] == null || _statistics['labels'] == null) {
      return Center(
        child: Text(
          'Données incomplètes pour le graphique',
          style: TextStyle(color: Colors.grey[600]),
        ),
      );
    }

    final List<double> data = List<double>.from(_statistics['data'] as List);
    final List<String> labels =
        List<String>.from(_statistics['labels'] as List);

    // Si aucune donnée n'est supérieure à 0, afficher un message
    if (data.every((element) => element == 0)) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.analytics_outlined,
              size: 48,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'Aucune donnée pour cette période',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    // Créer les spots pour le graphique
    final List<FlSpot> spots = [];
    for (int i = 0; i < data.length; i++) {
      spots.add(FlSpot(i.toDouble(), data[i]));
    }

    return LineChart(
      LineChartData(
        lineTouchData: LineTouchData(
          touchTooltipData: LineTouchTooltipData(
            // Remplacer tooltipBgColor par cette méthode
            tooltipRoundedRadius: 8,
            tooltipPadding: const EdgeInsets.all(8),
            tooltipBorder: const BorderSide(color: Colors.transparent),
            getTooltipColor: (touchedSpot) => const Color(0xFF37474F),
            getTooltipItems: (List<LineBarSpot> touchedBarSpots) {
              return touchedBarSpots.map((barSpot) {
                final int index = barSpot.x.toInt();
                final String value = _selectedMetric == 'revenue'
                    ? '${barSpot.y.toStringAsFixed(2)} €'
                    : barSpot.y.toStringAsFixed(0);

                return LineTooltipItem(
                  '${labels[index]}: $value',
                  const TextStyle(color: Colors.white),
                );
              }).toList();
            },
          ),
        ),
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          horizontalInterval: 1,
          getDrawingHorizontalLine: (value) {
            return FlLine(
              color: Colors.grey[300],
              strokeWidth: 1,
              dashArray: [5, 5],
            );
          },
        ),
        titlesData: FlTitlesData(
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 30,
              interval: _selectedPeriod == 'year' ? 1 : 2,
              getTitlesWidget: (value, meta) {
                if (value < 0 || value >= labels.length) {
                  return const SizedBox.shrink();
                }

                return Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Text(
                    labels[value.toInt()],
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 10,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                );
              },
            ),
          ),
          leftTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          topTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          rightTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
        ),
        borderData: FlBorderData(show: false),
        lineBarsData: [
          LineChartBarData(
            spots: spots,
            isCurved: true,
            color: Theme.of(context).primaryColor,
            barWidth: 4,
            isStrokeCapRound: true,
            dotData: FlDotData(
              show: true,
              getDotPainter: (spot, percent, barData, index) {
                return FlDotCirclePainter(
                  radius: 4,
                  color: Theme.of(context).primaryColor,
                  strokeWidth: 2,
                  strokeColor: Colors.white,
                );
              },
            ),
            belowBarData: BarAreaData(
              show: true,
              // CORRECTION : Suppression des propriétés incompatibles
              gradient: LinearGradient(
                colors: [
                  Theme.of(context).primaryColor.withOpacity(0.3),
                  Theme.of(context).primaryColor.withOpacity(0.05),
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsSummary(bool isLoading) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatisticItem(
            isLoading ? '...' : _statistics['total']?.toString() ?? '0',
            _selectedMetric == 'revenue' ? '€' : '',
            'Total',
          ),
          Container(
            height: 40,
            width: 1,
            color: Colors.grey[300],
          ),
          _buildStatisticItem(
            isLoading ? '...' : _statistics['average']?.toString() ?? '0',
            _selectedMetric == 'revenue' ? '€' : '',
            'Moyenne',
          ),
          Container(
            height: 40,
            width: 1,
            color: Colors.grey[300],
          ),
          _buildStatisticItem(
            isLoading ? '...' : _statistics['growth']?.toString() ?? '0',
            '%',
            'Croissance',
            showTrend: true,
            isPositive: _statistics['growth'] != null
                ? (double.tryParse(_statistics['growth'].toString()) ?? 0) >= 0
                : true,
          ),
        ],
      ),
    );
  }

  Widget _buildMetricButton(String metric, IconData icon, String label) {
    final isSelected = _selectedMetric == metric;

    return Expanded(
      child: InkWell(
        onTap: _isLoadingStats ? null : () => _changeMetric(metric),
        borderRadius: BorderRadius.circular(8),
        child: Opacity(
          opacity: _isLoadingStats ? 0.6 : 1.0,
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
            decoration: BoxDecoration(
              color: isSelected
                  ? Theme.of(context).primaryColor
                  : Colors.grey[200],
              borderRadius: BorderRadius.circular(8),
              boxShadow: isSelected
                  ? [
                      BoxShadow(
                        color: Theme.of(context).primaryColor.withOpacity(0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ]
                  : null,
            ),
            child: Column(
              children: [
                Icon(
                  icon,
                  color: isSelected ? Colors.white : Colors.grey[600],
                  size: 20,
                ),
                const SizedBox(height: 6),
                Text(
                  label,
                  style: TextStyle(
                    color: isSelected ? Colors.white : Colors.grey[600],
                    fontWeight:
                        isSelected ? FontWeight.bold : FontWeight.normal,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatisticItem(String value, String unit, String label,
      {bool showTrend = false, bool isPositive = true}) {
    // Formater la valeur pour un meilleur affichage
    String displayValue = value;
    if (value != '...' && double.tryParse(value) != null) {
      final doubleValue = double.parse(value);

      // Si c'est un montant d'argent, formater avec des séparateurs de milliers
      if (unit == '€') {
        final formatter = NumberFormat.currency(
            locale: 'fr_FR', symbol: '', decimalDigits: 2);
        displayValue = formatter.format(doubleValue);
      }
      // Si c'est un nombre entier, formater sans décimales
      else if (doubleValue.toInt() == doubleValue) {
        final formatter = NumberFormat.decimalPattern('fr_FR');
        displayValue = formatter.format(doubleValue.toInt());
      }
      // Sinon, limiter à 1 décimale
      else {
        displayValue = doubleValue.toStringAsFixed(1);
      }
    }

    return Column(
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            RichText(
              text: TextSpan(
                style: DefaultTextStyle.of(context).style.copyWith(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                children: [
                  TextSpan(text: displayValue),
                  TextSpan(
                    text: unit,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            if (showTrend && value != '...')
              Padding(
                padding: const EdgeInsets.only(left: 4.0),
                child: Icon(
                  isPositive ? Icons.trending_up : Icons.trending_down,
                  color: isPositive ? Colors.green : Colors.red,
                  size: 16,
                ),
              ),
          ],
        ),
        const SizedBox(height: 4),
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

  Widget _buildQuickActionsScrollable() {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Actions rapides',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.info_outline, size: 18),
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                            'Accédez rapidement aux fonctionnalités principales'),
                        duration: Duration(seconds: 2),
                      ),
                    );
                  },
                ),
              ],
            ),
            const SizedBox(height: 16),
            // ScrollView horizontal pour les boutons
            SizedBox(
              height: 100, // Hauteur fixe pour les boutons
              child: ListView(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                children: [
                  _buildActionButtonScrollable(
                    Icons.add_business,
                    'Ajouter\ncommerce',
                    _navigateToAddBusiness,
                    Colors.blue,
                  ),
                  const SizedBox(width: 16),
                  _buildActionButtonScrollable(
                    Icons.inventory,
                    'Produits',
                    _navigateToProducts,
                    Colors.green,
                  ),
                  const SizedBox(width: 16),
                  _buildActionButtonScrollable(
                    Icons.list_alt,
                    'Commandes',
                    _navigateToOrders,
                    Colors.orange,
                  ),
                  const SizedBox(width: 16),
                  _buildActionButtonScrollable(
                    Icons.people,
                    'Clients',
                    _navigateToClients,
                    Colors.purple,
                  ),
                  const SizedBox(width: 16), // Padding final
                ],
              ),
            ),
            // Indicateur de scroll (optionnel)
            Center(
              child: Container(
                margin: const EdgeInsets.only(top: 8),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.swipe,
                      size: 16,
                      color: Colors.grey[400],
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Glissez pour plus d\'options',
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.grey[500],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtonScrollable(
      IconData icon, String label, VoidCallback onTap, Color color) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: 85, // Largeur fixe pour éviter l'overflow
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: color.withOpacity(0.05),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: color.withOpacity(0.2),
            width: 1,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(
                    color: color.withOpacity(0.1),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Icon(
                icon,
                color: color,
                size:
                    20, // Légèrement réduit pour laisser plus de place au texte
              ),
            ),
            const SizedBox(height: 6),
            // Texte avec contraintes pour éviter l'overflow
            Flexible(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey[800],
                ),
                textAlign: TextAlign.center,
                maxLines: 2, // Maximum 2 lignes
                overflow:
                    TextOverflow.ellipsis, // Points de suspension si trop long
              ),
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
      elevation: 3,
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
                  TextButton.icon(
                    onPressed: () {
                      Navigator.pushNamed(context, '/vendor/businesses');
                    },
                    icon: const Icon(Icons.arrow_forward, size: 16),
                    label: Text(
                      'Voir tout',
                      style: TextStyle(
                        color: Theme.of(context).primaryColor,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            _isLoadingBusinesses
                ? const Center(
                    child: Padding(
                      padding: EdgeInsets.all(20.0),
                      child: CircularProgressIndicator(),
                    ),
                  )
                : _userBusinesses.isEmpty
                    ? _buildEmptyBusinessesView()
                    : _buildBusinessesListView(),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyBusinessesView() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.store_mall_directory_outlined,
            size: 48,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          const Text(
            'Vous n\'avez pas encore de commerce',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            'Créez votre premier commerce pour commencer à vendre vos produits',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            onPressed: _navigateToAddBusiness,
            icon: const Icon(Icons.add_business),
            label: const Text('Ajouter un commerce'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBusinessesListView() {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _userBusinesses.length > 3 ? 3 : _userBusinesses.length,
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final business = _userBusinesses[index];
        return InkWell(
          onTap: () => _navigateToBusinessDetail(business),
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.1),
                  spreadRadius: 1,
                  blurRadius: 4,
                  offset: const Offset(0, 1),
                ),
              ],
              border: Border.all(color: Colors.grey[200]!),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 24,
                  backgroundColor: business.businessType == 'fixe'
                      ? Colors.blue.withOpacity(0.8)
                      : Colors.green.withOpacity(0.8),
                  child: Icon(
                    business.businessType == 'fixe'
                        ? Icons.store
                        : Icons.delivery_dining,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        business.name,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(
                            Icons.location_on,
                            size: 14,
                            color: Colors.grey[600],
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              business.address,
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 12,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: business.isOpenNow()
                        ? Colors.green.withOpacity(0.1)
                        : Colors.red.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: business.isOpenNow() ? Colors.green : Colors.red,
                      width: 1,
                    ),
                  ),
                  child: Text(
                    business.isOpenNow() ? 'Ouvert' : 'Fermé',
                    style: TextStyle(
                      color: business.isOpenNow() ? Colors.green : Colors.red,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Icon(
                  Icons.chevron_right,
                  color: Colors.grey[400],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildRecentOrders() {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      elevation: 3,
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
                TextButton.icon(
                  onPressed: _navigateToOrders,
                  icon: const Icon(Icons.arrow_forward, size: 16),
                  label: Text(
                    'Voir tout',
                    style: TextStyle(
                      color: Theme.of(context).primaryColor,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _isLoadingOrders
                ? const Center(
                    child: Padding(
                      padding: EdgeInsets.all(20.0),
                      child: CircularProgressIndicator(),
                    ),
                  )
                : _recentOrders.isEmpty
                    ? _buildEmptyOrdersView()
                    : _buildOrdersListView(),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyOrdersView() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.receipt_long,
            size: 48,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          const Text(
            'Aucune commande récente',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            'Les nouvelles commandes apparaîtront ici',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrdersListView() {
    return Column(
      children: List.generate(_recentOrders.length, (index) {
        final order = _recentOrders[index];
        return InkWell(
          onTap: () => _navigateToOrderDetail(order),
          child: Container(
            margin: EdgeInsets.only(
                bottom: index < _recentOrders.length - 1 ? 12 : 0),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.1),
                  spreadRadius: 1,
                  blurRadius: 4,
                  offset: const Offset(0, 1),
                ),
              ],
              border: Border.all(color: Colors.grey[200]!),
            ),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: _getStatusColor(order.status).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Center(
                    child: Text(
                      order.orderNumber.substring(0, 2).toUpperCase(),
                      style: TextStyle(
                        color: _getStatusColor(order.status),
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Commande #${order.orderNumber}',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(
                            Icons.shopping_bag_outlined,
                            size: 14,
                            color: Colors.grey[600],
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${order.items.length} article${order.items.length > 1 ? 's' : ''}',
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 12,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Icon(
                            Icons.euro,
                            size: 14,
                            color: Colors.grey[600],
                          ),
                          const SizedBox(width: 4),
                          Text(
                            order.total.toStringAsFixed(2),
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: _getStatusColor(order.status).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    _getStatusLabel(order.status),
                    style: TextStyle(
                      color: _getStatusColor(order.status),
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      }),
    );
  }

  Widget _buildPendingRequests() {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      elevation: 3,
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
                TextButton.icon(
                  onPressed: _navigateToRequests,
                  icon: const Icon(Icons.arrow_forward, size: 16),
                  label: Text(
                    'Voir tout',
                    style: TextStyle(
                      color: Theme.of(context).primaryColor,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _isLoadingRequests
                ? const Center(
                    child: Padding(
                      padding: EdgeInsets.all(20.0),
                      child: CircularProgressIndicator(),
                    ),
                  )
                : _pendingRequests.isEmpty
                    ? _buildEmptyRequestsView()
                    : _buildRequestsListView(),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyRequestsView() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.handyman_outlined,
            size: 48,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          const Text(
            'Aucune demande en attente',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            'Les nouvelles demandes de service apparaîtront ici',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRequestsListView() {
    return Column(
      children: List.generate(
        _pendingRequests.length > 2 ? 2 : _pendingRequests.length,
        (index) {
          final request = _pendingRequests[index];
          return InkWell(
            onTap: () => _navigateToRequests(),
            child: Container(
              margin: EdgeInsets.only(
                  bottom: index <
                          (_pendingRequests.length > 2
                                  ? 2
                                  : _pendingRequests.length) -
                              1
                      ? 12
                      : 0),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.1),
                    spreadRadius: 1,
                    blurRadius: 4,
                    offset: const Offset(0, 1),
                  ),
                ],
                border: Border.all(color: Colors.grey[200]!),
              ),
              child: Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: Colors.orange.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Center(
                      child: Icon(
                        Icons.build_outlined,
                        color: Colors.orange,
                        size: 24,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Demande du ${_formatDate(request.requestDate)}',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          request.description,
                          style: TextStyle(
                            color: Colors.grey[800],
                            fontSize: 13,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    Icons.chevron_right,
                    color: Colors.grey[400],
                  ),
                ],
              ),
            ),
          );
        },
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

  void _navigateToRequestDetail(ServiceRequestModel request) {
    Navigator.pushNamed(
      context,
      '/vendor/request-detail',
      arguments:
          request.id, // CHANGEMENT : passer l'ID au lieu de l'objet complet
    ).then((_) => _loadData());
  }
}
