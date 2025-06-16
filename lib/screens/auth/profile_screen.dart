// Fichier screens/common/profile_screen.dart
import 'package:flutter/material.dart';
import '../../services/auth_service.dart';
import '../../services/error_handler.dart'; // Ajout de l'import
import '../../l10n/translations.dart';
import 'package:provider/provider.dart';
import '../../providers/locale_provider.dart';

// Écran de gestion des langues
class LanguageScreen extends StatelessWidget {
  const LanguageScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final localeProvider = Provider.of<LocaleProvider>(context);
    final currentLocale = localeProvider.locale;

    return Scaffold(
      appBar: AppBar(
        title: Text(AppTranslations.text(context, 'language_settings')),
      ),
      body: ListView(
        children: [
          RadioListTile<String>(
            title: const Text('Français'),
            value: 'fr',
            groupValue: currentLocale.languageCode,
            onChanged: (value) {
              if (value != null) {
                localeProvider.changeLocale(Locale(value));
              }
            },
          ),
          RadioListTile<String>(
            title: const Text('English'),
            value: 'en',
            groupValue: currentLocale.languageCode,
            onChanged: (value) {
              if (value != null) {
                localeProvider.changeLocale(Locale(value));
              }
            },
          ),
          // Ajouter d'autres langues selon les besoins
        ],
      ),
    );
  }
}

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final AuthService _authService = AuthService();
  String _email = '';
  String _userType = '';
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final userData = await _authService.getCurrentUser();
      setState(() {
        _email = userData!.email;
        _userType = userData.userType;
        _isLoading = false;
      });
    } catch (e) {
      print('Erreur lors du chargement des données utilisateur: $e');
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ErrorHandler.showErrorSnackBar(
          context, 
          e,
          onRetry: _loadUserData,
        );
      }
    }
  }

  Future<void> _signOut() async {
    try {
      await _authService.signOut();
      if (!mounted) return;
      Navigator.of(context).pushReplacementNamed('/login');
    } catch (e) {
      print('Erreur lors de la déconnexion: $e');
      if (!mounted) return;
      ErrorHandler.showErrorSnackBar(
        context, 
        e,
        onRetry: _signOut,
      );
    }
  }

  void _navigateToLanguageScreen() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const LanguageScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppTranslations.text(context, 'profile')),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Avatar et nom d'utilisateur
                  Center(
                    child: Column(
                      children: [
                        const CircleAvatar(
                          radius: 50,
                          backgroundColor: Colors.blue,
                          child: Icon(
                            Icons.person,
                            size: 60,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          _email,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _userType == 'client'
                              ? AppTranslations.text(context, 'client')
                              : AppTranslations.text(context, 'vendor'),
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Informations du compte
                  Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 2,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            AppTranslations.text(context, 'account_info'),
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 16),
                          _buildInfoRow(
                            icon: Icons.email,
                            label: AppTranslations.text(context, 'email_label'),
                            value: _email,
                          ),
                          const Divider(height: 24),
                          _buildInfoRow(
                            icon: Icons.person,
                            label: AppTranslations.text(context, 'account_type'),
                            value: _userType == 'client'
                                ? AppTranslations.text(context, 'client')
                                : AppTranslations.text(context, 'vendor'),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Options du profil
                  Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 2,
                    child: Column(
                      children: [
                        // Option langue
                        ListTile(
                          leading: const Icon(Icons.language),
                          title: Text(AppTranslations.text(context, 'language_settings')),
                          trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                          onTap: _navigateToLanguageScreen,
                        ),
                        const Divider(height: 1),
                        // Option éditer profil
                        ListTile(
                          leading: const Icon(Icons.edit),
                          title: Text(AppTranslations.text(context, 'edit_profile')),
                          trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                          onTap: () {
                            // Implémentation pour éditer le profil
                            // TODO: Implémenter cette fonctionnalité
                          },
                        ),
                        const Divider(height: 1),
                        // Option changer mot de passe
                        ListTile(
                          leading: const Icon(Icons.lock),
                          title: Text(AppTranslations.text(context, 'change_password')),
                          trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                          onTap: () {
                            // Implémentation pour changer le mot de passe
                            // TODO: Implémenter cette fonctionnalité
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Bouton de déconnexion
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: Text(AppTranslations.text(context, 'logout')),
                            content: Text(AppTranslations.text(context, 'confirm_logout')),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context),
                                child: Text(AppTranslations.text(context, 'cancel')),
                              ),
                              TextButton(
                                onPressed: () {
                                  Navigator.pop(context);
                                  _signOut();
                                },
                                child: Text(AppTranslations.text(context, 'yes')),
                              ),
                            ],
                          ),
                        );
                      },
                      icon: const Icon(Icons.logout),
                      label: Text(AppTranslations.text(context, 'logout')),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      children: [
        Icon(icon, color: Colors.blue, size: 20),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: const TextStyle(
                fontSize: 16,
              ),
            ),
          ],
        ),
      ],
    );
  }
}