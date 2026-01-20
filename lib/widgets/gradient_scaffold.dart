import 'package:flutter/material.dart';

class GradientScaffold extends StatelessWidget {
  final Widget body;
  final PreferredSizeWidget? appBar;
  final Widget? floatingActionButton;
  final FloatingActionButtonLocation? floatingActionButtonLocation;
  final Widget? bottomNavigationBar;
  final bool extendBody;

  const GradientScaffold({
    super.key,
    required this.body,
    this.appBar,
    this.floatingActionButton,
    this.floatingActionButtonLocation,
    this.bottomNavigationBar,
    this.extendBody = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      extendBody: extendBody,
      extendBodyBehindAppBar: true, // Key for transparent app bars
      appBar: appBar,
      floatingActionButton: floatingActionButton,
      floatingActionButtonLocation: floatingActionButtonLocation,
      bottomNavigationBar: bottomNavigationBar,
      body: Stack(
        children: [
          // Background Gradient
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: isDark
                    ? [
                        const Color(0xFF0F172A), // Slate 900
                        const Color(0xFF1E1B4B), // Indigo 950
                        const Color(0xFF020617), // Slate 950
                      ]
                    : [
                        const Color(0xFFF8FAFC), // Slate 50
                        const Color(0xFFEEF2FF), // Indigo 50
                        const Color(0xFFF0F9FF), // Sky 50
                      ],
              ),
            ),
          ),
          // Subtle Mesh/Orb Effects (simulated with positioned gradients)
          Positioned(
            top: -100,
            right: -100,
            child: Container(
              width: 400,
              height: 400,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: isDark
                      ? [
                          const Color(0xFF6366F1).withOpacity(0.15),
                          Colors.transparent
                        ]
                      : [
                          const Color(0xFF818CF8).withOpacity(0.1),
                          Colors.transparent
                        ],
                ),
              ),
            ),
          ),
          Positioned(
            bottom: -50,
            left: -50,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: isDark
                      ? [
                          const Color(0xFF14B8A6).withOpacity(0.1),
                          Colors.transparent
                        ]
                      : [
                          const Color(0xFF2DD4BF).withOpacity(0.1),
                          Colors.transparent
                        ],
                ),
              ),
            ),
          ),
          // Main Body
          SafeArea(
            bottom: !extendBody,
            top: appBar == null, // Handle safe area if no app bar
            child: body,
          ),
        ],
      ),
    );
  }
}
