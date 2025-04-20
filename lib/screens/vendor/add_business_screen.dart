// Fichier screens/vendor/add_business_screen.dart
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../models/business_model.dart';
import '../../services/business_service.dart';
import '../../services/location_service.dart';

class AddBusinessScreen extends StatefulWidget {
  const AddBusinessScreen({Key? key}) : super(key: key);

  @override
  State<AddBusinessScreen> createState() => _AddBusinessScreenState();
}

class _AddBusinessScreenState extends State<AddBusinessScreen> {
  final BusinessService _businessService = BusinessService();
  final LocationService _locationService = LocationService();
  final _formKey = GlobalKey<FormState>();
  
  String _name = '';
  String _description = '';
  String _businessType = 'fixe';
  double _latitude = 0.0;
  double _longitude = 0.0;
  String _openingTime = '08:00';
  String _closingTime = '18:00';
  String _address = '';
  String _phone = '';
  
  bool _isLoading = false;
  bool _locationSet = false;
  
  final Marker _marker = const Marker(
    markerId: MarkerId('business_location'),
    position: LatLng(0, 0),
  );
  
  late CameraPosition _initialCameraPosition;
  
  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
    _initialCameraPosition = const CameraPosition(
      target: LatLng(0, 0),
      zoom: 14,
    );
  }
  
  Future<void> _getCurrentLocation() async {
    try {
      final position = await _locationService.getCurrentPosition();
      setState(() {
        _latitude = position.latitude;
        _longitude = position.longitude;
        _locationSet = true;
        _initialCameraPosition = CameraPosition(
          target: LatLng(_latitude, _longitude),
          zoom: 14,
        );
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Impossible d\'obtenir votre position actuelle')),
      );
    }
  }
  
  Future<void> _saveBusiness() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    
    if (!_locationSet) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Veuillez définir la position du commerce sur la carte')),
      );
      return;
    }
    
    _formKey.currentState!.save();
    
    setState(() {
      _isLoading = true;
    });
    
    try {
      final userId = Supabase.instance.client.auth.currentUser!.id;
      
      final business = BusinessModel(
        id: '',  // Sera généré par Supabase
        userId: userId,
        name: _name,
        description: _description,
        businessType: _businessType,
        latitude: _latitude,
        longitude: _longitude,
        openingTime: _openingTime,
        closingTime: _closingTime,
        address: _address,
        phone: _phone,
        createdAt: DateTime.now(),
      );
      
      await _businessService.addBusiness(business);
      
      setState(() {
        _isLoading = false;
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Commerce ajouté avec succès')),
      );
      
      Navigator.pop(context, true);
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Erreur lors de l\'ajout du commerce')),
      );
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ajouter un commerce'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Nom du commerce
                    TextFormField(
                      decoration: const InputDecoration(
                        labelText: 'Nom du commerce',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Veuillez entrer un nom';
                        }
                        return null;
                      },
                      onSaved: (value) {
                        _name = value!;
                      },
                    ),
                    const SizedBox(height: 16),
                    
                    // Description
                    TextFormField(
                      decoration: const InputDecoration(
                        labelText: 'Description',
                        border: OutlineInputBorder(),
                      ),
                      maxLines: 3,
                      onSaved: (value) {
                        _description = value ?? '';
                      },
                    ),
                    const SizedBox(height: 16),
                    
                    // Type de commerce
                    const Text(
                      'Type de commerce',
                      style: TextStyle(fontSize: 16),
                    ),
                    RadioListTile<String>(
                      title: const Text('Commerce fixe (boutique)'),
                      value: 'fixe',
                      groupValue: _businessType,
                      onChanged: (value) {
                        setState(() {
                          _businessType = value!;
                        });
                      },
                    ),
                    RadioListTile<String>(
                      title: const Text('Commerce mobile (ambulant)'),
                      value: 'mobile',
                      groupValue: _businessType,
                      onChanged: (value) {
                        setState(() {
                          _businessType = value!;
                        });
                      },
                    ),
                    const SizedBox(height: 16),
                    
                    // Heures d'ouverture
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            decoration: const InputDecoration(
                              labelText: 'Heure d\'ouverture',
                              hintText: 'HH:MM',
                              border: OutlineInputBorder(),
                            ),
                            initialValue: _openingTime,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Requis';
                              }
                              return null;
                            },
                            onSaved: (value) {
                              _openingTime = value!;
                            },
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: TextFormField(
                            decoration: const InputDecoration(
                              labelText: 'Heure de fermeture',
                              hintText: 'HH:MM',
                              border: OutlineInputBorder(),
                            ),
                            initialValue: _closingTime,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Requis';
                              }
                              return null;
                            },
                            onSaved: (value) {
                              _closingTime = value!;
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    
                    // Adresse
                    TextFormField(
                      decoration: const InputDecoration(
                        labelText: 'Adresse',
                        border: OutlineInputBorder(),
                      ),
                      onSaved: (value) {
                        _address = value ?? '';
                      },
                    ),
                    const SizedBox(height: 16),
                    
                    // Téléphone
                    TextFormField(
                      decoration: const InputDecoration(
                        labelText: 'Téléphone',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.phone,
                      onSaved: (value) {
                        _phone = value ?? '';
                      },
                    ),
                    const SizedBox(height: 24),
                    
                    // Position sur la carte
                    const Text(
                      'Position sur la carte',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Appuyez longuement sur la carte pour définir la position de votre commerce.',
                      style: TextStyle(fontSize: 14, color: Colors.grey),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      height: 300,
                      child: GoogleMap(
                        initialCameraPosition: _initialCameraPosition,
                        markers: {_marker},
                        myLocationEnabled: true,
                        myLocationButtonEnabled: true,
                        onMapCreated: (controller) {
                          if (_locationSet) {
                            controller.animateCamera(
                              CameraUpdate.newLatLng(LatLng(_latitude, _longitude)),
                            );
                          }
                        },
                        onLongPress: (position) {
                          setState(() {
                            _latitude = position.latitude;
                            _longitude = position.longitude;
                            _locationSet = true;
                          });
                        },
                      ),
                    ),
                    const SizedBox(height: 32),
                    
                    // Bouton de sauvegarde
                    Center(
                      child: ElevatedButton(
                        onPressed: _saveBusiness,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                        ),
                        child: const Text('Enregistrer', style: TextStyle(fontSize: 16)),
                      ),
                    ),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
    );
  }
}