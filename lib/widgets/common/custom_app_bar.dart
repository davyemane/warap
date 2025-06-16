// Fichier widgets/common/custom_app_bar.dart
import 'package:flutter/material.dart';
import 'package:badges/badges.dart' as badges; // Ajoutez cette dépendance
import '../../models/user_model.dart';
import '../../services/auth_service.dart';
import '../../services/error_handler.dart';
import '../../services/notification_service.dart'; // Nouveau service
import '../../services/cart_service.dart'; // Pour l'indicateur du panier
import '../../services/order_service.dart'; // Pour les nouvelles commandes
import '../../screens/auth/login_screen.dart';
import '../../screens/client/cart_screen.dart';
import '../../screens/client/request_service_history_screen.dart';
import '../../screens/vendor/new_orders_screen.dart';
import '../../utils/theme.dart';
import '../../l10n/translations.dart';

class CustomAppBar extends StatefulWidget implements PreferredSizeWidget {
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
    super.key,
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
  });

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  State<CustomAppBar> createState() => _CustomAppBarState();
}

class _CustomAppBarState extends State<CustomAppBar> {
  final AuthService _authService = AuthService();
  final CartService _cartService = CartService();
  final OrderService _orderService = OrderService();
  final NotificationService _notificationService = NotificationService();
  
  int _cartItemCount = 0;
  int _orderNotifications = 0;
  int _requestNotifications = 0;
  bool _isLoading = false;
  
  @override
  void initState() {
    super.initState();
    _loadData();
  }
  
  @override
  void didUpdateWidget(CustomAppBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.currentUser?.id != widget.currentUser?.id) {
      _loadData();
    }
  }
  
  Future<void> _loadData() async {
    if (widget.currentUser == null) return;
    
    setState(() {
      _isLoading = true;
    });
    
    try {
      // Pour les clients, chargement du panier et des notifications
      if (widget.currentUser!.userType == 'client') {
        final cartItems = await _cartService.getCart();
        final notifications = await _notificationService.getClientNotifications();
        
        setState(() {
          _cartItemCount = cartItems.length;
          _requestNotifications = notifications.where((n) => n.type == 'request').length;
          _isLoading = false;
        });
      } 
      // Pour les vendeurs, chargement des nouvelles commandes/demandes
      else {
        final pendingOrders = await _orderService.getPendingOrdersCount();
        final pendingRequests = await _notificationService.getVendorRequestsCount();
        
        setState(() {
          _orderNotifications = pendingOrders;
          _requestNotifications = pendingRequests;
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
          fallbackMessage: AppTranslations.text(context, 'error_loading_notifications'),
        );
      }
    }
  }
  
  void _navigateToCart() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const CartScreen()),
    ).then((_) => _loadData());
  }
  
  void _navigateToRequestHistory() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const RequestServiceHistoryScreen()),
    ).then((_) => _loadData());
  }
  
  void _navigateToNewOrders() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const NewOrdersScreen()),
    ).then((_) => _loadData());
  }

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: GestureDetector(
        onTap: widget.onLogoPressed,
        child: Text(
          widget.title,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: widget.foregroundColor,
          ),
        ),
      ),
      backgroundColor: widget.backgroundColor,
      foregroundColor: widget.foregroundColor,
      centerTitle: true,
      elevation: widget.elevation,
      leading: widget.showBackButton
          ? IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: widget.onBackPressed ?? () => Navigator.of(context).pop(),
            )
          : null,
      actions: [
        // Bouton du panier pour les clients
        if (widget.currentUser != null && widget.currentUser!.userType == 'client')
          badges.Badge(
            showBadge: _cartItemCount > 0,
            badgeContent: Text(
              _cartItemCount.toString(),
              style: const TextStyle(color: Colors.white, fontSize: 10),
            ),
            position: badges.BadgePosition.topEnd(top: 4, end: 4),
            badgeStyle: const badges.BadgeStyle(
              badgeColor: Colors.red,
              padding: EdgeInsets.all(4),
            ),
            child: IconButton(
              icon: const Icon(Icons.shopping_cart),
              onPressed: _navigateToCart,
              tooltip: AppTranslations.text(context, 'cart'),
            ),
          ),
        
        // Bouton d'historique des demandes pour les clients
        if (widget.currentUser != null && widget.currentUser!.userType == 'client')
          badges.Badge(
            showBadge: _requestNotifications > 0,
            badgeContent: Text(
              _requestNotifications.toString(),
              style: const TextStyle(color: Colors.white, fontSize: 10),
            ),
            position: badges.BadgePosition.topEnd(top: 4, end: 4),
            badgeStyle: const badges.BadgeStyle(
              badgeColor: Colors.orange,
              padding: EdgeInsets.all(4),
            ),
            child: IconButton(
              icon: const Icon(Icons.history),
              onPressed: _navigateToRequestHistory,
              tooltip: AppTranslations.text(context, 'service_requests'),
            ),
          ),
        
        // Bouton des nouvelles commandes pour les vendeurs
        if (widget.currentUser != null && widget.currentUser!.userType != 'client')
          badges.Badge(
            showBadge: _orderNotifications > 0 || _requestNotifications > 0,
            badgeContent: Text(
              (_orderNotifications + _requestNotifications).toString(),
              style: const TextStyle(color: Colors.white, fontSize: 10),
            ),
            position: badges.BadgePosition.topEnd(top: 4, end: 4),
            badgeStyle: const badges.BadgeStyle(
              badgeColor: Colors.red,
              padding: EdgeInsets.all(4),
            ),
            child: IconButton(
              icon: const Icon(Icons.notifications),
              onPressed: _navigateToNewOrders,
              tooltip: AppTranslations.text(context, 'new_orders'),
            ),
          ),
          
        // Actions personnalisées
        ...?widget.actions,
        
        // Bouton de profil avec photo ou initiales
        if (widget.currentUser != null)
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: Hero(
              tag: 'profile-${widget.currentUser?.id}',
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
                      backgroundImage: widget.currentUser!.hasProfileImage
                          ? NetworkImage(widget.currentUser!.profileImageUrl!)
                          : null,
                      child: !widget.currentUser!.hasProfileImage
                          ? Text(
                              widget.currentUser!.initials,
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
        
        // Menu de déconnexion et options
        if (widget.showLogoutButton)
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
              } else if (value == 'dashboard' && widget.currentUser?.userType != 'client') {
                Navigator.pushNamed(context, '/vendor/dashboard');
              }
            },
            itemBuilder: (context) => [
              if (widget.currentUser?.userType != 'client')
                PopupMenuItem<String>(
                  value: 'dashboard',
                  child: Row(
                    children: [
                      const Icon(Icons.dashboard, color: AppTheme.primaryColor),
                      const SizedBox(width: 8),
                      Text(AppTranslations.text(context, 'dashboard')),
                    ],
                  ),
                ),
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