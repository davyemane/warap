// Fichier screens/client/favorites_screen.dart
import 'package:flutter/material.dart';
import '../../models/business_model.dart';
import '../../services/business_service.dart';
import '../../services/error_handler.dart'; // Ajout de l'import
import 'business_details_screen.dart';
import '../../l10n/translations.dart';

class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({Key? key}) : super(key: key);

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  final BusinessService _businessService = BusinessService();
  List<BusinessModel> _favorites = [];
  bool _isLoading = true;
  
  @override
  void initState() {
    super.initState();
    _loadFavorites();
  }
  
  Future<void> _loadFavorites() async {
    // Dans une implémentation réelle, vous devriez aller chercher les favoris
    // Pour l'instant, nous utilisons simplement tous les commerces
    setState(() {
      _isLoading = true;
    });
    
    try {
      final businesses = await _businessService.getAllBusinesses();
      setState(() {
        // Simuler des favoris en prenant quelques commerces
        _favorites = businesses.take(3).toList();
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
          fallbackMessage: AppTranslations.text(context, 'error_loading_favorites'),
          onRetry: _loadFavorites,
        );
      }
    }
  }
  
  void _removeFavorite(int index, BusinessModel business) {
    try {
      setState(() {
        _favorites.removeAt(index);
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppTranslations.textWithParams(
            context, 'removed_from_favorites', [business.name])),
        ),
      );
    } catch (e) {
      ErrorHandler.showErrorSnackBar(
        context, 
        e,
        fallbackMessage: AppTranslations.text(context, 'error_removing_favorite'),
      );
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppTranslations.text(context, 'my_favorites')),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadFavorites,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _favorites.isEmpty
              ? Center(
                  child: Text(
                    AppTranslations.text(context, 'no_favorites'),
                    style: const TextStyle(fontSize: 18),
                  ),
                )
              : ListView.builder(
                  itemCount: _favorites.length,
                  itemBuilder: (context, index) {
                    final business = _favorites[index];
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
                        trailing: IconButton(
                          icon: const Icon(Icons.favorite, color: Colors.red),
                          onPressed: () => _removeFavorite(index, business),
                        ),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => BusinessDetailsScreen(
                                business: business,
                              ),
                            ),
                          );
                        },
                      ),
                    );
                  },
                ),
    );
  }
}