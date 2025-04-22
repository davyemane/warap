// lib/services/vendor_settings_service.dart
import 'package:shared_preferences/shared_preferences.dart';

class VendorSettingsService {
  static const String _showWhenClosedKey = 'vendor_show_when_closed';
  static const String _newCustomerNotificationKey = 'vendor_new_customer_notification';
  static const String _defaultOpeningTimeKey = 'vendor_default_opening_time';
  static const String _defaultClosingTimeKey = 'vendor_default_closing_time';
  static const String _defaultStatsPeriodKey = 'vendor_default_stats_period';
  static const String _acceptCashKey = 'vendor_accept_cash';
  static const String _acceptCreditCardKey = 'vendor_accept_credit_card';
  static const String _acceptMobilePaymentKey = 'vendor_accept_mobile_payment';

  // Charger les paramètres
  Future<Map<String, dynamic>> loadSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      return {
        'showWhenClosed': prefs.getBool(_showWhenClosedKey) ?? true,
        'newCustomerNotification': prefs.getBool(_newCustomerNotificationKey) ?? true,
        'defaultOpeningTime': prefs.getString(_defaultOpeningTimeKey) ?? '08:00',
        'defaultClosingTime': prefs.getString(_defaultClosingTimeKey) ?? '18:00',
        'defaultStatsPeriod': prefs.getString(_defaultStatsPeriodKey) ?? 'week',
        'acceptCash': prefs.getBool(_acceptCashKey) ?? true,
        'acceptCreditCard': prefs.getBool(_acceptCreditCardKey) ?? false,
        'acceptMobilePayment': prefs.getBool(_acceptMobilePaymentKey) ?? false,
      };
    } catch (e) {
      print('Erreur lors du chargement des paramètres: $e');
      rethrow;
    }
  }

  // Sauvegarder les paramètres
  Future<void> saveSettings(Map<String, dynamic> settings) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      await prefs.setBool(_showWhenClosedKey, settings['showWhenClosed'] ?? true);
      await prefs.setBool(_newCustomerNotificationKey, settings['newCustomerNotification'] ?? true);
      await prefs.setString(_defaultOpeningTimeKey, settings['defaultOpeningTime'] ?? '08:00');
      await prefs.setString(_defaultClosingTimeKey, settings['defaultClosingTime'] ?? '18:00');
      await prefs.setString(_defaultStatsPeriodKey, settings['defaultStatsPeriod'] ?? 'week');
      await prefs.setBool(_acceptCashKey, settings['acceptCash'] ?? true);
      await prefs.setBool(_acceptCreditCardKey, settings['acceptCreditCard'] ?? false);
      await prefs.setBool(_acceptMobilePaymentKey, settings['acceptMobilePayment'] ?? false);
    } catch (e) {
      print('Erreur lors de la sauvegarde des paramètres: $e');
      rethrow;
    }
  }
}