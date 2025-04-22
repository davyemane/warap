// lib/l10n/translations.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/locale_provider.dart';

class AppTranslations {
  static final Map<String, Map<String, String>> _translations = {
    'fr': {
      'login': 'Connexion',
      'email': 'Email',
      'email_hint': 'exemple@email.com',
      'password': 'Mot de passe',
      'sign_in': 'Se connecter',
      'resend_confirmation': 'Renvoyer l\'email de confirmation',
      'confirmation_sent':
          'Email de confirmation renvoyé. Vérifiez votre boîte de réception.',
      'no_account': 'Pas encore de compte ? S\'inscrire',
      'error': 'Erreur',
      'storage_error':
          'Erreur lors du téléchargement ou de l\'accès aux fichiers.',

      'register': 'Inscription',
      'create_account': 'Créer un compte',
      'confirm_password': 'Confirmer le mot de passe',
      'user_type': 'Je suis :',
      'client_type': 'Un client',
      'client_desc': 'Je souhaite découvrir des commerces à proximité',
      'vendor_type': 'Un commerçant',
      'vendor_desc': 'Je souhaite référencer mon commerce',
      'sign_up': 'S\'inscrire',
      'have_account': 'Déjà un compte ? Se connecter',
      'account_created': 'Compte créé avec succès',
      // Ajoutez d'autres traductions ici
      // Business Details Screen
      'fixed_business': 'Commerce fixe',
      'mobile_business': 'Commerce mobile',
      'open': 'Ouvert',
      'closed': 'Fermé',
      'description': 'Description',
      'opening_hours': 'Heures d\'ouverture',
      'address': 'Adresse',
      'open_in_maps': 'Ouvrir dans Google Maps',
      'contact': 'Contact',
      'call': 'Appeler',
      'directions': 'Itinéraire',
      'favorites': 'Favoris',
      'share': 'Partager',
      'added_to_favorites': '{0} ajouté aux favoris',
      'discover_business': 'Découvrez {0}',
      'discover_app': 'Découvrez ce commerce sur Warap!',
      // Favorites Screen
      'my_favorites': 'Mes Favoris',
      'no_favorites': 'Aucun favori pour le moment',
      'removed_from_favorites': '{0} retiré des favoris',

// Filter Screen
      'filter_businesses': 'Filtrer les commerces',
      'business_type': 'Type de commerce',
      'all_businesses': 'Tous les commerces',
      'fixed_businesses': 'Commerces fixes (boutiques)',
      'mobile_businesses': 'Commerces mobiles (ambulants)',
      'show_open_only': 'Afficher uniquement les commerces ouverts',
      'hide_closed': 'Masquer les commerces actuellement fermés',
      'reset': 'Réinitialiser',
      'apply': 'Appliquer',

// Map Screen
      'nearby_businesses': 'Commerces à proximité',
      'shop': 'Boutique',
      'mobile': 'Mobile',
      'active_filters': 'Filtres actifs',
      'see_more_details': 'Voir plus de détails',
      'error_location': 'Impossible d\'obtenir votre position actuelle',
      'error_loading_businesses': 'Erreur lors du chargement des commerces',
      'coming_soon': 'Fonctionnalité à venir', // Pour le français

// Search Screen
      'search': 'Rechercher',
      'search_business': 'Rechercher un commerce',
      'search_hint': 'Nom, description, adresse...',
      'no_results': 'Aucun résultat trouvé',

      // Pour les écrans vendeur
      'add_business': 'Ajouter un commerce',
      'business_name': 'Nom du commerce',
      'business_type': 'Type de commerce',
      'fixed_business_desc': 'Commerce fixe (boutique)',
      'mobile_business_desc': 'Commerce mobile (ambulant)',
      'opening_hours': 'Heure d\'ouverture',
      'closing_hours': 'Heure de fermeture',
      'map_position': 'Position sur la carte',
      'map_instructions':
          'Appuyez longuement sur la carte pour définir la position de votre commerce.',
      'save': 'Enregistrer',
      'please_enter_name': 'Veuillez entrer un nom',
      'required': 'Requis',
      'set_business_location':
          'Veuillez définir la position du commerce sur la carte',
      'business_added': 'Commerce ajouté avec succès',
      'error_adding_business': 'Erreur lors de l\'ajout du commerce',

      'my_businesses': 'Mes Commerces',
      'no_businesses': 'Vous n\'avez pas encore de commerce',
      'add_business_button': 'Ajouter un commerce',
      'delete_business': 'Supprimer ce commerce ?',
      'confirm_delete': 'Êtes-vous sûr de vouloir supprimer {0} ?',
      'delete': 'Supprimer',
      'business_deleted': 'Commerce supprimé avec succès',
      'error_deleting_business': 'Erreur lors de la suppression du commerce',
      'hours': 'Heures: {0} - {1}',

      'edit_business': 'Modifier: {0}',
      'update': 'Mettre à jour',
      'map_edit_instructions':
          'Appuyez longuement sur la carte pour modifier la position de votre commerce.',
      'business_updated': 'Commerce mis à jour avec succès',
      'error_updating_business': 'Erreur lors de la mise à jour du commerce',

      'statistics': 'Statistiques',
      'share_statistics': 'Partager les statistiques',
      'activity_overview': 'Vue d\'ensemble de votre activité',
      'day': 'Jour',
      'week': 'Semaine',
      'month': 'Mois',
      'year': 'Année',
      'views': 'Visualisations',
      'total_views': 'Vues totales',
      'updates': 'Mises à jour',
      'businesses': 'Commerces',
      'popular_businesses': 'Commerces populaires',
      'days_mon': 'Lun',
      'days_tue': 'Mar',
      'days_wed': 'Mer',
      'days_thu': 'Jeu',
      'days_fri': 'Ven',
      'days_sat': 'Sam',
      'days_sun': 'Dim',
      'share_business': 'Partager ce commerce',
      'my_statistics': 'Mes statistiques sur warap',

      // Edit Profile Screen
      'edit_profile': 'Modifier le profil',
      'save': 'Enregistrer',
      'full_name': 'Nom complet',
      'enter_name': 'Entrez votre nom',
      'please_enter_name': 'Veuillez entrer votre nom',
      'choose_from_gallery': 'Choisir depuis la galerie',
      'take_photo': 'Prendre une photo',
      'delete_photo': 'Supprimer la photo',
      'photo_deleted': 'Photo supprimée',
      'profile_updated': 'Profil mis à jour avec succès',
      'error_updating_profile': 'Erreur lors de la mise à jour du profil',
      'error_selecting_image': 'Erreur lors de la sélection de l\'image',
      'error_taking_photo': 'Erreur lors de la prise de photo',

// FAQ Screen
      'faq': 'Questions fréquentes',
      'create_account_question': 'Comment créer un compte ?',
      'create_account_answer':
          'Pour créer un compte, cliquez sur le bouton "S\'inscrire" sur la page d\'accueil et remplissez le formulaire.',
      'edit_info_question': 'Comment modifier mes informations personnelles ?',
      'edit_info_answer':
          'Rendez-vous dans la section "Profil", puis appuyez sur "Modifier mes informations".',
      'add_business_question': 'Comment ajouter un commerce ?',
      'add_business_answer':
          'Allez dans la section "Mes commerces" et cliquez sur "Ajouter un commerce". Suivez ensuite les instructions.',
      'contact_vendor_question':
          'Puis-je contacter un commerçant directement ?',
      'contact_vendor_answer':
          'Oui, chaque fiche commerce contient un bouton pour contacter directement le commerçant par téléphone ou email.',
      'app_free_question': 'L\'application est-elle gratuite ?',
      'app_free_answer':
          'Oui, l\'application est entièrement gratuite pour les utilisateurs. Certaines fonctionnalités premium seront disponibles bientôt.',

// Help Screen
      'help_support': 'Aide et support',
      'how_can_we_help': 'Comment pouvons-nous vous aider ?',
      'faq_title': 'Questions fréquentes',
      'faq_desc': 'Trouvez des réponses aux questions les plus courantes.',
      'user_guide_title': 'Guide d\'utilisation',
      'user_guide_desc':
          'Découvrez toutes les fonctionnalités de l\'application.',
      'contact_support_title': 'Contacter le support',
      'contact_support_desc': 'Envoyez un email à notre équipe de support.',
      'live_chat_title': 'Chat en direct',
      'live_chat_desc': 'Discutez avec un représentant du service client.',
      'live_chat_soon': 'Le chat en direct sera disponible prochainement',
      'vendor_guide_title': 'Guide pour les commerçants',
      'vendor_guide_desc': 'Comment gérer efficacement votre boutique.',
      'follow_social': 'Suivez-nous sur les réseaux sociaux',
      'app_version': 'Version de l\'application: 1.0.0',
      'privacy_policy': 'Politique de confidentialité',
      'terms_of_use': 'Conditions d\'utilisation',

// Language Screen
      'choose_language': 'Choisir la langue',
      'language_changed': 'Langue changée en {0}',

// Settings Screen
      'settings': 'Paramètres',
      'notifications': 'Notifications',
      'enable_notifications': 'Activer les notifications',
      'notifications_desc':
          'Recevez des mises à jour sur les commerces à proximité',
      'location': 'Localisation',
      'enable_location': 'Activer la localisation',
      'location_desc': 'Permet de voir les commerces à proximité',
      'search_radius': 'Rayon de recherche',
      'appearance': 'Apparence',
      'dark_mode': 'Mode sombre',
      'dark_mode_desc': 'Activer le thème sombre',
      'account': 'Compte',
      'delete_account': 'Supprimer mon compte',
      'delete_account_desc': 'Cette action est irréversible',
      'delete_account_question': 'Supprimer votre compte ?',
      'delete_account_warning':
          'Cette action est irréversible. Toutes vos données seront supprimées définitivement.',
      'settings_saved': 'Paramètres sauvegardés',
      'km': 'km',

// User Guide Screen
      'user_guide': 'Guide d\'utilisation',
      'user_guide_coming': 'Guide d\'utilisation de l\'application à venir...',

// Vendor Guide Screen
      'vendor_guide': 'Guide pour les commerçants',
      'vendor_guide_coming': 'Guide pour les vendeurs à venir...',

      // Bottom Navigation
      'map': 'Carte',
      'favorites': 'Favoris',
      'search': 'Recherche',
      'profile': 'Profil',
      'my_businesses': 'Mes Commerces',
      'add': 'Ajouter',
      'statistics': 'Statistiques',

// Custom App Bar
      'logout': 'Déconnexion',
      'logout_question': 'Êtes-vous sûr de vouloir vous déconnecter ?',
      'cancel': 'Annuler',
      'error_logout': 'Erreur lors de la déconnexion:',

// Loading Indicator
      'loading': 'Chargement...',

      'vendor_settings': 'Paramètres vendeur',
      'business_settings': 'Paramètres commerciaux',
      'visibility': 'Visibilité',
      'business_visibility': 'Visibilité des commerces',
      'show_business_when_closed':
          'Afficher mes commerces même lorsqu\'ils sont fermés',
      'default_settings': 'Paramètres par défaut',
      'default_opening_hours': 'Horaires d\'ouverture par défaut',
      'default_closing_hours': 'Horaires de fermeture par défaut',
      'notifications_settings': 'Paramètres des notifications',
      'new_customer_notification': 'Notifications de nouveaux clients',
      'receive_new_customer_notifications':
          'Recevoir des notifications lorsque de nouveaux clients consultent mes commerces',
      'stats_settings': 'Paramètres des statistiques',
      'stats_period': 'Période de statistiques par défaut',
      'payment_settings': 'Paramètres de paiement',
      'payment_methods': 'Méthodes de paiement acceptées',
      'cash': 'Espèces',
      'credit_card': 'Carte de crédit',
      'mobile_payment': 'Paiement mobile',
      'settings_saved': 'Paramètres sauvegardés',

      // Pour le français
      'network_error':
          'Erreur de connexion au réseau. Vérifiez votre connexion internet.',
      'auth_error': 'Erreur d\'authentification. Veuillez vous reconnecter.',
      'server_error': 'Erreur du serveur. Veuillez réessayer plus tard.',
      'not_found_error': 'La ressource demandée n\'a pas été trouvée.',
      'validation_error': 'Erreur de validation des données.',
      'timeout_error':
          'La requête a pris trop de temps. Vérifiez votre connexion internet.',
      'unknown_error': 'Une erreur inconnue s\'est produite.',
      'retry': 'Réessayer',
    },
    'en': {
      'login': 'Login',
      'email': 'Email',
      'email_hint': 'example@email.com',
      'password': 'Password',
      'sign_in': 'Sign in',
      'resend_confirmation': 'Resend confirmation email',
      'confirmation_sent': 'Confirmation email sent. Please check your inbox.',
      'no_account': 'No account yet? Register',
      'error': 'Error',

      'register': 'Register',
      'create_account': 'Create an account',
      'confirm_password': 'Confirm password',
      'user_type': 'I am:',
      'client_type': 'A customer',
      'client_desc': 'I want to discover nearby businesses',
      'vendor_type': 'A vendor',
      'vendor_desc': 'I want to list my business',
      'sign_up': 'Sign up',
      'have_account': 'Already have an account? Sign in',
      'account_created':
          'Account successfully created', // Ajoutez d'autres traductions ici
      // Business Details Screen
      'fixed_business': 'Fixed Business',
      'mobile_business': 'Mobile Business',
      'open': 'Open',
      'closed': 'Closed',
      'description': 'Description',
      'opening_hours': 'Opening Hours',
      'address': 'Address',
      'open_in_maps': 'Open in Google Maps',
      'contact': 'Contact',
      'call': 'Call',
      'directions': 'Directions',
      'favorites': 'Favorites',
      'share': 'Share',
      'added_to_favorites': '{0} added to favorites',
      'discover_business': 'Discover {0}',
      'discover_app': 'Discover this business on Warap!',

// Favorites Screen
      'my_favorites': 'My Favorites',
      'no_favorites': 'No favorites yet',
      'removed_from_favorites': '{0} removed from favorites',

// Filter Screen
      'filter_businesses': 'Filter Businesses',
      'business_type': 'Business Type',
      'all_businesses': 'All businesses',
      'fixed_businesses': 'Fixed businesses (shops)',
      'mobile_businesses': 'Mobile businesses (vendors)',
      'show_open_only': 'Show only open businesses',
      'hide_closed': 'Hide currently closed businesses',
      'reset': 'Reset',
      'apply': 'Apply',

// Map Screen
      'nearby_businesses': 'Nearby Businesses',
      'shop': 'Shop',
      'mobile': 'Mobile',
      'active_filters': 'Active filters',
      'see_more_details': 'See more details',
      'error_location': 'Unable to get your current location',
      'error_loading_businesses': 'Error loading businesses',

// Search Screen
      'search': 'Search',
      'search_business': 'Search a business',
      'search_hint': 'Name, description, address...',
      'no_results': 'No results found',

      // Pour les écrans vendeur
      'add_business': 'Add a business',
      'business_name': 'Business name',
      'business_type': 'Business type',
      'fixed_business_desc': 'Fixed business (shop)',
      'mobile_business_desc': 'Mobile business (street vendor)',
      'opening_hours': 'Opening hours',
      'closing_hours': 'Closing hours',
      'map_position': 'Position on map',
      'map_instructions':
          'Press and hold on the map to set your business location.',
      'save': 'Save',
      'please_enter_name': 'Please enter a name',
      'required': 'Required',
      'set_business_location': 'Please set the business location on the map',
      'business_added': 'Business added successfully',
      'error_adding_business': 'Error adding business',

      'my_businesses': 'My Businesses',
      'no_businesses': 'You don\'t have any businesses yet',
      'add_business_button': 'Add a business',
      'delete_business': 'Delete this business?',
      'confirm_delete': 'Are you sure you want to delete {0}?',
      'delete': 'Delete',
      'business_deleted': 'Business deleted successfully',
      'error_deleting_business': 'Error deleting business',
      'hours': 'Hours: {0} - {1}',

      'edit_business': 'Edit: {0}',
      'update': 'Update',
      'map_edit_instructions':
          'Press and hold on the map to modify your business location.',
      'business_updated': 'Business updated successfully',
      'error_updating_business': 'Error updating business',

      'statistics': 'Statistics',
      'share_statistics': 'Share statistics',
      'activity_overview': 'Overview of your activity',
      'day': 'Day',
      'week': 'Week',
      'month': 'Month',
      'year': 'Year',
      'views': 'Views',
      'total_views': 'Total views',
      'updates': 'Updates',
      'businesses': 'Businesses',
      'popular_businesses': 'Popular businesses',
      'days_mon': 'Mon',
      'days_tue': 'Tue',
      'days_wed': 'Wed',
      'days_thu': 'Thu',
      'days_fri': 'Fri',
      'days_sat': 'Sat',
      'days_sun': 'Sun',
      'share_business': 'Share this business',
      'my_statistics': 'My statistics on Warap',
      'coming_soon': 'Coming soon', // Pour l'anglais

      // Edit Profile Screen
      'edit_profile': 'Edit Profile',
      'save': 'Save',
      'full_name': 'Full Name',
      'enter_name': 'Enter your name',
      'please_enter_name': 'Please enter your name',
      'choose_from_gallery': 'Choose from gallery',
      'take_photo': 'Take a photo',
      'delete_photo': 'Delete photo',
      'photo_deleted': 'Photo deleted',
      'profile_updated': 'Profile updated successfully',
      'error_updating_profile': 'Error updating profile',
      'error_selecting_image': 'Error selecting image',
      'error_taking_photo': 'Error taking photo',

// FAQ Screen
      'faq': 'Frequently Asked Questions',
      'create_account_question': 'How do I create an account?',
      'create_account_answer':
          'To create an account, click on the "Register" button on the home page and fill out the form.',
      'edit_info_question': 'How do I edit my personal information?',
      'edit_info_answer':
          'Go to the "Profile" section, then tap on "Edit my information".',
      'add_business_question': 'How do I add a business?',
      'add_business_answer':
          'Go to the "My Businesses" section and click on "Add a business". Then follow the instructions.',
      'contact_vendor_question': 'Can I contact a vendor directly?',
      'contact_vendor_answer':
          'Yes, each business card contains a button to directly contact the vendor by phone or email.',
      'app_free_question': 'Is the app free?',
      'app_free_answer':
          'Yes, the app is completely free for users. Some premium features will be available soon.',

// Help Screen
      'help_support': 'Help and Support',
      'how_can_we_help': 'How can we help you?',
      'faq_title': 'Frequently Asked Questions',
      'faq_desc': 'Find answers to the most common questions.',
      'user_guide_title': 'User Guide',
      'user_guide_desc': 'Discover all the features of the application.',
      'contact_support_title': 'Contact Support',
      'contact_support_desc': 'Send an email to our support team.',
      'live_chat_title': 'Live Chat',
      'live_chat_desc': 'Chat with a customer service representative.',
      'live_chat_soon': 'Live chat will be available soon',
      'vendor_guide_title': 'Vendor Guide',
      'vendor_guide_desc': 'How to effectively manage your business.',
      'follow_social': 'Follow us on social media',
      'app_version': 'App version: 1.0.0',
      'privacy_policy': 'Privacy Policy',
      'terms_of_use': 'Terms of Use',

// Language Screen
      'choose_language': 'Choose language',
      'language_changed': 'Language changed to {0}',

// Settings Screen
      'settings': 'Settings',
      'notifications': 'Notifications',
      'enable_notifications': 'Enable notifications',
      'notifications_desc': 'Receive updates about nearby businesses',
      'location': 'Location',
      'enable_location': 'Enable location',
      'location_desc': 'Allows you to see nearby businesses',
      'search_radius': 'Search radius',
      'appearance': 'Appearance',
      'dark_mode': 'Dark mode',
      'dark_mode_desc': 'Enable dark theme',
      'account': 'Account',
      'delete_account': 'Delete my account',
      'delete_account_desc': 'This action is irreversible',
      'delete_account_question': 'Delete your account?',
      'delete_account_warning':
          'This action is irreversible. All your data will be permanently deleted.',
      'settings_saved': 'Settings saved',
      'km': 'km',

// User Guide Screen
      'user_guide': 'User Guide',
      'user_guide_coming': 'User guide coming soon...',

// Vendor Guide Screen
      'vendor_guide': 'Vendor Guide',
      'vendor_guide_coming': 'Vendor guide coming soon...',
      // Bottom Navigation
      'map': 'Map',
      'favorites': 'Favorites',
      'search': 'Search',
      'profile': 'Profile',
      'my_businesses': 'My Businesses',
      'add': 'Add',
      'statistics': 'Statistics',

// Custom App Bar
      'logout': 'Logout',
      'logout_question': 'Are you sure you want to log out?',
      'cancel': 'Cancel',
      'error_logout': 'Error during logout:',

// Loading Indicator
      'loading': 'Loading...',

      'vendor_settings': 'Vendor Settings',
      'business_settings': 'Business Settings',
      'visibility': 'Visibility',
      'business_visibility': 'Business visibility',
      'show_business_when_closed': 'Show my businesses even when closed',
      'default_settings': 'Default Settings',
      'default_opening_hours': 'Default opening hours',
      'default_closing_hours': 'Default closing hours',
      'notifications_settings': 'Notification Settings',
      'new_customer_notification': 'New customer notifications',
      'receive_new_customer_notifications':
          'Receive notifications when new customers view my businesses',
      'stats_settings': 'Statistics Settings',
      'stats_period': 'Default statistics period',
      'payment_settings': 'Payment Settings',
      'payment_methods': 'Accepted payment methods',
      'cash': 'Cash',
      'credit_card': 'Credit Card',
      'mobile_payment': 'Mobile Payment',
      'settings_saved': 'Settings saved',

      // Pour l'anglais
      'network_error':
          'Network connection error. Please check your internet connection.',
      'auth_error': 'Authentication error. Please log in again.',
      'server_error': 'Server error. Please try again later.',
      'not_found_error': 'The requested resource was not found.',
      'validation_error': 'Data validation error.',
      'timeout_error':
          'The request took too long. Please check your internet connection.',
      'unknown_error': 'An unknown error occurred.',
      'retry': 'Retry',
      'storage_error': 'Error uploading or accessing files.',
    },
  };

  static String text(BuildContext context, String key) {
    final provider = Provider.of<LocaleProvider>(context, listen: false);
    final lang = provider.languageCode;

    if (_translations.containsKey(lang) &&
        _translations[lang]!.containsKey(key)) {
      return _translations[lang]![key]!;
    }

    // Fallback à la version française si la traduction n'existe pas
    if (_translations['fr']!.containsKey(key)) {
      return _translations['fr']![key]!;
    }

    return key; // Retourner la clé comme fallback final
  }

  // Ajoutez cette méthode à la classe AppTranslations
  static String textWithParams(
      BuildContext context, String key, List<String> params) {
    String text = AppTranslations.text(context, key);

    for (int i = 0; i < params.length; i++) {
      text = text.replaceAll('{$i}', params[i]);
    }

    return text;
  }
}
