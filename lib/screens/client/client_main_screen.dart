// Fichier screens/client/client_main_screen.dart
import 'package:flutter/material.dart';
import '../../widgets/common/bottom_navigation.dart';
import '../../services/auth_service.dart';
import '../../services/cart_service.dart';
import '../../services/error_handler.dart';
import '../../screens/client/map_screen.dart';
import '../../screens/client/favorites_screen.dart';
import '../../screens/client/search_screen.dart';
import '../../screens/client/profile_screen.dart';
import '../../screens/client/cart_screen.dart';
import '../../screens/client/request_service_history_screen.dart';
import '../../screens/client/new_request_screen.dart';
import '../../l10n/translations.dart';
import '../../config/app_theme.dart'; // Pour les couleurs du thème

class ClientMainScreen extends StatefulWidget {
  const ClientMainScreen({super.key});

  @override
  State<ClientMainScreen> createState() => _ClientMainScreenState();
}

class _ClientMainScreenState extends State<ClientMainScreen> {
  int _currentIndex = 0;
  final AuthService _authService = AuthService();
  final CartService _cartService = CartService();
  
  int _cartItemCount = 0;
  bool _isLoading = false;
  
  // Liste des écrans à afficher
  late List<Widget> _screens;
  
  @override
  void initState() {
    super.initState();
    _screens = [
      const ClientMapScreen(showAppBar: true),
      const FavoritesScreen(),
      const SearchScreen(),
      const ProfileScreen(showAppBar: true),
    ];
    _loadCartItemCount();
  }
  
  Future<void> _loadCartItemCount() async {
    setState(() {
      _isLoading = true;
    });
    
    try {
      final cartItems = await _cartService.getCart();
      setState(() {
        _cartItemCount = cartItems.length;
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
          fallbackMessage: AppTranslations.text(context, 'error_loading_cart'),
          onRetry: _loadCartItemCount,
        );
      }
    }
  }
  
  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }
  
void _navigateToCart() {
  // Debug print to check if the method is being called
  print('Navigate to cart button pressed');
  
  // Use pushNamed instead of push for consistency
  Navigator.pushNamed(
    context,
    '/client/cart',
  ).then((_) => _loadCartItemCount());
}  
  void _navigateToRequestService() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const NewRequestScreen()),
    );
  }
  
  void _navigateToRequestHistory() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const RequestServiceHistoryScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: CustomBottomNavigation(
        currentIndex: _currentIndex,
        onTap: _onTabTapped,
        userType: 'client',
        selectedItemColor: AppTheme.primaryColor,
        unselectedItemColor: Colors.grey,
        backgroundColor: Colors.white,
        elevation: 10,
        showLabels: true,
        iconSize: 24,
        enableAnimation: true,
      ),
      floatingActionButton: _buildFloatingActionButton(),
    );
  }
  
  Widget _buildFloatingActionButton() {
    // Sur l'écran de la carte, afficher un bouton flottant étendu
    if (_currentIndex == 0) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Bouton de panier
          FloatingActionButton.small(
            heroTag: 'cart',
            onPressed: _navigateToCart,
            tooltip: AppTranslations.text(context, 'cart'),
            backgroundColor: Colors.blue,
            child: Badge(
              isLabelVisible: _cartItemCount > 0,
              label: Text(_cartItemCount.toString(), style: const TextStyle(color: Colors.white)),
              child: const Icon(Icons.shopping_cart),
            ),
          ),
          const SizedBox(height: 10),
          // Bouton d'historique
          FloatingActionButton.small(
            heroTag: 'requests',
            onPressed: _navigateToRequestHistory,
            tooltip: AppTranslations.text(context, 'service_requests'),
            backgroundColor: Colors.amber,
            child: const Icon(Icons.history),
          ),
          const SizedBox(height: 10),
          // Bouton principal pour demander un service
          FloatingActionButton.extended(
            heroTag: 'main',
            onPressed: _navigateToRequestService,
            icon: const Icon(Icons.handyman),
            label: Text(AppTranslations.text(context, 'request_service')),
            backgroundColor: Theme.of(context).primaryColor,
          ),
        ],
      );
    } 
    // Sur les autres écrans, afficher un bouton flottant simple pour le panier
    else if (_currentIndex != 3) { // Pas sur l'écran de profil
      return FloatingActionButton(
        heroTag: 'cart',
        onPressed: _navigateToCart,
        tooltip: AppTranslations.text(context, 'cart'),
        child: Badge(
          isLabelVisible: _cartItemCount > 0,
          label: Text(_cartItemCount.toString(), style: const TextStyle(color: Colors.white)),
          child: const Icon(Icons.shopping_cart),
        ),
      );
    } else {
      return Container(); // Pas de FAB sur l'écran de profil
    }
  }
}