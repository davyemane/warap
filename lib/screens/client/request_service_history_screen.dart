// Fichier screens/client/request_service_history_screen.dart
import 'package:flutter/material.dart';
import '../../models/service_request_model.dart';
import '../../services/service_request_service.dart';
import '../../services/error_handler.dart';
import '../../l10n/translations.dart';
import '../../utils/theme.dart';
import '../../widgets/common/custom_app_bar.dart';
import '../../widgets/common/loading_indicator.dart';
import '../../widgets/common/status_badge.dart'; // Ensure this import is correct and the StatusBadge widget exists in this file.

class RequestServiceHistoryScreen extends StatefulWidget {
  const RequestServiceHistoryScreen({Key? key}) : super(key: key);

  @override
  State<RequestServiceHistoryScreen> createState() => _RequestServiceHistoryScreenState();
}

class _RequestServiceHistoryScreenState extends State<RequestServiceHistoryScreen>
    with SingleTickerProviderStateMixin {
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
      final requests = await _requestService.getClientRequests();
      
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
    Navigator.pushNamed(
      context,
      '/client/request-detail',
      arguments: request,
    ).then((_) => _loadRequests());
  }
  
  Future<void> _cancelRequest(ServiceRequestModel request) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppTranslations.text(context, 'cancel_request')),
        content: Text(AppTranslations.text(context, 'cancel_request_confirm')),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(AppTranslations.text(context, 'no')),
          ),
          TextButton(
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(AppTranslations.text(context, 'yes')),
          ),
        ],
      ),
    );
    
    if (confirm != true) return;
    
    try {
      await _requestService.updateRequestStatus(request.id, 'cancelled');
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppTranslations.text(context, 'request_cancelled'))),
        );
      }
      
      await _loadRequests();
    } catch (e) {
      if (mounted) {
        ErrorHandler.showErrorSnackBar(
          context, 
          e,
          fallbackMessage: AppTranslations.text(context, 'error_cancelling_request'),
          onRetry: () => _cancelRequest(request),
        );
      }
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: AppTranslations.text(context, 'my_service_requests'),
        showBackButton: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadRequests,
            tooltip: AppTranslations.text(context, 'refresh'),
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
                                    ? AppTranslations.text(context, 'make_first_request')
                                    : AppTranslations.text(context, 'no_requests_with_status'),
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: Colors.grey[600],
                                ),
                              ),
                            ),
                            const SizedBox(height: 24),
                            if (_selectedFilter != 'all')
                              ElevatedButton(
                                onPressed: () => _applyFilter('all'),
                                child: Text(AppTranslations.text(context, 'show_all_requests')),
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
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(context, '/client/new-request');
        },
        child: const Icon(Icons.add),
        tooltip: AppTranslations.text(context, 'new_request'),
      ),
    );
  }
  
  Widget _buildRequestCard(ServiceRequestModel request) {
    String statusText;
    Color statusColor;
    
    switch (request.status) {
      case 'pending':
        statusText = AppTranslations.text(context, 'pending');
        statusColor = AppTheme.pendingColor;
        break;
      case 'accepted':
        statusText = AppTranslations.text(context, 'accepted');
        statusColor = AppTheme.processingColor;
        break;
      case 'completed':
        statusText = AppTranslations.text(context, 'completed');
        statusColor = AppTheme.completedColor;
        break;
      case 'cancelled':
        statusText = AppTranslations.text(context, 'cancelled');
        statusColor = AppTheme.cancelledColor;
        break;
      default:
        statusText = request.status;
        statusColor = Colors.grey;
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
                  StatusBadge(
                    status: request.status,
                    label: statusText,
                    color: statusColor,
                  ),
                ],
              ),
              const SizedBox(height: 12),
              
              // Titre de la demande
              Text(
                _getTruncatedDescription(request.description, 50),
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              
              // Date préférée
              Row(
                children: [
                  const Icon(Icons.event, size: 16, color: Colors.grey),
                  const SizedBox(width: 8),
                  Text(
                    '${AppTranslations.text(context, 'preferred_date')}: ${_formatDateTime(request.preferredDate)}',
                    style: TextStyle(
                      color: Colors.grey[700],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              
              // Adresse
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
              
              // Actions
              if (request.status == 'pending')
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => _cancelRequest(request),
                      style: TextButton.styleFrom(foregroundColor: Colors.red),
                      child: Text(AppTranslations.text(context, 'cancel')),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: () => _viewRequestDetails(request),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).primaryColor,
                        foregroundColor: Colors.white,
                      ),
                      child: Text(AppTranslations.text(context, 'details')),
                    ),
                  ],
                ),
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