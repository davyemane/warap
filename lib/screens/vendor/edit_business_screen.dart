// Fichier screens/vendor/edit_business_screen.dart
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../models/business_model.dart';
import '../../services/business_service.dart';
import '../../l10n/translations.dart';

class EditBusinessScreen extends StatefulWidget {
  final BusinessModel business;
  
  const EditBusinessScreen({Key? key, required this.business}) : super(key: key);

  @override
  State<EditBusinessScreen> createState() => _EditBusinessScreenState();
}

class _EditBusinessScreenState extends State<EditBusinessScreen> {
  final BusinessService _businessService = BusinessService();
  final _formKey = GlobalKey<FormState>();
  
  late String _name;
  late String _description;
  late String _businessType;
  late double _latitude;
  late double _longitude;
  late String _openingTime;
  late String _closingTime;
  late String _address;
  late String _phone;
  
  bool _isLoading = false;
  
  late CameraPosition _initialCameraPosition;
  Set<Marker> _markers = {};
  
  @override
  void initState() {
    super.initState();
    _name = widget.business.name;
    _description = widget.business.description;
    _businessType = widget.business.businessType;
    _latitude = widget.business.latitude;
    _longitude = widget.business.longitude;
    _openingTime = widget.business.openingTime;
    _closingTime = widget.business.closingTime;
    _address = widget.business.address;
    _phone = widget.business.phone;
    
    _initialCameraPosition = CameraPosition(
      target: LatLng(_latitude, _longitude),
      zoom: 14,
    );
    
    _markers = {
      Marker(
        markerId: const MarkerId('business_location'),
        position: LatLng(_latitude, _longitude),
      ),
    };
  }
  
  Future<void> _updateBusiness() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    
    _formKey.currentState!.save();
    
    setState(() {
      _isLoading = true;
    });
    
    try {
      final updatedBusiness = BusinessModel(
        id: widget.business.id,
        userId: widget.business.userId,
        name: _name,
        description: _description,
        businessType: _businessType,
        latitude: _latitude,
        longitude: _longitude,
        openingTime: _openingTime,
        closingTime: _closingTime,
        address: _address,
        phone: _phone,
        createdAt: widget.business.createdAt,
      );
      
      await _businessService.updateBusiness(updatedBusiness);
      
      setState(() {
        _isLoading = false;
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppTranslations.text(context, 'business_updated'))),
      );
      
      Navigator.pop(context, true);
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppTranslations.text(context, 'error_updating_business'))),
      );
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppTranslations.textWithParams(
          context, 'edit_business', [widget.business.name])),
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
                      decoration: InputDecoration(
                        labelText: AppTranslations.text(context, 'business_name'),
                        border: const OutlineInputBorder(),
                      ),
                      initialValue: _name,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return AppTranslations.text(context, 'please_enter_name');
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
                      decoration: InputDecoration(
                        labelText: AppTranslations.text(context, 'description'),
                        border: const OutlineInputBorder(),
                      ),
                      initialValue: _description,
                      maxLines: 3,
                      onSaved: (value) {
                        _description = value ?? '';
                      },
                    ),
                    const SizedBox(height: 16),
                    
                    // Type de commerce
                    Text(
                      AppTranslations.text(context, 'business_type'),
                      style: const TextStyle(fontSize: 16),
                    ),
                    RadioListTile<String>(
                      title: Text(AppTranslations.text(context, 'fixed_business_desc')),
                      value: 'fixe',
                      groupValue: _businessType,
                      onChanged: (value) {
                        setState(() {
                          _businessType = value!;
                        });
                      },
                    ),
                    RadioListTile<String>(
                      title: Text(AppTranslations.text(context, 'mobile_business_desc')),
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
                            decoration: InputDecoration(
                              labelText: AppTranslations.text(context, 'opening_hours'),
                              hintText: 'HH:MM',
                              border: const OutlineInputBorder(),
                            ),
                            initialValue: _openingTime,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return AppTranslations.text(context, 'required');
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
                            decoration: InputDecoration(
                              labelText: AppTranslations.text(context, 'closing_hours'),
                              hintText: 'HH:MM',
                              border: const OutlineInputBorder(),
                            ),
                            initialValue: _closingTime,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return AppTranslations.text(context, 'required');
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
                      decoration: InputDecoration(
                        labelText: AppTranslations.text(context, 'address'),
                        border: const OutlineInputBorder(),
                      ),
                      initialValue: _address,
                      onSaved: (value) {
                        _address = value ?? '';
                      },
                    ),
                    const SizedBox(height: 16),
                    
                    // Téléphone
                    TextFormField(
                      decoration: InputDecoration(
                        labelText: AppTranslations.text(context, 'phone'),
                        border: const OutlineInputBorder(),
                      ),
                      initialValue: _phone,
                      keyboardType: TextInputType.phone,
                      onSaved: (value) {
                        _phone = value ?? '';
                      },
                    ),
                    const SizedBox(height: 24),
                    
                    // Position sur la carte
                    Text(
                      AppTranslations.text(context, 'map_position'),
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      AppTranslations.text(context, 'map_edit_instructions'),
                      style: const TextStyle(fontSize: 14, color: Colors.grey),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      height: 300,
                      child: GoogleMap(
                        initialCameraPosition: _initialCameraPosition,
                        markers: _markers,
                        myLocationEnabled: true,
                        myLocationButtonEnabled: true,
                        onLongPress: (position) {
                          setState(() {
                            _latitude = position.latitude;
                            _longitude = position.longitude;
                            _markers = {
                              Marker(
                                markerId: const MarkerId('business_location'),
                                position: LatLng(_latitude, _longitude),
                              ),
                            };
                          });
                        },
                      ),
                    ),
                    const SizedBox(height: 32),
                    
                    // Bouton de sauvegarde
                    Center(
                      child: ElevatedButton(
                        onPressed: _updateBusiness,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                        ),
                        child: Text(AppTranslations.text(context, 'update'), style: const TextStyle(fontSize: 16)),
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