// Fichier screens/common/settings_screen.dart
import 'package:flutter/material.dart';
import '../../models/user_model.dart';
import '../../services/auth_service.dart';
import '../../l10n/translations.dart';

class SettingsScreen extends StatefulWidget {
  final UserModel? user;
  final VoidCallback onSettingsChanged;
  
  const SettingsScreen({
    super.key,
    required this.user,
    required this.onSettingsChanged,
  });

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final AuthService _authService = AuthService();
  
  // Paramètres
  bool _notificationsEnabled = true;
  bool _locationEnabled = true;
  bool _darkModeEnabled = false;
  double _searchRadius = 5.0; // km
  
  @override
  void initState() {
    super.initState();
    // Charger les paramètres depuis les préférences locales ou le serveur
    _loadSettings();
  }
  
  Future<void> _loadSettings() async {
    // Dans une implémentation réelle, chargez les paramètres depuis
    // SharedPreferences ou depuis votre serveur
    setState(() {
      // Pour l'instant, on utilise des valeurs par défaut
    });
  }
  
  Future<void> _saveSettings() async {
    // Dans une implémentation réelle, sauvegardez les paramètres dans
    // SharedPreferences ou sur votre serveur
    
    // Afficher un indicateur de chargement
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(),
      ),
    );
    
    // Simuler un délai de sauvegarde
    await Future.delayed(const Duration(seconds: 1));
    
    // Fermer l'indicateur de chargement
    if (!mounted) return;
    Navigator.pop(context);
    
    // Afficher un message de confirmation
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(AppTranslations.text(context, 'settings_saved')),
        backgroundColor: Colors.green,
      ),
    );
    
    // Notifier le parent que les paramètres ont changé
    widget.onSettingsChanged();
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppTranslations.text(context, 'settings')),
        actions: [
          TextButton(
            onPressed: _saveSettings,
            child: Text(
              AppTranslations.text(context, 'save'),
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
      body: ListView(
        children: [
          // Section Notifications
          _buildSectionHeader(context, AppTranslations.text(context, 'notifications')),
          SwitchListTile(
            title: Text(AppTranslations.text(context, 'enable_notifications')),
            subtitle: Text(AppTranslations.text(context, 'notifications_desc')),
            value: _notificationsEnabled,
            onChanged: (value) {
              setState(() {
                _notificationsEnabled = value;
              });
            },
          ),
          const Divider(),
          
          // Section Localisation
          _buildSectionHeader(context, AppTranslations.text(context, 'location')),
          SwitchListTile(
            title: Text(AppTranslations.text(context, 'enable_location')),
            subtitle: Text(AppTranslations.text(context, 'location_desc')),
            value: _locationEnabled,
            onChanged: (value) {
              setState(() {
                _locationEnabled = value;
              });
            },
          ),
          
          // Rayon de recherche
          ListTile(
            title: Text(AppTranslations.text(context, 'search_radius')),
            subtitle: Text('${_searchRadius.toInt()} ${AppTranslations.text(context, 'km')}'),
            trailing: SizedBox(
              width: 150,
              child: Slider(
                value: _searchRadius,
                min: 1.0,
                max: 20.0,
                divisions: 19,
                label: '${_searchRadius.toInt()} ${AppTranslations.text(context, 'km')}',
                onChanged: (value) {
                  setState(() {
                    _searchRadius = value;
                  });
                },
              ),
            ),
          ),
          const Divider(),
          
          // Section Apparence
          _buildSectionHeader(context, AppTranslations.text(context, 'appearance')),
          SwitchListTile(
            title: Text(AppTranslations.text(context, 'dark_mode')),
            subtitle: Text(AppTranslations.text(context, 'dark_mode_desc')),
            value: _darkModeEnabled,
            onChanged: (value) {
              setState(() {
                _darkModeEnabled = value;
              });
              
              // Ici vous implémenteriez la logique pour changer le thème
            },
          ),
          const Divider(),
          
          // Section Compte
          _buildSectionHeader(context, AppTranslations.text(context, 'account')),
          ListTile(
            title: Text(AppTranslations.text(context, 'email')),
            subtitle: Text(widget.user?.email ?? AppTranslations.text(context, 'user_not_connected')),
            leading: const Icon(Icons.email),
          ),
          ListTile(
            title: Text(AppTranslations.text(context, 'account_type')),
            subtitle: Text(widget.user?.userType == 'client' 
                ? AppTranslations.text(context, 'client') 
                : AppTranslations.text(context, 'vendor')),
            leading: const Icon(Icons.badge),
          ),
          
          // Option pour supprimer le compte
          ListTile(
            title: Text(AppTranslations.text(context, 'delete_account')),
            subtitle: Text(AppTranslations.text(context, 'delete_account_desc')),
            leading: const Icon(Icons.delete_forever, color: Colors.red),
            onTap: _showDeleteAccountConfirmation,
          ),
          
          const SizedBox(height: 32),
        ],
      ),
    );
  }
  
  Widget _buildSectionHeader(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Colors.blue,
        ),
      ),
    );
  }
  
  void _showDeleteAccountConfirmation() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppTranslations.text(context, 'delete_account_question')),
        content: Text(AppTranslations.text(context, 'delete_account_warning')),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(AppTranslations.text(context, 'cancel')),
          ),
          TextButton(
            style: TextButton.styleFrom(
              foregroundColor: Colors.red,
            ),
            onPressed: () {
              Navigator.pop(context);
              _deleteAccount();
            },
            child: Text(AppTranslations.text(context, 'delete')),
          ),
        ],
      ),
    );
  }
  
  Future<void> _deleteAccount() async {
    // Afficher un indicateur de chargement
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(),
      ),
    );
    
    try {
      // Simuler une suppression de compte
      await Future.delayed(const Duration(seconds: 2));
      
      // Dans une implémentation réelle, vous appelleriez un service comme :
      // await _authService.deleteAccount();
      
      // Déconnexion après suppression
      await _authService.signOut();
      
      // Rediriger vers l'écran de connexion
      if (!mounted) return;
      Navigator.of(context).popUntil((route) => route.isFirst);
      Navigator.of(context).pushReplacementNamed('/login');
      
      // Afficher un message de confirmation
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppTranslations.text(context, 'account_deleted')),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      // Fermer l'indicateur de chargement
      if (!mounted) return;
      Navigator.pop(context);
      
      // Afficher un message d'erreur
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${AppTranslations.text(context, 'error_deleting_account')}: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  
}