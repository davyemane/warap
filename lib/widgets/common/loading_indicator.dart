import 'package:flutter/material.dart';

class LoadingIndicator extends StatelessWidget {
  final String? message;
  final Color color;
  final double size;
  final double strokeWidth;
  final bool isOverlay;

  const LoadingIndicator({
    Key? key,
    this.message,
    this.color = Colors.green,
    this.size = 50.0,
    this.strokeWidth = 4.0,
    this.isOverlay = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final loadingWidget = Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SizedBox(
          width: size,
          height: size,
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(color),
            strokeWidth: strokeWidth,
          ),
        ),
        if (message != null) ...[
          const SizedBox(height: 16),
          Text(
            message!,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ],
      ],
    );

    if (isOverlay) {
      return Container(
        color: Colors.black.withOpacity(0.5),
        child: Center(
          child: Card(
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: loadingWidget,
            ),
          ),
        ),
      );
    }

    return Center(
      child: loadingWidget,
    );
  }
}

// Widget de superposition de chargement plein écran avec blocage des interactions
class FullScreenLoader extends StatelessWidget {
  final String? message;

  const FullScreenLoader({
    Key? key,
    this.message,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        ModalBarrier(
          dismissible: false,
          color: Colors.black.withOpacity(0.3),
        ),
        LoadingIndicator(
          message: message,
          isOverlay: true,
          color: Theme.of(context).primaryColor,
        ),
      ],
    );
  }
}

// Extension pour montrer facilement un loader
extension LoadingContext on BuildContext {
  // Afficher un loader plein écran
  void showLoader({String? message}) {
    showDialog(
      context: this,
      barrierDismissible: false,
      builder: (context) => FullScreenLoader(message: message),
    );
  }

  // Fermer le loader
  void hideLoader() {
    if (Navigator.canPop(this)) {
      Navigator.pop(this);
    }
  }
}