// Fichier screens/vendor/client_map_screen.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import '../../models/service_request_model.dart';
import '../../services/service_request_service.dart';
import '../../services/location_service.dart';
import '../../services/error_handler.dart';
import '../../l10n/translations.dart';
import '../../widgets/common/custom_app_bar.dart';
import '../../widgets/common/loading_indicator.dart';

class ClientMapScreen extends StatefulWidget {
  const ClientMapScreen({Key? key}) : super(key: key);

  @override
  State<ClientMapScreen> createState() => _ClientMapScreenState();
}

class _ClientMapScreenState extends State<ClientMapScreen> {
  final Completer<GoogleMapController> _controller = Completer();
  final ServiceRequestService _requestService = ServiceRequestService();
  final LocationService _locationService = LocationService();
  
  List<ServiceRequestModel> _allRequests = [];
  List<ServiceRequestModel> _filteredRequests = [];
  Map<String, Marker> _markers = {};
  
  CameraPosition _initialCameraPosition = const CameraPosition(
    target: LatLng(0, 0),
    zoom: 14,
  );
  
  String _selectedStatus = 'all';
  bool _showOnlyNearby = false;
  double _maxDistance = 10.0; // en km
  bool _isLoading = true;
  bool _isRefreshing = false;
  Position? _currentPosition;
  Timer? _refreshTimer;
  
  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
    _loadServiceRequests();
    
    // Mettre à jour les demandes toutes les 5 minutes
    _refreshTimer = Timer.periodic(const Duration(minutes: 5), (timer) {
      if (mounted) _refreshData();
    });
  }
  
  @override
  void dispose() {
    _refreshTimer?.cancel();
    super.dispose();
  }
  
  Future<void> _getCurrentLocation() async {
    try {
      final position = await _locationService.getCurrentPosition();
      final GoogleMapController controller = await _controller.future;
      
      setState(() {
        _currentPosition = position;
        _initialCameraPosition = CameraPosition(
          target: LatLng(position.latitude, position.longitude),
          zoom: 14,
        );
      });
      
      controller.animateCamera(CameraUpdate.newCameraPosition(_initialCameraPosition));
      
      // Une fois que nous avons la position actuelle, filtrer les demandes
      if (_showOnlyNearby) {
        _applyFilters();
      }
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
  
  Future<void> _loadServiceRequests() async {
    setState(() {
      _isLoading = true;
    });
    
    try {
      final requests = await _requestService.getServiceRequests();
      
      setState(() {
        _allRequests = requests;
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
          fallbackMessage: AppTranslations.text(context, 'error_loading_requests'),
          onRetry: _loadServiceRequests,
        );
      }
    }
  }
  
  Future<void> _refreshData() async {
    if (_isRefreshing) return;
    
    setState(() {
      _isRefreshing = true;
    });
    
    try {
      final requests = await _requestService.getServiceRequests();
      
      setState(() {
        _allRequests = requests;
        _applyFilters();
        _isRefreshing = false;
      });
    } catch (e) {
      setState(() {
        _isRefreshing = false;
      });
      
      if (mounted) {
        ErrorHandler.showErrorSnackBar(
          context, 
          e,
          fallbackMessage: AppTranslations.text(context, 'error_refreshing_data'),
        );
      }
    }
  }
  
  void _applyFilters() {
    List<ServiceRequestModel> filtered = _allRequests;
    
    // Filtre par statut
    if (_selectedStatus != 'all') {
      filtered = filtered.where((request) => request.status == _selectedStatus).toList();
    }
    
    // Filtre par distance
    if (_showOnlyNearby && _currentPosition != null) {
      filtered = filtered.where((request) {
        final distance = _locationService.calculateDistance(
          _currentPosition!.latitude,
          _currentPosition!.longitude,
          request.latitude,
          request.longitude,
        );
        
        return distance <= _maxDistance;
      }).toList();
      
      // Trier par proximité
      filtered.sort((a, b) {
        final distanceA = _locationService.calculateDistance(
          _currentPosition!.latitude,
          _currentPosition!.longitude,
          a.latitude,
          a.longitude,
        );
        
        final distanceB = _locationService.calculateDistance(
          _currentPosition!.latitude,
          _currentPosition!.longitude,
          b.latitude,
          b.longitude,
        );
        
        return distanceA.compareTo(distanceB);
      });
    }
    
    setState(() {
      _filteredRequests = filtered;
      _createMarkers();
    });
  }
  
  void _createMarkers() {
    final Map<String, Marker> markerMap = {};
    
    // Ajouter les marqueurs pour les demandes
    for (final request in _filteredRequests) {
      final marker = Marker(
        markerId: MarkerId(request.id),
        position: LatLng(request.latitude, request.longitude),
        infoWindow: InfoWindow(
          title: _getRequestTitle(request),
          snippet: _getRequestSnippet(request),
          onTap: () => _navigateToRequestDetails(request),
        ),
        icon: _getMarkerIcon(request.status),
        onTap: () {
          _showRequestInfoBottomSheet(request);
        },
      );
      
      markerMap[request.id] = marker;
    }
    
    // Ajouter un marqueur pour la position actuelle
    if (_currentPosition != null) {
      final userMarker = Marker(
        markerId: const MarkerId('current_location'),
        position: LatLng(_currentPosition!.latitude, _currentPosition!.longitude),
        infoWindow: InfoWindow(
          title: AppTranslations.text(context, 'your_location'),
        ),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
        zIndex: 2, // Pour s'assurer qu'il est au-dessus des autres marqueurs
      );
      
      markerMap['current_location'] = userMarker;
    }
    
    setState(() {
      _markers = markerMap;
    });
  }
  
  BitmapDescriptor _getMarkerIcon(String status) {
    switch (status) {
      case 'pending':
        return BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueOrange);
      case 'accepted':
        return BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen);
      case 'completed':
        return BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure);
      case 'cancelled':
        return BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed);
      default:
        return BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueYellow);
    }
  }
  
  String _getRequestTitle(ServiceRequestModel request) {
    return AppTranslations.text(context, 'service_request');
  }
  
  String _getRequestSnippet(ServiceRequestModel request) {
    final distance = _currentPosition != null
        ? _locationService.calculateDistance(
            _currentPosition!.latitude,
            _currentPosition!.longitude,
            request.latitude,
            request.longitude,
          ).toStringAsFixed(1)
        : null;
        
    return distance != null
        ? '${_getStatusLabel(context, request.status)} - ${distance} km'
        : _getStatusLabel(context, request.status);
  }
  
  Future<void> _acceptRequest(ServiceRequestModel request) async {
    try {
      await _requestService.updateRequestStatus(request.id, 'accepted');
      
      // Recharger les demandes
      await _loadServiceRequests();
      
      if (mounted) {
        Navigator.pop(context); // Fermer la bottom sheet
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppTranslations.text(context, 'request_accepted')),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        Navigator.pop(context); // Fermer la bottom sheet
        ErrorHandler.showErrorSnackBar(
          context, 
          e,
          fallbackMessage: AppTranslations.text(context, 'error_accepting_request'),
          onRetry: () => _acceptRequest(request),
        );
      }
    }
  }
  
  Future<void> _navigateToRequestDetails(ServiceRequestModel request) async {
    final result = await Navigator.pushNamed(
      context,
      '/vendor/request-detail',
      arguments: request,
    );
    
    if (result == true) {
      // Si des modifications ont été apportées, recharger les données
      _loadServiceRequests();
    }
  }
  
  void _showRequestInfoBottomSheet(ServiceRequestModel request) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.5,
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
                  
                  // En-tête avec statut
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        AppTranslations.text(context, 'service_request'),
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: _getStatusColor(request.status),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Text(
                          _getStatusLabel(context, request.status),
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  
                  // Date de la demande
                  Text(
                    '${AppTranslations.text(context, 'requested_on')}: ${_formatDate(request.requestDate)}',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontStyle: FontStyle.italic,
                    ),
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
                  Text(
                    request.description,
                    style: const TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 16),
                  
                  // Date préférée
                  Text(
                    AppTranslations.text(context, 'preferred_date_time'),
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _formatDateTime(request.preferredDate),
                    style: const TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 16),
                  
                  // Adresse
                  Text(
                    AppTranslations.text(context, 'location'),
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.location_on, color: Colors.red),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          request.address,
                          style: const TextStyle(fontSize: 16),
                        ),
                      ),
                    ],
                  ),
                  
                  if (_currentPosition != null) ...[
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(Icons.directions, color: Colors.blue),
                        const SizedBox(width: 8),
                        Text(
                          '${_locationService.calculateDistance(
                            _currentPosition!.latitude,
                            _currentPosition!.longitude,
                            request.latitude,
                            request.longitude,
                          ).toStringAsFixed(1)} km ${AppTranslations.text(context, 'from_you')}',
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ],
                  
                  const SizedBox(height: 32),
                  
                  // Boutons d'action
                  if (request.status == 'pending') ...[
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () => _acceptRequest(request),
                        icon: const Icon(Icons.check),
                        label: Text(AppTranslations.text(context, 'accept_request')),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                  
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () => _navigateToRequestDetails(request),
                      icon: const Icon(Icons.info),
                      label: Text(AppTranslations.text(context, 'view_details')),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
  
  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
  
  String _formatDateTime(DateTime date) {
    return '${date.day}/${date.month}/${date.year} - ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }
  
  Color _getStatusColor(String status) {
    switch (status) {
      case 'pending':
        return Colors.orange;
      case 'accepted':
        return Colors.green;
      case 'completed':
        return Colors.blue;
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
  
  String _getStatusLabel(BuildContext context, String status) {
    switch (status) {
      case 'pending':
        return AppTranslations.text(context, 'pending');
      case 'accepted':
        return AppTranslations.text(context, 'accepted');
      case 'completed':
        return AppTranslations.text(context, 'completed');
      case 'cancelled':
        return AppTranslations.text(context, 'cancelled');
      default:
        return status;
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: AppTranslations.text(context, 'client_requests'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _refreshData,
            tooltip: AppTranslations.text(context, 'refresh'),
          ),
          IconButton(
            icon: const Icon(Icons.list),
            onPressed: () {
              Navigator.pushNamed(context, '/vendor/requests-list');
            },
            tooltip: AppTranslations.text(context, 'list_view'),
          ),
        ],
      ),
      body: _isLoading
          ? Center(
              child: LoadingIndicator(
                message: AppTranslations.text(context, 'loading_map'),
                animationType: AnimationType.bounce,
                color: Theme.of(context).primaryColor,
              ),
            )
          : Stack(
              children: [
                GoogleMap(
                  mapType: MapType.normal,
                  initialCameraPosition: _initialCameraPosition,
                  markers: _markers.values.toSet(),
                  myLocationEnabled: true,
                  myLocationButtonEnabled: false,
                  onMapCreated: (GoogleMapController controller) {
                    _controller.complete(controller);
                  },
                  zoomControlsEnabled: false,
                ),
                
                // Indicateur de chargement pendant le rafraîchissement
                if (_isRefreshing)
                  Positioned(
                    top: 0,
                    left: 0,
                    right: 0,
                    child: LinearProgressIndicator(
                      backgroundColor: Colors.transparent,
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                
                // Filtres
                Positioned(
                  top: 16,
                  left: 16,
                  right: 16,
                  child: Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            AppTranslations.text(context, 'filters'),
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              // Filtre par statut
                              Expanded(
                                child: DropdownButtonFormField<String>(
                                  decoration: InputDecoration(
                                    labelText: AppTranslations.text(context, 'status'),
                                    isDense: true,
                                    contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 8,
                                    ),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                  value: _selectedStatus,
                                  items: [
                                    DropdownMenuItem(
                                      value: 'all',
                                      child: Text(AppTranslations.text(context, 'all')),
                                    ),
                                    DropdownMenuItem(
                                      value: 'pending',
                                      child: Text(AppTranslations.text(context, 'pending')),
                                    ),
                                    DropdownMenuItem(
                                      value: 'accepted',
                                      child: Text(AppTranslations.text(context, 'accepted')),
                                    ),
                                    DropdownMenuItem(
                                      value: 'completed',
                                      child: Text(AppTranslations.text(context, 'completed')),
                                    ),
                                    DropdownMenuItem(
                                      value: 'cancelled',
                                      child: Text(AppTranslations.text(context, 'cancelled')),
                                    ),
                                  ],
                                  onChanged: (value) {
                                    if (value != null) {
                                      setState(() {
                                        _selectedStatus = value;
                                      });
                                      _applyFilters();
                                    }
                                  },
                                ),
                              ),
                              const SizedBox(width: 16),
                              
                              // Filtre par distance
                              Expanded(
                                child: SwitchListTile(
                                  title: Text(
                                    AppTranslations.text(context, 'nearby_only'),
                                    style: const TextStyle(fontSize: 14),
                                  ),
                                  value: _showOnlyNearby,
                                  onChanged: (value) {
                                    setState(() {
                                      _showOnlyNearby = value;
                                    });
                                    if (value && _currentPosition == null) {
                                      _getCurrentLocation();
                                    } else {
                                      _applyFilters();
                                    }
                                  },
                                  dense: true,
                                  contentPadding: EdgeInsets.zero,
                                ),
                              ),
                            ],
                          ),
                          if (_showOnlyNearby) ...[
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    '${AppTranslations.text(context, 'max_distance')}: ${_maxDistance.toStringAsFixed(1)} km',
                                  ),
                                ),
                                Expanded(
                                  flex: 2,
                                  child: Slider(
                                    value: _maxDistance,
                                    min: 1.0,
                                    max: 50.0,
                                    divisions: 49,
                                    label: '${_maxDistance.toStringAsFixed(1)} km',
                                    onChanged: (value) {
                                      setState(() {
                                        _maxDistance = value;
                                      });
                                    },
                                    onChangeEnd: (value) {
                                      _applyFilters();
                                    },
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ),
                
                // Compteur de résultats
                Positioned(
                  bottom: 96,
                  right: 16,
                  child: Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      child: Text(
                        '${_filteredRequests.length} ${AppTranslations.text(context, 'requests')}',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
                
                // Bouton pour centrer sur ma position
                Positioned(
                  bottom: 32,
                  right: 16,
                  child: FloatingActionButton(
                    onPressed: _getCurrentLocation,
                    tooltip: AppTranslations.text(context, 'my_location'),
                    child: const Icon(Icons.my_location),
                  ),
                ),
              ],
            ),
    );
  }
}