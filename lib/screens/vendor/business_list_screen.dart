// Fichier screens/vendor/business_list_screen.dart
import 'package:flutter/material.dart';
import '../../models/business_model.dart';
import '../../services/business_service.dart';
import '../../services/error_handler.dart';
import '../../l10n/translations.dart';
import '../../utils/theme.dart';
import '../../widgets/vendor/vendor_app_bar.dart';
import '../../widgets/common/loading_indicator.dart';
import 'business_detail_screen.dart';
import 'add_business_screen.dart';

class BusinessListScreen extends StatefulWidget {
  const BusinessListScreen({super.key});

  @override
  State<BusinessListScreen> createState() => _BusinessListScreenState();
}

class _BusinessListScreenState extends State<BusinessListScreen> {
  final BusinessService _businessService = BusinessService();
  
  List<BusinessModel> _businesses = [];
  bool _isLoading = true;
  
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
      final businesses = await _businessService.getUserBusinesses();
      
      setState(() {
        _businesses = businesses;
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
  
  void _navigateToAddBusiness() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const AddBusinessScreen(),
      ),
    ).then((_) => _loadBusinesses());
  }
  
  void _navigateToBusinessDetail(BusinessModel business) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => BusinessDetailScreen(business: business),
      ),
    ).then((_) => _loadBusinesses());
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: VendorAppBar(
        title: AppTranslations.text(context, 'my_businesses'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadBusinesses,
            tooltip: AppTranslations.text(context, 'refresh'),
          ),
        ],
      ),
      body: _isLoading
          ? Center(
              child: LoadingIndicator(
                message: AppTranslations.text(context, 'loading_businesses'),
                animationType: AnimationType.bounce,
                color: AppTheme.primaryColor,
              ),
            )
          : _businesses.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.store_mall_directory_outlined,
                        size: 80,
                        color: Colors.grey,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        AppTranslations.text(context, 'no_businesses_yet'),
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        AppTranslations.text(context, 'add_first_business'),
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.grey[600],
                        ),
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton.icon(
                        onPressed: _navigateToAddBusiness,
                        icon: const Icon(Icons.add_business),
                        label: Text(AppTranslations.text(context, 'add_business')),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _loadBusinesses,
                  child: ListView.builder(
                    itemCount: _businesses.length,
                    padding: const EdgeInsets.all(16),
                    itemBuilder: (context, index) {
                      final business = _businesses[index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 2,
                        child: InkWell(
                          onTap: () => _navigateToBusinessDetail(business),
                          borderRadius: BorderRadius.circular(12),
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    CircleAvatar(
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
                                    const SizedBox(width: 16),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            business.name,
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 18,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            business.businessType == 'fixe'
                                                ? AppTranslations.text(context, 'fixed_business')
                                                : AppTranslations.text(context, 'mobile_business'),
                                            style: TextStyle(
                                              color: Colors.grey[600],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 12,
                                        vertical: 6,
                                      ),
                                      decoration: BoxDecoration(
                                        color: business.isOpenNow()
                                            ? Colors.green
                                            : Colors.red,
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      child: Text(
                                        business.isOpenNow()
                                            ? AppTranslations.text(context, 'open')
                                            : AppTranslations.text(context, 'closed'),
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 16),
                                
                                // Adresse
                                Row(
                                  children: [
                                    const Icon(Icons.location_on, color: Colors.grey, size: 16),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        business.address,
                                        style: TextStyle(
                                          color: Colors.grey[700],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                
                                // Horaires
                                Row(
                                  children: [
                                    const Icon(Icons.access_time, color: Colors.grey, size: 16),
                                    const SizedBox(width: 8),
                                    Text(
                                      '${business.openingTime} - ${business.closingTime}',
                                      style: TextStyle(
                                        color: Colors.grey[700],
                                      ),
                                    ),
                                  ],
                                ),
                                
                                const Divider(height: 24),
                                
                                // Actions
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    TextButton.icon(
                                      onPressed: () {
                                        // Naviguer vers les produits
                                        Navigator.pushNamed(
                                          context,
                                          '/vendor/products',
                                          arguments: business,
                                        ).then((_) => _loadBusinesses());
                                      },
                                      icon: const Icon(Icons.inventory),
                                      label: Text(AppTranslations.text(context, 'products')),
                                    ),
                                    const SizedBox(width: 8),
                                    ElevatedButton.icon(
                                      onPressed: () => _navigateToBusinessDetail(business),
                                      icon: const Icon(Icons.edit),
                                      label: Text(AppTranslations.text(context, 'manage')),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: _navigateToAddBusiness,
        tooltip: AppTranslations.text(context, 'add_business'),
        child: const Icon(Icons.add),
      ),
    );
  }
}