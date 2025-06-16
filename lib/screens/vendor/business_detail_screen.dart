// Fichier screens/vendor/business_detail_screen.dart
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../models/business_model.dart';
import '../../models/product_model.dart';
import '../../services/business_service.dart';
import '../../services/product_service.dart';
import '../../services/error_handler.dart';
import '../../l10n/translations.dart';
import '../../widgets/common/custom_app_bar.dart';
import '../../widgets/common/loading_indicator.dart';
import 'edit_business_screen.dart';
import 'product_list_screen.dart';

class BusinessDetailScreen extends StatefulWidget {
  final BusinessModel business;
  
  const BusinessDetailScreen({super.key, required this.business});

  @override
  State<BusinessDetailScreen> createState() => _BusinessDetailScreenState();
}

class _BusinessDetailScreenState extends State<BusinessDetailScreen> {
  final BusinessService _businessService = BusinessService();
  final ProductService _productService = ProductService();
  
  BusinessModel? _business;
  List<ProductModel> _products = [];
  bool _isLoading = true;
  bool _isLoadingProducts = true;
  bool _isDeleting = false;
  
  @override
  void initState() {
    super.initState();
    _loadBusinessDetails();
    _loadProducts();
  }
  
  Future<void> _loadBusinessDetails() async {
    setState(() {
      _isLoading = true;
    });
    
    try {
      final business = await _businessService.getBusinessById(widget.business.id);
      
      setState(() {
        _business = business;
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
          fallbackMessage: AppTranslations.text(context, 'error_loading_business'),
          onRetry: _loadBusinessDetails,
        );
      }
    }
  }
  
  Future<void> _loadProducts() async {
    setState(() {
      _isLoadingProducts = true;
    });
    
    try {
      final products = await _productService.getBusinessProducts(widget.business.id);
      
      setState(() {
        _products = products;
        _isLoadingProducts = false;
      });
    } catch (e) {
      setState(() {
        _isLoadingProducts = false;
      });
      
      if (mounted) {
        ErrorHandler.showErrorSnackBar(
          context, 
          e,
          fallbackMessage: AppTranslations.text(context, 'error_loading_products'),
          onRetry: _loadProducts,
        );
      }
    }
  }
  
  Future<void> _editBusiness() async {
    if (_business == null) return;
    
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (context) => EditBusinessScreen(business: _business!),
      ),
    );
    
    if (result == true) {
      await _loadBusinessDetails();
    }
  }
  
  Future<void> _deleteBusiness() async {
    // Confirmer la suppression
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppTranslations.text(context, 'delete_business')),
        content: Text(AppTranslations.textWithParams(
          context, 'confirm_delete', [_business?.name ?? ''])),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(AppTranslations.text(context, 'cancel')),
          ),
          TextButton(
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(AppTranslations.text(context, 'delete')),
          ),
        ],
      ),
    );
    
    if (confirm != true) return;
    
    setState(() {
      _isDeleting = true;
    });
    
    try {
      await _businessService.deleteBusiness(widget.business.id);
      
      setState(() {
        _isDeleting = false;
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppTranslations.text(context, 'business_deleted'))),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      setState(() {
        _isDeleting = false;
      });
      
      if (mounted) {
        ErrorHandler.showErrorSnackBar(
          context, 
          e,
          fallbackMessage: AppTranslations.text(context, 'error_deleting_business'),
          onRetry: _deleteBusiness,
        );
      }
    }
  }
  
  void _navigateToProducts() {
    if (_business == null) return;
    
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ProductListScreen(business: _business!),
      ),
    ).then((_) => _loadProducts());
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: _business?.name ?? AppTranslations.text(context, 'business_details'),
        showBackButton: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: _isLoading ? null : _editBusiness,
            tooltip: AppTranslations.text(context, 'edit'),
          ),
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: _isLoading || _isDeleting ? null : _deleteBusiness,
            tooltip: AppTranslations.text(context, 'delete'),
          ),
        ],
      ),
      body: _isLoading
          ? Center(
              child: LoadingIndicator(
                message: AppTranslations.text(context, 'loading_business'),
                animationType: AnimationType.bounce,
                color: Theme.of(context).primaryColor,
              ),
            )
          : _isDeleting
              ? Center(
                  child: LoadingIndicator(
                    message: AppTranslations.text(context, 'deleting_business'),
                    animationType: AnimationType.bounce,
                    color: Theme.of(context).primaryColor,
                  ),
                )
              : _business == null
                  ? Center(
                      child: Text(
                        AppTranslations.text(context, 'business_not_found'),
                        style: const TextStyle(fontSize: 18),
                      ),
                    )
                  : SingleChildScrollView(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Carte d'information principale
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
                                  // En-tête avec type et statut
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 12,
                                          vertical: 6,
                                        ),
                                        decoration: BoxDecoration(
                                          color: _business!.businessType == 'fixe'
                                              ? Colors.blue.shade100
                                              : Colors.green.shade100,
                                          borderRadius: BorderRadius.circular(20),
                                        ),
                                        child: Text(
                                          _business!.businessType == 'fixe'
                                              ? AppTranslations.text(context, 'fixed_business')
                                              : AppTranslations.text(context, 'mobile_business'),
                                          style: TextStyle(
                                            color: _business!.businessType == 'fixe'
                                                ? Colors.blue.shade800
                                                : Colors.green.shade800,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 12,
                                          vertical: 6,
                                        ),
                                        decoration: BoxDecoration(
                                          color: _business!.isOpenNow()
                                              ? Colors.green
                                              : Colors.red,
                                          borderRadius: BorderRadius.circular(20),
                                        ),
                                        child: Text(
                                          _business!.isOpenNow()
                                              ? AppTranslations.text(context, 'open')
                                              : AppTranslations.text(context, 'closed'),
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 16),
                                  
                                  // Description
                                  Text(
                                    AppTranslations.text(context, 'description'),
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(_business!.description.isNotEmpty
                                      ? _business!.description
                                      : AppTranslations.text(context, 'no_description')),
                                  const SizedBox(height: 16),
                                  
                                  // Horaires
                                  Text(
                                    AppTranslations.text(context, 'opening_hours'),
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Row(
                                    children: [
                                      const Icon(Icons.access_time, size: 16),
                                      const SizedBox(width: 8),
                                      Text('${_business!.openingTime} - ${_business!.closingTime}'),
                                    ],
                                  ),
                                  const SizedBox(height: 16),
                                  
                                  // Adresse
                                  Text(
                                    AppTranslations.text(context, 'address'),
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Row(
                                    children: [
                                      const Icon(Icons.location_on, size: 16),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Text(_business!.address.isNotEmpty
                                            ? _business!.address
                                            : AppTranslations.text(context, 'no_address')),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 16),
                                  
                                  // Téléphone
                                  Text(
                                    AppTranslations.text(context, 'phone'),
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Row(
                                    children: [
                                      const Icon(Icons.phone, size: 16),
                                      const SizedBox(width: 8),
                                      Text(_business!.phone.isNotEmpty
                                          ? _business!.phone
                                          : AppTranslations.text(context, 'no_phone')),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 24),
                          
                          // Carte
                          Text(
                            AppTranslations.text(context, 'location'),
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          SizedBox(
                            height: 200,
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: GoogleMap(
                                initialCameraPosition: CameraPosition(
                                  target: LatLng(_business!.latitude, _business!.longitude),
                                  zoom: 14,
                                ),
                                markers: {
                                  Marker(
                                    markerId: const MarkerId('business_location'),
                                    position: LatLng(_business!.latitude, _business!.longitude),
                                    infoWindow: InfoWindow(
                                      title: _business!.name,
                                      snippet: _business!.address,
                                    ),
                                  ),
                                },
                                myLocationEnabled: false,
                                zoomControlsEnabled: false,
                                scrollGesturesEnabled: false,
                                tiltGesturesEnabled: false,
                                rotateGesturesEnabled: false,
                                mapToolbarEnabled: false,
                              ),
                            ),
                          ),
                          const SizedBox(height: 24),
                          
                          // Liste des produits
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                AppTranslations.text(context, 'products'),
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              TextButton.icon(
                                onPressed: _navigateToProducts,
                                icon: const Icon(Icons.list),
                                label: Text(AppTranslations.text(context, 'manage_products')),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          _isLoadingProducts
                              ? const Center(child: CircularProgressIndicator())
                              : _products.isEmpty
                                  ? Card(
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Padding(
                                        padding: const EdgeInsets.all(16),
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.center,
                                          children: [
                                            Text(
                                              AppTranslations.text(context, 'no_products'),
                                              style: const TextStyle(fontSize: 16),
                                            ),
                                            const SizedBox(height: 8),
                                            ElevatedButton.icon(
                                              onPressed: _navigateToProducts,
                                              icon: const Icon(Icons.add),
                                              label: Text(AppTranslations.text(context, 'add_product')),
                                            ),
                                          ],
                                        ),
                                      ),
                                    )
                                  : SizedBox(
                                      height: 120,
                                      child: ListView.builder(
                                        scrollDirection: Axis.horizontal,
                                        itemCount: _products.length > 5 ? 5 : _products.length,
                                        itemBuilder: (context, index) {
                                          final product = _products[index];
                                          return Card(
                                            margin: const EdgeInsets.only(right: 16),
                                            child: Container(
                                              width: 150,
                                              padding: const EdgeInsets.all(8),
                                              child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    product.name,
                                                    style: const TextStyle(
                                                      fontWeight: FontWeight.bold,
                                                      fontSize: 14,
                                                    ),
                                                    maxLines: 1,
                                                    overflow: TextOverflow.ellipsis,
                                                  ),
                                                  const SizedBox(height: 4),
                                                  Text(
                                                    '${product.price.toStringAsFixed(2)} €',
                                                    style: TextStyle(
                                                      color: Theme.of(context).primaryColor,
                                                      fontWeight: FontWeight.bold,
                                                    ),
                                                  ),
                                                  const SizedBox(height: 4),
                                                  Text(
                                                    product.isAvailable
                                                        ? AppTranslations.text(context, 'available')
                                                        : AppTranslations.text(context, 'not_available'),
                                                    style: TextStyle(
                                                      color: product.isAvailable
                                                          ? Colors.green
                                                          : Colors.red,
                                                      fontSize: 12,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          );
                                        },
                                      ),
                                    ),
                          const SizedBox(height: 32),
                          
                          // Boutons d'action
                          Row(
                            children: [
                              Expanded(
                                child: OutlinedButton.icon(
                                  onPressed: _editBusiness,
                                  icon: const Icon(Icons.edit),
                                  label: Text(AppTranslations.text(context, 'edit')),
                                  style: OutlinedButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(vertical: 12),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: ElevatedButton.icon(
                                  onPressed: _navigateToProducts,
                                  icon: const Icon(Icons.inventory),
                                  label: Text(AppTranslations.text(context, 'products')),
                                  style: ElevatedButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(vertical: 12),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
    );
  }
}