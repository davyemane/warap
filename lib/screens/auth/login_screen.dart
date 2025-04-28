// Fichier screens/auth/login_screen.dart
import 'package:flutter/material.dart';
import 'dart:math';
import '../../services/auth_service.dart';
import '../../services/error_handler.dart'; // Ajout de l'import
import 'register_screen.dart';
import '../../l10n/translations.dart';
import 'package:provider/provider.dart';
import '../../providers/locale_provider.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final AuthService _authService = AuthService();
  final _formKey = GlobalKey<FormState>();
  
  String _email = '';
  String _password = '';
  bool _isLoading = false;
  bool _obscurePassword = true;
  
  Future<void> _signIn() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    
    _formKey.currentState!.save();
    
    setState(() {
      _isLoading = true;
    });
    
    try {
      print('Tentative de connexion avec: $_email');
      final user = await _authService.signIn(
        email: _email,
        password: _password,
      );
      
      setState(() {
        _isLoading = false;
      });
      
      print('Connexion réussie, userType: ${user.userType}');
      
      // Rediriger en fonction du type d'utilisateur
      if (user.userType == 'client') {
        Navigator.pushReplacementNamed(context, '/client/map');
      } else {
        Navigator.pushReplacementNamed(context, '/vendor');
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      
      print('Erreur de connexion: $e');
      ErrorHandler.showErrorSnackBar(
        context, 
        e, 
        onRetry: _signIn,
      );
    }
  }
  
  void _navigateToRegister() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const RegisterScreen()),
    );
  }

  Future<void> _resendConfirmationEmail() async {
    if (_email.isEmpty || !_email.contains('@') || !_email.contains('.')) {
      ErrorHandler.showErrorSnackBar(
        context, 
        ErrorType.validation,
        fallbackMessage: AppTranslations.text(context, 'enter_valid_email'),
      );
      return;
    }
    
    try {
      await _authService.resendConfirmationEmail(_email);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppTranslations.text(context, 'confirmation_sent'))),
      );
    } catch (e) {
      ErrorHandler.showErrorSnackBar(
        context, 
        e,
        onRetry: _resendConfirmationEmail,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppTranslations.text(context, 'login')),
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
                  AppTranslations.text(context, 'login'),
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 48),
                
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
                  ),
                  obscureText: _obscurePassword,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Veuillez entrer votre mot de passe';
                    }
                    return null;
                  },
                  onSaved: (value) {
                    _password = value!;
                  },
                  onChanged: (value) {
                    _password = value;
                  },
                ),
                const SizedBox(height: 32),
                
                // Bouton de connexion
                _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : ElevatedButton(
                        onPressed: _signIn,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: Text(
                          AppTranslations.text(context, 'sign_in'),
                          style: const TextStyle(fontSize: 16),
                        ),
                      ),
                ElevatedButton(
                  onPressed: _resendConfirmationEmail,
                  child: Text(AppTranslations.text(context, 'resend_confirmation')),
                ),
                const SizedBox(height: 16),
                
                // Lien vers l'inscription
                TextButton(
                  onPressed: _navigateToRegister,
                  child: Text(AppTranslations.text(context, 'no_account')),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}