// Fichier screens/client/business_details_screen.dart
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:share_plus/share_plus.dart';
import '../../models/business_model.dart';
import '../../widgets/common/custom_app_bar.dart';
import '../../l10n/translations.dart';
import '../../services/error_handler.dart'; // Ajout de l'import

class BusinessDetailsScreen extends StatelessWidget {
  final BusinessModel business;
  
  const BusinessDetailsScreen({Key? key, required this.business}) : super(key: key);

  // Fonction de partage
  void _shareBusiness(BuildContext context) {
    final String message = """
${business.name}
${business.businessType == 'fixe' ? AppTranslations.text(context, 'fixed_business') : AppTranslations.text(context, 'mobile_business')}
${business.isOpenNow() ? AppTranslations.text(context, 'open') : AppTranslations.text(context, 'closed')} - ${AppTranslations.text(context, 'opening_hours')}: ${business.openingTime} - ${business.closingTime}
${business.address.isNotEmpty ? '${AppTranslations.text(context, 'address')}: ${business.address}' : ''}
${business.description.isNotEmpty ? '\n${business.description}' : ''}

${AppTranslations.text(context, 'discover_app')}
""";

    Share.share(message, subject: AppTranslations.textWithParams(context, 'discover_business', [business.name]));
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
                SnackBar(content: Text(AppTranslations.textWithParams(
                  context, 'added_to_favorites', [business.name]))),
              );
            },
          ),
          // Bouton de partage
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: () => _shareBusiness(context),
            tooltip: AppTranslations.text(context, 'share'),
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
                    business.businessType == 'fixe'
                        ? AppTranslations.text(context, 'fixed_business')
                        : AppTranslations.text(context, 'mobile_business'),
                  ),
                  backgroundColor: business.businessType == 'fixe' 
                      ? Colors.blue.shade100 
                      : Colors.green.shade100,
                ),
                Chip(
                  label: Text(
                    business.isOpenNow()
                        ? AppTranslations.text(context, 'open')
                        : AppTranslations.text(context, 'closed'),
                  ),
                  backgroundColor: business.isOpenNow() 
                      ? Colors.green.shade100 
                      : Colors.red.shade100,
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            // Description
            Text(
              AppTranslations.text(context, 'description'),
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(business.description),
            const SizedBox(height: 16),
            
            // Heures d'ouverture
            Text(
              AppTranslations.text(context, 'opening_hours'),
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text('${AppTranslations.text(context, 'from')} ${business.openingTime} ${AppTranslations.text(context, 'to')} ${business.closingTime}'),
            const SizedBox(height: 16),
            
            // Adresse
            if (business.address.isNotEmpty) ...[
              Text(
                AppTranslations.text(context, 'address'),
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(business.address),
              const SizedBox(height: 8),
              TextButton.icon(
                icon: const Icon(Icons.map),
                label: Text(AppTranslations.text(context, 'open_in_maps')),
                onPressed: () => _openMap(context, business.latitude, business.longitude),
              ),
              const SizedBox(height: 16),
            ],
            
            // Téléphone
            if (business.phone.isNotEmpty) ...[
              Text(
                AppTranslations.text(context, 'contact'),
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Text(business.phone),
                  const SizedBox(width: 16),
                  TextButton.icon(
                    icon: const Icon(Icons.phone),
                    label: Text(AppTranslations.text(context, 'call')),
                    onPressed: () => _callPhone(context, business.phone),
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
                  label: AppTranslations.text(context, 'directions'),
                  color: Colors.blue,
                  onTap: () => _openMap(context, business.latitude, business.longitude),
                ),
                _ActionButton(
                  icon: Icons.favorite_border,
                  label: AppTranslations.text(context, 'favorites'),
                  color: Colors.red,
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(AppTranslations.textWithParams(
                        context, 'added_to_favorites', [business.name]))),
                    );
                  },
                ),
                _ActionButton(
                  icon: Icons.share,
                  label: AppTranslations.text(context, 'share'),
                  color: Colors.green,
                  onTap: () => _shareBusiness(context),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _openMap(BuildContext context, double latitude, double longitude) async {
    final Uri url = Uri.parse('https://www.google.com/maps/search/?api=1&query=$latitude,$longitude');
    
    try {
      if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
        throw Exception('Could not launch $url');
      }
    } catch (e) {
      ErrorHandler.showErrorSnackBar(
        context,
        e,
        fallbackMessage: AppTranslations.text(context, 'error_opening_maps'),
        onRetry: () => _openMap(context, latitude, longitude),
      );
    }
  }

  Future<void> _callPhone(BuildContext context, String phone) async {
    final Uri url = Uri.parse('tel:$phone');
    
    try {
      if (!await launchUrl(url)) {
        throw Exception('Could not launch $url');
      }
    } catch (e) {
      ErrorHandler.showErrorSnackBar(
        context,
        e,
        fallbackMessage: AppTranslations.text(context, 'error_making_call'),
        onRetry: () => _callPhone(context, phone),
      );
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