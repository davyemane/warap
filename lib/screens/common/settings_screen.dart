// Fichier screens/common/settings_screen.dart
import 'package:flutter/material.dart';
import '../../models/user_model.dart';
import '../../services/auth_service.dart';

class SettingsScreen extends StatefulWidget {
  final UserModel? user;
  final VoidCallback onSettingsChanged;
  
  const SettingsScreen({
    Key? key,
    required this.user,
    required this.onSettingsChanged,
  }) : super(key: key);

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
      const SnackBar(
        content: Text('Paramètres sauvegardés'),
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
        title: const Text('Paramètres'),
        actions: [
          TextButton(
            onPressed: _saveSettings,
            child: const Text(
              'Enregistrer',
              style: TextStyle(
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
          _buildSectionHeader('Notifications'),
          SwitchListTile(
            title: const Text('Activer les notifications'),
            subtitle: const Text('Recevez des mises à jour sur les commerces à proximité'),
            value: _notificationsEnabled,
            onChanged: (value) {
              setState(() {
                _notificationsEnabled = value;
              });
            },
          ),
          const Divider(),
          
          // Section Localisation
          _buildSectionHeader('Localisation'),
          SwitchListTile(
            title: const Text('Activer la localisation'),
            subtitle: const Text('Permet de voir les commerces à proximité'),
            value: _locationEnabled,
            onChanged: (value) {
              setState(() {
                _locationEnabled = value;
              });
            },
          ),
          
          // Rayon de recherche
          ListTile(
            title: const Text('Rayon de recherche'),
            subtitle: Text('${_searchRadius.toInt()} km'),
            trailing: SizedBox(
              width: 150,
              child: Slider(
                value: _searchRadius,
                min: 1.0,
                max: 20.0,
                divisions: 19,
                label: '${_searchRadius.toInt()} km',
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
          _buildSectionHeader('Apparence'),
          SwitchListTile(
            title: const Text('Mode sombre'),
            subtitle: const Text('Activer le thème sombre'),
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
          _buildSectionHeader('Compte'),
          ListTile(
            title: const Text('Email'),
            subtitle: Text(widget.user?.email ?? 'Non connecté'),
            leading: const Icon(Icons.email),
          ),
          ListTile(
            title: const Text('Type de compte'),
            subtitle: Text(widget.user?.userType == 'client' ? 'Client' : 'Commerçant'),
            leading: const Icon(Icons.badge),
          ),
          
          // Option pour supprimer le compte
          ListTile(
            title: const Text('Supprimer mon compte'),
            subtitle: const Text('Cette action est irréversible'),
            leading: const Icon(Icons.delete_forever, color: Colors.red),
            onTap: _showDeleteAccountConfirmation,
          ),
          
          const SizedBox(height: 32),
        ],
      ),
    );
  }
  
  Widget _buildSectionHeader(String title) {
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
        title: const Text('Supprimer votre compte ?'),
        content: const Text(
          'Cette action est irréversible. Toutes vos données seront supprimées définitivement.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          TextButton(
            style: TextButton.styleFrom(
              foregroundColor: Colors.red,
            ),
            onPressed: () {
              Navigator.pop(context);
              _deleteAccount();
            },
            child: const Text('Supprimer'),
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
        const SnackBar(
          content: Text('Votre compte a été supprimé'),
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
          content: Text('Erreur lors de la suppression du compte: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}