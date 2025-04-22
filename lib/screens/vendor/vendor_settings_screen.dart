// Fichier screens/vendor/vendor_settings_screen.dart
import 'package:flutter/material.dart';
import '../../models/user_model.dart';
import '../../l10n/translations.dart';
import '../../services/auth_service.dart';
import '../../services/vendor_settings_service.dart';

class VendorSettingsScreen extends StatefulWidget {
  const VendorSettingsScreen({Key? key}) : super(key: key);

  @override
  State<VendorSettingsScreen> createState() => _VendorSettingsScreenState();
}

class _VendorSettingsScreenState extends State<VendorSettingsScreen> {
  final AuthService _authService = AuthService();
  UserModel? _currentUser;
  bool _isLoadingUser = true;

  // Paramètres du vendeur
  bool _showWhenClosed = true;
  bool _newCustomerNotification = true;
  String _defaultOpeningTime = '08:00';
  String _defaultClosingTime = '18:00';
  String _defaultStatsPeriod = 'week';
  bool _acceptCash = true;
  bool _acceptCreditCard = false;
  bool _acceptMobilePayment = false;

  @override
  void initState() {
    super.initState();
    _loadUserData();
    _loadSettings();
  }

  Future<void> _loadUserData() async {
    setState(() {
      _isLoadingUser = true;
    });

    try {
      final user = await _authService.getCurrentUser();
      setState(() {
        _currentUser = user;
        _isLoadingUser = false;
      });
    } catch (e) {
      setState(() {
        _isLoadingUser = false;
      });
      print('Erreur lors du chargement des données utilisateur: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppTranslations.text(context, 'vendor_settings')),
        actions: [
          TextButton(
            onPressed: _saveSettings,
            child: Text(
              AppTranslations.text(context, 'save'),
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
      body: ListView(
        children: [
          // Section Visibilité
          _buildSectionHeader(
              context, AppTranslations.text(context, 'business_settings')),
          SwitchListTile(
            title: Text(AppTranslations.text(context, 'business_visibility')),
            subtitle: Text(
                AppTranslations.text(context, 'show_business_when_closed')),
            value: _showWhenClosed,
            onChanged: (value) {
              setState(() {
                _showWhenClosed = value;
              });
            },
          ),
          const Divider(),

          // Section Paramètres par défaut
          _buildSectionHeader(
              context, AppTranslations.text(context, 'default_settings')),

          // Horaires d'ouverture par défaut
          ListTile(
            title: Text(AppTranslations.text(context, 'default_opening_hours')),
            trailing: DropdownButton<String>(
              value: _defaultOpeningTime,
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    _defaultOpeningTime = value;
                  });
                }
              },
              items: ['06:00', '07:00', '08:00', '09:00', '10:00']
                  .map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
            ),
          ),

          // Horaires de fermeture par défaut
          ListTile(
            title: Text(AppTranslations.text(context, 'default_closing_hours')),
            trailing: DropdownButton<String>(
              value: _defaultClosingTime,
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    _defaultClosingTime = value;
                  });
                }
              },
              items: ['17:00', '18:00', '19:00', '20:00', '21:00', '22:00']
                  .map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
            ),
          ),

          const Divider(),

          // Section Notifications
          _buildSectionHeader(
              context, AppTranslations.text(context, 'notifications_settings')),
          SwitchListTile(
            title: Text(
                AppTranslations.text(context, 'new_customer_notification')),
            subtitle: Text(AppTranslations.text(
                context, 'receive_new_customer_notifications')),
            value: _newCustomerNotification,
            onChanged: (value) {
              setState(() {
                _newCustomerNotification = value;
              });
            },
          ),

          const Divider(),

          // Section Statistiques
          _buildSectionHeader(
              context, AppTranslations.text(context, 'stats_settings')),
          ListTile(
            title: Text(AppTranslations.text(context, 'stats_period')),
            trailing: DropdownButton<String>(
              value: _defaultStatsPeriod,
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    _defaultStatsPeriod = value;
                  });
                }
              },
              items: ['day', 'week', 'month', 'year']
                  .map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(AppTranslations.text(context, value)),
                );
              }).toList(),
            ),
          ),

          const Divider(),

          // Section Paiements
          _buildSectionHeader(
              context, AppTranslations.text(context, 'payment_settings')),

          CheckboxListTile(
            title: Text(AppTranslations.text(context, 'cash')),
            value: _acceptCash,
            onChanged: (value) {
              if (value != null) {
                setState(() {
                  _acceptCash = value;
                });
              }
            },
          ),

          CheckboxListTile(
            title: Text(AppTranslations.text(context, 'credit_card')),
            value: _acceptCreditCard,
            onChanged: (value) {
              if (value != null) {
                setState(() {
                  _acceptCreditCard = value;
                });
              }
            },
          ),

          CheckboxListTile(
            title: Text(AppTranslations.text(context, 'mobile_payment')),
            value: _acceptMobilePayment,
            onChanged: (value) {
              if (value != null) {
                setState(() {
                  _acceptMobilePayment = value;
                });
              }
            },
          ),

          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Colors.blue,
        ),
      ),
    );
  }

// Dans VendorSettingsScreen
  final VendorSettingsService _settingsService = VendorSettingsService();

  Future<void> _loadSettings() async {
    try {
      final settings = await _settingsService.loadSettings();

      setState(() {
        _showWhenClosed = settings['showWhenClosed'];
        _newCustomerNotification = settings['newCustomerNotification'];
        _defaultOpeningTime = settings['defaultOpeningTime'];
        _defaultClosingTime = settings['defaultClosingTime'];
        _defaultStatsPeriod = settings['defaultStatsPeriod'];
        _acceptCash = settings['acceptCash'];
        _acceptCreditCard = settings['acceptCreditCard'];
        _acceptMobilePayment = settings['acceptMobilePayment'];
      });
    } catch (e) {
      print('Erreur lors du chargement des paramètres: $e');
    }
  }

  Future<void> _saveSettings() async {
    // Afficher un indicateur de chargement
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(),
      ),
    );

    try {
      await _settingsService.saveSettings({
        'showWhenClosed': _showWhenClosed,
        'newCustomerNotification': _newCustomerNotification,
        'defaultOpeningTime': _defaultOpeningTime,
        'defaultClosingTime': _defaultClosingTime,
        'defaultStatsPeriod': _defaultStatsPeriod,
        'acceptCash': _acceptCash,
        'acceptCreditCard': _acceptCreditCard,
        'acceptMobilePayment': _acceptMobilePayment,
      });

      // Fermer l'indicateur de chargement
      if (!mounted) return;
      Navigator.pop(context);

      // Afficher un message de confirmation
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppTranslations.text(context, 'settings_saved')),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      // Fermer l'indicateur de chargement
      if (!mounted) return;
      Navigator.pop(context);

      // Afficher un message d'erreur
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${AppTranslations.text(context, 'error')}: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}
