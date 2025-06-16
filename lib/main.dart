// Fichier main.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:warap/models/business_model.dart';
import 'package:warap/models/cart_item_model.dart';
import 'package:warap/models/product_model.dart';
import 'package:warap/models/service_request_model.dart';
import 'package:warap/models/user_model.dart';
import 'package:warap/screens/client/business_details_screen.dart';
import 'package:warap/screens/client/cart_screen.dart';
import 'package:warap/screens/client/checkout_screen.dart';
import 'package:warap/screens/client/favorites_screen.dart';
import 'package:warap/screens/client/new_request_screen.dart';
import 'package:warap/screens/client/order_details_screen.dart';
import 'package:warap/screens/client/product_detail_screen.dart';
import 'package:warap/screens/client/search_screen.dart';
import 'package:warap/screens/client/request_service_history_screen.dart';
import 'package:warap/screens/vendor/add_business_screen.dart';
import 'package:warap/screens/vendor/add_product_screen.dart';
import 'package:warap/screens/vendor/business_list_screen.dart';
import 'package:warap/screens/vendor/client_list_screen.dart';
import 'package:warap/screens/vendor/client_map_screen.dart' as vendor_map;
import 'package:warap/screens/vendor/edit_product_screen.dart';
import 'package:warap/screens/vendor/orders_screen.dart';
import 'package:warap/screens/vendor/order_detail_screen.dart';
import 'package:warap/screens/vendor/request_detail_screen.dart';
import 'package:warap/screens/vendor/service_requests_screen.dart';
import 'package:warap/screens/vendor/vendor_dashboard_screen.dart';
import 'package:warap/screens/vendor/business_detail_screen.dart';
import 'package:warap/screens/vendor/product_list_screen.dart';
import 'package:warap/screens/vendor/statistics_screen.dart';
import 'package:warap/screens/vendor/diagnostic_screen.dart';
import 'config/supabase_config.dart';
import 'config/app_theme.dart';
import 'providers/locale_provider.dart';
import 'screens/auth/login_screen.dart';
import 'screens/auth/register_screen.dart';
import 'screens/client/map_screen.dart';
import 'screens/vendor/business_management_screen.dart';
import 'screens/client/client_main_screen.dart';
import 'screens/vendor/vendor_main_screen.dart';
import 'screens/vendor/vendor_settings_screen.dart';
import 'screens/common/language_screen.dart';
import 'services/auth_service.dart';
import 'services/user_access_service.dart';
import 'screens/vendor/profile_screen.dart' as vendor_profile;
import 'screens/client/profile_screen.dart' as client_profile;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Définir l'orientation de l'application (portrait uniquement)
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Définir le style de la barre d'état
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
  ));

  // Initialisation de Supabase
  await Supabase.initialize(
    url: SupabaseConfig.url,
    anonKey: SupabaseConfig.anonKey,
  );

  runApp(
    ChangeNotifierProvider(
      create: (context) =>
          LocaleProvider(const Locale('fr')), // ou votre locale par défaut
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Initialiser le service de contrôle d'accès
    final UserAccessService userAccessService = UserAccessService();

    return Consumer<LocaleProvider>(
      builder: (context, localeProvider, child) {
        return MaterialApp(
          title: 'Warap',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.lightTheme(),
          // Ne pas inclure les paramètres de localisation qui utilisent flutter_localizations
          home: const SplashScreen(),
          routes: {
            // Routes d'authentification
            '/login': (context) => const LoginScreen(),
            '/register': (context) => const RegisterScreen(),

            // Routes client
            '/client': (context) => const ClientMainScreen(),
            '/client/map': (context) => const ClientMapScreen(),
            '/client/favorites': (context) => const FavoritesScreen(),
            '/client/search': (context) => const SearchScreen(),
            '/client/profile': (context) =>
                const client_profile.ProfileScreen(),
            '/client/cart': (context) => const CartScreen(),
            '/client/new-request': (context) => const NewRequestScreen(),
            '/client/service-history': (context) =>
                const RequestServiceHistoryScreen(),

            // Routes vendeur
            '/vendor': (context) => const VendorMainScreen(),
            '/vendor/settings': (context) => const VendorSettingsScreen(),
            '/vendor/order-detail': (context) {
              // Récupérer les arguments passés
              final String? orderId =
                  ModalRoute.of(context)?.settings.arguments as String?;
              return OrderDetailScreenVendor(orderId: orderId ?? '');
            },
            '/vendor/dashboard': (context) => const VendorDashboardScreen(),
            '/vendor/businesses': (context) => const BusinessListScreen(),
            '/vendor/add-business': (context) => const AddBusinessScreen(),
            '/vendor/orders': (context) => const OrdersScreen(),
            '/vendor/requests': (context) => const ServiceRequestsScreen(),
            '/vendor/clients': (context) => const ClientListScreen(),
            '/vendor/client-map': (context) =>
                const vendor_map.ClientMapScreen(),
            '/vendor/profile': (context) =>
                const vendor_profile.ProfileScreen(),
            '/vendor/new-orders': (context) => const BusinessManagementScreen(),
            '/vendor/statistics': (context) => const StatisticsScreen(),
            '/vendor/diagnostic': (context) => const DiagnosticScreen(),

            // Routes communes
            '/language': (context) => const LanguageScreen(),
          },
          // Utiliser le middleware de contrôle d'accès
          onGenerateRoute: (settings) => userAccessService.onGenerateRoute(
              settings, (routeSettings) => _generateRoute(routeSettings)),
        );
      },
    );
  }
}

// Fonction pour générer les routes avec arguments
Route<dynamic>? _generateRoute(RouteSettings settings) {
  switch (settings.name) {
    // Routes côté vendeur
    case '/vendor/business-detail':
      final business = settings.arguments as BusinessModel;
      return MaterialPageRoute(
        builder: (context) => BusinessDetailScreen(business: business),
        settings: settings,
      );

    case '/vendor/order-detail':
      final orderId = settings.arguments as String;
      return MaterialPageRoute(
        builder: (context) => OrderDetailScreenVendor(orderId: orderId),
        settings: settings,
      );

    case '/vendor/products':
      final business = settings.arguments as BusinessModel;
      return MaterialPageRoute(
        builder: (context) => ProductListScreen(business: business),
        settings: settings,
      );

    case '/vendor/add-product':
      final business = settings.arguments as BusinessModel;
      return MaterialPageRoute(
        builder: (context) => AddProductScreen(business: business),
        settings: settings,
      );

    case '/vendor/edit-product':
      final product = settings.arguments as ProductModel;
      return MaterialPageRoute(
        builder: (context) => EditProductScreen(product: product),
        settings: settings,
      );

    case '/vendor/request-detail':
      final arguments = settings.arguments;

      if (arguments is ServiceRequestModel) {
        // Si on passe l'objet complet
        return MaterialPageRoute(
          builder: (context) => RequestDetailScreen(request: arguments),
          settings: settings,
        );
      } else if (arguments is String) {
        // Si on passe juste l'ID (comme depuis le dashboard)
        return MaterialPageRoute(
          builder: (context) => RequestDetailScreen(requestId: arguments),
          settings: settings,
        );
      } else {
        // Cas d'erreur - retourner à la liste des demandes
        return MaterialPageRoute(
          builder: (context) => const ServiceRequestsScreen(),
          settings: settings,
        );
      }

    case '/vendor/client-detail':
      final client = settings.arguments as UserModel;
      return MaterialPageRoute(
        builder: (context) =>
            const ClientMapScreen(), // Remplacez par votre écran de détail client quand vous l'aurez créé
        settings: settings,
      );

    // Routes côté client
    case '/client/business-detail':
      final business = settings.arguments as BusinessModel;
      return MaterialPageRoute(
        builder: (context) => BusinessDetailsScreen(business: business),
        settings: settings,
      );

    case '/client/product-detail':
      final product = settings.arguments as ProductModel;
      return MaterialPageRoute(
        builder: (context) => ProductDetailScreen(product: product),
        settings: settings,
      );

    case '/client/order-detail':
      final orderId = settings.arguments as String;
      return MaterialPageRoute(
        builder: (context) => OrderDetailsScreen(orderId: orderId),
        settings: settings,
      );

    case '/client/request-detail':
      final request = settings.arguments as ServiceRequestModel;
      return MaterialPageRoute(
        builder: (context) => RequestDetailScreen(request: request),
        settings: settings,
      );

    case '/client/checkout':
      final args = settings.arguments as Map<String, dynamic>;
      return MaterialPageRoute(
        builder: (context) => CheckoutScreen(
          cartItems: args['cartItems'] as List<CartItemModel>,
          business: args['business'] as BusinessModel,
        ),
        settings: settings,
      );

    default:
      return null;
  }
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  final AuthService _authService = AuthService();
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();

    // Configuration de l'animation
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeIn,
      ),
    );

    // Démarrer l'animation
    _animationController.forward();

    // Vérifier l'authentification après un court délai
    Future.delayed(const Duration(seconds: 2), () {
      _checkAuthentication();
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _checkAuthentication() async {
    try {
      final isAuthenticated = await _authService.isAuthenticated();

      if (isAuthenticated) {
        final userType = await _authService.getUserType();

        if (!mounted) return;

        if (userType == 'client') {
          Navigator.of(context).pushReplacementNamed('/client');
        } else {
          Navigator.of(context).pushReplacementNamed('/vendor');
        }
      } else {
        if (!mounted) return;
        Navigator.of(context).pushReplacementNamed('/login');
      }
    } catch (e) {
      if (!mounted) return;
      Navigator.of(context).pushReplacementNamed('/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppTheme.primaryColor,
              AppTheme.primaryColor.withOpacity(0.8),
            ],
          ),
        ),
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Logo de l'application
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(60),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: const Center(
                  child: Icon(
                    Icons.store,
                    size: 70,
                    color: AppTheme.primaryColor,
                  ),
                ),
              ),
              const SizedBox(height: 24),
              // Nom de l'application
              const Text(
                'Warap',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 8),
              // Slogan
              const Text(
                'Connectez-vous aux commerces près de chez vous',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 48),
              // Indicateur de chargement
              const CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
