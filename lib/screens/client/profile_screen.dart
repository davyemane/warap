// Fichier screens/client/profile_screen.dart
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:share_plus/share_plus.dart';
import '../../services/auth_service.dart';
import '../../services/error_handler.dart'; // Ajout de l'import
import '../../models/user_model.dart';
import '../auth/login_screen.dart';
import '../common/edit_profile_screen.dart';
import '../common/settings_screen.dart';
import '../common/help_screen.dart';
import '../common/language_screen.dart';
import '../../l10n/translations.dart';

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
      if (mounted) {
        ErrorHandler.showErrorSnackBar(
          context, 
          e,
          fallbackMessage: AppTranslations.text(context, 'error_loading_user_data'),
          onRetry: _loadUserData,
        );
      }
    }
  }
  
  Future<void> _editProfile() async {
    if (_currentUser == null) return;
    
    try {
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
    } catch (e) {
      if (mounted) {
        ErrorHandler.showErrorSnackBar(
          context, 
          e,
          fallbackMessage: AppTranslations.text(context, 'error_editing_profile'),
        );
      }
    }
  }
  
  // Ouvrir les paramètres
  void _openSettings() {
    try {
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
    } catch (e) {
      if (mounted) {
        ErrorHandler.showErrorSnackBar(
          context, 
          e,
          fallbackMessage: AppTranslations.text(context, 'error_opening_settings'),
        );
      }
    }
  }
  
  // Ouvrir l'aide et le support
  void _openHelpAndSupport() {
    try {
      // Première option: ouvrir un écran d'aide intégré
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const HelpScreen(),
        ),
      );
    } catch (e) {
      if (mounted) {
        ErrorHandler.showErrorSnackBar(
          context, 
          e,
          fallbackMessage: AppTranslations.text(context, 'error_opening_help'),
        );
      }
    }
  }
  
  // Ouvrir une URL
  Future<void> _launchURL(String urlString) async {
    final Uri url = Uri.parse(urlString);
    try {
      if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
        throw Exception('Could not launch $url');
      }
    } catch (e) {
      if (mounted) {
        ErrorHandler.showErrorSnackBar(
          context, 
          e,
          fallbackMessage: AppTranslations.text(context, 'error_opening_link'),
          onRetry: () => _launchURL(urlString),
        );
      }
    }
  }
  
  // Changer de langue
  void _changeLanguage() {
    try {
      // Au lieu d'ouvrir une bottom sheet, naviguer vers l'écran de langue
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const LanguageScreen()),
      );
    } catch (e) {
      if (mounted) {
        ErrorHandler.showErrorSnackBar(
          context, 
          e,
          fallbackMessage: AppTranslations.text(context, 'error_changing_language'),
        );
      }
    }
  }
  
  // Partager le profil
  void _shareProfile() {
    if (_currentUser == null) return;
    
    try {
      final String message = """
${_currentUser!.name.isNotEmpty ? _currentUser!.name : AppTranslations.text(context, 'user')} - ${_currentUser!.userType == 'client' ? AppTranslations.text(context, 'client') : AppTranslations.text(context, 'vendor')}
${_currentUser!.email}

${AppTranslations.text(context, 'join_app')}
""";

      Share.share(message, subject: AppTranslations.text(context, 'my_profile'));
    } catch (e) {
      if (mounted) {
        ErrorHandler.showErrorSnackBar(
          context, 
          e,
          fallbackMessage: AppTranslations.text(context, 'error_sharing_profile'),
        );
      }
    }
  }
  
  Future<void> _signOut() async {
    try {
      // Afficher une boîte de dialogue de confirmation
      final bool? confirm = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(AppTranslations.text(context, 'logout')),
          content: Text(AppTranslations.text(context, 'confirm_logout')),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text(AppTranslations.text(context, 'cancel')),
            ),
            TextButton(
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              onPressed: () => Navigator.of(context).pop(true),
              child: Text(AppTranslations.text(context, 'logout')),
            ),
          ],
        ),
      );
      
      if (confirm != true) return;
      
      setState(() {
        _isLoading = true;
      });
      
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
      if (mounted) {
        ErrorHandler.showErrorSnackBar(
          context, 
          e,
          fallbackMessage: AppTranslations.text(context, 'error_logout'),
          onRetry: _signOut,
        );
      }
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: widget.showAppBar ? AppBar(
        title: Text(AppTranslations.text(context, 'profile')),
        actions: [
          // Bouton de partage
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: _shareProfile,
            tooltip: AppTranslations.text(context, 'share_profile'),
          ),
          // Bouton d'actualisation
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadUserData,
            tooltip: AppTranslations.text(context, 'refresh'),
          ),
        ],
      ) : null,
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _currentUser == null
              ? Center(
                  child: Text(
                    AppTranslations.text(context, 'user_not_connected'),
                    style: const TextStyle(fontSize: 18),
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
                            : AppTranslations.text(context, 'user'),
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
                              ? AppTranslations.text(context, 'client')
                              : AppTranslations.text(context, 'vendor'),
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
                        title: Text(AppTranslations.text(context, 'edit_profile')),
                        trailing: const Icon(Icons.arrow_forward_ios),
                        onTap: _editProfile,
                      ),
                      
                      ListTile(
                        leading: const Icon(Icons.settings, color: Colors.grey),
                        title: Text(AppTranslations.text(context, 'settings')),
                        trailing: const Icon(Icons.arrow_forward_ios),
                        onTap: _openSettings,
                      ),
                      
                      ListTile(
                        leading: const Icon(Icons.help, color: Colors.amber),
                        title: Text(AppTranslations.text(context, 'help_title')),
                        trailing: const Icon(Icons.arrow_forward_ios),
                        onTap: _openHelpAndSupport,
                      ),
                      
                      ListTile(
                        leading: const Icon(Icons.language, color: Colors.green),
                        title: Text(AppTranslations.text(context, 'language')),
                        trailing: const Icon(Icons.arrow_forward_ios),
                        onTap: _changeLanguage,
                      ),
                      
                      const Divider(),
                      const SizedBox(height: 16),
                      
                      // Bouton de déconnexion
                      ElevatedButton.icon(
                        onPressed: _signOut,
                        icon: const Icon(Icons.logout),
                        label: Text(AppTranslations.text(context, 'logout')),
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