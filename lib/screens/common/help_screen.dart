// Fichier screens/common/help_screen.dart
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../l10n/translations.dart';
import 'faq_screen.dart';
import 'user_guide_screen.dart';
import 'vendor_guide_screen.dart';

class HelpScreen extends StatelessWidget {
  const HelpScreen({super.key});

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
      query: 'subject=Demande d\'aide - Warap&body=Décrivez votre problème ici:',
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
        title: Text(AppTranslations.text(context, 'help_support')),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          // En-tête
          Center(
            child: Text(
              AppTranslations.text(context, 'how_can_we_help'),
              style: const TextStyle(
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
            title: AppTranslations.text(context, 'faq_title'),
            description: AppTranslations.text(context, 'faq_desc'),
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
            title: AppTranslations.text(context, 'user_guide_title'),
            description: AppTranslations.text(context, 'user_guide_desc'),
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
            title: AppTranslations.text(context, 'contact_support_title'),
            description: AppTranslations.text(context, 'contact_support_desc'),
            onTap: _sendEmail,
          ),
          
          _buildHelpCard(
            context,
            icon: Icons.chat,
            title: AppTranslations.text(context, 'live_chat_title'),
            description: AppTranslations.text(context, 'live_chat_desc'),
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(AppTranslations.text(context, 'live_chat_soon')),
                ),
              );
            },
          ),
          
          _buildHelpCard(
            context,
            icon: Icons.shopping_bag,
            title: AppTranslations.text(context, 'vendor_guide_title'),
            description: AppTranslations.text(context, 'vendor_guide_desc'),
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
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Text(
              AppTranslations.text(context, 'follow_social'),
              style: const TextStyle(
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
          Text(
            AppTranslations.text(context, 'app_version'),
            style: const TextStyle(color: Colors.grey),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          GestureDetector(
            onTap: () => _launchURL('https://commerceconnect.com/privacy'),
            child: Text(
              AppTranslations.text(context, 'privacy_policy'),
              style: const TextStyle(
                color: Colors.blue,
                decoration: TextDecoration.underline,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 8),
          GestureDetector(
            onTap: () => _launchURL('https://commerceconnect.com/terms'),
            child: Text(
              AppTranslations.text(context, 'terms_of_use'),
              style: const TextStyle(
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