// Fichier screens/client/request_service_screen.dart
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import '../../models/business_model.dart';
import '../../models/service_request_model.dart';
import '../../services/location_service.dart';
import '../../services/service_request_service.dart';
import '../../services/error_handler.dart';
import '../../l10n/translations.dart';
import '../../widgets/common/custom_app_bar.dart';
import '../../widgets/common/loading_indicator.dart';

class RequestServiceScreen extends StatefulWidget {
  final BusinessModel business;
  
  const RequestServiceScreen({super.key, required this.business});

  @override
  State<RequestServiceScreen> createState() => _RequestServiceScreenState();
}

class _RequestServiceScreenState extends State<RequestServiceScreen> {
  final _formKey = GlobalKey<FormState>();
  final ServiceRequestService _requestService = ServiceRequestService();
  final LocationService _locationService = LocationService();
  
  String _needDescription = '';
  DateTime _preferredDate = DateTime.now().add(const Duration(hours: 1));
  TimeOfDay _preferredTime = TimeOfDay.now();
  bool _useCurrentLocation = true;
  Position? _currentPosition;
  String _address = '';
  bool _isLoading = false;
  bool _isLocationLoading = false;
  
  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }
  
  Future<void> _getCurrentLocation() async {
    setState(() {
      _isLocationLoading = true;
    });
    
    try {
      final position = await _locationService.getCurrentPosition();
      final address = await _locationService.getAddressFromPosition(position);
      
      setState(() {
        _currentPosition = position;
        _address = address;
        _isLocationLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLocationLoading = false;
      });
      if (mounted) {
        ErrorHandler.showErrorSnackBar(
          context, 
          e,
          fallbackMessage: AppTranslations.text(context, 'error_getting_location'),
          onRetry: _getCurrentLocation,
        );
      }
    }
  }
  
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _preferredDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 30)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: Theme.of(context).primaryColor,
              onPrimary: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );
    
    if (picked != null && picked != _preferredDate) {
      setState(() {
        _preferredDate = picked;
      });
    }
  }
  
  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _preferredTime,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: Theme.of(context).primaryColor,
              onPrimary: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );
    
    if (picked != null && picked != _preferredTime) {
      setState(() {
        _preferredTime = picked;
      });
    }
  }
  
  Future<void> _submitRequest() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    
    _formKey.currentState!.save();
    
    if (_useCurrentLocation && _currentPosition == null) {
      if (mounted) {
        ErrorHandler.showErrorSnackBar(
          context, 
          Exception('Location not available'),
          fallbackMessage: AppTranslations.text(context, 'location_required'),
          onRetry: _getCurrentLocation,
        );
      }
      return;
    }
    
    setState(() {
      _isLoading = true;
    });
    
    try {
      final position = _useCurrentLocation ? _currentPosition! : await _locationService.getPositionFromAddress(_address);
      
      // Créer la demande de service
      final request = ServiceRequestModel(
        id: '',
        businessId: widget.business.id,
        clientId: '', // Sera rempli par le service
        description: _needDescription,
        latitude: position.latitude,
        longitude: position.longitude,
        address: _address,
        requestDate: DateTime.now(),
        preferredDate: DateTime(
          _preferredDate.year,
          _preferredDate.month,
          _preferredDate.day,
          _preferredTime.hour,
          _preferredTime.minute,
        ),
        status: 'pending',
      );
      
      await _requestService.createServiceRequest(request);
      
      setState(() {
        _isLoading = false;
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppTranslations.text(context, 'request_sent_successfully'))),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      
      if (mounted) {
        ErrorHandler.showErrorSnackBar(
          context, 
          e,
          fallbackMessage: AppTranslations.text(context, 'error_sending_request'),
          onRetry: _submitRequest,
        );
      }
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: AppTranslations.text(context, 'request_service'),
        showBackButton: true,
      ),
      body: _isLoading
          ? Center(
              child: LoadingIndicator(
                message: AppTranslations.text(context, 'sending_request'),
                animationType: AnimationType.bounce,
                color: Theme.of(context).primaryColor,
              ),
            )
          : SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // En-tête avec info du commerce
                      _buildBusinessHeader(),
                      const SizedBox(height: 24),
                      
                      // Description du besoin
                      Text(
                        AppTranslations.text(context, 'need_description'),
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        maxLines: 5,
                        decoration: InputDecoration(
                          hintText: AppTranslations.text(context, 'describe_your_need'),
                          border: const OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return AppTranslations.text(context, 'need_required');
                          }
                          return null;
                        },
                        onSaved: (value) {
                          _needDescription = value!;
                        },
                      ),
                      const SizedBox(height: 24),
                      
                      // Date et heure préférées
                      Text(
                        AppTranslations.text(context, 'preferred_date_time'),
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: InkWell(
                              onTap: () => _selectDate(context),
                              child: InputDecorator(
                                decoration: InputDecoration(
                                  border: const OutlineInputBorder(),
                                  labelText: AppTranslations.text(context, 'date'),
                                  suffixIcon: const Icon(Icons.calendar_today),
                                ),
                                child: Text(
                                  '${_preferredDate.day}/${_preferredDate.month}/${_preferredDate.year}',
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: InkWell(
                              onTap: () => _selectTime(context),
                              child: InputDecorator(
                                decoration: InputDecoration(
                                  border: const OutlineInputBorder(),
                                  labelText: AppTranslations.text(context, 'time'),
                                  suffixIcon: const Icon(Icons.access_time),
                                ),
                                child: Text(
                                  '${_preferredTime.hour}:${_preferredTime.minute.toString().padLeft(2, '0')}',
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      
                      // Localisation
                      Text(
                        AppTranslations.text(context, 'location'),
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      SwitchListTile(
                        title: Text(AppTranslations.text(context, 'use_current_location')),
                        value: _useCurrentLocation,
                        onChanged: (value) {
                          setState(() {
                            _useCurrentLocation = value;
                            if (value && _currentPosition == null) {
                              _getCurrentLocation();
                            }
                          });
                        },
                        contentPadding: EdgeInsets.zero,
                      ),
                      const SizedBox(height: 8),
                      _isLocationLoading
                          ? const LinearProgressIndicator()
                          : _useCurrentLocation
                              ? Card(
                                  child: ListTile(
                                    leading: const Icon(Icons.location_on),
                                    title: Text(_address.isNotEmpty
                                        ? _address
                                        : AppTranslations.text(context, 'location_not_available')),
                                    trailing: IconButton(
                                      icon: const Icon(Icons.refresh),
                                      onPressed: _getCurrentLocation,
                                    ),
                                  ),
                                )
                              : TextFormField(
                                  initialValue: _address,
                                  decoration: InputDecoration(
                                    labelText: AppTranslations.text(context, 'address'),
                                    hintText: AppTranslations.text(context, 'enter_address'),
                                    border: const OutlineInputBorder(),
                                    prefixIcon: const Icon(Icons.location_on),
                                  ),
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return AppTranslations.text(context, 'address_required');
                                    }
                                    return null;
                                  },
                                  onChanged: (value) {
                                    _address = value;
                                  },
                                ),
                      const SizedBox(height: 32),
                      
                      // Bouton d'envoi
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: _submitRequest,
                          icon: const Icon(Icons.send),
                          label: Text(AppTranslations.text(context, 'send_request')),
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
    );
  }
  
  Widget _buildBusinessHeader() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: Colors.green,
              radius: 24,
              child: const Icon(
                Icons.delivery_dining,
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
                    widget.business.name,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    widget.business.description,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}