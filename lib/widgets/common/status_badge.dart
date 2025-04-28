// Fichier widgets/common/status_badge.dart
import 'package:flutter/material.dart';
import '../../utils/theme.dart';

class StatusBadge extends StatelessWidget {
  final String status;
  final String label;
  final Color color;
  final Color textColor;
  final double fontSize;
  
  const StatusBadge({
    Key? key,
    required this.status,
    required this.label,
    required this.color,
    this.textColor = Colors.white,
    this.fontSize = 12.0,
  }) : super(key: key);
  
  factory StatusBadge.fromStatus(
    BuildContext context,
    String status,
    String label,
  ) {
    Color color;
    
    switch (status) {
      case 'open':
        color = AppTheme.openColor;
        break;
      case 'closed':
        color = AppTheme.closedColor;
        break;
      case 'pending':
        color = AppTheme.pendingColor;
        break;
      case 'processing':
      case 'accepted':
        color = AppTheme.processingColor;
        break;
      case 'completed':
        color = AppTheme.completedColor;
        break;
      case 'cancelled':
        color = AppTheme.cancelledColor;
        break;
      default:
        color = Colors.grey;
    }
    
    return StatusBadge(
      status: status,
      label: label,
      color: color,
    );
  }
  
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 4,
      ),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: textColor,
          fontWeight: FontWeight.bold,
          fontSize: fontSize,
        ),
      ),
    );
  }
}