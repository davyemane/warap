import 'dart:io';
import 'dart:typed_data';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as path;

class ImageService {
  final SupabaseClient _supabase = Supabase.instance.client;
  final ImagePicker _picker = ImagePicker();

  // Sélectionner une image depuis la galerie ou la caméra
  Future<XFile?> pickImage({ImageSource source = ImageSource.gallery}) async {
    try {
      final XFile? image = await _picker.pickImage(
        source: source,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 80,
      );
      return image;
    } catch (e) {
      print('Erreur lors de la sélection de l\'image: $e');
      throw Exception('Erreur lors de la sélection de l\'image');
    }
  }

  // Upload d'une image vers Supabase Storage
  Future<String> uploadProductImage(XFile imageFile, String productId) async {
    try {
      // Lire les bytes du fichier
      final bytes = await imageFile.readAsBytes();

      // Créer un nom de fichier unique
      final extension = path.extension(imageFile.name);
      final fileName =
          'product_${productId}_${DateTime.now().millisecondsSinceEpoch}$extension';

      // Upload vers le bucket "images"
      final response = await _supabase.storage
          .from('images')
          .uploadBinary('products/$fileName', bytes);

      // Obtenir l'URL publique
      final publicUrl =
          _supabase.storage.from('images').getPublicUrl('products/$fileName');

      print('Image uploadée avec succès: $publicUrl');
      return publicUrl;
    } catch (e) {
      print('Erreur lors de l\'upload de l\'image: $e');
      throw Exception('Erreur lors de l\'upload de l\'image: $e');
    }
  }

  // Upload depuis les bytes (pour les web apps)
  Future<String> uploadProductImageFromBytes(
      Uint8List bytes, String fileName, String productId) async {
    try {
      final extension = path.extension(fileName);
      final uniqueFileName =
          'product_${productId}_${DateTime.now().millisecondsSinceEpoch}$extension';

      await _supabase.storage
          .from('images')
          .uploadBinary('products/$uniqueFileName', bytes);

      final publicUrl = _supabase.storage
          .from('images')
          .getPublicUrl('products/$uniqueFileName');

      return publicUrl;
    } catch (e) {
      print('Erreur lors de l\'upload des bytes: $e');
      throw Exception('Erreur lors de l\'upload de l\'image');
    }
  }

  // Supprimer une image du storage
  Future<void> deleteProductImage(String imageUrl) async {
    try {
      // Extraire le path du fichier depuis l'URL
      final uri = Uri.parse(imageUrl);
      final pathSegments = uri.pathSegments;

      // Trouver l'index de 'images' dans les segments
      final imagesIndex = pathSegments.indexOf('images');
      if (imagesIndex != -1 && imagesIndex < pathSegments.length - 1) {
        // Reconstruire le path après 'images'
        final filePath = pathSegments.sublist(imagesIndex + 1).join('/');

        await _supabase.storage.from('images').remove([filePath]);

        print('Image supprimée du storage: $filePath');
      }
    } catch (e) {
      print('Erreur lors de la suppression de l\'image: $e');
      // Ne pas lever d'exception pour la suppression d'image car le produit peut quand même être supprimé
    }
  }

  // Obtenir l'URL publique d'une image
  String getPublicUrl(String bucketName, String filePath) {
    return _supabase.storage.from(bucketName).getPublicUrl(filePath);
  }
}
