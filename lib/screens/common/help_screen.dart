// Fichier screens/common/help_screen.dart
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'faq_screen.dart';
import 'user_guide_screen.dart';
import 'vendor_guide_screen.dart';

class HelpScreen extends StatelessWidget {
  const HelpScreen({Key? key}) : super(key: key);

  Future<void> _launchURL(String urlString) async {
    final Uri url = Uri.parse(urlString);
    try {
      if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
        throw Exception('Could not launch $url');
      }
    } catch (e) {
      print('Erreur lors de l\'ouverture de l\'URL: $e');
    }
  }
  
  Future<void> _sendEmail() async {
    final Uri emailUri = Uri(
      scheme: 'mailto',
      path: 'support@commerceconnect.com',
      query: 'subject=Demande d\'aide - Commerce Connect&body=Décrivez votre problème ici:',
    );
    
    try {
      await launchUrl(emailUri);
    } catch (e) {
      print('Erreur lors de l\'envoi de l\'email: $e');
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Aide et support'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          // En-tête
          const Center(
            child: Text(
              'Comment pouvons-nous vous aider ?',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 24),
          
          // Options d'aide
          _buildHelpCard(
            context,
            icon: Icons.help_outline,
            title: 'Questions fréquentes',
            description: 'Trouvez des réponses aux questions les plus courantes.',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const FAQScreen(),
                ),
              );
            },
          ),
          
          _buildHelpCard(
            context,
            icon: Icons.book,
            title: 'Guide d\'utilisation',
            description: 'Découvrez toutes les fonctionnalités de l\'application.',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const UserGuideScreen(),
                ),
              );
            },
          ),
          
          _buildHelpCard(
            context,
            icon: Icons.email,
            title: 'Contacter le support',
            description: 'Envoyez un email à notre équipe de support.',
            onTap: _sendEmail,
          ),
          
          _buildHelpCard(
            context,
            icon: Icons.chat,
            title: 'Chat en direct',
            description: 'Discutez avec un représentant du service client.',
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Le chat en direct sera disponible prochainement'),
                ),
              );
            },
          ),
          
          _buildHelpCard(
            context,
            icon: Icons.shopping_bag,
            title: 'Guide pour les commerçants',
            description: 'Comment gérer efficacement votre boutique.',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const VendorGuideScreen(),
                ),
              );
            },
          ),
          
          const SizedBox(height: 16),
          
          // Section des liens sociaux
          const Divider(),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 16),
            child: Text(
              'Suivez-nous sur les réseaux sociaux',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildSocialButton(
                icon: Icons.facebook,
                color: Colors.blue,
                onTap: () => _launchURL('https://facebook.com/commerceconnect'),
              ),
              _buildSocialButton(
                icon: Icons.camera_alt,
                color: Colors.purple,
                onTap: () => _launchURL('https://instagram.com/commerceconnect'),
              ),
              _buildSocialButton(
                icon: Icons.messenger_outline,
                color: Colors.lightBlue,
                onTap: () => _launchURL('https://twitter.com/commerceconnect'),
              ),
              _buildSocialButton(
                icon: Icons.video_collection,
                color: Colors.red,
                onTap: () => _launchURL('https://youtube.com/commerceconnect'),
              ),
            ],
          ),
          
          const SizedBox(height: 32),
          const Text(
            'Version de l\'application: 1.0.0',
            style: TextStyle(color: Colors.grey),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          GestureDetector(
            onTap: () => _launchURL('https://commerceconnect.com/privacy'),
            child: const Text(
              'Politique de confidentialité',
              style: TextStyle(
                color: Colors.blue,
                decoration: TextDecoration.underline,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 8),
          GestureDetector(
            onTap: () => _launchURL('https://commerceconnect.com/terms'),
            child: const Text(
              'Conditions d\'utilisation',
              style: TextStyle(
                color: Colors.blue,
                decoration: TextDecoration.underline,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
  
Widget _buildSocialButton({
  required IconData icon,
  required Color color,
  required VoidCallback onTap,
}) {
  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 8.0),
    child: InkWell(
      onTap: onTap,
      child: CircleAvatar(
        backgroundColor: color.withOpacity(0.1),
        radius: 24,
        child: Icon(
          icon,
          color: color,
          size: 24,
        ),
      ),
    ),
  );
}

Widget _buildHelpCard(
  BuildContext context, {
  required IconData icon,
  required String title,
  required String description,
  required VoidCallback onTap,
}) {
  return Card(
    margin: const EdgeInsets.only(bottom: 16),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(12),
    ),
    elevation: 2,
    child: InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: Theme.of(context).primaryColor.withOpacity(0.1),
              radius: 24,
              child: Icon(
                icon,
                color: Theme.of(context).primaryColor,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: TextStyle(
                      color: Colors.grey[700],
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: Colors.grey,
            ),
          ],
        ),
      ),
    ),
  );
}
}