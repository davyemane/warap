// Fichier screens/client/filter_screen.dart
import 'package:flutter/material.dart';
import '../../l10n/translations.dart';
import '../../services/error_handler.dart'; // Ajout de l'import

class FilterScreen extends StatefulWidget {
  final String? selectedType;
  final bool showOpenOnly;
  
  const FilterScreen({
    super.key,
    this.selectedType,
    this.showOpenOnly = false,
  });

  @override
  State<FilterScreen> createState() => _FilterScreenState();
}

class _FilterScreenState extends State<FilterScreen> {
  late String? _selectedType;
  late bool _showOpenOnly;
  
  @override
  void initState() {
    super.initState();
    _selectedType = widget.selectedType;
    _showOpenOnly = widget.showOpenOnly;
  }

  void _applyFilters() {
    try {
      Navigator.pop(context, {
        'selectedType': _selectedType,
        'showOpenOnly': _showOpenOnly,
      });
    } catch (e) {
      ErrorHandler.showErrorSnackBar(
        context, 
        e,
        fallbackMessage: AppTranslations.text(context, 'error_applying_filters'),
      );
    }
  }

  void _resetFilters() {
    try {
      setState(() {
        _selectedType = null;
        _showOpenOnly = false;
      });
    } catch (e) {
      ErrorHandler.showErrorSnackBar(
        context, 
        e,
        fallbackMessage: AppTranslations.text(context, 'error_resetting_filters'),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppTranslations.text(context, 'filter_businesses')),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              AppTranslations.text(context, 'business_type'),
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            RadioListTile<String?>(
              title: Text(AppTranslations.text(context, 'all_businesses')),
              value: null,
              groupValue: _selectedType,
              activeColor: Theme.of(context).primaryColor,
              onChanged: (value) {
                setState(() {
                  _selectedType = value;
                });
              },
            ),
            RadioListTile<String>(
              title: Text(AppTranslations.text(context, 'fixed_businesses')),
              secondary: const Icon(Icons.store, color: Colors.blue),
              value: 'fixe',
              groupValue: _selectedType,
              activeColor: Theme.of(context).primaryColor,
              onChanged: (value) {
                setState(() {
                  _selectedType = value;
                });
              },
            ),
            RadioListTile<String>(
              title: Text(AppTranslations.text(context, 'mobile_businesses')),
              secondary: const Icon(Icons.delivery_dining, color: Colors.green),
              value: 'mobile',
              groupValue: _selectedType,
              activeColor: Theme.of(context).primaryColor,
              onChanged: (value) {
                setState(() {
                  _selectedType = value;
                });
              },
            ),
            const SizedBox(height: 24),
            const Divider(),
            
            // Option pour afficher uniquement les commerces ouverts
            SwitchListTile(
              title: Text(
                AppTranslations.text(context, 'show_open_only'),
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Text(
                AppTranslations.text(context, 'hide_closed')
              ),
              value: _showOpenOnly,
              activeColor: Theme.of(context).primaryColor,
              onChanged: (value) {
                setState(() {
                  _showOpenOnly = value;
                });
              },
            ),
            
            const Spacer(),
            // Boutons d'action
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: _resetFilters,
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: Text(AppTranslations.text(context, 'reset')),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _applyFilters,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: Text(AppTranslations.text(context, 'apply')),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}