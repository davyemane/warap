// Fichier screens/vendor/statistics_screen.dart
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../models/business_model.dart';
import '../../services/business_service.dart';
import '../../services/auth_service.dart';
import 'package:share_plus/share_plus.dart';

class StatisticsScreen extends StatefulWidget {
  final bool showAppBar;
  
  const StatisticsScreen({
    Key? key, 
    this.showAppBar = true
  }) : super(key: key);

  @override
  State<StatisticsScreen> createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends State<StatisticsScreen> {
  final BusinessService _businessService = BusinessService();
  final AuthService _authService = AuthService();
  
  List<BusinessModel> _vendorBusinesses = [];
  Map<String, int> _viewsData = {};
  Map<String, int> _favoritesData = {};
  bool _isLoading = true;
  
  // Période sélectionnée
  String _selectedPeriod = 'Semaine';
  
  @override
  void initState() {
    super.initState();
    _loadStatisticsData();
  }
  
  Future<void> _loadStatisticsData() async {
    setState(() {
      _isLoading = true;
    });
    
    try {
      // Récupérer l'ID de l'utilisateur connecté
      final userId = Supabase.instance.client.auth.currentUser!.id;
      
      // Récupérer les commerces du vendeur
      final businesses = await _businessService.getVendorBusinesses(userId);
      
      // Simuler des données de statistiques pour chaque commerce
      // Dans une vraie application, ces données viendraient d'une table de statistiques
      final Map<String, int> views = {};
      final Map<String, int> favorites = {};
      
      for (var business in businesses) {
        // Générer des nombres basés sur les attributs du commerce pour la démonstration
        views[business.id] = 100 + (business.name.length * 10); // Simulation
        favorites[business.id] = 10 + (business.name.length * 2); // Simulation
      }
      
      setState(() {
        _vendorBusinesses = businesses;
        _viewsData = views;
        _favoritesData = favorites;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      print('Erreur lors du chargement des statistiques: $e');
    }
  }
  
  // Calculer le total des vues
  int get _totalViews => _viewsData.values.fold(0, (sum, views) => sum + views);
  
  // Calculer le total des favoris
  int get _totalFavorites => _favoritesData.values.fold(0, (sum, favs) => sum + favs);
  
  // Nombre de commerces
  int get _businessCount => _vendorBusinesses.length;
  
  // Nombre de mises à jour (simulé)
// Remplacez cette méthode qui cause l'erreur
int get _updatesCount => _vendorBusinesses.fold(0, 
    (sum, business) => sum + (business.updatedAt != null ? 1 : 0));  
  // Générer les données du graphique en fonction des commerces
  List<FlSpot> get _weeklyViewsData {
    // Dans une vraie application, ces données viendraient d'une base de données
    List<FlSpot> spots = [];
    final int businessCount = _vendorBusinesses.length;
    
    for (int i = 0; i < 7; i++) {
      // Base value influenced by number of businesses
      double value = 3.0;
      
      // Add business-based variation
      if (businessCount > 0) {
        value += (businessCount * 0.8);
        
        // Use business attributes to influence the chart
        for (var business in _vendorBusinesses) {
          // Create a deterministic but varied pattern
          final dayFactor = (business.name.length + i) % 5;
          value += dayFactor * 0.2;
        }
      }
      
      // Add day-specific patterns
      if (i == 5) value += 1.5; // Saturday peak
      if (i == 6) value += 0.5; // Sunday slightly higher
      if (i == 0) value -= 0.5; // Monday dip
      
      spots.add(FlSpot(i.toDouble(), value));
    }
    return spots;
  }
  
  // Fonction pour partager les statistiques
  void _shareStatistics() {
    final message = """
Statistiques de mes commerces sur Commerce Connect

Vues totales: $_totalViews
Favoris: $_totalFavorites
Nombre de commerces: $_businessCount

Mes commerces:
${_vendorBusinesses.map((b) => "- ${b.name} (${b.businessType})").join('\n')}

Rejoignez Commerce Connect pour découvrir des commerces à proximité!
""";

    Share.share(message, subject: 'Mes statistiques sur Commerce Connect');
  }
  
  // Fonction pour partager un commerce spécifique
  void _shareBusiness(BusinessModel business) {
    final String message = """
${business.name}
${business.businessType == 'fixe' ? 'Commerce fixe' : 'Commerce mobile'}
${business.isOpenNow() ? 'Ouvert' : 'Fermé'} - Horaires: ${business.openingTime} - ${business.closingTime}
${business.address.isNotEmpty ? 'Adresse: ${business.address}' : ''}
${business.description.isNotEmpty ? '\n${business.description}' : ''}

Découvrez ce commerce sur Commerce Connect!
""";

    Share.share(message, subject: 'Découvrez ${business.name}');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: widget.showAppBar ? AppBar(
        title: const Text('Statistiques'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadStatisticsData,
          ),
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: _shareStatistics,
            tooltip: 'Partager les statistiques',
          ),
        ],
      ) : null,
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // En-tête et sélecteur de période
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Vue d\'ensemble de votre activité',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      // Dropdown pour sélectionner la période
                      DropdownButton<String>(
                        value: _selectedPeriod,
                        underline: Container(),
                        icon: const Icon(Icons.keyboard_arrow_down),
                        items: ['Jour', 'Semaine', 'Mois', 'Année']
                            .map((period) => DropdownMenuItem<String>(
                                  value: period,
                                  child: Text(period),
                                ))
                            .toList(),
                        onChanged: (value) {
                          if (value != null) {
                            setState(() {
                              _selectedPeriod = value;
                              // Ici, vous pourriez charger des données différentes
                              // selon la période sélectionnée
                            });
                          }
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  
                  // Carte avec les statistiques de visualisation
                  Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
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
                                'Visualisations',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              // Badge pour montrer la tendance
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.green.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Row(
                                  children: const [
                                    Icon(
                                      Icons.arrow_upward,
                                      color: Colors.green,
                                      size: 14,
                                    ),
                                    SizedBox(width: 4),
                                    Text(
                                      '+12%',
                                      style: TextStyle(
                                        color: Colors.green,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          SizedBox(
                            height: 200,
                            child: LineChart(
                              LineChartData(
                                gridData: FlGridData(
                                  show: true,
                                  drawVerticalLine: false,
                                  horizontalInterval: 1,
                                  getDrawingHorizontalLine: (value) {
                                    return FlLine(
                                      color: Colors.grey.withOpacity(0.2),
                                      strokeWidth: 1,
                                    );
                                  },
                                ),
                                titlesData: FlTitlesData(
                                  leftTitles: AxisTitles(
                                    sideTitles: SideTitles(
                                      showTitles: true,
                                      reservedSize: 30,
                                      getTitlesWidget: (value, meta) {
                                        return Padding(
                                          padding: const EdgeInsets.only(right: 8.0),
                                          child: Text(
                                            value.toInt().toString(),
                                            style: const TextStyle(
                                              color: Colors.grey,
                                              fontSize: 10,
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                  rightTitles: AxisTitles(
                                    sideTitles: SideTitles(showTitles: false),
                                  ),
                                  topTitles: AxisTitles(
                                    sideTitles: SideTitles(showTitles: false),
                                  ),
                                  bottomTitles: AxisTitles(
                                    sideTitles: SideTitles(
                                      showTitles: true,
                                      reservedSize: 30,
                                      getTitlesWidget: (value, meta) {
                                        const style = TextStyle(
                                          color: Colors.grey,
                                          fontSize: 12,
                                        );
                                        String text;
                                        switch (value.toInt()) {
                                          case 0:
                                            text = 'Lun';
                                            break;
                                          case 1:
                                            text = 'Mar';
                                            break;
                                          case 2:
                                            text = 'Mer';
                                            break;
                                          case 3:
                                            text = 'Jeu';
                                            break;
                                          case 4:
                                            text = 'Ven';
                                            break;
                                          case 5:
                                            text = 'Sam';
                                            break;
                                          case 6:
                                            text = 'Dim';
                                            break;
                                          default:
                                            return Container();
                                        }
                                        return Text(text, style: style);
                                      },
                                    ),
                                  ),
                                ),
                                borderData: FlBorderData(show: false),
                                lineBarsData: [
                                  LineChartBarData(
                                    spots: _weeklyViewsData,
                                    isCurved: true,
                                    color: Colors.blue,
                                    barWidth: 3,
                                    isStrokeCapRound: true,
                                    dotData: FlDotData(
                                      show: true,
                                      getDotPainter: (spot, percent, barData, index) {
                                        return FlDotCirclePainter(
                                          radius: 4,
                                          color: Colors.white,
                                          strokeWidth: 2,
                                          strokeColor: Colors.blue,
                                        );
                                      },
                                    ),
                                    belowBarData: BarAreaData(
                                      show: true,
                                      color: Colors.blue.withOpacity(0.2),
                                    ),
                                  ),
                                ],
                                minY: 0,
              lineTouchData: LineTouchData(
                touchTooltipData: LineTouchTooltipData(
                  // Suppression de la ligne problématique
                  getTooltipItems: (touchedSpots) {
                    return touchedSpots.map((touchedSpot) {
                      return LineTooltipItem(
                        '${touchedSpot.y.toInt()}',
                        const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      );
                    }).toList();
                  },
                ),
              ),
            ),
          ),
        ),
      ],
    ),
  ),
),
                  
                  const SizedBox(height: 24),
                  
                  // Statistiques en chiffres
                  Row(
                    children: [
                      Expanded(
                        child: _StatCard(
                          title: 'Vues totales',
                          value: _totalViews.toString(),
                          icon: Icons.visibility,
                          color: Colors.blue,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _StatCard(
                          title: 'Favoris',
                          value: _totalFavorites.toString(),
                          icon: Icons.favorite,
                          color: Colors.red,
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 16),
                  
                  Row(
                    children: [
                      Expanded(
                        child: _StatCard(
                          title: 'Mises à jour',
                          value: _updatesCount.toString(),
                          icon: Icons.update,
                          color: Colors.green,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _StatCard(
                          title: 'Commerces',
                          value: _businessCount.toString(),
                          icon: Icons.store,
                          color: Colors.orange,
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Section des commerces populaires
                  const Text(
                    'Commerces populaires',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  _vendorBusinesses.isEmpty
                  ? const Center(
                      child: Text(
                        'Vous n\'avez pas encore de commerce',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey,
                        ),
                      ),
                    )
                  : Column(
                      children: _vendorBusinesses.map((business) => Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: _PopularBusinessCard(
                          business: business,
                          views: _viewsData[business.id]?.toString() ?? '0',
                          favorites: _favoritesData[business.id]?.toString() ?? '0',
                          onSharePressed: () => _shareBusiness(business),
                        ),
                      )).toList(),
                    ),
                ],
              ),
            ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[700],
                  ),
                ),
                Icon(icon, color: color),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PopularBusinessCard extends StatelessWidget {
  final BusinessModel business;
  final String views;
  final String favorites;
  final VoidCallback onSharePressed;

  const _PopularBusinessCard({
    required this.business,
    required this.views,
    required this.favorites,
    required this.onSharePressed,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          children: [
            // Icône du commerce
            CircleAvatar(
              backgroundColor: business.businessType == 'fixe' ? Colors.blue : Colors.green,
              child: Icon(
                business.businessType == 'fixe' ? Icons.store : Icons.delivery_dining,
                color: Colors.white,
              ),
            ),
            const SizedBox(width: 16),
            // Informations
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    business.name,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(Icons.visibility, size: 16, color: Colors.grey[600]),
                      const SizedBox(width: 4),
                      Text(
                        views,
                        style: TextStyle(color: Colors.grey[600], fontSize: 14),
                      ),
                      const SizedBox(width: 16),
                      Icon(Icons.favorite, size: 16, color: Colors.red[400]),
                      const SizedBox(width: 4),
                      Text(
                        favorites,
                        style: TextStyle(color: Colors.grey[600], fontSize: 14),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            // Bouton de partage
            IconButton(
              icon: const Icon(Icons.share, color: Colors.green),
              onPressed: onSharePressed,
              tooltip: 'Partager ce commerce',
            ),
          ],
        ),
      ),
    );
  }
}