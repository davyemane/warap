// Fichier screens/client/client_main_screen.dart
import 'package:flutter/material.dart';
import '../../widgets/common/bottom_navigation.dart';
import '../../services/auth_service.dart';
import '../../services/error_handler.dart'; // Ajout de l'import
import '../../screens/client/map_screen.dart';
import '../../screens/client/favorites_screen.dart';
import '../../screens/client/search_screen.dart';
import '../../screens/client/profile_screen.dart';
import '../../l10n/translations.dart';

class ClientMainScreen extends StatefulWidget {
  const ClientMainScreen({Key? key}) : super(key: key);

  @override
  State<ClientMainScreen> createState() => _ClientMainScreenState();
}

class _ClientMainScreenState extends State<ClientMainScreen> {
  int _currentIndex = 0;
  final AuthService _authService = AuthService();
  
  // Liste des écrans à afficher
  late List<Widget> _screens;
  
  @override
  void initState() {
    super.initState();
    _screens = [
      const ClientMapScreen(),
      const FavoritesScreen(),
      const SearchScreen(),
      const ProfileScreen(),
    ];
  }
  
  void _onTabTapped(int index) {
    try {
      setState(() {
        _currentIndex = index;
      });
    } catch (e) {
      if (mounted) {
        ErrorHandler.showErrorSnackBar(
          context, 
          e,
          fallbackMessage: AppTranslations.text(context, 'error_changing_tab'),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: CustomBottomNavigation(
        currentIndex: _currentIndex,
        onTap: _onTabTapped,
        userType: 'client',
      ),
    );
  }
}