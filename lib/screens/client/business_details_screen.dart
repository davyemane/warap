// Fichier screens/client/business_details_screen.dart
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../models/business_model.dart';

class BusinessDetailsScreen extends StatelessWidget {
  final BusinessModel business;
  
  const BusinessDetailsScreen({Key? key, required this.business}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(business.name),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Type de commerce et statut (ouvert/fermé)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Chip(
                  label: Text(
                    business.businessType == 'fixe' ? 'Commerce fixe' : 'Commerce mobile',
                  ),
                  backgroundColor: business.businessType == 'fixe' 
                      ? Colors.blue.shade100 
                      : Colors.green.shade100,
                ),
                Chip(
                  label: Text(
                    business.isOpenNow() ? 'Ouvert' : 'Fermé',
                  ),
                  backgroundColor: business.isOpenNow() 
                      ? Colors.green.shade100 
                      : Colors.red.shade100,
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            // Description
            const Text(
              'Description',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(business.description),
            const SizedBox(height: 16),
            
            // Heures d'ouverture
            const Text(
              'Heures d\'ouverture',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text('De ${business.openingTime} à ${business.closingTime}'),
            const SizedBox(height: 16),
            
            // Adresse
            if (business.address.isNotEmpty) ...[
              const Text(
                'Adresse',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(business.address),
              const SizedBox(height: 8),
              TextButton.icon(
                icon: const Icon(Icons.map),
                label: const Text('Ouvrir dans Google Maps'),
                onPressed: () => _openMap(business.latitude, business.longitude),
              ),
              const SizedBox(height: 16),
            ],
            
            // Téléphone
            if (business.phone.isNotEmpty) ...[
              const Text(
                'Contact',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Text(business.phone),
                  const SizedBox(width: 16),
                  TextButton.icon(
                    icon: const Icon(Icons.phone),
                    label: const Text('Appeler'),
                    onPressed: () => _callPhone(business.phone),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Future<void> _openMap(double latitude, double longitude) async {
    final url = 'https://www.google.com/maps/search/?api=1&query=$latitude,$longitude';
    if (await canLaunch(url)) {
      await launch(url);
    }
  }

  Future<void> _callPhone(String phone) async {
    final url = 'tel:$phone';
    if (await canLaunch(url)) {
      await launch(url);
    }
  }
}