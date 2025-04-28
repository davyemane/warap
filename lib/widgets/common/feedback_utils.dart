// Fichier utils/feedback_utils.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class FeedbackUtils {
  // Feedback tactile pour les interactions importantes
  static void vibrate({FeedbackType type = FeedbackType.light}) {
    switch (type) {
      case FeedbackType.light:
        HapticFeedback.lightImpact();
        break;
      case FeedbackType.medium:
        HapticFeedback.mediumImpact();
        break;
      case FeedbackType.heavy:
        HapticFeedback.heavyImpact();
        break;
      case FeedbackType.success:
        HapticFeedback.lightImpact();
        break;
      case FeedbackType.error:
        HapticFeedback.vibrate();
        break;
    }
  }
  
  // Afficher un toast réussi
  static void showSuccessToast(BuildContext context, String message) {
    vibrate(type: FeedbackType.success);
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );
  }
  
  // Afficher un toast d'erreur
  static void showErrorToast(BuildContext context, String message) {
    vibrate(type: FeedbackType.error);
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 3),
      ),
    );
  }
}

enum FeedbackType {
  light,
  medium,
  heavy,
  success,
  error,
}