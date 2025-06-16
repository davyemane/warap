// Fichier screens/client/search_screen.dart
import 'package:flutter/material.dart';
import '../../models/business_model.dart';
import '../../services/business_service.dart';
import '../../services/error_handler.dart'; // Ajout de l'import
import 'business_details_screen.dart';
import '../../l10n/translations.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final BusinessService _businessService = BusinessService();
  final TextEditingController _searchController = TextEditingController();
  
  List<BusinessModel> _allBusinesses = [];
  List<BusinessModel> _filteredBusinesses = [];
  bool _isLoading = true;
  String _searchQuery = '';
  
  @override
  void initState() {
    super.initState();
    _loadBusinesses();
  }
  
  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
  
  Future<void> _loadBusinesses() async {
    setState(() {
      _isLoading = true;
    });
    
    try {
      final businesses = await _businessService.getAllBusinesses();
      setState(() {
        _allBusinesses = businesses;
        _applySearch();
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
  
  void _applySearch() {
    try {
      if (_searchQuery.isEmpty) {
        setState(() {
          _filteredBusinesses = _allBusinesses;
        });
        return;
      }
      
      setState(() {
        _filteredBusinesses = _allBusinesses.where((business) {
          final name = business.name.toLowerCase();
          final description = business.description.toLowerCase();
          final address = business.address.toLowerCase();
          final query = _searchQuery.toLowerCase();
          
          return name.contains(query) ||
                description.contains(query) ||
                address.contains(query);
        }).toList();
      });
    } catch (e) {
      if (mounted) {
        ErrorHandler.showErrorSnackBar(
          context, 
          e,
          fallbackMessage: AppTranslations.text(context, 'error_searching'),
        );
      }
    }
  }
  
  void _navigateToBusinessDetails(BusinessModel business) {
    try {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => BusinessDetailsScreen(
            business: business,
          ),
        ),
      );
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
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppTranslations.text(context, 'search')),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                labelText: AppTranslations.text(context, 'search_business'),
                hintText: AppTranslations.text(context, 'search_hint'),
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          setState(() {
                            _searchQuery = '';
                            _applySearch();
                          });
                        },
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                  _applySearch();
                });
              },
            ),
          ),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _filteredBusinesses.isEmpty
                    ? Center(
                        child: Text(
                          AppTranslations.text(context, 'no_results'),
                          style: const TextStyle(fontSize: 18),
                        ),
                      )
                    : ListView.builder(
                        itemCount: _filteredBusinesses.length,
                        itemBuilder: (context, index) {
                          final business = _filteredBusinesses[index];
                          return Card(
                            margin: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            child: ListTile(
                              leading: CircleAvatar(
                                backgroundColor: business.businessType == 'fixe'
                                    ? Colors.blue
                                    : Colors.green,
                                child: Icon(
                                  business.businessType == 'fixe'
                                      ? Icons.store
                                      : Icons.delivery_dining,
                                  color: Colors.white,
                                ),
                              ),
                              title: Text(
                                business.name,
                                style: const TextStyle(fontWeight: FontWeight.bold),
                              ),
                              subtitle: Text(
                                business.isOpenNow()
                                    ? '${AppTranslations.text(context, 'open')} • ${business.address}'
                                    : '${AppTranslations.text(context, 'closed')} • ${business.address}',
                              ),
                              trailing: const Icon(Icons.arrow_forward_ios),
                              onTap: () => _navigateToBusinessDetails(business),
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }
}