// Fichier screens/vendor/service_requests_screen.dart
import 'package:flutter/material.dart';
import '../../models/service_request_model.dart';
import '../../services/service_request_service.dart';
import '../../services/error_handler.dart';
import '../../l10n/translations.dart';
import '../../utils/theme.dart';
import '../../widgets/common/custom_app_bar.dart';
import '../../widgets/common/loading_indicator.dart';

class ServiceRequestsScreen extends StatefulWidget {
  const ServiceRequestsScreen({super.key});

  @override
  State<ServiceRequestsScreen> createState() => _ServiceRequestsScreenState();
}

class _ServiceRequestsScreenState extends State<ServiceRequestsScreen> with SingleTickerProviderStateMixin {
  final ServiceRequestService _requestService = ServiceRequestService();
  
  List<ServiceRequestModel> _requests = [];
  List<ServiceRequestModel> _filteredRequests = [];
  bool _isLoading = true;
  late TabController _tabController;
  String _selectedFilter = 'all';
  
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _tabController.addListener(_handleTabChange);
    _loadRequests();
  }
  
  @override
  void dispose() {
    _tabController.removeListener(_handleTabChange);
    _tabController.dispose();
    super.dispose();
  }
  
  void _handleTabChange() {
    if (!_tabController.indexIsChanging) {
      switch (_tabController.index) {
        case 0:
          _applyFilter('all');
          break;
        case 1:
          _applyFilter('pending');
          break;
        case 2:
          _applyFilter('accepted');
          break;
        case 3:
          _applyFilter('completed');
          break;
      }
    }
  }
  
  Future<void> _loadRequests() async {
    setState(() {
      _isLoading = true;
    });
    
    try {
      final requests = await _requestService.getBusinessRequests();
      
      setState(() {
        _requests = requests;
        _applyFilter(_selectedFilter);
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
          onRetry: _loadRequests,
        );
      }
    }
  }
  
  void _applyFilter(String filter) {
    setState(() {
      _selectedFilter = filter;
      
      if (filter == 'all') {
        _filteredRequests = _requests;
      } else {
        _filteredRequests = _requests.where((request) => request.status == filter).toList();
      }
      
      // Trier par date décroissante
      _filteredRequests.sort((a, b) => b.requestDate.compareTo(a.requestDate));
    });
  }
  
  void _viewRequestDetails(ServiceRequestModel request) {
    // Cette fonction pourrait naviguer vers un écran de détails de la demande
    _showRequestDetailsDialog(request);
  }
  
  void _showRequestDetailsDialog(ServiceRequestModel request) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppTranslations.text(context, 'request_details')),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                AppTranslations.text(context, 'description'),
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              Text(request.description),
              const SizedBox(height: 12),
              
              Text(
                AppTranslations.text(context, 'address'),
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              Text(request.address),
              const SizedBox(height: 12),
              
              Text(
                AppTranslations.text(context, 'requested_on'),
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              Text(_formatDateTime(request.requestDate)),
              const SizedBox(height: 12),
              
              Text(
                AppTranslations.text(context, 'preferred_date'),
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              Text(_formatDateTime(request.preferredDate)),
              const SizedBox(height: 12),
              
              Text(
                AppTranslations.text(context, 'status'),
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              _buildStatusChip(request.status),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(AppTranslations.text(context, 'close')),
          ),
          if (request.status == 'pending')
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                _changeRequestStatus(request, 'accepted');
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
              ),
              child: Text(AppTranslations.text(context, 'accept')),
            ),
          if (request.status == 'accepted')
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                _changeRequestStatus(request, 'completed');
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
              ),
              child: Text(AppTranslations.text(context, 'mark_completed')),
            ),
        ],
      ),
    );
  }
  
  Future<void> _changeRequestStatus(ServiceRequestModel request, String newStatus) async {
    try {
      await _requestService.updateRequestStatus(request.id, newStatus);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppTranslations.text(context, 'status_updated'))),
        );
      }
      
      await _loadRequests();
    } catch (e) {
      if (mounted) {
        ErrorHandler.showErrorSnackBar(
          context, 
          e,
          fallbackMessage: AppTranslations.text(context, 'error_updating_status'),
          onRetry: () => _changeRequestStatus(request, newStatus),
        );
      }
    }
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
        horizontal: 8,
        vertical: 4,
      ),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      ),
    );
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: AppTranslations.text(context, 'service_requests'),
        showBackButton: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadRequests,
            tooltip: AppTranslations.text(context, 'refresh'),
          ),
          IconButton(
            icon: const Icon(Icons.map),
            onPressed: () {
              Navigator.pushNamed(context, '/vendor/client-map');
            },
            tooltip: AppTranslations.text(context, 'view_map'),
          ),
        ],
      ),
      body: Column(
        children: [
          // Onglets de filtrage
          Container(
            color: Theme.of(context).primaryColor,
            child: TabBar(
              controller: _tabController,
              indicatorColor: Colors.white,
              labelColor: Colors.white,
              unselectedLabelColor: Colors.white.withOpacity(0.7),
              tabs: [
                Tab(text: AppTranslations.text(context, 'all')),
                Tab(text: AppTranslations.text(context, 'pending')),
                Tab(text: AppTranslations.text(context, 'accepted')),
                Tab(text: AppTranslations.text(context, 'completed')),
              ],
            ),
          ),
          
          // Liste des demandes
          Expanded(
            child: _isLoading
                ? Center(
                    child: LoadingIndicator(
                      message: AppTranslations.text(context, 'loading_requests'),
                      animationType: AnimationType.bounce,
                      color: Theme.of(context).primaryColor,
                    ),
                  )
                : _filteredRequests.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.history,
                              size: 80,
                              color: Colors.grey[400],
                            ),
                            const SizedBox(height: 16),
                            Text(
                              AppTranslations.text(context, 'no_requests_found'),
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 32),
                              child: Text(
                                _selectedFilter == 'all'
                                    ? AppTranslations.text(context, 'no_requests_yet')
                                    : AppTranslations.text(context, 'no_requests_with_status'),
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: Colors.grey[600],
                                ),
                              ),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        itemCount: _filteredRequests.length,
                        padding: const EdgeInsets.all(16),
                        itemBuilder: (context, index) {
                          final request = _filteredRequests[index];
                          return _buildRequestCard(request);
                        },
                      ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildRequestCard(ServiceRequestModel request) {
    Color statusColor;
    String statusText;
    
    switch (request.status) {
      case 'pending':
        statusColor = AppTheme.pendingColor;
        statusText = AppTranslations.text(context, 'pending');
        break;
      case 'accepted':
        statusColor = AppTheme.processingColor;
        statusText = AppTranslations.text(context, 'accepted');
        break;
      case 'completed':
        statusColor = AppTheme.completedColor;
        statusText = AppTranslations.text(context, 'completed');
        break;
      case 'cancelled':
        statusColor = AppTheme.cancelledColor;
        statusText = AppTranslations.text(context, 'cancelled');
        break;
      default:
        statusColor = Colors.grey;
        statusText = request.status;
    }
    
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      elevation: 2,
      child: InkWell(
        onTap: () => _viewRequestDetails(request),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // En-tête avec date et statut
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    _formatDate(request.requestDate),
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 14,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: statusColor,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      statusText,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              
              // Description tronquée
              Text(
                _getTruncatedDescription(request.description, 100),
                style: const TextStyle(
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 8),
              
              // Date préférée et adresse
              Row(
                children: [
                  const Icon(Icons.event, size: 16, color: Colors.grey),
                  const SizedBox(width: 8),
                  Text(
                    _formatDate(request.preferredDate),
                    style: TextStyle(
                      color: Colors.grey[700],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  const Icon(Icons.location_on, size: 16, color: Colors.grey),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      request.address,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: Colors.grey[700],
                      ),
                    ),
                  ),
                ],
              ),
              
              // Actions pour les demandes en attente ou en cours
              if (request.status == 'pending') ...[
                const Divider(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => _changeRequestStatus(request, 'cancelled'),
                      style: TextButton.styleFrom(foregroundColor: Colors.red),
                      child: Text(AppTranslations.text(context, 'reject')),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: () => _changeRequestStatus(request, 'accepted'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                      ),
                      child: Text(AppTranslations.text(context, 'accept')),
                    ),
                  ],
                ),
              ] else if (request.status == 'accepted') ...[
                const Divider(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    ElevatedButton(
                      onPressed: () => _changeRequestStatus(request, 'completed'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                      ),
                      child: Text(AppTranslations.text(context, 'mark_completed')),
                    ),
                  ],
                ),
              ],
            ],
          ),
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
  
  String _getTruncatedDescription(String text, int maxLength) {
    if (text.length <= maxLength) {
      return text;
    }
    return '${text.substring(0, maxLength)}...';
  }
}