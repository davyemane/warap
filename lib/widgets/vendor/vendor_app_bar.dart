// widgets/vendor/vendor_app_bar.dart
import 'package:flutter/material.dart';
import '../../services/auth_service.dart';
import '../../services/notification_service.dart';
import '../../models/user_model.dart';

class VendorAppBar extends StatefulWidget implements PreferredSizeWidget {
  final String title;
  final List<Widget>? actions;
  final bool showBackButton;
  final VoidCallback? onNotificationPressed;

  const VendorAppBar({
    super.key,
    required this.title,
    this.actions,
    this.onNotificationPressed,
    this.showBackButton = false,
  });

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  State<VendorAppBar> createState() => _VendorAppBarState();
}

class _VendorAppBarState extends State<VendorAppBar> {
  final AuthService _authService = AuthService();
  final NotificationService _notificationService = NotificationService();

  UserModel? _currentUser;
  bool _isLoadingUser = true;
  int _notificationCount = 0;

  @override
  void initState() {
    super.initState();
    _loadUserData();
    _checkNotifications();
  }

  Future<void> _loadUserData() async {
    try {
      final user = await _authService.getCurrentUser();

      if (mounted) {
        setState(() {
          _currentUser = user;
          _isLoadingUser = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoadingUser = false;
        });
      }
      print('Erreur lors du chargement des données utilisateur: $e');
    }
  }

  Future<void> _checkNotifications() async {
    try {
      // Pour simplifier, utiliser un compteur fixe en cas d'erreur
      int count = 0;

      try {
        count = await _notificationService.getVendorRequestsCount();
      } catch (e) {
        print('Erreur service de notification: $e');
        // En cas d'erreur, vérifier si l'utilisateur a des notifications
        if (_currentUser != null && _currentUser!.hasNotifications) {
          count = 1; // Au moins une notification
        }
      }

      if (mounted) {
        setState(() {
          _notificationCount = count;
        });
      }
    } catch (e) {
      print('Erreur lors de la vérification des notifications: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text(widget.title),
      centerTitle: true,
      leading: widget.showBackButton
          ? IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () => Navigator.of(context).pop(),
            )
          : null,
      actions: [
        // Notifications icon with badge
        Stack(
          alignment: Alignment.center,
          children: [
            IconButton(
              icon: const Icon(Icons.notifications),
              onPressed: widget.onNotificationPressed ??
                  () {
                    Navigator.pushNamed(context, '/vendor/new-orders');
                  },
              tooltip: 'Notifications',
            ),
            if (_notificationCount > 0)
              Positioned(
                right: 8,
                top: 8,
                child: Container(
                  padding: const EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    color: Colors.red,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  constraints: const BoxConstraints(
                    minWidth: 16,
                    minHeight: 16,
                  ),
                  child: Text(
                    _notificationCount.toString(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
          ],
        ),

        // User profile icon
        IconButton(
          icon: _isLoadingUser
              ? const SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                )
              : _currentUser != null && _currentUser!.hasProfileImage
                  ? CircleAvatar(
                      radius: 14,
                      backgroundImage:
                          NetworkImage(_currentUser!.profileImageUrl!),
                      backgroundColor: Colors.white,
                    )
                  : const CircleAvatar(
                      radius: 14,
                      backgroundColor: Colors.white,
                      child: Icon(
                        Icons.person,
                        size: 20,
                        color: Colors.blue,
                      ),
                    ),
          onPressed: () {
            Navigator.pushNamed(context, '/profile');
          },
          tooltip: 'Profile',
        ),

        // Additional actions if provided
        if (widget.actions != null) ...?widget.actions,
      ],
    );
  }
}
