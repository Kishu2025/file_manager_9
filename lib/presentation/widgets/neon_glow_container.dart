import 'package:flutter/material.dart';
import '../../core/theme.dart';

class NeonGlowContainer extends StatelessWidget {
  final Widget child;
  final Color color;
  final double blurRadius;
  final double spreadRadius;
  final BorderRadius? borderRadius;
  final EdgeInsetsGeometry? padding;
  final double borderWidth;

  const NeonGlowContainer({
    super.key,
    required this.child,
    this.color = NeonTheme.neonBlue,
    this.blurRadius = 8.0,
    this.spreadRadius = 1.0,
    this.borderRadius,
    this.padding,
    this.borderWidth = 1.0,
  });

  @override
  Widget build(BuildContext context) {
    final radius = borderRadius ?? BorderRadius.circular(12);
    
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.3),
        borderRadius: radius,
        border: Border.all(color: color.withOpacity(0.5), width: borderWidth),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.2),
            blurRadius: blurRadius,
            spreadRadius: spreadRadius,
          ),
        ],
      ),
      child: child,
    );
  }
}
