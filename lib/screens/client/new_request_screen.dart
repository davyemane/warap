// Fichier screens/client/new_request_screen.dart
import 'package:flutter/material.dart';
import '../../models/business_model.dart';
import '../../services/business_service.dart';
import '../../services/error_handler.dart';
import '../../l10n/translations.dart';
import '../../widgets/common/custom_app_bar.dart';
import '../../widgets/common/loading_indicator.dart';
import 'request_service_screen.dart';

// Cette classe sert de wrapper pour RequestServiceScreen
// Elle permet à l'utilisateur de sélectionner un commerce avant de passer à l'écran de demande
class NewRequestScreen extends StatefulWidget {
  const NewRequestScreen({super.key});

  @override
  State<NewRequestScreen> createState() => _NewRequestScreenState();
}

class _NewRequestScreenState extends State<NewRequestScreen> {
  final BusinessService _businessService = BusinessService();
  
  List<BusinessModel> _businesses = [];
  List<BusinessModel> _filteredBusinesses = [];
  bool _isLoading = true;
  String _searchQuery = '';
  bool _showMobileOnly = true;  // Par défaut, montrer seulement les commerces mobiles
  
  @override
  void initState() {
    super.initState();
    _loadBusinesses();
  }
  
  Future<void> _loadBusinesses() async {
    setState(() {
      _isLoading = true;
    });
    
    try {
      final businesses = await _businessService.getAllBusinesses();
      
      setState(() {
        _businesses = businesses;
        _applyFilters();
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
          fallbackMessage: AppTranslations.text(context, 'error_loading_businesses'),
          onRetry: _loadBusinesses,
        );
      }
    }
  }
  
  void _applyFilters() {
    List<BusinessModel> filtered = _businesses;
    
    // Filtre par type si l'option est activée
    if (_showMobileOnly) {
      filtered = filtered.where((business) => business.businessType == 'mobile').toList();
    }
    
    // Filtre par recherche
    if (_searchQuery.isNotEmpty) {
      final query = _searchQuery.toLowerCase();
      filtered = filtered.where((business) {
        final name = business.name.toLowerCase();
        final description = business.description.toLowerCase();
        return name.contains(query) || description.contains(query);
      }).toList();
    }
    
    setState(() {
      _filteredBusinesses = filtered;
    });
  }
  
  void _selectBusiness(BuildContext context, BusinessModel business) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => RequestServiceScreen(business: business),
      ),
    ).then((success) {
      if (success == true) {
        // Si la demande a été envoyée avec succès, revenir à l'écran précédent
        Navigator.pop(context);
      }
    });
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: AppTranslations.text(context, 'select_business'),
        showBackButton: true,
      ),
      body: Column(
        children: [
          // En-tête avec description
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.blue.shade50,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AppTranslations.text(context, 'request_service_intro'),
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  AppTranslations.text(context, 'select_business_description'),
                  style: TextStyle(
                    color: Colors.grey[700],
                  ),
                ),
              ],
            ),
          ),
          
          // Barre de recherche et filtre
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                TextField(
                  decoration: InputDecoration(
                    hintText: AppTranslations.text(context, 'search_business'),
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    contentPadding: const EdgeInsets.symmetric(vertical: 0),
                  ),
                  onChanged: (value) {
                    setState(() {
                      _searchQuery = value;
                      _applyFilters();
                    });
                  },
                ),
                const SizedBox(height: 8),
                SwitchListTile(
                  title: Text(AppTranslations.text(context, 'show_mobile_only')),
                  subtitle: Text(AppTranslations.text(context, 'mobile_business_description')),
                  value: _showMobileOnly,
                  onChanged: (value) {
                    setState(() {
                      _showMobileOnly = value;
                      _applyFilters();
                    });
                  },
                  contentPadding: EdgeInsets.zero,
                ),
              ],
            ),
          ),
          
          // Liste des commerces
          Expanded(
            child: _isLoading
                ? Center(
                    child: LoadingIndicator(
                      message: AppTranslations.text(context, 'loading_businesses'),
                      animationType: AnimationType.bounce,
                      color: Theme.of(context).primaryColor,
                    ),
                  )
                : _filteredBusinesses.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.store_mall_directory,
                              size: 80,
                              color: Colors.grey[400],
                            ),
                            const SizedBox(height: 16),
                            Text(
                              AppTranslations.text(context, 'no_businesses_found'),
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 8),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 32),
                              child: Text(
                                _showMobileOnly
                                    ? AppTranslations.text(context, 'try_all_businesses')
                                    : AppTranslations.text(context, 'try_different_search'),
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: Colors.grey[600],
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),
                            if (_showMobileOnly)
                              TextButton(
                                onPressed: () {
                                  setState(() {
                                    _showMobileOnly = false;
                                    _applyFilters();
                                  });
                                },
                                child: Text(AppTranslations.text(context, 'show_all_businesses')),
                              ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        itemCount: _filteredBusinesses.length,
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        itemBuilder: (context, index) {
                          final business = _filteredBusinesses[index];
                          return Card(
                            margin: const EdgeInsets.only(bottom: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: ListTile(
                              contentPadding: const EdgeInsets.all(12),
                              leading: CircleAvatar(
                                backgroundColor: business.businessType == 'fixe'
                                    ? Colors.blue
                                    : Colors.green,
                                radius: 24,
                                child: Icon(
                                  business.businessType == 'fixe'
                                      ? Icons.store
                                      : Icons.delivery_dining,
                                  color: Colors.white,
                                  size: 24,
                                ),
                              ),
                              title: Text(
                                business.name,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const SizedBox(height: 4),
                                  Text(
                                    business.description,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 4),
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.circle,
                                        size: 10,
                                        color: business.isOpenNow() ? Colors.green : Colors.red,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        business.isOpenNow()
                                            ? AppTranslations.text(context, 'open')
                                            : AppTranslations.text(context, 'closed'),
                                        style: TextStyle(
                                          color: business.isOpenNow() ? Colors.green : Colors.red,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              onTap: () => _selectBusiness(context, business),
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }
}