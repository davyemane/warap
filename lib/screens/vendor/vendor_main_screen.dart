// Fichier screens/vendor/vendor_main_screen.dart
import 'package:flutter/material.dart';
import '../../widgets/common/bottom_navigation.dart';
import '../../services/auth_service.dart';
import '../../l10n/translations.dart';
import 'business_management_screen.dart';
import 'add_business_screen.dart';
import 'statistics_screen.dart';
import 'profile_screen.dart';

class VendorMainScreen extends StatefulWidget {
  const VendorMainScreen({Key? key}) : super(key: key);

  @override
  State<VendorMainScreen> createState() => _VendorMainScreenState();
}

class _VendorMainScreenState extends State<VendorMainScreen> {
  int _currentIndex = 0;
  final AuthService _authService = AuthService();
  
  // Liste des écrans à afficher
  late List<Widget> _screens;
  
  @override
  void initState() {
    super.initState();
    _screens = [
      const BusinessManagementScreen(showAppBar: false),
      const AddBusinessScreen(),
      const StatisticsScreen(),
      const ProfileScreen(),
    ];
  }
  
  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
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