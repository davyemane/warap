// Fichier screens/auth/register_screen.dart
import 'package:flutter/material.dart';
import 'dart:math';
import '../../services/auth_service.dart';
import '../../services/error_handler.dart'; // Ajout de l'import
import '../../l10n/translations.dart';
import 'package:provider/provider.dart';
import '../../providers/locale_provider.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final AuthService _authService = AuthService();
  final _formKey = GlobalKey<FormState>();
  
  String _email = '';
  String _password = '';
  String _confirmPassword = '';
  String _userType = 'client';
  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  
  Future<void> _signUp() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    
    _formKey.currentState!.save();
    
    setState(() {
      _isLoading = true;
    });
    
    try {
      print('Tentative d\'inscription avec: $_email, type: $_userType');
      final user = await _authService.signUp(
        email: _email,
        password: _password,
        userType: _userType,
      );
      
      setState(() {
        _isLoading = false;
      });
      
      print('Inscription réussie, userType: ${user.userType}');
      
      // Afficher un message de succès
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppTranslations.text(context, 'account_created'))),
      );
      
      // Rediriger en fonction du type d'utilisateur
      if (user.userType == 'client') {
        Navigator.pushReplacementNamed(context, '/client/map');
      } else {
        Navigator.pushReplacementNamed(context, '/vendor/businesses');
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      
      print('Erreur d\'inscription: $e');
      if (!mounted) return;
      ErrorHandler.showErrorSnackBar(
        context, 
        e,
        onRetry: _signUp,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppTranslations.text(context, 'register')),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Logo ou icône
                const Icon(
                  Icons.store,
                  size: 80,
                  color: Colors.blue,
                ),
                const SizedBox(height: 8),
                Text(
                  AppTranslations.text(context, 'create_account'),
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 32),
                
                // Champ email
                TextFormField(
                  decoration: InputDecoration(
                    labelText: AppTranslations.text(context, 'email'),
                    prefixIcon: const Icon(Icons.email),
                    border: const OutlineInputBorder(),
                    hintText: AppTranslations.text(context, 'email_hint'),
                  ),
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Veuillez entrer votre email';
                    }
                    if (!value.contains('@') || !value.contains('.')) {
                      return 'Veuillez entrer un email valide';
                    }
                    return null;
                  },
                  onSaved: (value) {
                    _email = value!.trim();
                  },
                  onChanged: (value) {
                    _email = value.trim();
                  },
                ),
                const SizedBox(height: 16),
                
                // Champ mot de passe
                TextFormField(
                  decoration: InputDecoration(
                    labelText: AppTranslations.text(context, 'password'),
                    prefixIcon: const Icon(Icons.lock),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword ? Icons.visibility : Icons.visibility_off,
                      ),
                      onPressed: () {
                        setState(() {
                          _obscurePassword = !_obscurePassword;
                        });
                      },
                    ),
                    border: const OutlineInputBorder(),
                    hintText: '6 caractères minimum',
                  ),
                  obscureText: _obscurePassword,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Veuillez entrer un mot de passe';
                    }
                    if (value.length < 6) {
                      return 'Le mot de passe doit contenir au moins 6 caractères';
                    }
                    return null;
                  },
                  onSaved: (value) {
                    _password = value!;
                  },
                  onChanged: (value) {
                    _password = value;
                    // Force rebuild pour mettre à jour la validation
                    setState(() {});
                  },
                ),
                const SizedBox(height: 16),
                
                // Champ confirmation mot de passe
                TextFormField(
                  decoration: InputDecoration(
                    labelText: AppTranslations.text(context, 'confirm_password'),
                    prefixIcon: const Icon(Icons.lock_outline),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscureConfirmPassword ? Icons.visibility : Icons.visibility_off,
                      ),
                      onPressed: () {
                        setState(() {
                          _obscureConfirmPassword = !_obscureConfirmPassword;
                        });
                      },
                    ),
                    border: const OutlineInputBorder(),
                  ),
                  obscureText: _obscureConfirmPassword,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Veuillez confirmer votre mot de passe';
                    }
                    if (value != _password) {
                      return 'Les mots de passe ne correspondent pas';
                    }
                    return null;
                  },
                  onSaved: (value) {
                    _confirmPassword = value!;
                  },
                ),
                const SizedBox(height: 24),
                
                // Type d'utilisateur
                Text(
                  AppTranslations.text(context, 'user_type'),
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                RadioListTile<String>(
                  title: Text(AppTranslations.text(context, 'client_type')),
                  subtitle: Text(AppTranslations.text(context, 'client_desc')),
                  value: 'client',
                  groupValue: _userType,
                  onChanged: (value) {
                    setState(() {
                      _userType = value!;
                    });
                  },
                ),
                RadioListTile<String>(
                  title: Text(AppTranslations.text(context, 'vendor_type')),
                  subtitle: Text(AppTranslations.text(context, 'vendor_desc')),
                  value: 'vendeur',
                  groupValue: _userType,
                  onChanged: (value) {
                    setState(() {
                      _userType = value!;
                    });
                  },
                ),
                const SizedBox(height: 32),
                
                // Bouton d'inscription
                _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : ElevatedButton(
                        onPressed: _signUp,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: Text(
                          AppTranslations.text(context, 'sign_up'),
                          style: const TextStyle(fontSize: 16),
                        ),
                      ),
                const SizedBox(height: 16),
                
                // Lien retour connexion
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(AppTranslations.text(context, 'have_account')),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}