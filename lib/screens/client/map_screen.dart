// Fichier screens/client/map_screen.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import '../../models/business_model.dart';
import '../../models/user_model.dart';
import '../../services/business_service.dart';
import '../../services/location_service.dart';
import '../../services/auth_service.dart';
import '../../services/error_handler.dart';
import '../../services/cart_service.dart';
import '../../widgets/common/custom_app_bar.dart';
import '../../l10n/translations.dart';
import 'business_details_screen.dart';
import 'filter_screen.dart';
import 'cart_screen.dart';
import 'new_request_screen.dart';
import 'request_service_history_screen.dart';

class ClientMapScreen extends StatefulWidget {
  final bool showAppBar;

  const ClientMapScreen({super.key, this.showAppBar = true});

  @override
  State<ClientMapScreen> createState() => _ClientMapScreenState();
}

class _ClientMapScreenState extends State<ClientMapScreen> {
  final Completer<GoogleMapController> _controller = Completer();
  final BusinessService _businessService = BusinessService();
  final LocationService _locationService = LocationService();
  final AuthService _authService = AuthService();
  final CartService _cartService = CartService();
  
  List<BusinessModel> _allBusinesses = [];
  List<BusinessModel> _filteredBusinesses = [];
  Map<String, Marker> _markers = {};
  UserModel? _currentUser;
  int _cartItemCount = 0;
  
  CameraPosition _initialCameraPosition = const CameraPosition(
    target: LatLng(0, 0),
    zoom: 14,
  );
  
  String? _selectedBusinessType;
  bool _showOpenOnly = false;
  bool _isLoading = true;
  bool _isUserLoading = true;
  late BitmapDescriptor _fixedBusinessIcon;
  late BitmapDescriptor _mobileBusinessIcon;
  late BitmapDescriptor _fixedClosedBusinessIcon;
  late BitmapDescriptor _mobileClosedBusinessIcon;

  @override
  void initState() {
    super.initState();
    _loadUserData();
    _loadCustomMarkerIcons();
    _loadBusinesses();
    _getCurrentLocation();
    _loadCartItemCount();
  }

  // Charger les données de l'utilisateur actuel
  Future<void> _loadUserData() async {
    setState(() {
      _isUserLoading = true;
    });
    
    try {
      final user = await _authService.getCurrentUser();
      setState(() {
        _currentUser = user;
        _isUserLoading = false;
      });
    } catch (e) {
      setState(() {
        _isUserLoading = false;
      });
      if (mounted) {
        ErrorHandler.showErrorSnackBar(
          context, 
          e,
          fallbackMessage: AppTranslations.text(context, 'error_loading_user_data'),
          onRetry: _loadUserData,
        );
      }
    }
  }

  // Charger le nombre d'articles dans le panier
  Future<void> _loadCartItemCount() async {
    try {
      final cartItems = await _cartService.getCart();
      if (mounted) {
        setState(() {
          _cartItemCount = cartItems.length;
        });
      }
    } catch (e) {
      // Gérer silencieusement les erreurs
    }
  }
  
  void _navigateToCart() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const CartScreen()),
    ).then((_) => _loadCartItemCount());
  }

  // Charger les icônes personnalisées pour les marqueurs
  Future<void> _loadCustomMarkerIcons() async {
    try {
      _fixedBusinessIcon = await BitmapDescriptor.fromAssetImage(
        const ImageConfiguration(size: Size(48, 48)),
        'assets/icons/store_open.png',
      ).catchError((error) {
        // Fallback à l'icône par défaut si l'asset n'est pas trouvé
        return BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue);
      });
      
      _mobileBusinessIcon = await BitmapDescriptor.fromAssetImage(
        const ImageConfiguration(size: Size(48, 48)),
        'assets/icons/mobile_open.png',
      ).catchError((error) {
        return BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen);
      });
      
      _fixedClosedBusinessIcon = await BitmapDescriptor.fromAssetImage(
        const ImageConfiguration(size: Size(48, 48)),
        'assets/icons/store_closed.png',
      ).catchError((error) {
        return BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed);
      });
      
      _mobileClosedBusinessIcon = await BitmapDescriptor.fromAssetImage(
        const ImageConfiguration(size: Size(48, 48)),
        'assets/icons/mobile_closed.png',
      ).catchError((error) {
        return BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueOrange);
      });
    } catch (e) {
      if (mounted) {
        ErrorHandler.showErrorSnackBar(
          context, 
          e,
          fallbackMessage: AppTranslations.text(context, 'error_loading_icons'),
        );
      }
    }
  }

  // Charger les commerces depuis Supabase
  Future<void> _loadBusinesses() async {
    setState(() {
      _isLoading = true;
    });
    
    try {
      final businesses = await _businessService.getAllBusinesses();
      setState(() {
        _allBusinesses = businesses;
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

  // Obtenir la position actuelle de l'utilisateur
  Future<void> _getCurrentLocation() async {
    try {
      final position = await _locationService.getCurrentPosition();
      final GoogleMapController controller = await _controller.future;
      
      setState(() {
        _initialCameraPosition = CameraPosition(
          target: LatLng(position.latitude, position.longitude),
          zoom: 14,
        );
      });
      
      controller.animateCamera(CameraUpdate.newCameraPosition(_initialCameraPosition));
    } catch (e) {
      if (mounted) {
        ErrorHandler.showErrorSnackBar(
          context, 
          e,
          fallbackMessage: AppTranslations.text(context, 'error_location'),
          onRetry: _getCurrentLocation,
        );
      }
    }
  }

  // Appliquer les filtres
  void _applyFilters() {
    try {
      List<BusinessModel> filtered = _allBusinesses;
      
      // Filtre par type de commerce
      if (_selectedBusinessType != null && _selectedBusinessType!.isNotEmpty) {
        filtered = filtered.where((business) => business.businessType == _selectedBusinessType).toList();
      }
      
      // Filtre pour afficher uniquement les commerces ouverts
      if (_showOpenOnly) {
        filtered = filtered.where((business) => business.isOpenNow()).toList();
      }
      
      setState(() {
        _filteredBusinesses = filtered;
        _createMarkers();
      });
    } catch (e) {
      if (mounted) {
        ErrorHandler.showErrorSnackBar(
          context, 
          e,
          fallbackMessage: AppTranslations.text(context, 'error_applying_filters'),
        );
      }
    }
  }

  // Créer les marqueurs pour la carte
  void _createMarkers() {
    try {
      final Map<String, Marker> markerMap = {};
      
      for (final business in _filteredBusinesses) {
        final isOpen = business.isOpenNow();
        final BitmapDescriptor icon;
        
        // Déterminer l'icône appropriée
        if (business.businessType == 'fixe') {
          icon = isOpen ? _fixedBusinessIcon : _fixedClosedBusinessIcon;
        } else {
          icon = isOpen ? _mobileBusinessIcon : _mobileClosedBusinessIcon;
        }
        
        final marker = Marker(
          markerId: MarkerId(business.id),
          position: LatLng(business.latitude, business.longitude),
          infoWindow: InfoWindow(
            title: business.name,
            snippet: '${business.businessType == 'fixe' 
                ? AppTranslations.text(context, 'shop') 
                : AppTranslations.text(context, 'mobile')} - ${isOpen 
                ? AppTranslations.text(context, 'open') 
                : AppTranslations.text(context, 'closed')}',
            onTap: () => _navigateToBusinessDetails(business),
          ),
          icon: icon,
          onTap: () {
            _showBusinessInfoBottomSheet(business);
          },
        );
        
        markerMap[business.id] = marker;
      }
      
      setState(() {
        _markers = markerMap;
      });
    } catch (e) {
      if (mounted) {
        ErrorHandler.showErrorSnackBar(
          context, 
          e,
          fallbackMessage: AppTranslations.text(context, 'error_creating_markers'),
        );
      }
    }
  }

  // Obtenir l'icône appropriée pour le marqueur
  BitmapDescriptor _getMarkerIcon(String businessType, bool isOpen) {
    if (businessType == 'fixe') {
      return isOpen ? _fixedBusinessIcon : _fixedClosedBusinessIcon;
    } else {
      return isOpen ? _mobileBusinessIcon : _mobileClosedBusinessIcon;
    }
  }

  // Afficher la fiche du commerce en bas de l'écran
  void _showBusinessInfoBottomSheet(BusinessModel business) {
    try {
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        builder: (context) => DraggableScrollableSheet(
          initialChildSize: 0.4,
          minChildSize: 0.3,
          maxChildSize: 0.9,
          expand: false,
          builder: (context, scrollController) {
            return SingleChildScrollView(
              controller: scrollController,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Poignée de glissement
                    Center(
                      child: Container(
                        width: 40,
                        height: 5,
                        decoration: BoxDecoration(
                          color: Colors.grey[300],
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    // En-tête avec nom et statut
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            business.name,
                            style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: business.isOpenNow() ? Colors.green : Colors.red,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Text(
                            business.isOpenNow() 
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
                    const SizedBox(height: 8),
                    
                    // Type de commerce
                    Row(
                      children: [
                        Icon(
                          business.businessType == 'fixe'
                              ? Icons.store
                              : Icons.delivery_dining,
                          color: business.businessType == 'fixe'
                              ? Colors.blue
                              : Colors.green,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          business.businessType == 'fixe'
                              ? AppTranslations.text(context, 'fixed_business')
                              : AppTranslations.text(context, 'mobile_business'),
                          style: TextStyle(
                            color: Colors.grey[700],
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    
                    // Description
                    if (business.description.isNotEmpty) ...[
                      Text(
                        AppTranslations.text(context, 'description'),
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(business.description),
                      const SizedBox(height: 16),
                    ],
                    
                    // Horaires
                    Text(
                      AppTranslations.text(context, 'opening_hours'),
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text('${business.openingTime} - ${business.closingTime}'),
                    const SizedBox(height: 16),
                    
                    // Adresse
                    if (business.address.isNotEmpty) ...[
                      Text(
                        AppTranslations.text(context, 'address'),
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(business.address),
                      const SizedBox(height: 16),
                    ],
                    
                    // Boutons d'action
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _ActionButton(
                          icon: Icons.directions,
                          label: "Itinéraire",
                          color: Colors.blue,
                          onTap: () {
                            // Ouvrir Google Maps
                            Navigator.pop(context);
                          },
                        ),
                        _ActionButton(
                          icon: Icons.favorite_border,
                          label: "Favoris",
                          color: Colors.red,
                          onTap: () {
                            // Ajouter aux favoris
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text("Ajouté aux favoris: ${business.name}"),
                              ),
                            );
                            Navigator.pop(context);
                          },
                        ),
                        _ActionButton(
                          icon: Icons.share,
                          label: "Partager",
                          color: Colors.green,
                          onTap: () {
                            // Partager
                            Navigator.pop(context);
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    
                    // Bouton pour afficher plus de détails
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context);
                          _navigateToBusinessDetails(business);
                        },
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        child: Text("Voir les détails et produits"),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      );
    } catch (e) {
      if (mounted) {
        ErrorHandler.showErrorSnackBar(
          context, 
          e,
          fallbackMessage: AppTranslations.text(context, 'error_showing_details'),
        );
      }
    }
  }

  // Naviguer vers les détails d'un commerce
  void _navigateToBusinessDetails(BusinessModel business) {
    try {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => BusinessDetailsScreen(business: business),
        ),
      ).then((_) => _loadCartItemCount());
    } catch (e) {
      if (mounted) {
        ErrorHandler.showErrorSnackBar(
          context, 
          e,
          fallbackMessage: AppTranslations.text(context, 'error_opening_details'),
        );
      }
    }
  }

  // Ouvrir l'écran de filtres
  void _openFilterScreen() async {
    try {
      final result = await Navigator.push<Map<String, dynamic>>(
        context,
        MaterialPageRoute(
          builder: (context) => FilterScreen(
            selectedType: _selectedBusinessType,
            showOpenOnly: _showOpenOnly,
          ),
        ),
      );
      
      if (result != null) {
        setState(() {
          _selectedBusinessType = result['selectedType'];
          _showOpenOnly = result['showOpenOnly'];
          _applyFilters();
        });
      }
    } catch (e) {
      if (mounted) {
        ErrorHandler.showErrorSnackBar(
          context, 
          e,
          fallbackMessage: AppTranslations.text(context, 'error_filter_screen'),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: widget.showAppBar
          ? CustomAppBar(
              title: "Commerces à proximité",
              currentUser: _currentUser,
              actions: [
                IconButton(
                  icon: const Icon(Icons.filter_list),
                  onPressed: _openFilterScreen,
                ),
                IconButton(
                  icon: const Icon(Icons.refresh),
                  onPressed: _loadBusinesses,
                ),
              ],
            )
          : null,
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Stack(
              children: [
                GoogleMap(
                  mapType: MapType.normal,
                  initialCameraPosition: _initialCameraPosition,
                  markers: _markers.values.toSet(),
                  myLocationEnabled: true,
                  myLocationButtonEnabled: true,
                  onMapCreated: (GoogleMapController controller) {
                    _controller.complete(controller);
                  },
                  zoomControlsEnabled: false,
                ),
                
                // Bouton de filtre flottant
                Positioned(
                  top: 16,
                  right: 16,
                  child: FloatingActionButton(
                    mini: true,
                    onPressed: _openFilterScreen,
                    child: const Icon(Icons.filter_list),
                  ),
                ),
                
                // Indicateur de filtres actifs
                if (_selectedBusinessType != null || _showOpenOnly)
                  Positioned(
                    top: 16,
                    left: 16,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.filter_alt, size: 16),
                          const SizedBox(width: 4),
                          Text(
                            "Filtres actifs",
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).primaryColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  
                // Bouton de panier (en bas à droite)
                Positioned(
                  bottom: 90, // Positionner au-dessus des boutons de service
                  right: 16,
                  child: FloatingActionButton(
                    heroTag: 'cart',
                    onPressed: _navigateToCart,
                    backgroundColor: Colors.blue,
                    child: Badge(
                      isLabelVisible: _cartItemCount > 0,
                      label: Text(_cartItemCount.toString(), style: const TextStyle(color: Colors.white)),
                      child: const Icon(Icons.shopping_cart),
                    ),
                  ),
                ),
                
                // Boutons pour les services en bas de l'écran
                Positioned(
                  bottom: 16,
                  left: 16,
                  right: 16,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => const NewRequestScreen()),
                            );
                          },
                          icon: const Icon(Icons.handyman),
                          label: const Text("Demander un service"),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Theme.of(context).primaryColor,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => const RequestServiceHistoryScreen()),
                            );
                          },
                          icon: const Icon(Icons.history),
                          label: const Text("Mes demandes"),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.amber,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}

// Widget pour les boutons d'action dans la bottom sheet
class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: color,
              size: 28,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}