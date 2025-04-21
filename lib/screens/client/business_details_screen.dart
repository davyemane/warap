// Fichier screens/client/business_details_screen.dart
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:share_plus/share_plus.dart';
import '../../models/business_model.dart';
import '../../widgets/common/custom_app_bar.dart';

class BusinessDetailsScreen extends StatelessWidget {
  final BusinessModel business;
  
  const BusinessDetailsScreen({Key? key, required this.business}) : super(key: key);

  // Fonction de partage
  void _shareBusiness() {
    final String message = """
${business.name}
${business.businessType == 'fixe' ? 'Commerce fixe' : 'Commerce mobile'}
${business.isOpenNow() ? 'Ouvert' : 'Fermé'} - Horaires: ${business.openingTime} - ${business.closingTime}
${business.address.isNotEmpty ? 'Adresse: ${business.address}' : ''}
${business.description.isNotEmpty ? '\n${business.description}' : ''}

Découvrez ce commerce sur Commerce Connect!
""";

    Share.share(message, subject: 'Découvrez ${business.name}');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: business.name,
        showBackButton: true,
        actions: [
          // Bouton de favoris
          IconButton(
            icon: const Icon(Icons.favorite_border),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('${business.name} ajouté aux favoris')),
              );
            },
          ),
          // Bouton de partage
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: _shareBusiness,
            tooltip: 'Partager',
          ),
        ],
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

            // Boutons d'action
            const SizedBox(height: 32),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _ActionButton(
                  icon: Icons.directions,
                  label: 'Itinéraire',
                  color: Colors.blue,
                  onTap: () => _openMap(business.latitude, business.longitude),
                ),
                _ActionButton(
                  icon: Icons.favorite_border,
                  label: 'Favoris',
                  color: Colors.red,
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('${business.name} ajouté aux favoris')),
                    );
                  },
                ),
                _ActionButton(
                  icon: Icons.share,
                  label: 'Partager',
                  color: Colors.green,
                  onTap: _shareBusiness,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _openMap(double latitude, double longitude) async {
    final Uri url = Uri.parse('https://www.google.com/maps/search/?api=1&query=$latitude,$longitude');
    
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      throw Exception('Could not launch $url');
    }
  }

  Future<void> _callPhone(String phone) async {
    final Uri url = Uri.parse('tel:$phone');
    
    if (!await launchUrl(url)) {
      throw Exception('Could not launch $url');
    }
  }
}

// Widget pour les boutons d'action
class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: color,
              size: 28,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}