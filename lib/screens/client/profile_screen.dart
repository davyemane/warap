// Fichier screens/client/profile_screen.dart
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:share_plus/share_plus.dart';
import '../../services/auth_service.dart';
import '../../models/user_model.dart';
import '../auth/login_screen.dart';
import '../common/edit_profile_screen.dart';
import '../common/settings_screen.dart';
import '../common/help_screen.dart';
import '../common/language_screen.dart';

class ProfileScreen extends StatefulWidget {
  final bool showAppBar;
  
  const ProfileScreen({
    Key? key, 
    this.showAppBar = true
  }) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final AuthService _authService = AuthService();
  UserModel? _currentUser;
  bool _isLoading = true;
  
  // Liste des langues disponibles
  final List<Map<String, String>> _availableLanguages = [
    {'code': 'fr', 'name': 'Français'},
    {'code': 'en', 'name': 'English'},
    {'code': 'es', 'name': 'Español'},
    {'code': 'ar', 'name': 'العربية'},
  ];
  
  // Langue actuellement sélectionnée
  String _currentLanguage = 'fr';
  
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
      final user = await _authService.getCurrentUser();
      setState(() {
        _currentUser = user;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      _showErrorSnackBar('Erreur lors du chargement des données utilisateur');
    }
  }
  
  Future<void> _editProfile() async {
    if (_currentUser == null) return;
    
    final updatedUser = await Navigator.push<UserModel>(
      context,
      MaterialPageRoute(
        builder: (context) => EditProfileScreen(user: _currentUser!),
      ),
    );
    
    if (updatedUser != null) {
      setState(() {
        _currentUser = updatedUser;
      });
    }
  }
  
  // Ouvrir les paramètres
  void _openSettings() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SettingsScreen(
          user: _currentUser,
          onSettingsChanged: () {
            // Recharger les données utilisateur après modification des paramètres
            _loadUserData();
          },
        ),
      ),
    );
  }
  
  // Ouvrir l'aide et le support
  void _openHelpAndSupport() {
    // Première option: ouvrir un écran d'aide intégré
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const HelpScreen(),
      ),
    );
    
    // Deuxième option: ouvrir un site web d'aide
    // _launchURL('https://commerceconnect.example.com/help');
  }
  
  // Ouvrir une URL
  Future<void> _launchURL(String urlString) async {
    final Uri url = Uri.parse(urlString);
    try {
      if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
        throw Exception('Could not launch $url');
      }
    } catch (e) {
      _showErrorSnackBar('Impossible d\'ouvrir le lien');
    }
  }
  
  // Changer de langue
  void _changeLanguage() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Choisir une langue',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            ...List.generate(
              _availableLanguages.length,
              (index) => RadioListTile<String>(
                title: Text(_availableLanguages[index]['name']!),
                value: _availableLanguages[index]['code']!,
                groupValue: _currentLanguage,
                onChanged: (value) {
                  setState(() {
                    _currentLanguage = value!;
                  });
                  
                  // Fermer la bottom sheet
                  Navigator.pop(context);
                  
                  // Ici vous implémenteriez la logique pour changer la langue de l'app
                  // Par exemple avec un package comme flutter_localizations
                  
                  // Afficher un message de confirmation
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Langue changée en ${_availableLanguages[index]['name']}'),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  // Partager le profil
  void _shareProfile() {
    if (_currentUser == null) return;
    
    final String message = """
${_currentUser!.name.isNotEmpty ? _currentUser!.name : 'Utilisateur'} - ${_currentUser!.userType == 'client' ? 'Client' : 'Commerçant'}
${_currentUser!.email}

Rejoignez-moi sur Commerce Connect !
""";

    Share.share(message, subject: 'Mon profil Commerce Connect');
  }
  
  Future<void> _signOut() async {
    // Afficher une boîte de dialogue de confirmation
    final bool? confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Déconnexion'),
        content: const Text('Êtes-vous sûr de vouloir vous déconnecter ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Annuler'),
          ),
          TextButton(
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Déconnexion'),
          ),
        ],
      ),
    );
    
    if (confirm != true) return;
    
    setState(() {
      _isLoading = true;
    });
    
    try {
      await _authService.signOut();
      
      // Rediriger vers l'écran de connexion
      if (!mounted) return;
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const LoginScreen()),
        (route) => false,
      );
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      _showErrorSnackBar('Erreur lors de la déconnexion');
    }
  }
  
  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: widget.showAppBar ? AppBar(
        title: const Text('Mon Profil'),
        actions: [
          // Bouton de partage
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: _shareProfile,
            tooltip: 'Partager mon profil',
          ),
          // Bouton d'actualisation
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadUserData,
            tooltip: 'Actualiser',
          ),
        ],
      ) : null,
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _currentUser == null
              ? const Center(
                  child: Text(
                    'Utilisateur non connecté',
                    style: TextStyle(fontSize: 18),
                  ),
                )
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const SizedBox(height: 20),
                      
                      // Photo de profil avec possibilité de modification
                      Stack(
                        children: [
                          // Avatar avec photo ou initiales
                          CircleAvatar(
                            radius: 60,
                            backgroundColor: Colors.blue.shade100,
                            backgroundImage: _currentUser!.hasProfileImage
                                ? NetworkImage(_currentUser!.profileImageUrl!)
                                : null,
                            child: !_currentUser!.hasProfileImage
                                ? Text(
                                    _currentUser!.initials,
                                    style: const TextStyle(
                                      fontSize: 40,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.blue,
                                    ),
                                  )
                                : null,
                          ),
                          
                          // Bouton de modification
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: GestureDetector(
                              onTap: _editProfile,
                              child: Container(
                                padding: const EdgeInsets.all(6),
                                decoration: BoxDecoration(
                                  color: Colors.blue,
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: Colors.white,
                                    width: 2,
                                  ),
                                ),
                                child: const Icon(
                                  Icons.edit,
                                  color: Colors.white,
                                  size: 20,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      
                      const SizedBox(height: 24),
                      
                      // Nom d'utilisateur
                      Text(
                        _currentUser!.name.isNotEmpty
                            ? _currentUser!.name
                            : 'Utilisateur',
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      
                      const SizedBox(height: 8),
                      
                      // Email
                      Text(
                        _currentUser!.email,
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.grey,
                        ),
                      ),
                      
                      const SizedBox(height: 16),
                      
                      // Type d'utilisateur
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: _currentUser!.userType == 'client'
                              ? Colors.blue
                              : Colors.green,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          _currentUser!.userType == 'client'
                              ? 'Client'
                              : 'Commerçant',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      
                      const SizedBox(height: 32),
                      const Divider(),
                      
                      // Options de profil
                      ListTile(
                        leading: const Icon(Icons.edit, color: Colors.blue),
                        title: const Text('Modifier le profil'),
                        trailing: const Icon(Icons.arrow_forward_ios),
                        onTap: _editProfile,
                      ),
                      
                      ListTile(
                        leading: const Icon(Icons.settings, color: Colors.grey),
                        title: const Text('Paramètres'),
                        trailing: const Icon(Icons.arrow_forward_ios),
                        onTap: _openSettings,
                      ),
                      
                      ListTile(
                        leading: const Icon(Icons.help, color: Colors.amber),
                        title: const Text('Aide et support'),
                        trailing: const Icon(Icons.arrow_forward_ios),
                        onTap: _openHelpAndSupport,
                      ),
                      
                      ListTile(
                        leading: const Icon(Icons.language, color: Colors.green),
                        title: const Text('Changer de langue'),
                        trailing: const Icon(Icons.arrow_forward_ios),
                        onTap: _changeLanguage,
                      ),
                      
                      const Divider(),
                      const SizedBox(height: 16),
                      
                      // Bouton de déconnexion
                      ElevatedButton.icon(
                        onPressed: _signOut,
                        icon: const Icon(Icons.logout),
                        label: const Text('Se déconnecter'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 32,
                            vertical: 12,
                          ),
                        ),
                      ),
                      
                      const SizedBox(height: 32),
                    ],
                  ),
                ),
    );
  }
}