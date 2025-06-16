import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../models/business_model.dart';
import '../../models/product_model.dart';
import '../../services/product_service.dart';
import '../../services/error_handler.dart';
import '../../l10n/translations.dart';
import '../../widgets/common/custom_app_bar.dart';
import '../../widgets/common/image_picker_widget.dart';

class AddProductScreen extends StatefulWidget {
  final BusinessModel business;
  
  const AddProductScreen({super.key, required this.business});

  @override
  State<AddProductScreen> createState() => _AddProductScreenState();
}

class _AddProductScreenState extends State<AddProductScreen> {
  final _formKey = GlobalKey<FormState>();
  final ProductService _productService = ProductService();
  
  String _name = '';
  String _description = '';
  double _price = 0.0;
  String _category = '';
  bool _isAvailable = true;
  int _stockQuantity = 0;
  XFile? _selectedImage; // MODIFIÉ: XFile au lieu de File
  bool _isLoading = false;
  bool _categoriesLoaded = false; // NOUVEAU: Pour gérer le chargement des catégories
  List<String> _categories = ['Entrées', 'Plats', 'Desserts', 'Boissons'];
  
  @override
  void initState() {
    super.initState();
    _loadCategories();
  }
  
  Future<void> _loadCategories() async {
    try {
      final categories = await _productService.getBusinessCategories(widget.business.id);
      setState(() {
        if (categories.isNotEmpty) {
          _categories = categories;
          _category = categories.first;
        } else {
          _category = _categories.first;
        }
        _categoriesLoaded = true;
      });
    } catch (e) {
      setState(() {
        _category = _categories.first;
        _categoriesLoaded = true;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppTranslations.text(context, 'error_loading_categories'))),
        );
      }
    }
  }
  
  Future<void> _saveProduct() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    
    _formKey.currentState!.save();
    
    setState(() {
      _isLoading = true;
    });
    
    try {
      // Créer le produit
      final product = ProductModel(
        id: '', // Sera généré par Supabase
        businessId: widget.business.id,
        name: _name,
        description: _description,
        price: _price,
        category: _category,
        imageUrl: '', // Sera mis à jour par le service si une image est fournie
        isAvailable: _isAvailable,
        stockQuantity: _stockQuantity,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      
      // MODIFIÉ: Utiliser le nouveau service avec gestion d'image
      await _productService.addProduct(product, imageFile: _selectedImage);
      
      setState(() {
        _isLoading = false;
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppTranslations.text(context, 'product_added'))),
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
          fallbackMessage: AppTranslations.text(context, 'error_adding_product'),
          onRetry: _saveProduct,
        );
      }
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: AppTranslations.text(context, 'add_product'),
        showBackButton: true,
      ),
      body: _isLoading
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Ajout du produit en cours...'),
                ],
              ),
            )
          : !_categoriesLoaded
              ? const Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16.0),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Info du commerce
                        Card(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Row(
                              children: [
                                CircleAvatar(
                                  backgroundColor: widget.business.businessType == 'fixe'
                                      ? Colors.blue
                                      : Colors.green,
                                  child: Icon(
                                    widget.business.businessType == 'fixe'
                                        ? Icons.store
                                        : Icons.delivery_dining,
                                    color: Colors.white,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        widget.business.name,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                        ),
                                      ),
                                      Text(
                                        widget.business.businessType == 'fixe'
                                            ? 'Commerce fixe'
                                            : 'Commerce mobile',
                                        style: TextStyle(
                                          color: Colors.grey[600],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                        
                        // NOUVEAU: Widget de sélection d'image
                        const Text(
                          'Image du produit',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        ImagePickerWidget(
                          selectedImage: _selectedImage,
                          onImageSelected: (image) {
                            setState(() {
                              _selectedImage = image;
                            });
                          },
                        ),
                        const SizedBox(height: 24),
                        
                        // Nom du produit
                        TextFormField(
                          decoration: InputDecoration(
                            labelText: AppTranslations.text(context, 'product_name'),
                            border: const OutlineInputBorder(),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return AppTranslations.text(context, 'required_field');
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
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return AppTranslations.text(context, 'required_field');
                            }
                            try {
                              final price = double.parse(value.replaceAll(',', '.'));
                              if (price <= 0) {
                                return AppTranslations.text(context, 'positive_price');
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
                          value: _category.isEmpty ? null : _category,
                          items: [
                            ..._categories.map((category) => DropdownMenuItem(
                              value: category,
                              child: Text(category),
                            )),
                            DropdownMenuItem(
                              value: 'new_category',
                              child: Row(
                                children: [
                                  const Icon(Icons.add),
                                  const SizedBox(width: 8),
                                  Text(AppTranslations.text(context, 'new_category')),
                                ],
                              ),
                            ),
                          ],
                          onChanged: (value) {
                            if (value == 'new_category') {
                              _showAddCategoryDialog();
                            } else if (value != null) {
                              setState(() {
                                _category = value;
                              });
                            }
                          },
                          validator: (value) {
                            if (value == null || value.isEmpty || value == 'new_category') {
                              return AppTranslations.text(context, 'required_field');
                            }
                            return null;
                          },
                          onSaved: (value) {
                            if (value != null && value != 'new_category') {
                              _category = value;
                            }
                          },
                        ),
                        const SizedBox(height: 16),
                        
                        // Quantité en stock
                        TextFormField(
                          decoration: InputDecoration(
                            labelText: AppTranslations.text(context, 'stock_quantity'),
                            border: const OutlineInputBorder(),
                            prefixIcon: const Icon(Icons.inventory),
                          ),
                          keyboardType: TextInputType.number,
                          initialValue: '0',
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return null;
                            }
                            try {
                              final quantity = int.parse(value);
                              if (quantity < 0) {
                                return AppTranslations.text(context, 'positive_quantity');
                              }
                            } catch (e) {
                              return AppTranslations.text(context, 'invalid_quantity');
                            }
                            return null;
                          },
                          onSaved: (value) {
                            _stockQuantity = value != null && value.isNotEmpty
                                ? int.parse(value)
                                : 0;
                          },
                        ),
                        const SizedBox(height: 16),
                        
                        // Disponibilité
                        SwitchListTile(
                          title: Text(AppTranslations.text(context, 'availability')),
                          subtitle: Text(AppTranslations.text(context, 'product_available')),
                          value: _isAvailable,
                          onChanged: (value) {
                            setState(() {
                              _isAvailable = value;
                            });
                          },
                        ),
                        const SizedBox(height: 32),
                        
                        // Bouton de sauvegarde
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: _saveProduct,
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                            ),
                            child: Text(
                              AppTranslations.text(context, 'save'),
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
  
  void _showAddCategoryDialog() {
    String newCategory = '';
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppTranslations.text(context, 'add_category')),
        content: TextField(
          decoration: InputDecoration(
            labelText: AppTranslations.text(context, 'category_name'),
            border: const OutlineInputBorder(),
          ),
          onChanged: (value) {
            newCategory = value;
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(AppTranslations.text(context, 'cancel')),
          ),
          ElevatedButton(
            onPressed: () {
              if (newCategory.isNotEmpty) {
                setState(() {
                  _categories.add(newCategory);
                  _category = newCategory;
                });
              }
              Navigator.of(context).pop();
            },
            child: Text(AppTranslations.text(context, 'add')),
          ),
        ],
      ),
    );
  }
}