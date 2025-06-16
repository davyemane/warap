import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../models/product_model.dart';
import '../../services/product_service.dart';
import '../../services/error_handler.dart';
import '../../l10n/translations.dart';
import '../../widgets/common/custom_app_bar.dart';
import '../../widgets/common/image_picker_widget.dart';

class EditProductScreen extends StatefulWidget {
  final ProductModel product;

  const EditProductScreen({super.key, required this.product});

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
  XFile? _selectedNewImage; // NOUVEAU: Nouvelle image sélectionnée
  bool _imageChanged = false; // NOUVEAU: Track si l'image a changé
  
  List<String> _categories = ['Entrées', 'Plats', 'Desserts', 'Boissons'];
  bool _isLoading = false;
  bool _isDeleting = false;
  bool _categoriesLoaded = false;

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

    // S'assurer que la catégorie actuelle est dans la liste dès le début
    if (!_categories.contains(_category)) {
      _categories.add(_category);
    }

    _loadCategories();
  }

  Future<void> _loadCategories() async {
    try {
      final categories = await _productService
          .getBusinessCategories(widget.product.businessId);
      setState(() {
        if (categories.isNotEmpty) {
          _categories = categories;
        }
        // S'assurer que la catégorie actuelle est incluse
        if (!_categories.contains(_category)) {
          _categories.add(_category);
        }
        _categoriesLoaded = true;
      });
    } catch (e) {
      setState(() {
        if (!_categories.contains(_category)) {
          _categories.add(_category);
        }
        _categoriesLoaded = true;
      });
      print('Erreur lors du chargement des catégories: $e');
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
        imageUrl: _imageUrl, // Sera mis à jour par le service si nécessaire
        isAvailable: _isAvailable,
        stockQuantity: _stockQuantity,
        updatedAt: DateTime.now(),
      );

      // MODIFIÉ: Utiliser le nouveau service avec gestion d'image
      await _productService.updateProduct(
        updatedProduct,
        newImageFile: _selectedNewImage,
        deleteOldImage: _imageChanged && _selectedNewImage == null,
      );

      setState(() {
        _isLoading = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(AppTranslations.text(context, 'product_updated'))),
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
          fallbackMessage:
              AppTranslations.text(context, 'error_updating_product'),
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
          SnackBar(
              content: Text(AppTranslations.text(context, 'product_deleted'))),
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
          fallbackMessage:
              AppTranslations.text(context, 'error_deleting_product'),
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
                  const CircularProgressIndicator(),
                  const SizedBox(height: 16),
                  Text(_isDeleting
                      ? AppTranslations.text(context, 'deleting_product')
                      : AppTranslations.text(context, 'updating_product')),
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
                        // NOUVEAU: Widget de gestion d'image
                        const Text(
                          'Image du produit',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        ImagePickerWidget(
                          currentImageUrl: _selectedNewImage == null ? _imageUrl : null,
                          selectedImage: _selectedNewImage,
                          onImageSelected: (image) {
                            setState(() {
                              _selectedNewImage = image;
                              _imageChanged = true;
                            });
                          },
                          onImageRemoved: () {
                            setState(() {
                              _selectedNewImage = null;
                              _imageChanged = true;
                              _imageUrl = '';
                            });
                          },
                        ),
                        const SizedBox(height: 24),
                        
                        // Nom du produit
                        TextFormField(
                          decoration: InputDecoration(
                            labelText:
                                AppTranslations.text(context, 'product_name'),
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
                              return AppTranslations.text(
                                  context, 'price_required');
                            }
                            try {
                              final price =
                                  double.parse(value.replaceAll(',', '.'));
                              if (price <= 0) {
                                return AppTranslations.text(
                                    context, 'price_positive');
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
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return AppTranslations.text(
                                  context, 'category_required');
                            }
                            return null;
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
                            labelText:
                                AppTranslations.text(context, 'stock_quantity'),
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
                                return AppTranslations.text(
                                    context, 'quantity_not_negative');
                              }
                            } catch (e) {
                              return AppTranslations.text(
                                  context, 'invalid_quantity');
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