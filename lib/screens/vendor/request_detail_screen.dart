// Fichier screens/vendor/request_detail_screen.dart
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../models/service_request_model.dart';
import '../../services/service_request_service.dart';
import '../../services/error_handler.dart';
import '../../l10n/translations.dart';
import '../../utils/theme.dart';
import '../../widgets/common/custom_app_bar.dart';
import '../../widgets/common/loading_indicator.dart';

class RequestDetailScreen extends StatefulWidget {
  final ServiceRequestModel request;
  
  const RequestDetailScreen({
    Key? key,
    required this.request,
  }) : super(key: key);

  @override
  State<RequestDetailScreen> createState() => _RequestDetailScreenState();
}

class _RequestDetailScreenState extends State<RequestDetailScreen> {
  final ServiceRequestService _requestService = ServiceRequestService();
  
  bool _isLoading = false;
  bool _isUpdating = false;
  
  Future<void> _updateRequestStatus(String status) async {
    // Confirmer le changement de statut
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppTranslations.text(context, 'update_status')),
        content: Text(AppTranslations.textWithParams(
          context, 'confirm_status_change', [_getStatusLabel(context, status)])),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(AppTranslations.text(context, 'cancel')),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(AppTranslations.text(context, 'confirm')),
          ),
        ],
      ),
    );
    
    if (confirm != true) return;
    
    setState(() {
      _isUpdating = true;
    });
    
    try {
      await _requestService.updateRequestStatus(widget.request.id, status);
      
      setState(() {
        _isUpdating = false;
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppTranslations.text(context, 'status_updated'))),
        );
        Navigator.pop(context, true); // Retourner true pour indiquer une mise à jour
      }
    } catch (e) {
      setState(() {
        _isUpdating = false;
      });
      
      if (mounted) {
        ErrorHandler.showErrorSnackBar(
          context, 
          e,
          fallbackMessage: AppTranslations.text(context, 'error_updating_status'),
          onRetry: () => _updateRequestStatus(status),
        );
      }
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: AppTranslations.text(context, 'request_details'),
        showBackButton: true,
      ),
      body: _isUpdating
          ? Center(
              child: LoadingIndicator(
                message: AppTranslations.text(context, 'updating_status'),
                animationType: AnimationType.bounce,
                color: Theme.of(context).primaryColor,
              ),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // En-tête avec statut
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
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                _formatDate(widget.request.requestDate),
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: 14,
                                ),
                              ),
                              _buildStatusChip(widget.request.status),
                            ],
                          ),
                          const SizedBox(height: 16),
                          
                          // Informations client
                          Text(
                            AppTranslations.text(context, 'client_info'),
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text('Client ID: ${widget.request.clientId}'),
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
                          Text(widget.request.description),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  
                  // Date préférée
                  Text(
                    AppTranslations.text(context, 'preferred_date_time'),
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 2,
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          const Icon(Icons.event, color: Colors.blue),
                          const SizedBox(width: 16),
                          Text(
                            _formatDateTime(widget.request.preferredDate),
                            style: const TextStyle(fontSize: 16),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  
                  // Localisation
                  Text(
                    AppTranslations.text(context, 'location'),
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
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
                          Row(
                            children: [
                              const Icon(Icons.location_on, color: Colors.red),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Text(
                                  widget.request.address,
                                  style: const TextStyle(fontSize: 16),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          SizedBox(
                            height: 200,
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: GoogleMap(
                                initialCameraPosition: CameraPosition(
                                  target: LatLng(widget.request.latitude, widget.request.longitude),
                                  zoom: 14,
                                ),
                                markers: {
                                  Marker(
                                    markerId: const MarkerId('request_location'),
                                    position: LatLng(widget.request.latitude, widget.request.longitude),
                                    infoWindow: InfoWindow(
                                      title: AppTranslations.text(context, 'service_location'),
                                      snippet: widget.request.address,
                                    ),
                                  ),
                                },
                                zoomControlsEnabled: false,
                                scrollGesturesEnabled: false,
                                tiltGesturesEnabled: false,
                                rotateGesturesEnabled: false,
                                myLocationEnabled: false,
                                mapToolbarEnabled: false,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                  
                  // Actions selon statut
                  if (widget.request.status == 'pending') ...[
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () => _updateRequestStatus('cancelled'),
                            icon: const Icon(Icons.cancel),
                            label: Text(AppTranslations.text(context, 'reject')),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Colors.red,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () => _updateRequestStatus('accepted'),
                            icon: const Icon(Icons.check),
                            label: Text(AppTranslations.text(context, 'accept')),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ] else if (widget.request.status == 'accepted') ...[
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () => _updateRequestStatus('completed'),
                        icon: const Icon(Icons.done_all),
                        label: Text(AppTranslations.text(context, 'mark_completed')),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
    );
  }
  
  Widget _buildStatusChip(String status) {
    Color color;
    String label;
    
    switch (status) {
      case 'pending':
        color = AppTheme.pendingColor;
        label = AppTranslations.text(context, 'pending');
        break;
      case 'accepted':
        color = AppTheme.processingColor;
        label = AppTranslations.text(context, 'accepted');
        break;
      case 'completed':
        color = AppTheme.completedColor;
        label = AppTranslations.text(context, 'completed');
        break;
      case 'cancelled':
        color = AppTheme.cancelledColor;
        label = AppTranslations.text(context, 'cancelled');
        break;
      default:
        color = Colors.grey;
        label = status;
    }
    
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 6,
      ),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
  
  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
  
  String _formatDateTime(DateTime date) {
    return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
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
}