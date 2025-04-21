import 'package:flutter/material.dart';

class FilterScreen extends StatefulWidget {
  final String? selectedType;
  final bool showOpenOnly;
  
  const FilterScreen({
    Key? key,
    this.selectedType,
    this.showOpenOnly = false,
  }) : super(key: key);

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Filtrer les commerces'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Type de commerce',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            RadioListTile<String?>(
              title: const Text('Tous les commerces'),
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
              title: const Text('Commerces fixes (boutiques)'),
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
              title: const Text('Commerces mobiles (ambulants)'),
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
              title: const Text(
                'Afficher uniquement les commerces ouverts',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: const Text(
                'Masquer les commerces actuellement fermés'
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
                    onPressed: () {
                      // Réinitialiser les filtres
                      setState(() {
                        _selectedType = null;
                        _showOpenOnly = false;
                      });
                    },
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: const Text('Réinitialiser'),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context, {
                        'selectedType': _selectedType,
                        'showOpenOnly': _showOpenOnly,
                      });
                    },
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: const Text('Appliquer'),
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

// Petit Widget pour les boutons d'action dans la bottom sheet
class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: color,
              size: 28,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}