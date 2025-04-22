// Fichier widgets/common/custom_app_bar.dart
import 'package:flutter/material.dart';
import '../../models/user_model.dart';
import '../../services/auth_service.dart';
import '../../services/error_handler.dart'; // Ajout de l'import
import '../../screens/auth/login_screen.dart';
import '../../l10n/translations.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final List<Widget>? actions;
  final bool showBackButton;
  final bool showLogoutButton;
  final VoidCallback? onBackPressed;
  final VoidCallback? onLogoPressed;
  final UserModel? currentUser;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final double elevation;
  
  const CustomAppBar({
    Key? key,
    required this.title,
    this.actions,
    this.showBackButton = false,
    this.showLogoutButton = true,
    this.onBackPressed,
    this.onLogoPressed,
    this.currentUser,
    this.backgroundColor,
    this.foregroundColor,
    this.elevation = 0,
  }) : super(key: key);

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: GestureDetector(
        onTap: onLogoPressed,
        child: Text(
          title,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: foregroundColor,
          ),
        ),
      ),
      backgroundColor: backgroundColor,
      foregroundColor: foregroundColor,
      centerTitle: true,
      elevation: elevation,
      leading: showBackButton
          ? IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: onBackPressed ?? () => Navigator.of(context).pop(),
            )
          : null,
      actions: [
        // Actions personnalisées
        ...?actions,
        
        // Bouton de profil avec photo ou initiales
        if (currentUser != null)
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: Hero(
              tag: 'profile-${currentUser?.id}',
              child: Material(
                type: MaterialType.transparency,
                child: InkWell(
                  onTap: () {
                    // Navigation vers le profil
                    Navigator.pushNamed(context, '/profile');
                  },
                  customBorder: const CircleBorder(),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: CircleAvatar(
                      radius: 16,
                      backgroundColor: Colors.grey.shade200,
                      backgroundImage: currentUser!.hasProfileImage
                          ? NetworkImage(currentUser!.profileImageUrl!)
                          : null,
                      child: !currentUser!.hasProfileImage
                          ? Text(
                              currentUser!.initials,
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context).primaryColor,
                              ),
                            )
                          : null,
                    ),
                  ),
                ),
              ),
            ),
          ),
        
        // Bouton de déconnexion
        if (showLogoutButton)
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert),
            onSelected: (value) async {
              if (value == 'logout') {
                // Confirmer la déconnexion
                final confirm = await _showLogoutConfirmationDialog(context);
                if (confirm == true) {
                  _handleLogout(context);
                }
              } else if (value == 'settings') {
                Navigator.pushNamed(context, '/settings');
              } else if (value == 'help') {
                Navigator.pushNamed(context, '/help');
              }
            },
            itemBuilder: (context) => [
              PopupMenuItem<String>(
                value: 'settings',
                child: Row(
                  children: [
                    const Icon(Icons.settings, color: Colors.grey),
                    const SizedBox(width: 8),
                    Text(AppTranslations.text(context, 'settings')),
                  ],
                ),
              ),
              PopupMenuItem<String>(
                value: 'help',
                child: Row(
                  children: [
                    const Icon(Icons.help, color: Colors.blue),
                    const SizedBox(width: 8),
                    Text(AppTranslations.text(context, 'help')),
                  ],
                ),
              ),
              const PopupMenuDivider(),
              PopupMenuItem<String>(
                value: 'logout',
                child: Row(
                  children: [
                    const Icon(Icons.logout, color: Colors.red),
                    const SizedBox(width: 8),
                    Text(AppTranslations.text(context, 'logout')),
                  ],
                ),
              ),
            ],
          ),
      ],
    );
  }

  // Dialogue de confirmation pour la déconnexion
  Future<bool?> _showLogoutConfirmationDialog(BuildContext context) {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppTranslations.text(context, 'logout')),
        content: Text(AppTranslations.text(context, 'logout_question')),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(AppTranslations.text(context, 'cancel')),
          ),
          TextButton(
            style: TextButton.styleFrom(
              foregroundColor: Colors.red,
            ),
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(AppTranslations.text(context, 'logout')),
          ),
        ],
      ),
    );
  }

  // Gérer la déconnexion
  Future<void> _handleLogout(BuildContext context) async {
    final authService = AuthService();
    
    try {
      // Afficher un indicateur de chargement
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: CircularProgressIndicator(),
        ),
      );
      
      // Déconnexion
      await authService.signOut();
      
      // Fermer l'indicateur de chargement
      if (context.mounted) Navigator.pop(context);
      
      // Rediriger vers l'écran de connexion
      if (context.mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const LoginScreen()),
          (route) => false,
        );
      }
    } catch (e) {
      // Fermer l'indicateur de chargement
      if (context.mounted) Navigator.pop(context);
      
      // Afficher un message d'erreur avec ErrorHandler
      if (context.mounted) {
        ErrorHandler.showErrorSnackBar(
          context, 
          e,
          fallbackMessage: AppTranslations.text(context, 'error_logout'),
          onRetry: () => _handleLogout(context),
        );
      }
    }
  }
}