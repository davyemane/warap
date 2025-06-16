// Fichier: screens/vendor/diagnostic_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../services/supabase_debug_service.dart';
import '../../services/connection_test_service.dart';

class DiagnosticScreen extends StatefulWidget {
  const DiagnosticScreen({super.key});

  @override
  State<DiagnosticScreen> createState() => _DiagnosticScreenState();
}

class _DiagnosticScreenState extends State<DiagnosticScreen> {
  final SupabaseDebugService _debugService = SupabaseDebugService();
  final ConnectionTestService _connectionService = ConnectionTestService();
  
  bool _isRunningTest = false;
  String _testResults = '';
  final ScrollController _scrollController = ScrollController();
  
  final List<String> _tables = [
    'users',
    'businesses',
    'products',
    'orders',
    'service_requests',
    'cart_items',
    'notifications',
    'vendor_settings',
  ];
  
  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }
  
  void _addLog(String message) {
    setState(() {
      _testResults += '$message\n';
    });
    
    // Défiler vers le bas
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }
  
  Future<void> _runConnectionTests() async {
    setState(() {
      _isRunningTest = true;
      _testResults = '';
    });
    
    _addLog('🔄 Tests de connexion en cours...');
    
    // Tester la connexion Internet
    _addLog('\n📡 Test de connexion Internet:');
    final hasInternet = await _connectionService.testInternetConnection();
    _addLog(hasInternet ? '✅ Connexion Internet OK' : '❌ Pas de connexion Internet');
    
    // Tester la connexion à Supabase
    _addLog('\n🔌 Test de connexion à Supabase:');
    final hasSupabaseConnection = await _connectionService.testSupabaseConnection();
    _addLog(hasSupabaseConnection ? '✅ Connexion à Supabase OK' : '❌ Pas de connexion à Supabase');
    
    // Vérifier l'authentification
    _addLog('\n🔐 Vérification de l\'authentification:');
    final authStatus = await _connectionService.checkSupabaseAuth();
    _addLog(authStatus['authenticated'] 
        ? '✅ Authentifié en tant que ${authStatus['details']['email']}' 
        : '❌ Non authentifié: ${authStatus['message']}');
    
    setState(() {
      _isRunningTest = false;
    });
  }
  
  Future<void> _runTableTests() async {
    setState(() {
      _isRunningTest = true;
      _testResults = '';
    });
    
    _addLog('🔄 Tests des tables en cours...');
    
    for (final table in _tables) {
      _addLog('\n📋 Analyse de la table "$table":');
      await _debugService.checkTableStructure(table);
      await _debugService.checkTablePermissions(table);
    }
    
    // Tester quelques relations importantes
    _addLog('\n🔗 Vérification des relations entre tables:');
    await _debugService.checkRelations('orders', 'users', 'client_id');
    await _debugService.checkRelations('products', 'businesses', 'business_id');
    await _debugService.checkRelations('businesses', 'users', 'user_id');
    
    _addLog('\n✅ Tests terminés!');
    
    setState(() {
      _isRunningTest = false;
    });
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Diagnostic Supabase'),
        actions: [
          IconButton(
            icon: const Icon(Icons.copy),
            onPressed: () {
              Clipboard.setData(ClipboardData(text: _testResults));
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Logs copiés dans le presse-papier')),
              );
            },
            tooltip: 'Copier les logs',
          ),
          IconButton(
            icon: const Icon(Icons.clear),
            onPressed: () {
              setState(() {
                _testResults = '';
              });
            },
            tooltip: 'Effacer les logs',
          ),
        ],
      ),
      body: Column(
        children: [
          // Boutons de test
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _isRunningTest ? null : _runConnectionTests,
                    icon: const Icon(Icons.network_check),
                    label: const Text('Tester la connexion'),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _isRunningTest ? null : _runTableTests,
                    icon: const Icon(Icons.table_chart),
                    label: const Text('Tester les tables'),
                  ),
                ),
              ],
            ),
          ),
          
          // Résultats des tests
          Expanded(
            child: _isRunningTest
                ? const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircularProgressIndicator(),
                        SizedBox(height: 16),
                        Text('Tests en cours...'),
                      ],
                    ),
                  )
                : Container(
                    margin: const EdgeInsets.all(16),
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.black87,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: _testResults.isEmpty
                        ? const Center(
                            child: Text(
                              'Exécutez un test pour voir les résultats',
                              style: TextStyle(color: Colors.white70),
                            ),
                          )
                        : SingleChildScrollView(
                            controller: _scrollController,
                            child: Text(
                              _testResults,
                              style: const TextStyle(
                                color: Colors.greenAccent,
                                fontFamily: 'monospace',
                                fontSize: 12,
                              ),
                            ),
                          ),
                  ),
          ),
        ],
      ),
    );
  }
}