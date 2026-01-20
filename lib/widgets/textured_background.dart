import 'package:flutter/material.dart';
import 'dart:ui';

class TexturedBackground extends StatelessWidget {
  final Widget child;

  const TexturedBackground({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    return Stack(
      children: [
        // Fundamental background color
        Container(color: theme.scaffoldBackgroundColor),

        // Gradient blob 1
        Positioned(
          top: -100,
          right: -100,
          child: Container(
            width: 300,
            height: 300,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: theme.primaryColor.withOpacity(isDarkMode ? 0.15 : 0.05),
            ),
          ),
        ),

        // Gradient blob 2
        Positioned(
          bottom: 100,
          left: -50,
          child: Container(
            width: 250,
            height: 250,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: theme.colorScheme.secondary
                  .withOpacity(isDarkMode ? 0.1 : 0.03),
            ),
          ),
        ),

        // Blur overlay to blend the blobs
        Positioned.fill(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 80, sigmaY: 80),
            child: Container(color: Colors.transparent),
          ),
        ),

        child,
      ],
    );
  }
}
