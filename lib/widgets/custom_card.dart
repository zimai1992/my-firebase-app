import 'dart:ui';
import 'package:flutter/material.dart';

class CustomCard extends StatelessWidget {
  final Widget child;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry? margin;
  final EdgeInsetsGeometry? padding;
  final Color? color;
  final BoxBorder? border;
  final Gradient? gradient;
  final double? borderRadius;
  final bool isGlass;

  const CustomCard({
    super.key,
    required this.child,
    this.onTap,
    this.margin,
    this.padding,
    this.color,
    this.border,
    this.gradient,
    this.borderRadius,
    this.isGlass = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;
    final double r = borderRadius ?? 24;

    Widget cardContent = AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      margin: margin ?? const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      padding: padding,
      decoration: BoxDecoration(
        color: color ??
            (isGlass
                ? (isDarkMode ? Colors.white.withOpacity(0.05) : Colors.white.withOpacity(0.6))
                : theme.cardTheme.color),
        gradient: gradient,
        borderRadius: BorderRadius.circular(r),
        border: border ??
            Border.all(
              color: isGlass
                  ? (isDarkMode ? Colors.white.withOpacity(0.1) : Colors.white.withOpacity(0.4))
                  : (isDarkMode ? Colors.white.withOpacity(0.05) : Colors.white.withOpacity(0.0)),
              width: 1,
            ),
        boxShadow: isGlass
            ? [] // Glass usually flat or subtle
            : [
                BoxShadow(
                  color: isDarkMode ? Colors.black.withOpacity(0.3) : const Color(0xFF6366F1).withOpacity(0.08),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                  spreadRadius: -4,
                ),
                BoxShadow(
                  color: isDarkMode ? Colors.black.withOpacity(0.2) : Colors.black.withOpacity(0.03),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                  spreadRadius: -2,
                ),
              ],
      ),
      child: child,
    );

    if (isGlass) {
      // Glassmorphism wrapper
      cardContent = ClipRRect(
        borderRadius: BorderRadius.circular(r),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
          child: cardContent,
        ),
      );
    } else {
      // Standard clipping
      cardContent = ClipRRect(
        borderRadius: BorderRadius.circular(r),
        child: cardContent,
      );
    }

    if (onTap != null) {
      return GestureDetector(
        onTap: onTap,
        child: cardContent,
      );
    }

    return cardContent;
  }
}
