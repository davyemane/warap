// Fichier services/location_service.dart
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart'; // Ajouter cette importation
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

  // Convertir une adresse en position géographique
  Future<Position> getPositionFromAddress(String address) async {
    try {
      if (address.isEmpty) {
        throw FormatException('L\'adresse ne peut pas être vide');
      }
      
      // Utiliser geocoding pour obtenir les coordonnées à partir de l'adresse
      List<Location> locations = await locationFromAddress(address);
      
      if (locations.isEmpty) {
        throw Exception('Impossible de trouver des coordonnées pour cette adresse');
      }
      
      // Prendre la première correspondance
      Location location = locations.first;
      
      // Convertir en objet Position (requis par certaines fonctions de Geolocator)
      return Position(
        latitude: location.latitude,
        longitude: location.longitude,
        timestamp: DateTime.now(),
        accuracy: 0,
        altitude: 0,
        heading: 0,
        speed: 0,
        speedAccuracy: 0,
        altitudeAccuracy: 0,
        headingAccuracy: 0,
      );
    } catch (e) {
      print('Erreur lors de la conversion de l\'adresse en position: $e');
      if (e is NoResultFoundException) {
        throw Exception('Adresse introuvable');
      }
      rethrow;
    }
  }

  // Obtenir l'adresse à partir des coordonnées
  Future<String> getAddressFromPosition(Position position) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );
      
      if (placemarks.isEmpty) {
        return 'Adresse inconnue';
      }
      
      Placemark place = placemarks.first;
      return [
        place.street,
        place.postalCode,
        place.locality,
        place.country,
      ].where((element) => element != null && element.isNotEmpty).join(', ');
    } catch (e) {
      print('Erreur lors de la conversion de la position en adresse: $e');
      return 'Adresse inconnue';
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