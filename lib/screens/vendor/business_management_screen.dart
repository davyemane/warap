// Fichier screens/vendor/business_management_screen.dart
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../models/business_model.dart';
import '../../services/business_service.dart';
import '../../services/auth_service.dart';
import 'add_business_screen.dart';
import 'edit_business_screen.dart';

class BusinessManagementScreen extends StatefulWidget {
  final bool showAppBar;
  
  const BusinessManagementScreen({
    Key? key, 
    this.showAppBar = true
  }) : super(key: key);

  @override
  State<BusinessManagementScreen> createState() => _BusinessManagementScreenState();
}

class _BusinessManagementScreenState extends State<BusinessManagementScreen> {
  final BusinessService _businessService = BusinessService();
  final AuthService _authService = AuthService();
  List<BusinessModel> _businesses = [];
  bool _isLoading = true;
  
  @override
  void initState() {
    super.initState();
    _loadBusinesses();
  }

  Future<void> _loadBusinesses() async {
    setState(() {
      _isLoading = true;
    });
    
    try {
      final userId = Supabase.instance.client.auth.currentUser!.id;
      final businesses = await _businessService.getVendorBusinesses(userId);
      
      setState(() {
        _businesses = businesses;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      _showErrorSnackBar('Erreur lors du chargement des commerces');
    }
  }
  
  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }
  
  Future<void> _deleteBusiness(String businessId) async {
    try {
      await _businessService.deleteBusiness(businessId);
      _loadBusinesses();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Commerce supprimé avec succès')),
      );
    } catch (e) {
      _showErrorSnackBar('Erreur lors de la suppression du commerce');
    }
  }
  
  Future<void> _signOut() async {
    try {
      await _authService.signOut();
      Navigator.of(context).pushReplacementNamed('/login');
    } catch (e) {
      _showErrorSnackBar('Erreur lors de la déconnexion');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: widget.showAppBar
          ? AppBar(
              title: const Text('Mes Commerces'),
              actions: [
                IconButton(
                  icon: const Icon(Icons.exit_to_app),
                  onPressed: _signOut,
                ),
              ],
            )
          : null,
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _businesses.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        'Vous n\'avez pas encore de commerce',
                        style: TextStyle(fontSize: 18),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () => _navigateToAddBusiness(),
                        child: const Text('Ajouter un commerce'),
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _loadBusinesses,
                  child: ListView.builder(
                    itemCount: _businesses.length,
                    itemBuilder: (context, index) {
                      final business = _businesses[index];
                      return BusinessListItem(
                        business: business,
                        onEdit: () => _navigateToEditBusiness(business),
                        onDelete: () => _showDeleteConfirmation(business),
                      );
                    },
                  ),
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: _navigateToAddBusiness,
        child: const Icon(Icons.add),
      ),
    );
  }
  
  void _navigateToAddBusiness() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const AddBusinessScreen()),
    );
    
    if (result == true) {
      _loadBusinesses();
    }
  }
  
  void _navigateToEditBusiness(BusinessModel business) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditBusinessScreen(business: business),
      ),
    );
    
    if (result == true) {
      _loadBusinesses();
    }
  }
  
  void _showDeleteConfirmation(BusinessModel business) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Supprimer ce commerce ?'),
        content: Text('Êtes-vous sûr de vouloir supprimer ${business.name} ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _deleteBusiness(business.id);
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Supprimer'),
          ),
        ],
      ),
    );
  }
}

class BusinessListItem extends StatelessWidget {
  final BusinessModel business;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  
  const BusinessListItem({
    Key? key,
    required this.business,
    required this.onEdit,
    required this.onDelete,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    business.name,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Chip(
                  label: Text(
                    business.businessType == 'fixe' ? 'Fixe' : 'Mobile',
                  ),
                  backgroundColor: business.businessType == 'fixe'
                      ? Colors.blue.shade100
                      : Colors.green.shade100,
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(business.description),
            const SizedBox(height: 8),
            Text('Heures: ${business.openingTime} - ${business.closingTime}'),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton.icon(
                  icon: const Icon(Icons.edit),
                  label: const Text('Modifier'),
                  onPressed: onEdit,
                ),
                const SizedBox(width: 8),
                TextButton.icon(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  label: const Text('Supprimer', 
                    style: TextStyle(color: Colors.red),
                  ),
                  onPressed: onDelete,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}