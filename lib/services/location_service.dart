// Fichier services/location_service.dart
import 'package:geolocator/geolocator.dart';
import 'error_handler.dart';

class LocationService {
  // Obtenir la position actuelle de l'utilisateur
  Future<Position> getCurrentPosition() async {
    try {
      bool serviceEnabled;
      LocationPermission permission;

      // Vérifier si les services de localisation sont activés
      serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        throw PermissionException('Location services are disabled.');
      }

      // Vérifier les permissions de localisation
      permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          throw PermissionException('Location permissions are denied');
        }
      }

      if (permission == LocationPermission.deniedForever) {
        throw PermissionException('Location permissions are permanently denied, we cannot request permissions.');
      }

      // Obtenir la position
      return await Geolocator.getCurrentPosition();
    } catch (e) {
      print('Erreur lors de l\'obtention de la position: $e');
      rethrow;
    }
  }

  // Calculer la distance entre deux positions
  double calculateDistance(double startLatitude, double startLongitude, 
                         double endLatitude, double endLongitude) {
    try {
      return Geolocator.distanceBetween(
        startLatitude, 
        startLongitude, 
        endLatitude, 
        endLongitude
      );
    } catch (e) {
      print('Erreur lors du calcul de la distance: $e');
      rethrow;
    }
  }
}