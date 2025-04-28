// Fichier screens/vendor/add_product_screen.dart
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../../models/business_model.dart';
import '../../models/product_model.dart';
import '../../services/product_service.dart';
import '../../services/error_handler.dart';
import '../../l10n/translations.dart';
import '../../widgets/common/custom_app_bar.dart';

class AddProductScreen extends StatefulWidget {
  final BusinessModel business;
  
  const AddProductScreen({Key? key, required this.business}) : super(key: key);

  @override
  State<AddProductScreen> createState() => _AddProductScreenState();
}

class _AddProductScreenState extends State<AddProductScreen> {
  final _formKey = GlobalKey<FormState>();
  final ProductService _productService = ProductService();
  final ImagePicker _picker = ImagePicker();
  
  String _name = '';
  String _description = '';
  double _price = 0.0;
  String _category = '';
  bool _isAvailable = true;
  int _stockQuantity = 0;
  File? _imageFile;
  bool _isLoading = false;
  List<String> _categories = ['Entrées', 'Plats', 'Desserts', 'Boissons']; // Catégories par défaut
  
  @override
  void initState() {
    super.initState();
    _loadCategories();
  }
  
  Future<void> _loadCategories() async {
    try {
      // Charger les catégories existantes du commerce
      final categories = await _productService.getBusinessCategories(widget.business.id);
      if (categories.isNotEmpty) {
        setState(() {
          _categories = categories;
          // Définir la première catégorie comme valeur par défaut
          _category = categories.first;
        });
      }
    } catch (e) {
      // En cas d'erreur, on garde les catégories par défaut
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppTranslations.text(context, 'error_loading_categories'))),
        );
      }
    }
  }
  
  Future<void> _pickImage() async {
    try {
      final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
      if (image != null) {
        setState(() {
          _imageFile = File(image.path);
        });
      }
    } catch (e) {
      if (mounted) {
        ErrorHandler.showErrorSnackBar(
          context, 
          e,
          fallbackMessage: AppTranslations.text(context, 'error_picking_image'),
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
      String imageUrl = '';
      
      // Si une image a été sélectionnée, la télécharger
      if (_imageFile != null) {
        // Version simplifiée - dans une vraie implémentation, vous téléchargeriez l'image
        // sur Supabase Storage et récupéreriez l'URL
        imageUrl = 'https://example.com/images/placeholder.jpg';
      }
      
      // Créer le produit
      final product = ProductModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(), // Temporaire, sera remplacé par Supabase
        businessId: widget.business.id,
        name: _name,
        description: _description,
        price: _price,
        category: _category,
        imageUrl: imageUrl,
        isAvailable: _isAvailable,
        stockQuantity: _stockQuantity,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      
      // Enregistrer le produit
      await _productService.addProduct(product);
      
      setState(() {
        _isLoading = false;
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppTranslations.text(context, 'product_added'))),
        );
        Navigator.pop(context, true); // Retourner avec succès
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
                                        ? AppTranslations.text(context, 'fixed_business')
                                        : AppTranslations.text(context, 'mobile_business'),
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
                    
                    // Formulaire d'ajout
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
                      value: _category.isEmpty ? (_categories.isNotEmpty ? _categories.first : null) : _category,
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
                          // Afficher une boîte de dialogue pour ajouter une nouvelle catégorie
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
                          return null; // Optionnel
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
                    const SizedBox(height: 16),
                    
                    // Sélection d'image
                    Text(
                      AppTranslations.text(context, 'product_image'),
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    GestureDetector(
                      onTap: _pickImage,
                      child: Container(
                        height: 150,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.grey[400]!),
                        ),
                        child: _imageFile != null
                            ? ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.file(
                                  _imageFile!,
                                  fit: BoxFit.cover,
                                ),
                              )
                            : Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(
                                    Icons.add_photo_alternate,
                                    size: 48,
                                    color: Colors.grey,
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    AppTranslations.text(context, 'tap_to_add_image'),
                                    style: const TextStyle(color: Colors.grey),
                                  ),
                                ],
                              ),
                      ),
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