import 'package:flutter/material.dart';

class TexturedBackground extends StatelessWidget {
  final Widget child;

  const TexturedBackground({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
          ),
        ),
        // This container creates a subtle noise texture.
        Container(
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: AssetImage(
                  'assets/images/noise.png'), // Assuming you have a noise texture image
              repeat: ImageRepeat.repeat,
              opacity: 0.05, // very subtle
            ),
          ),
        ),
        child,
      ],
    );
  }
}
