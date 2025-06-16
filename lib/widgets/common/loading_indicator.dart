// Fichier widgets/common/loading_indicator.dart
import 'package:flutter/material.dart';
import 'dart:math';
import '../../l10n/translations.dart';
import '../../services/error_handler.dart'; // Ajout de l'import

class LoadingIndicator extends StatelessWidget {
  final String? message;
  final Color color;
  final double size;
  final double strokeWidth;
  final bool isOverlay;
  final bool showShadow;
  final Widget? icon;
  final AnimationType animationType;

  const LoadingIndicator({
    super.key,
    this.message,
    this.color = Colors.blue,
    this.size = 50.0,
    this.strokeWidth = 4.0,
    this.isOverlay = false,
    this.showShadow = true,
    this.icon,
    this.animationType = AnimationType.circular,
  });

  @override
  Widget build(BuildContext context) {
    final defaultMessage = AppTranslations.text(context, 'loading');
    
    final Widget indicator;
    
    switch (animationType) {
      case AnimationType.circular:
        indicator = SizedBox(
          width: size,
          height: size,
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(color),
            strokeWidth: strokeWidth,
          ),
        );
        break;
      case AnimationType.linear:
        indicator = SizedBox(
          width: size * 4, // Plus large pour le linéaire
          child: LinearProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(color),
            backgroundColor: color.withOpacity(0.2),
            minHeight: strokeWidth,
          ),
        );
        break;
      case AnimationType.bounce:
        indicator = _BounceLoadingIndicator(
          size: size,
          color: color,
        );
        break;
      case AnimationType.pulse:
        indicator = _PulseLoadingIndicator(
          size: size,
          color: color,
          icon: icon ?? Icon(Icons.refresh, color: color, size: size * 0.6),
        );
        break;
      case AnimationType.custom:
        indicator = icon ?? SizedBox(
          width: size,
          height: size,
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(color),
            strokeWidth: strokeWidth,
          ),
        );
        break;
    }
    
    final loadingWidget = Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        indicator,
        if (message != null || defaultMessage.isNotEmpty) ...[
          const SizedBox(height: 16),
          Text(
            message ?? defaultMessage,
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
            elevation: showShadow ? 4 : 0,
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

enum AnimationType {
  circular,
  linear,
  bounce,
  pulse,
  custom
}

class _BounceLoadingIndicator extends StatefulWidget {
  final double size;
  final Color color;

  const _BounceLoadingIndicator({
    required this.size,
    required this.color,
  });

  @override
  State<_BounceLoadingIndicator> createState() => _BounceLoadingIndicatorState();
}

class _BounceLoadingIndicatorState extends State<_BounceLoadingIndicator> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.size * 2,
      height: widget.size,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(3, (index) {
          return AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 4),
                child: Transform.translate(
                  offset: Offset(0, sin((_controller.value * 360 - index * 120) * 0.0174533) * 10),
                  child: child,
                ),
              );
            },
            child: Container(
              width: widget.size * 0.2,
              height: widget.size * 0.2,
              decoration: BoxDecoration(
                color: widget.color,
                shape: BoxShape.circle,
              ),
            ),
          );
        }),
      ),
    );
  }
}

class _PulseLoadingIndicator extends StatefulWidget {
  final double size;
  final Color color;
  final Widget icon;

  const _PulseLoadingIndicator({
    required this.size,
    required this.color,
    required this.icon,
  });

  @override
  State<_PulseLoadingIndicator> createState() => _PulseLoadingIndicatorState();
}

class _PulseLoadingIndicatorState extends State<_PulseLoadingIndicator> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat();
    
    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.2).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ),
    );
    
    _opacityAnimation = Tween<double>(begin: 0.7, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.size,
      height: widget.size,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Opacity(
            opacity: _opacityAnimation.value,
            child: Transform.scale(
              scale: _scaleAnimation.value,
              child: widget.icon,
            ),
          );
        },
      ),
    );
  }
}

// Widget de superposition de chargement plein écran avec blocage des interactions
class FullScreenLoader extends StatelessWidget {
  final String? message;
  final AnimationType animationType;
  final Color color;
  final Widget? icon;
  final bool dismissible;

  const FullScreenLoader({
    super.key,
    this.message,
    this.animationType = AnimationType.circular,
    this.color = Colors.blue,
    this.icon,
    this.dismissible = false,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        ModalBarrier(
          dismissible: dismissible,
          color: Colors.black.withOpacity(0.3),
        ),
        LoadingIndicator(
          message: message,
          isOverlay: true,
          color: color,
          animationType: animationType,
          icon: icon,
        ),
      ],
    );
  }
}

// Extension pour montrer facilement un loader
extension LoadingContext on BuildContext {
  // Afficher un loader plein écran
  void showLoader({
    String? message, 
    AnimationType animationType = AnimationType.circular, 
    Color color = Colors.blue,
    Widget? icon,
    bool dismissible = false,
  }) {
    try {
      showDialog(
        context: this,
        barrierDismissible: dismissible,
        builder: (context) => FullScreenLoader(
          message: message,
          animationType: animationType,
          color: color,
          icon: icon,
          dismissible: dismissible,
        ),
      );
    } catch (e) {
      ErrorHandler.showErrorSnackBar(
        this, 
        e,
        fallbackMessage: AppTranslations.text(this, 'error_loading'),
      );
    }
  }

  // Fermer le loader
  void hideLoader() {
    try {
      if (Navigator.canPop(this)) {
        Navigator.pop(this);
      }
    } catch (e) {
      ErrorHandler.showErrorSnackBar(
        this, 
        e,
        fallbackMessage: AppTranslations.text(this, 'error_closing_loader'),
      );
    }
  }
}