// Fichier screens/common/edit_profile_screen.dart
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../../models/user_model.dart';
import '../../services/auth_service.dart';
import '../../l10n/translations.dart';

class EditProfileScreen extends StatefulWidget {
  final UserModel user;

  const EditProfileScreen({
    Key? key,
    required this.user,
  }) : super(key: key);

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final AuthService _authService = AuthService();
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();

  File? _imageFile;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _nameController.text = widget.user.name;
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  // Sélectionner une image depuis la galerie
  Future<void> _pickImage() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 512,
        maxHeight: 512,
        imageQuality: 85,
      );

      if (image != null) {
        setState(() {
          _imageFile = File(image.path);
        });
      }
    } catch (e) {
      _showErrorSnackBar(AppTranslations.text(context, 'error_selecting_image'));
    }
  }

  // Prendre une photo avec la caméra
  Future<void> _takePhoto() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? photo = await picker.pickImage(
        source: ImageSource.camera,
        maxWidth: 512,
        maxHeight: 512,
        imageQuality: 85,
      );

      if (photo != null) {
        setState(() {
          _imageFile = File(photo.path);
        });
      }
    } catch (e) {
      _showErrorSnackBar(AppTranslations.text(context, 'error_taking_photo'));
    }
  }

  // Afficher les options pour changer la photo
  void _showImageSourceOptions() {
    showModalBottomSheet(
      context: context,
      builder: (context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.photo_library),
            title: Text(AppTranslations.text(context, 'choose_from_gallery')),
            onTap: () {
              Navigator.pop(context);
              _pickImage();
            },
          ),
          ListTile(
            leading: const Icon(Icons.camera_alt),
            title: Text(AppTranslations.text(context, 'take_photo')),
            onTap: () {
              Navigator.pop(context);
              _takePhoto();
            },
          ),
          if (widget.user.hasProfileImage)
            ListTile(
              leading: const Icon(Icons.delete, color: Colors.red),
              title: Text(AppTranslations.text(context, 'delete_photo')),
              onTap: () {
                Navigator.pop(context);
                setState(() {
                  _imageFile = null;
                });
                _showSuccessSnackBar(AppTranslations.text(context, 'photo_deleted'));
              },
            ),
        ],
      ),
    );
  }

  // Sauvegarder les modifications du profil
  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      String? imageUrl;

      // Si une nouvelle image a été sélectionnée, la télécharger
      if (_imageFile != null) {
        final fileBytes = await _imageFile!.readAsBytes();
        final fileName = _imageFile!.path.split('/').last;

        imageUrl = await _authService.uploadProfileImage(
          widget.user.id,
          fileBytes,
          fileName,
        );
      }

      // Mettre à jour le profil
      final updatedUser = await _authService.updateUserProfile(
        userId: widget.user.id,
        name: _nameController.text,
        profileImageUrl: _imageFile == null ? null : imageUrl,
      );

      setState(() {
        _isLoading = false;
      });

      if (!mounted) return;
      _showSuccessSnackBar(AppTranslations.text(context, 'profile_updated'));

      // Revenir à l'écran précédent avec l'utilisateur mis à jour
      Navigator.pop(context, updatedUser);
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      _showErrorSnackBar(AppTranslations.text(context, 'error_updating_profile'));
    }
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppTranslations.text(context, 'edit_profile')),
        actions: [
          // Bouton de sauvegarde
          TextButton(
            onPressed: _isLoading ? null : _saveProfile,
            child: _isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : Text(
                    AppTranslations.text(context, 'save'),
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Photo de profil
                    GestureDetector(
                      onTap: _showImageSourceOptions,
                      child: Stack(
                        children: [
                          GestureDetector(
                            onTap: _showImageSourceOptions,
                            child: Stack(
                              children: [
                                // Nouveau widget d'image avec gestion d'erreur
                                Container(
                                  width: 120,
                                  height: 120,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Colors.grey[200],
                                  ),
                                  child: ClipOval(
                                    child: _imageFile != null
                                        ? Image.file(
                                            _imageFile!,
                                            fit: BoxFit.cover,
                                          )
                                        : widget.user.hasProfileImage
                                            ? Image.network(
                                                widget.user.profileImageUrl!,
                                                fit: BoxFit.cover,
                                                errorBuilder: (context, error,
                                                    stackTrace) {
                                                  print(
                                                      'Erreur de chargement: $error');
                                                  return Center(
                                                    child: Text(
                                                      widget.user.initials,
                                                      style: const TextStyle(
                                                        fontSize: 40,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        color: Colors.blue,
                                                      ),
                                                    ),
                                                  );
                                                },
                                              )
                                            : Center(
                                                child: Text(
                                                  widget.user.initials,
                                                  style: const TextStyle(
                                                    fontSize: 40,
                                                    fontWeight: FontWeight.bold,
                                                    color: Colors.blue,
                                                  ),
                                                ),
                                              ),
                                  ),
                                ),
                                // Icône de caméra en bas à droite
                                Positioned(
                                  bottom: 0,
                                  right: 0,
                                  child: Container(
                                    padding: const EdgeInsets.all(4),
                                    decoration: const BoxDecoration(
                                      color: Colors.blue,
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(
                                      Icons.camera_alt,
                                      color: Colors.white,
                                      size: 20,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: Container(
                              padding: const EdgeInsets.all(4),
                              decoration: const BoxDecoration(
                                color: Colors.blue,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.camera_alt,
                                color: Colors.white,
                                size: 20,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Champ de texte pour le nom
                    TextFormField(
                      controller: _nameController,
                      decoration: InputDecoration(
                        labelText: AppTranslations.text(context, 'full_name'),
                        hintText: AppTranslations.text(context, 'enter_name'),
                        prefixIcon: const Icon(Icons.person),
                        border: const OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return AppTranslations.text(context, 'please_enter_name');
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Email (non modifiable)
                    TextFormField(
                      initialValue: widget.user.email,
                      enabled: false,
                      decoration: InputDecoration(
                        labelText: AppTranslations.text(context, 'email'),
                        prefixIcon: const Icon(Icons.email),
                        border: const OutlineInputBorder(),
                        disabledBorder: const OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.grey),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Type d'utilisateur (non modifiable)
                    TextFormField(
                      initialValue: widget.user.userType == 'client'
                          ? AppTranslations.text(context, 'client')
                          : AppTranslations.text(context, 'vendor'),
                      enabled: false,
                      decoration: InputDecoration(
                        labelText: AppTranslations.text(context, 'account_type'),
                        prefixIcon: const Icon(Icons.badge),
                        border: const OutlineInputBorder(),
                        disabledBorder: const OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.grey),
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