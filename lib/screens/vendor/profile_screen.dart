// Fichier screens/vendor/profile_screen.dart
import 'package:flutter/material.dart';
import '../../services/auth_service.dart';
import '../../models/user_model.dart';
import '../auth/login_screen.dart';
import '../common/edit_profile_screen.dart';
import '../../l10n/translations.dart';
import 'vendor_settings_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final AuthService _authService = AuthService();
  UserModel? _currentUser;
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
      final user = await _authService.getCurrentUser();
      setState(() {
        _currentUser = user;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      _showErrorSnackBar(
          AppTranslations.text(context, 'error_loading_user_data'));
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

  Future<void> _signOut() async {
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
      _showErrorSnackBar(AppTranslations.text(context, 'error_logout'));
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
      appBar: AppBar(
        title: Text(AppTranslations.text(context, 'profile')),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadUserData,
            tooltip: AppTranslations.text(context, 'refresh'),
          ),
        ],
      ),
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
                        title:
                            Text(AppTranslations.text(context, 'edit_profile')),
                        trailing: const Icon(Icons.arrow_forward_ios),
                        onTap: _editProfile,
                      ),

                      ListTile(
                        leading: const Icon(Icons.settings, color: Colors.grey),
                        title: Text(AppTranslations.text(context, 'settings')),
                        trailing: const Icon(Icons.arrow_forward_ios),
                        onTap: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                  AppTranslations.text(context, 'coming_soon')),
                            ),
                          );
                        },
                      ),

                      ListTile(
                        leading: const Icon(Icons.help, color: Colors.amber),
                        title:
                            Text(AppTranslations.text(context, 'help_title')),
                        trailing: const Icon(Icons.arrow_forward_ios),
                        onTap: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                  AppTranslations.text(context, 'coming_soon')),
                            ),
                          );
                        },
                      ),

                      ListTile(
                        leading:
                            const Icon(Icons.language, color: Colors.green),
                        title: Text(AppTranslations.text(context, 'language')),
                        trailing: const Icon(Icons.arrow_forward_ios),
                        onTap: () {
                          Navigator.pushNamed(context, '/language');
                        },
                      ),
                      ListTile(
                        leading: const Icon(Icons.settings_applications,
                            color: Colors.orange),
                        title: Text(
                            AppTranslations.text(context, 'vendor_settings')),
                        trailing: const Icon(Icons.arrow_forward_ios),
                        onTap: () {
                          Navigator.pushNamed(context, '/vendor/settings');
                        },
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
