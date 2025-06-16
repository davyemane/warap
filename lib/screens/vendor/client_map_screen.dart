// Nouveau fichier: screens/vendor/client_map_screen.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../models/user_model.dart';
import '../../services/client_service.dart';
import '../../services/location_service.dart';
import '../../services/error_handler.dart';

class ClientMapScreen extends StatefulWidget {
  const ClientMapScreen({super.key});

  @override
  State<ClientMapScreen> createState() => _ClientMapScreenState();
}

class _ClientMapScreenState extends State<ClientMapScreen> {
  final Completer<GoogleMapController> _controller = Completer();
  final ClientService _clientService = ClientService();
  final LocationService _locationService = LocationService();
  
  List<UserModel> _clients = [];
  Map<MarkerId, Marker> _markers = {};
  
  Position? _currentPosition;
  bool _isLoading = true;
  String _errorMessage = '';
  
  @override
  void initState() {
    super.initState();
    _initialize();
  }
  
  Future<void> _initialize() async {
    await _getCurrentLocation();
    await _loadClients();
  }
  
  Future<void> _getCurrentLocation() async {
    try {
      final position = await _locationService.getCurrentPosition();
      
      setState(() {
        _currentPosition = position;
      });
      
      if (_controller.isCompleted) {
        final GoogleMapController controller = await _controller.future;
        controller.animateCamera(
          CameraUpdate.newCameraPosition(
            CameraPosition(
              target: LatLng(position.latitude, position.longitude),
              zoom: 12,
            ),
          ),
        );
      }
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
      });
    }
  }
  
  Future<void> _loadClients() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });
    
    try {
      final clients = await _clientService.getBusinessClients();
      
      setState(() {
        _clients = clients;
        _isLoading = false;
      });
      
      _createMarkers();
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = e.toString();
      });
      
      ErrorHandler.showErrorSnackBar(
        context,
        e,
        fallbackMessage: 'Erreur lors du chargement des clients',
        onRetry: _loadClients,
      );
    }
  }
  
  void _createMarkers() async {
    Map<MarkerId, Marker> markers = {};
    
    // Marqueur pour la position actuelle
    if (_currentPosition != null) {
      final currentPosMarkerId = const MarkerId('current_position');
      final currentPosMarker = Marker(
        markerId: currentPosMarkerId,
        position: LatLng(_currentPosition!.latitude, _currentPosition!.longitude),
        infoWindow: const InfoWindow(title: 'Ma position'),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
      );
      
      markers[currentPosMarkerId] = currentPosMarker;
    }
    
    // Obtenir la localisation pour chaque client (à partir des commandes ou demandes)
    for (int i = 0; i < _clients.length; i++) {
      final client = _clients[i];
      
      // Vous devrez adapter cette partie en fonction de votre structure de données
      // Supposons que nous ayons obtenu l'adresse du client et qu'il faut la géocoder
      try {
        // Pour cet exemple, nous allons créer des positions fictives autour de la position actuelle
        // Dans une vraie application, vous devriez obtenir les vraies coordonnées de vos clients
        if (_currentPosition != null) {
          // Création de positions fictives à proximité
          final offset = (i % 10) * 0.002; // Petit décalage pour éviter les superpositions
          final lat = _currentPosition!.latitude + offset;
          final lng = _currentPosition!.longitude + offset;
          
          final markerId = MarkerId(client.id);
          final marker = Marker(
            markerId: markerId,
            position: LatLng(lat, lng),
            infoWindow: InfoWindow(
              title: client.name.isNotEmpty ? client.name : 'Client',
              snippet: client.email,
              onTap: () => _showClientDetailBottomSheet(client, lat, lng),
            ),
            onTap: () => _showClientDetailBottomSheet(client, lat, lng),
          );
          
          markers[markerId] = marker;
        }
      } catch (e) {
        print('❌ Erreur lors de la création du marqueur pour ${client.name}: $e');
      }
    }
    
    setState(() {
      _markers = markers;
    });
    
    // Ajuster la caméra pour montrer tous les marqueurs
    if (_markers.isNotEmpty && _controller.isCompleted) {
      _fitBoundsToAllMarkers();
    }
  }
  
  Future<void> _fitBoundsToAllMarkers() async {
    if (_markers.isEmpty) return;
    
    final GoogleMapController controller = await _controller.future;
    
    // Calculer les limites pour inclure tous les marqueurs
    double minLat = double.infinity;
    double maxLat = -double.infinity;
    double minLng = double.infinity;
    double maxLng = -double.infinity;
    
    for (var marker in _markers.values) {
      minLat = marker.position.latitude < minLat ? marker.position.latitude : minLat;
      maxLat = marker.position.latitude > maxLat ? marker.position.latitude : maxLat;
      minLng = marker.position.longitude < minLng ? marker.position.longitude : minLng;
      maxLng = marker.position.longitude > maxLng ? marker.position.longitude : maxLng;
    }
    
    // Ajouter un peu de padding
    final paddingValue = 0.02;
    minLat -= paddingValue;
    maxLat += paddingValue;
    minLng -= paddingValue;
    maxLng += paddingValue;
    
    // Créer les limites et ajuster la caméra
    final bounds = LatLngBounds(
      southwest: LatLng(minLat, minLng),
      northeast: LatLng(maxLat, maxLng),
    );
    
    final cameraUpdate = CameraUpdate.newLatLngBounds(bounds, 50.0);
    await controller.animateCamera(cameraUpdate);
  }
  
  void _showClientDetailBottomSheet(UserModel client, double lat, double lng) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.4,
          minChildSize: 0.3,
          maxChildSize: 0.8,
          expand: false,
          builder: (context, scrollController) {
            return SingleChildScrollView(
              controller: scrollController,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Indicateur de drag
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
                    
                    // Info du client
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 30,
                          backgroundColor: Theme.of(context).primaryColor.withOpacity(0.1),
                          child: Text(
                            client.name.isNotEmpty ? client.initials : '?',
                            style: TextStyle(
                              color: Theme.of(context).primaryColor,
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                client.name.isNotEmpty ? client.name : 'Client sans nom',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                ),
                              ),
                              Text(
                                client.email,
                                style: TextStyle(
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    
                    // Actions
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () => _launchMaps(lat, lng, client.name),
                            icon: const Icon(Icons.directions),
                            label: const Text('Itinéraire'),
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () {
                              // Naviguer vers l'écran de détails du client
                              Navigator.pop(context);
                              Navigator.pushNamed(
                                context,
                                '/vendor/client-detail',
                                arguments: client,
                              );
                            },
                            icon: const Icon(Icons.person),
                            label: const Text('Voir détails'),
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    
                    // Plus d'actions
                    OutlinedButton.icon(
                      onPressed: () => _makePhoneCall('+01234567890'), // Remplacer par le numéro du client
                      icon: const Icon(Icons.phone),
                      label: const Text('Appeler le client'),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        minimumSize: const Size(double.infinity, 0),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
  
  Future<void> _launchMaps(double lat, double lng, String label) async {
    final url = 'https://www.google.com/maps/dir/?api=1&destination=$lat,$lng&destination_place_id=$label';
    final uri = Uri.parse(url);
    
    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Impossible d\'ouvrir Google Maps')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur: $e')),
      );
    }
  }
  
  Future<void> _makePhoneCall(String phoneNumber) async {
    final url = 'tel:$phoneNumber';
    final uri = Uri.parse(url);
    
    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Impossible de passer l\'appel')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur: $e')),
      );
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Carte des clients'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadClients,
            tooltip: 'Actualiser',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage.isNotEmpty
              ? Center(
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
                        'Erreur: $_errorMessage',
                        style: const TextStyle(color: Colors.red),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _initialize,
                        child: const Text('Réessayer'),
                      ),
                    ],
                  ),
                )
              : Stack(
                  children: [
                    GoogleMap(
                      mapType: MapType.normal,
                      initialCameraPosition: _currentPosition != null
                          ? CameraPosition(
                              target: LatLng(
                                _currentPosition!.latitude,
                                _currentPosition!.longitude,
                              ),
                              zoom: 12,
                            )
                          : const CameraPosition(
                              target: LatLng(0, 0),
                              zoom: 2,
                            ),
                      myLocationEnabled: true,
                      myLocationButtonEnabled: false,
                      markers: Set<Marker>.of(_markers.values),
                      onMapCreated: (GoogleMapController controller) {
                        _controller.complete(controller);
                        if (_currentPosition != null) {
                          controller.animateCamera(
                            CameraUpdate.newCameraPosition(
                              CameraPosition(
                                target: LatLng(
                                  _currentPosition!.latitude,
                                  _currentPosition!.longitude,
                                ),
                                zoom: 12,
                              ),
                            ),
                          );
                        }
                        
                        // Afficher tous les marqueurs
                        if (_markers.isNotEmpty) {
                          _fitBoundsToAllMarkers();
                        }
                      },
                    ),
                    
                    // Compteur de clients
                    Positioned(
                      top: 16,
                      left: 16,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
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
                            Icon(
                              Icons.people,
                              size: 16,
                              color: Theme.of(context).primaryColor,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '${_clients.length} client${_clients.length > 1 ? 's' : ''}',
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ),
                    ),
                    
                    // Boutons flottants
                    Positioned(
                      bottom: 16,
                      right: 16,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          FloatingActionButton(
                            heroTag: 'btn1',
                            onPressed: _getCurrentLocation,
                            tooltip: 'Ma position',
                            child: const Icon(Icons.my_location),
                          ),
                          const SizedBox(height: 16),
                          FloatingActionButton(
                            heroTag: 'btn2',
                            onPressed: _fitBoundsToAllMarkers,
                            tooltip: 'Voir tous les clients',
                            child: const Icon(Icons.zoom_out_map),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
      floatingActionButton: _isLoading || _errorMessage.isNotEmpty
          ? null
          : FloatingActionButton.extended(
              onPressed: () {
                // Naviguer vers la liste des clients
                Navigator.pushNamed(context, '/vendor/clients');
              },
              icon: const Icon(Icons.list),
              label: const Text('Liste des clients'),
            ),
      floatingActionButtonLocation: FloatingActionButtonLocation.startFloat,
    );
  }
}