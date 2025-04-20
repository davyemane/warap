// Fichier screens/client/map_screen.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import '../../models/business_model.dart';
import '../../services/business_service.dart';
import '../../services/location_service.dart';
import 'business_details_screen.dart';
import 'filter_screen.dart';

class ClientMapScreen extends StatefulWidget {
  const ClientMapScreen({Key? key}) : super(key: key);

  @override
  State<ClientMapScreen> createState() => _ClientMapScreenState();
}

class _ClientMapScreenState extends State<ClientMapScreen> {
  final Completer<GoogleMapController> _controller = Completer();
  final BusinessService _businessService = BusinessService();
  final LocationService _locationService = LocationService();
  
  List<BusinessModel> _allBusinesses = [];
  List<BusinessModel> _filteredBusinesses = [];
  Map<String, Marker> _markers = {};
  
  CameraPosition _initialCameraPosition = const CameraPosition(
    target: LatLng(0, 0),
    zoom: 14,
  );
  
  String? _selectedBusinessType;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadBusinesses();
    _getCurrentLocation();
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
      _showErrorSnackBar('Erreur lors du chargement des commerces');
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
      _showErrorSnackBar('Impossible d\'obtenir votre position actuelle');
    }
  }

  // Appliquer les filtres
  void _applyFilters() {
    List<BusinessModel> filtered = _allBusinesses;
    
    // Filtre par type de commerce
    if (_selectedBusinessType != null && _selectedBusinessType!.isNotEmpty) {
      filtered = filtered.where((business) => business.businessType == _selectedBusinessType).toList();
    }
    
    setState(() {
      _filteredBusinesses = filtered;
      _createMarkers();
    });
  }

  // Créer les marqueurs pour la carte
  void _createMarkers() {
    final Map<String, Marker> markerMap = {};
    
    for (final business in _filteredBusinesses) {
      final marker = Marker(
        markerId: MarkerId(business.id),
        position: LatLng(business.latitude, business.longitude),
        infoWindow: InfoWindow(
          title: business.name,
          snippet: '${business.businessType} - ${business.isOpenNow() ? 'Ouvert' : 'Fermé'}',
          onTap: () => _navigateToBusinessDetails(business),
        ),
        icon: business.businessType == 'fixe'
            ? BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue)
            : BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
      );
      
      markerMap[business.id] = marker;
    }
    
    setState(() {
      _markers = markerMap;
    });
  }

  // Naviguer vers les détails d'un commerce
  void _navigateToBusinessDetails(BusinessModel business) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => BusinessDetailsScreen(business: business),
      ),
    );
  }

  // Ouvrir l'écran de filtres
  void _openFilterScreen() async {
    final result = await Navigator.push<String>(
      context,
      MaterialPageRoute(
        builder: (context) => FilterScreen(selectedType: _selectedBusinessType),
      ),
    );
    
    if (result != null) {
      setState(() {
        _selectedBusinessType = result;
        _applyFilters();
      });
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Commerces à proximité'),
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
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : GoogleMap(
              mapType: MapType.normal,
              initialCameraPosition: _initialCameraPosition,
              markers: _markers.values.toSet(),
              myLocationEnabled: true,
              myLocationButtonEnabled: true,
              onMapCreated: (GoogleMapController controller) {
                _controller.complete(controller);
              },
            ),
    );
  }
}