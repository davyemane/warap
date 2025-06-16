// Fichier screens/vendor/product_list_screen.dart
import 'package:flutter/material.dart';
import 'package:warap/screens/vendor/add_product_screen.dart';
import 'package:warap/screens/vendor/edit_product_screen.dart';
import '../../models/business_model.dart';
import '../../models/product_model.dart';
import '../../services/product_service.dart';
import '../../services/error_handler.dart';
import '../../l10n/translations.dart';
import '../../widgets/common/custom_app_bar.dart';
import '../../widgets/common/loading_indicator.dart';

class ProductListScreen extends StatefulWidget {
  final BusinessModel business;
  
  const ProductListScreen({super.key, required this.business});

  @override
  State<ProductListScreen> createState() => _ProductListScreenState();
}

class _ProductListScreenState extends State<ProductListScreen> {
  final ProductService _productService = ProductService();
  
  List<ProductModel> _products = [];
  List<ProductModel> _filteredProducts = [];
  List<String> _categories = [];
  bool _isLoading = true;
  String _searchQuery = '';
  String? _selectedCategory;
  
  @override
  void initState() {
    super.initState();
    _loadProducts();
  }
  
  Future<void> _loadProducts() async {
    setState(() {
      _isLoading = true;
    });
    
    try {
      final products = await _productService.getBusinessProducts(widget.business.id);
      final categories = await _productService.getBusinessCategories(widget.business.id);
      
      setState(() {
        _products = products;
        _filteredProducts = products;
        _categories = categories;
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
          fallbackMessage: AppTranslations.text(context, 'error_loading_products'),
          onRetry: _loadProducts,
        );
      }
    }
  }
  
  void _applyFilters() {
    List<ProductModel> filtered = _products;
    
    // Filtre par recherche
    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((product) {
        final name = product.name.toLowerCase();
        final description = product.description.toLowerCase();
        final query = _searchQuery.toLowerCase();
        
        return name.contains(query) || description.contains(query);
      }).toList();
    }
    
    // Filtre par catégorie
    if (_selectedCategory != null) {
      filtered = filtered.where((product) => product.category == _selectedCategory).toList();
    }
    
    setState(() {
      _filteredProducts = filtered;
    });
  }
  
  Future<void> _deleteProduct(ProductModel product) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppTranslations.text(context, 'delete_product')),
        content: Text(AppTranslations.textWithParams(
          context, 'confirm_delete_product', [product.name])),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(AppTranslations.text(context, 'cancel')),
          ),
          TextButton(
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(AppTranslations.text(context, 'delete')),
          ),
        ],
      ),
    );
    
    if (confirm != true) return;
    
    try {
      await _productService.deleteProduct(product.id);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppTranslations.text(context, 'product_deleted'))),
        );
      }
      
      await _loadProducts();
    } catch (e) {
      if (mounted) {
        ErrorHandler.showErrorSnackBar(
          context, 
          e,
          fallbackMessage: AppTranslations.text(context, 'error_deleting_product'),
          onRetry: () => _deleteProduct(product),
        );
      }
    }
  }
  
void _addNewProduct() {
  // Utiliser MaterialPageRoute directement au lieu de pushNamed
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => AddProductScreen(business: widget.business),
    ),
  ).then((_) => _loadProducts());
}  
void _editProduct(ProductModel product) {
  // Utiliser MaterialPageRoute directement au lieu de pushNamed
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => EditProductScreen(product: product),
    ),
  ).then((_) => _loadProducts());
}  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: AppTranslations.textWithParams(context, 'business_products', [widget.business.name]),
        showBackButton: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              // Afficher une barre de recherche
              showSearch(
                context: context,
                delegate: _ProductSearchDelegate(
                  _products,
                  (query) {
                    setState(() {
                      _searchQuery = query;
                      _applyFilters();
                    });
                  },
                  (product) => _editProduct(product),
                  (product) => _deleteProduct(product),
                ),
              );
            },
            tooltip: AppTranslations.text(context, 'search'),
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadProducts,
            tooltip: AppTranslations.text(context, 'refresh'),
          ),
        ],
      ),
      body: _isLoading
          ? Center(
              child: LoadingIndicator(
                message: AppTranslations.text(context, 'loading_products'),
                animationType: AnimationType.bounce,
                color: Theme.of(context).primaryColor,
              ),
            )
          : Column(
              children: [
                // Filtres par catégorie
                if (_categories.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: SizedBox(
                      height: 40,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: _categories.length + 1, // +1 pour "Tous"
                        itemBuilder: (context, index) {
                          if (index == 0) {
                            return Padding(
                              padding: const EdgeInsets.only(right: 8),
                              child: FilterChip(
                                label: Text(AppTranslations.text(context, 'all')),
                                selected: _selectedCategory == null,
                                onSelected: (selected) {
                                  setState(() {
                                    _selectedCategory = null;
                                    _applyFilters();
                                  });
                                },
                              ),
                            );
                          }
                          
                          final category = _categories[index - 1];
                          return Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: FilterChip(
                              label: Text(category),
                              selected: _selectedCategory == category,
                              onSelected: (selected) {
                                setState(() {
                                  _selectedCategory = selected ? category : null;
                                  _applyFilters();
                                });
                              },
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                
                // Liste des produits
                Expanded(
                  child: _products.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.inventory,
                                size: 80,
                                color: Colors.grey[400],
                              ),
                              const SizedBox(height: 16),
                              Text(
                                AppTranslations.text(context, 'no_products_yet'),
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                AppTranslations.text(context, 'add_first_product'),
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: Colors.grey[600],
                                ),
                              ),
                              const SizedBox(height: 24),
                              ElevatedButton.icon(
                                onPressed: _addNewProduct,
                                icon: const Icon(Icons.add),
                                label: Text(AppTranslations.text(context, 'add_product')),
                              ),
                            ],
                          ),
                        )
                      : _filteredProducts.isEmpty
                          ? Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.search_off,
                                    size: 80,
                                    color: Colors.grey[400],
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    AppTranslations.text(context, 'no_products_found'),
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    AppTranslations.text(context, 'try_different_filter'),
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                  const SizedBox(height: 24),
                                  ElevatedButton(
                                    onPressed: () {
                                      setState(() {
                                        _searchQuery = '';
                                        _selectedCategory = null;
                                        _filteredProducts = _products;
                                      });
                                    },
                                    child: Text(AppTranslations.text(context, 'clear_filters')),
                                  ),
                                ],
                              ),
                            )
                          : ListView.builder(
                              itemCount: _filteredProducts.length,
                              padding: const EdgeInsets.all(16),
                              itemBuilder: (context, index) {
                                final product = _filteredProducts[index];
                                return Card(
                                  margin: const EdgeInsets.only(bottom: 16),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  elevation: 2,
                                  child: ListTile(
                                    contentPadding: const EdgeInsets.all(16),
                                    leading: Container(
                                      width: 60,
                                      height: 60,
                                      decoration: BoxDecoration(
                                        color: Colors.grey[200],
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: product.imageUrl.isNotEmpty
                                          ? ClipRRect(
                                              borderRadius: BorderRadius.circular(8),
                                              child: Image.network(
                                                product.imageUrl,
                                                fit: BoxFit.cover,
                                                errorBuilder: (context, error, stackTrace) {
                                                  return const Icon(
                                                    Icons.image,
                                                    color: Colors.grey,
                                                    size: 30,
                                                  );
                                                },
                                              ),
                                            )
                                          : const Icon(
                                              Icons.image,
                                              color: Colors.grey,
                                              size: 30,
                                            ),
                                    ),
                                    title: Text(
                                      product.name,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                    ),
                                    subtitle: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        const SizedBox(height: 4),
                                        Text(
                                          '${product.price.toStringAsFixed(2)} €',
                                          style: TextStyle(
                                            color: Theme.of(context).primaryColor,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          product.category,
                                          style: TextStyle(
                                            color: Colors.grey[600],
                                            fontSize: 12,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Row(
                                          children: [
                                            Icon(
                                              product.isAvailable
                                                  ? Icons.check_circle
                                                  : Icons.cancel,
                                              size: 16,
                                              color: product.isAvailable
                                                  ? Colors.green
                                                  : Colors.red,
                                            ),
                                            const SizedBox(width: 4),
                                            Text(
                                              product.isAvailable
                                                  ? AppTranslations.text(context, 'available')
                                                  : AppTranslations.text(context, 'not_available'),
                                              style: TextStyle(
                                                color: product.isAvailable
                                                    ? Colors.green
                                                    : Colors.red,
                                                fontSize: 12,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                    trailing: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        IconButton(
                                          icon: const Icon(Icons.edit),
                                          onPressed: () => _editProduct(product),
                                          tooltip: AppTranslations.text(context, 'edit'),
                                        ),
                                        IconButton(
                                          icon: const Icon(Icons.delete, color: Colors.red),
                                          onPressed: () => _deleteProduct(product),
                                          tooltip: AppTranslations.text(context, 'delete'),
                                        ),
                                      ],
                                    ),
                                    onTap: () => _editProduct(product),
                                  ),
                                );
                              },
                            ),
                ),
              ],
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addNewProduct,
        tooltip: AppTranslations.text(context, 'add_product'),
        child: const Icon(Icons.add),
      ),
    );
  }
}

// Délégué de recherche pour les produits
class _ProductSearchDelegate extends SearchDelegate<String> {
  final List<ProductModel> products;
  final Function(String) onSearch;
  final Function(ProductModel) onEdit;
  final Function(ProductModel) onDelete;
  
  _ProductSearchDelegate(this.products, this.onSearch, this.onEdit, this.onDelete);
  
  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: const Icon(Icons.clear),
        onPressed: () {
          query = '';
          showResults(context);
        },
      ),
    ];
  }
  
  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () {
        close(context, '');
      },
    );
  }
  
  @override
  Widget buildResults(BuildContext context) {
    onSearch(query);
    return Container(); // Résultats gérés par l'écran principal
  }
  
  @override
  Widget buildSuggestions(BuildContext context) {
    final suggestions = query.isEmpty
        ? []
        : products.where((product) {
            final name = product.name.toLowerCase();
            final description = product.description.toLowerCase();
            final queryLower = query.toLowerCase();
            return name.contains(queryLower) || description.contains(queryLower);
          }).toList();
    
    return ListView.builder(
      itemCount: suggestions.length,
      itemBuilder: (context, index) {
        final product = suggestions[index];
        return ListTile(
          leading: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(4),
            ),
            child: product.imageUrl.isNotEmpty
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: Image.network(
                      product.imageUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return const Icon(
                          Icons.image,
                          color: Colors.grey,
                          size: 20,
                        );
                      },
                    ),
                  )
                : const Icon(
                    Icons.image,
                    color: Colors.grey,
                    size: 20,
                  ),
          ),
          title: Text(product.name),
          subtitle: Text('${product.price.toStringAsFixed(2)} €'),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: const Icon(Icons.edit),
                onPressed: () {
                  close(context, '');
                  onEdit(product);
                },
              ),
              IconButton(
                icon: const Icon(Icons.delete, color: Colors.red),
                onPressed: () {
                  close(context, '');
                  onDelete(product);
                },
              ),
            ],
          ),
          onTap: () {
            query = product.name;
            showResults(context);
          },
        );
      },
    );
  }
}