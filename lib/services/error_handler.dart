// lib/services/error_handler.dart
import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../l10n/translations.dart';

enum ErrorType {
  network,
  auth,
  server,
  notFound,
  validation,
  timeout,
  storage,
  permission,
  unknown
}

class ErrorHandler {
  static ErrorType identifyError(dynamic error) {
    if (error is SocketException) {
      return ErrorType.network;
    } else if (error is AuthException) {
      return ErrorType.auth;
    } else if (error is TimeoutException) {
      return ErrorType.timeout;
    } else if (error is StorageException) {
      return ErrorType.storage;
    } else if (error is PermissionException || error.toString().contains('permission')) {
      return ErrorType.permission;
    } else {
      // Analyser les messages d'erreur pour les erreurs Supabase
      String errorString = error.toString().toLowerCase();
      
      if (errorString.contains('network') || errorString.contains('connection')) {
        return ErrorType.network;
      } else if (errorString.contains('not found') || errorString.contains('404')) {
        return ErrorType.notFound;
      } else if (errorString.contains('validation') || errorString.contains('invalid')) {
        return ErrorType.validation;
      } else if (errorString.contains('timeout')) {
        return ErrorType.timeout;
      } else if (errorString.contains('auth') || errorString.contains('login') || 
                errorString.contains('password') || errorString.contains('email_not_confirmed')) {
        return ErrorType.auth;
      } else if (errorString.contains('storage')) {
        return ErrorType.storage;
      } else if (errorString.contains('server') || errorString.contains('database') || 
                errorString.contains('sql')) {
        return ErrorType.server;
      }
    }
    return ErrorType.unknown;
  }
  
  static String getErrorMessage(BuildContext context, ErrorType type, {String? details}) {
    switch (type) {
      case ErrorType.network:
        return AppTranslations.text(context, 'network_error');
      case ErrorType.auth:
        if (details != null && details.contains('email_not_confirmed')) {
          return AppTranslations.text(context, 'email_not_confirmed_error');
        } else if (details != null && details.contains('invalid_credentials')) {
          return AppTranslations.text(context, 'invalid_credentials_error');
        }
        return AppTranslations.text(context, 'auth_error');
      case ErrorType.server:
        return AppTranslations.text(context, 'server_error');
      case ErrorType.notFound:
        return AppTranslations.text(context, 'not_found_error');
      case ErrorType.validation:
        return AppTranslations.text(context, 'validation_error');
      case ErrorType.timeout:
        return AppTranslations.text(context, 'timeout_error');
      case ErrorType.storage:
        return AppTranslations.text(context, 'storage_error');
      case ErrorType.permission:
        return AppTranslations.text(context, 'permission_error');
      case ErrorType.unknown:
      default:
        return details != null && details.length < 100
            ? '${AppTranslations.text(context, 'unknown_error')}: $details'
            : AppTranslations.text(context, 'unknown_error');
    }
  }
  
  static void showErrorSnackBar(BuildContext context, dynamic error, {
    String? fallbackMessage,
    VoidCallback? onRetry,
  }) {
    final errorType = identifyError(error);
    final message = fallbackMessage ?? getErrorMessage(
      context, 
      errorType, 
      details: error.toString()
    );
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 5),
        action: onRetry != null ? SnackBarAction(
          label: AppTranslations.text(context, 'retry'),
          onPressed: onRetry,
          textColor: Colors.white,
        ) : null,
      ),
    );
    
    // Logging de l'erreur
    print('ERROR [${errorType.name}]: $error');
  }
}

// Exception personnalisée pour les erreurs de permission
class PermissionException implements Exception {
  final String message;
  PermissionException(this.message);
  
  @override
  String toString() => message;
}