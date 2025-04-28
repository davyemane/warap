// Fichier screens/vendor/edit_product_screen.dart
import 'package:flutter/material.dart';
import '../../models/product_model.dart';
import '../../services/product_service.dart';
import '../../services/error_handler.dart';
import '../../l10n/translations.dart';
import '../../widgets/common/custom_app_bar.dart';

class EditProductScreen extends StatefulWidget {
  final ProductModel product;
  
  const EditProductScreen({Key? key, required this.product}) : super(key: key);

  @override
  State<EditProductScreen> createState() => _EditProductScreenState();
}

class _EditProductScreenState extends State<EditProductScreen> {
  final ProductService _productService = ProductService();
  final _formKey = GlobalKey<FormState>();
  
  late String _name;
  late String _description;
  late double _price;
  late String _category;
  late String _imageUrl;
  late bool _isAvailable;
  late int _stockQuantity;
  List<String> _categories = ['Entrées', 'Plats', 'Desserts', 'Boissons'];
  
  bool _isLoading = false;
  bool _isDeleting = false;
  
  @override
  void initState() {
    super.initState();
    // Initialiser les champs avec les valeurs existantes
    _name = widget.product.name;
    _description = widget.product.description;
    _price = widget.product.price;
    _category = widget.product.category;
    _imageUrl = widget.product.imageUrl;
    _isAvailable = widget.product.isAvailable;
    _stockQuantity = widget.product.stockQuantity;
    
    _loadCategories();
  }
  
  Future<void> _loadCategories() async {
    try {
      final categories = await _productService.getBusinessCategories(widget.product.businessId);
      if (categories.isNotEmpty) {
        setState(() {
          _categories = categories;
          // Vérifier si la catégorie actuelle existe dans la liste
          if (!_categories.contains(_category)) {
            // Si la catégorie n'existe pas, l'ajouter à la liste
            _categories.add(_category);
          }
        });
      }
    } catch (e) {
      // Utiliser les catégories par défaut en cas d'erreur
      print('Erreur lors du chargement des catégories: $e');
      // S'assurer que la catégorie actuelle est incluse
      if (!_categories.contains(_category)) {
        setState(() {
          _categories.add(_category);
        });
      }
    }
  }
  
  Future<void> _updateProduct() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    
    _formKey.currentState!.save();
    
    setState(() {
      _isLoading = true;
    });
    
    try {
      final updatedProduct = widget.product.copyWith(
        name: _name,
        description: _description,
        price: _price,
        category: _category,
        imageUrl: _imageUrl,
        isAvailable: _isAvailable,
        stockQuantity: _stockQuantity,
        updatedAt: DateTime.now(),
      );
      
      await _productService.updateProduct(updatedProduct);
      
      setState(() {
        _isLoading = false;
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppTranslations.text(context, 'product_updated'))),
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
          fallbackMessage: AppTranslations.text(context, 'error_updating_product'),
          onRetry: _updateProduct,
        );
      }
    }
  }
  
  Future<void> _deleteProduct() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppTranslations.text(context, 'delete_product')),
        content: Text(AppTranslations.textWithParams(
          context, 'confirm_delete_product', [widget.product.name])),
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
    
    setState(() {
      _isDeleting = true;
    });
    
    try {
      await _productService.deleteProduct(widget.product.id);
      
      setState(() {
        _isDeleting = false;
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppTranslations.text(context, 'product_deleted'))),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      setState(() {
        _isDeleting = false;
      });
      
      if (mounted) {
        ErrorHandler.showErrorSnackBar(
          context, 
          e,
          fallbackMessage: AppTranslations.text(context, 'error_deleting_product'),
          onRetry: _deleteProduct,
        );
      }
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: AppTranslations.text(context, 'edit_product'),
        showBackButton: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: _isLoading || _isDeleting ? null : _deleteProduct,
            tooltip: AppTranslations.text(context, 'delete'),
          ),
        ],
      ),
      body: _isLoading || _isDeleting
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  const SizedBox(height: 16),
                  Text(_isDeleting
                      ? AppTranslations.text(context, 'deleting_product')
                      : AppTranslations.text(context, 'updating_product')),
                ],
              ),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Nom du produit
                    TextFormField(
                      decoration: InputDecoration(
                        labelText: AppTranslations.text(context, 'product_name'),
                        border: const OutlineInputBorder(),
                      ),
                      initialValue: _name,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return AppTranslations.text(context, 'name_required');
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
                    
                    // Prix
                    TextFormField(
                      decoration: InputDecoration(
                        labelText: AppTranslations.text(context, 'price'),
                        border: const OutlineInputBorder(),
                        prefixIcon: const Icon(Icons.euro),
                      ),
                      initialValue: _price.toString(),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return AppTranslations.text(context, 'price_required');
                        }
                        try {
                          final price = double.parse(value.replaceAll(',', '.'));
                          if (price <= 0) {
                            return AppTranslations.text(context, 'price_positive');
                          }
                        } catch (e) {
                          return AppTranslations.text(context, 'invalid_price');
                        }
                        return null;
                      },
                      onSaved: (value) {
                        _price = double.parse(value!.replaceAll(',', '.'));
                      },
                    ),
                    const SizedBox(height: 16),
                    
                    // Catégorie
                    DropdownButtonFormField<String>(
                      decoration: InputDecoration(
                        labelText: AppTranslations.text(context, 'category'),
                        border: const OutlineInputBorder(),
                      ),
                      value: _category,
                      items: _categories.map((category) {
                        return DropdownMenuItem<String>(
                          value: category,
                          child: Text(category),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _category = value!;
                        });
                      },
                      onSaved: (value) {
                        _category = value!;
                      },
                    ),
                    const SizedBox(height: 16),
                    
                    // URL de l'image
                    TextFormField(
                      decoration: InputDecoration(
                        labelText: AppTranslations.text(context, 'image_url'),
                        border: const OutlineInputBorder(),
                        hintText: 'https://example.com/image.jpg',
                      ),
                      initialValue: _imageUrl,
                      onSaved: (value) {
                        _imageUrl = value ?? '';
                      },
                    ),
                    const SizedBox(height: 16),
                    
                    // Disponibilité
                    SwitchListTile(
                      title: Text(AppTranslations.text(context, 'available')),
                      value: _isAvailable,
                      onChanged: (value) {
                        setState(() {
                          _isAvailable = value;
                        });
                      },
                    ),
                    
                    // Quantité en stock
                    TextFormField(
                      decoration: InputDecoration(
                        labelText: AppTranslations.text(context, 'stock_quantity'),
                        border: const OutlineInputBorder(),
                      ),
                      initialValue: _stockQuantity.toString(),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return null;
                        }
                        try {
                          final quantity = int.parse(value);
                          if (quantity < 0) {
                            return AppTranslations.text(context, 'quantity_not_negative');
                          }
                        } catch (e) {
                          return AppTranslations.text(context, 'invalid_quantity');
                        }
                        return null;
                      },
                      onSaved: (value) {
                        _stockQuantity = int.tryParse(value ?? '0') ?? 0;
                      },
                    ),
                    const SizedBox(height: 32),
                    
                    // Bouton de sauvegarde
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _updateProduct,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        child: Text(
                          AppTranslations.text(context, 'update_product'),
                          style: const TextStyle(fontSize: 16),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}