// Fichier widgets/common/bottom_navigation.dart
import 'package:flutter/material.dart';
import '../../services/auth_service.dart';

class CustomBottomNavigation extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;
  final String userType;

  const CustomBottomNavigation({
    Key? key,
    required this.currentIndex,
    required this.onTap,
    required this.userType,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: BottomNavigationBar(
        currentIndex: currentIndex,
        onTap: onTap,
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey,
        showUnselectedLabels: true,
        type: BottomNavigationBarType.fixed,
        elevation: 10,
        items: userType == 'client'
            ? _buildClientNavItems()
            : _buildVendorNavItems(),
      ),
    );
  }

  List<BottomNavigationBarItem> _buildClientNavItems() {
    return [
      const BottomNavigationBarItem(
        icon: Icon(Icons.map),
        label: 'Carte',
      ),
      const BottomNavigationBarItem(
        icon: Icon(Icons.favorite),
        label: 'Favoris',
      ),
      const BottomNavigationBarItem(
        icon: Icon(Icons.search),
        label: 'Recherche',
      ),
      const BottomNavigationBarItem(
        icon: Icon(Icons.person),
        label: 'Profil',
      ),
    ];
  }

  List<BottomNavigationBarItem> _buildVendorNavItems() {
    return [
      const BottomNavigationBarItem(
        icon: Icon(Icons.store),
        label: 'Mes Commerces',
      ),
      const BottomNavigationBarItem(
        icon: Icon(Icons.add_business),
        label: 'Ajouter',
      ),
      const BottomNavigationBarItem(
        icon: Icon(Icons.analytics),
        label: 'Statistiques',
      ),
      const BottomNavigationBarItem(
        icon: Icon(Icons.person),
        label: 'Profil',
      ),
    ];
  }
}
