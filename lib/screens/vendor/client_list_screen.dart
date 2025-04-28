// Fichier screens/vendor/client_list_screen.dart
import 'package:flutter/material.dart';
import '../../models/user_model.dart';
import '../../services/client_service.dart';
import '../../services/error_handler.dart';
import '../../l10n/translations.dart';
import '../../widgets/common/custom_app_bar.dart';
import '../../widgets/common/loading_indicator.dart';

class ClientListScreen extends StatefulWidget {
  const ClientListScreen({Key? key}) : super(key: key);

  @override
  State<ClientListScreen> createState() => _ClientListScreenState();
}

class _ClientListScreenState extends State<ClientListScreen> {
  final ClientService _clientService = ClientService();
  
  List<UserModel> _clients = [];
  List<UserModel> _filteredClients = [];
  bool _isLoading = true;
  String _searchQuery = '';
  
  @override
  void initState() {
    super.initState();
    _loadClients();
  }
  
  Future<void> _loadClients() async {
    setState(() {
      _isLoading = true;
    });
    
    try {
      final clients = await _clientService.getBusinessClients();
      
      setState(() {
        _clients = clients;
        _applySearch();
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      
      if (mounted) {
        ErrorHandler.showErrorSnackBar(
          context, 
          e,
          fallbackMessage: AppTranslations.text(context, 'error_loading_clients'),
          onRetry: _loadClients,
        );
      }
    }
  }
  
  void _applySearch() {
    if (_searchQuery.isEmpty) {
      setState(() {
        _filteredClients = _clients;
      });
      return;
    }
    
    setState(() {
      _filteredClients = _clients.where((client) {
        final name = client.name.toLowerCase();
        final email = client.email.toLowerCase();
        final query = _searchQuery.toLowerCase();
        
        return name.contains(query) || email.contains(query);
      }).toList();
    });
  }
  
  void _viewClientDetails(UserModel client) {
    // Cette fonction pourrait naviguer vers un écran de détails client
    // Pour l'instant, affichons simplement un bottom sheet
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => _buildClientDetailsSheet(client),
    );
  }
  
  Widget _buildClientDetailsSheet(UserModel client) {
    return DraggableScrollableSheet(
      initialChildSize: 0.5,
      minChildSize: 0.3,
      maxChildSize: 0.9,
      expand: false,
      builder: (context, scrollController) {
        return SingleChildScrollView(
          controller: scrollController,
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Poignée de glissement
              Center(
                child: Container(
                  width: 40,
                  height: 5,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              
              // Profil du client
              Row(
                children: [
                  CircleAvatar(
                    radius: 40,
                    backgroundColor: Colors.blue.shade100,
                    backgroundImage: client.hasProfileImage
                        ? NetworkImage(client.profileImageUrl!)
                        : null,
                    child: !client.hasProfileImage
                        ? Text(
                            client.initials,
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.blue,
                            ),
                          )
                        : null,
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          client.name.isNotEmpty
                              ? client.name
                              : AppTranslations.text(context, 'no_name'),
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          client.email,
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              
              // Statistiques du client
              Text(
                AppTranslations.text(context, 'client_stats'),
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              
              // Ces statistiques seraient normalement chargées depuis une API
              _buildStatRow(Icons.shopping_bag, AppTranslations.text(context, 'total_orders'), '5'),
              const SizedBox(height: 8),
              _buildStatRow(Icons.access_time, AppTranslations.text(context, 'last_order'), '10/04/2024'),
              const SizedBox(height: 8),
              _buildStatRow(Icons.attach_money, AppTranslations.text(context, 'total_spent'), '150.50 €'),
              
              const SizedBox(height: 24),
              const Divider(),
              
              // Actions
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildActionButton(
                    Icons.message,
                    AppTranslations.text(context, 'message'),
                    Colors.blue,
                    () {
                      // Envoyer un message au client
                      Navigator.pop(context);
                    },
                  ),
                  _buildActionButton(
                    Icons.phone,
                    AppTranslations.text(context, 'call'),
                    Colors.green,
                    () {
                      // Appeler le client
                      Navigator.pop(context);
                    },
                  ),
                  _buildActionButton(
                    Icons.history,
                    AppTranslations.text(context, 'history'),
                    Colors.orange,
                    () {
                      // Voir l'historique des commandes
                      Navigator.pop(context);
                    },
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
  
  Widget _buildStatRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Colors.grey),
        const SizedBox(width: 16),
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              color: Colors.grey[700],
            ),
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
  
  Widget _buildActionButton(IconData icon, String label, Color color, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircleAvatar(
            backgroundColor: color.withOpacity(0.1),
            radius: 20,
            child: Icon(
              icon,
              color: color,
              size: 20,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: AppTranslations.text(context, 'my_clients'),
        showBackButton: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadClients,
            tooltip: AppTranslations.text(context, 'refresh'),
          ),
        ],
      ),
      body: Column(
        children: [
          // Barre de recherche
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              decoration: InputDecoration(
                hintText: AppTranslations.text(context, 'search_clients'),
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                filled: true,
                fillColor: Colors.grey[100],
                contentPadding: const EdgeInsets.symmetric(vertical: 0),
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                  _applySearch();
                });
              },
            ),
          ),
          
          // Liste des clients
          Expanded(
            child: _isLoading
                ? Center(
                    child: LoadingIndicator(
                      message: AppTranslations.text(context, 'loading_clients'),
                      animationType: AnimationType.bounce,
                      color: Theme.of(context).primaryColor,
                    ),
                  )
                : _filteredClients.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.people,
                              size: 80,
                              color: Colors.grey[400],
                            ),
                            const SizedBox(height: 16),
                            Text(
                              _searchQuery.isEmpty
                                  ? AppTranslations.text(context, 'no_clients_yet')
                                  : AppTranslations.text(context, 'no_matching_clients'),
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        itemCount: _filteredClients.length,
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemBuilder: (context, index) {
                          final client = _filteredClients[index];
                          return Card(
                            margin: const EdgeInsets.only(bottom: 12),
                            child: ListTile(
                              leading: CircleAvatar(
                                backgroundColor: Colors.blue.shade100,
                                backgroundImage: client.hasProfileImage
                                    ? NetworkImage(client.profileImageUrl!)
                                    : null,
                                child: !client.hasProfileImage
                                    ? Text(
                                        client.initials,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: Colors.blue,
                                        ),
                                      )
                                    : null,
                              ),
                              title: Text(
                                client.name.isNotEmpty
                                    ? client.name
                                    : AppTranslations.text(context, 'no_name'),
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              subtitle: Text(client.email),
                              trailing: const Icon(Icons.chevron_right),
                              onTap: () => _viewClientDetails(client),
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }
}