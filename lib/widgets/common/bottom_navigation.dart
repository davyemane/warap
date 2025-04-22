// Fichier widgets/common/bottom_navigation.dart
import 'package:flutter/material.dart';
import '../../services/auth_service.dart';
import '../../services/error_handler.dart'; // Ajout de l'import
import '../../l10n/translations.dart';

class CustomBottomNavigation extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;
  final String userType;
  final Color selectedItemColor;
  final Color unselectedItemColor;
  final Color backgroundColor;
  final double elevation;
  final bool showLabels;
  final double iconSize;
  final bool enableAnimation;

  const CustomBottomNavigation({
    Key? key,
    required this.currentIndex,
    required this.onTap,
    required this.userType,
    this.selectedItemColor = Colors.blue,
    this.unselectedItemColor = Colors.grey,
    this.backgroundColor = Colors.white,
    this.elevation = 10,
    this.showLabels = true,
    this.iconSize = 24,
    this.enableAnimation = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: backgroundColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: enableAnimation
          ? _buildAnimatedNavBar(context)
          : _buildRegularNavBar(context),
    );
  }

  Widget _buildRegularNavBar(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: currentIndex,
      onTap: (index) {
        try {
          onTap(index);
        } catch (e) {
          ErrorHandler.showErrorSnackBar(
            context, 
            e,
            fallbackMessage: AppTranslations.text(context, 'error_navigation'),
          );
        }
      },
      selectedItemColor: selectedItemColor,
      unselectedItemColor: unselectedItemColor,
      backgroundColor: backgroundColor,
      showUnselectedLabels: showLabels,
      type: BottomNavigationBarType.fixed,
      elevation: elevation,
      iconSize: iconSize,
      items: userType == 'client'
          ? _buildClientNavItems(context)
          : _buildVendorNavItems(context),
    );
  }

  Widget _buildAnimatedNavBar(BuildContext context) {
    return SafeArea(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 6.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: userType == 'client'
              ? _buildClientNavButtons(context)
              : _buildVendorNavButtons(context),
        ),
      ),
    );
  }

  List<Widget> _buildClientNavButtons(BuildContext context) {
    final items = [
      _NavItem(
        icon: Icons.map,
        label: AppTranslations.text(context, 'map'),
        index: 0,
      ),
      _NavItem(
        icon: Icons.favorite,
        label: AppTranslations.text(context, 'favorites'),
        index: 1,
      ),
      _NavItem(
        icon: Icons.search,
        label: AppTranslations.text(context, 'search'),
        index: 2,
      ),
      _NavItem(
        icon: Icons.person,
        label: AppTranslations.text(context, 'profile'),
        index: 3,
      ),
    ];

    return items.map((item) => _buildNavButton(context, item)).toList();
  }

  List<Widget> _buildVendorNavButtons(BuildContext context) {
    final items = [
      _NavItem(
        icon: Icons.store,
        label: AppTranslations.text(context, 'my_businesses'),
        index: 0,
      ),
      _NavItem(
        icon: Icons.add_business,
        label: AppTranslations.text(context, 'add'),
        index: 1,
      ),
      _NavItem(
        icon: Icons.analytics,
        label: AppTranslations.text(context, 'statistics'),
        index: 2,
      ),
      _NavItem(
        icon: Icons.person,
        label: AppTranslations.text(context, 'profile'),
        index: 3,
      ),
    ];

    return items.map((item) => _buildNavButton(context, item)).toList();
  }

  Widget _buildNavButton(BuildContext context, _NavItem item) {
    final isSelected = currentIndex == item.index;
    
    return Expanded(
      child: InkWell(
        onTap: () {
          try {
            onTap(item.index);
          } catch (e) {
            ErrorHandler.showErrorSnackBar(
              context, 
              e,
              fallbackMessage: AppTranslations.text(context, 'error_navigation'),
            );
          }
        },
        borderRadius: BorderRadius.circular(12),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          decoration: BoxDecoration(
            color: isSelected ? selectedItemColor.withOpacity(0.1) : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                item.icon,
                color: isSelected ? selectedItemColor : unselectedItemColor,
                size: iconSize,
              ),
              if (showLabels) ...[
                const SizedBox(height: 4),
                Text(
                  item.label,
                  style: TextStyle(
                    color: isSelected ? selectedItemColor : unselectedItemColor,
                    fontSize: 12,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  List<BottomNavigationBarItem> _buildClientNavItems(BuildContext context) {
    return [
      BottomNavigationBarItem(
        icon: const Icon(Icons.map),
        label: AppTranslations.text(context, 'map'),
      ),
      BottomNavigationBarItem(
        icon: const Icon(Icons.favorite),
        label: AppTranslations.text(context, 'favorites'),
      ),
      BottomNavigationBarItem(
        icon: const Icon(Icons.search),
        label: AppTranslations.text(context, 'search'),
      ),
      BottomNavigationBarItem(
        icon: const Icon(Icons.person),
        label: AppTranslations.text(context, 'profile'),
      ),
    ];
  }

  List<BottomNavigationBarItem> _buildVendorNavItems(BuildContext context) {
    return [
      BottomNavigationBarItem(
        icon: const Icon(Icons.store),
        label: AppTranslations.text(context, 'my_businesses'),
      ),
      BottomNavigationBarItem(
        icon: const Icon(Icons.add_business),
        label: AppTranslations.text(context, 'add'),
      ),
      BottomNavigationBarItem(
        icon: const Icon(Icons.analytics),
        label: AppTranslations.text(context, 'statistics'),
      ),
      BottomNavigationBarItem(
        icon: const Icon(Icons.person),
        label: AppTranslations.text(context, 'profile'),
      ),
    ];
  }
}

class _NavItem {
  final IconData icon;
  final String label;
  final int index;

  _NavItem({
    required this.icon,
    required this.label,
    required this.index,
  });
}