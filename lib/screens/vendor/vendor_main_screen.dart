// Fichier screens/vendor/vendor_main_screen.dart
import 'package:flutter/material.dart';
import '../../services/auth_service.dart';
import '../../services/error_handler.dart';
import '../../l10n/translations.dart';
import '../../widgets/common/loading_indicator.dart';
import '../../widgets/vendor/vendor_app_bar.dart';
import '../../widgets/common/bottom_navigation.dart';
import 'vendor_dashboard_screen.dart';
import 'business_list_screen.dart';
import 'add_business_screen.dart';
import '../auth/profile_screen.dart';

class VendorMainScreen extends StatefulWidget {
  const VendorMainScreen({Key? key}) : super(key: key);

  @override
  State<VendorMainScreen> createState() => _VendorMainScreenState();
}

class _VendorMainScreenState extends State<VendorMainScreen> {
  final AuthService _authService = AuthService();
  int _currentIndex = 0;
  bool _isLoading = true;
  
  // Liste des écrans pour la navigation
  late List<Widget> _screens;
  
  @override
  void initState() {
    super.initState();
    
    _screens = [
      const VendorDashboardScreen(),
      const BusinessListScreen(),
      const AddBusinessScreen(),
      const ProfileScreen(),
    ];
    
    _checkUserAuth();
  }
  
  Future<void> _checkUserAuth() async {
    setState(() {
      _isLoading = true;
    });
    
    try {
      final user = await _authService.getCurrentUser();
      
      if (user == null || user.userType != 'vendeur') {
        // Rediriger vers la page de connexion
        if (mounted) {
          Navigator.pushReplacementNamed(context, '/login');
        }
      } else {
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      
      if (mounted) {
        ErrorHandler.showErrorSnackBar(
          context, 
          e,
          fallbackMessage: AppTranslations.text(context, 'error_auth_check'),
          onRetry: _checkUserAuth,
        );
      }
    }
  }
  
  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }
  
  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        body: Center(
          child: LoadingIndicator(
            message: AppTranslations.text(context, 'loading'),
            animationType: AnimationType.bounce,
          ),
        ),
      );
    }
    
    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: CustomBottomNavigation(
        currentIndex: _currentIndex,
        onTap: _onTabTapped,
        userType: 'vendeur',
      ),
    );
  }
}