import 'package:flutter/material.dart';
import 'package:myapp/l10n/app_localizations.dart';
import 'dart:math' as math;

class SpecialBadge extends StatefulWidget {
  final String tier;
  final int level;

  const SpecialBadge({super.key, required this.tier, required this.level});

  @override
  State<SpecialBadge> createState() => _SpecialBadgeState();
}

class _SpecialBadgeState extends State<SpecialBadge> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    switch (widget.tier) {
      case 'Adherence Immortal':
        return _buildImmortalBadge(context);
      case 'Diamond Sentinel':
        return _buildDiamondBadge(context);
      case 'Adherence Hero':
        return _buildHeroBadge(context);
      case 'Adherence Guardian':
        return _buildGuardianBadge(context);
      default:
        return _buildSeedlingBadge(context);
    }
  }

  Widget _buildSeedlingBadge(BuildContext context) {
    return _wrapper(
      icon: Icons.eco,
      color: Colors.green,
      label: AppLocalizations.of(context)!.tier_seedling,
    );
  }

  Widget _buildGuardianBadge(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final glow = Curves.easeInOut.transform(
          (math.sin(_controller.value * 2 * math.pi) + 1) / 2,
        );
        return _wrapper(
          icon: Icons.shield,
          color: Colors.blue,
          label: AppLocalizations.of(context)!.tier_guardian,
          shadows: [
            Shadow(
              color: Colors.blue.withOpacity(0.5 * glow),
              blurRadius: 10 * glow,
            ),
          ],
        );
      },
    );
  }

  Widget _buildHeroBadge(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final scale = 1.0 + 0.1 * math.sin(_controller.value * 2 * math.pi);
        return Transform.scale(
          scale: scale,
          child: _wrapper(
            icon: Icons.shield_moon,
            color: Colors.orange,
            label: AppLocalizations.of(context)!.tier_hero,
            shadows: [
              const Shadow(color: Colors.orange, blurRadius: 15),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDiamondBadge(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return _wrapper(
          icon: Icons.diamond,
          color: Colors.cyan,
          label: AppLocalizations.of(context)!.tier_sentinel,
          gradient: LinearGradient(
            colors: [
              Colors.cyan,
              Colors.purple.withOpacity(0.7),
              Colors.blue,
            ],
            transform: GradientRotation(_controller.value * 2 * math.pi),
          ),
          shadows: [
            const Shadow(color: Colors.cyan, blurRadius: 20),
          ],
        );
      },
    );
  }

  Widget _buildImmortalBadge(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Stack(
          alignment: Alignment.center,
          children: [
            // Rotated Glow Aura
            Transform.rotate(
              angle: _controller.value * 2 * math.pi,
              child: Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: SweepGradient(
                    colors: [
                      Colors.amber.withOpacity(0),
                      Colors.amber.withOpacity(0.5),
                      Colors.amber.withOpacity(0),
                    ],
                  ),
                ),
              ),
            ),
            _wrapper(
              icon: Icons.workspace_premium, // Crown-like icon
              color: Colors.amber,
              label: AppLocalizations.of(context)!.tier_immortal,
              labelStyle: const TextStyle(
                color: Colors.amber,
                fontWeight: FontWeight.w900,
                letterSpacing: 1.5,
                fontSize: 10,
                shadows: [Shadow(color: Colors.amber, blurRadius: 10)],
              ),
              shadows: [
                const Shadow(color: Colors.amber, blurRadius: 25),
              ],
            ),
            // Sparkles logic (simplified with small particles)
            ...List.generate(4, (i) {
              final angle = (_controller.value * 2 * math.pi) + (i * math.pi / 2);
              return Transform.translate(
                offset: Offset(math.cos(angle) * 30, math.sin(angle) * 30),
                child: const Icon(Icons.auto_awesome, color: Colors.amber, size: 8),
              );
            }),
          ],
        );
      },
    );
  }

  Widget _wrapper({
    required IconData icon,
    required Color color,
    required String label,
    List<Shadow>? shadows,
    Gradient? gradient,
    TextStyle? labelStyle,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            shape: BoxShape.circle,
            border: Border.all(color: color.withOpacity(0.3), width: 2),
          ),
          child: Icon(
            icon,
            color: color,
            size: 32,
            shadows: shadows,
          ),
        ),
        const SizedBox(height: 8),
        if (gradient != null)
          ShaderMask(
            shaderCallback: (bounds) => gradient.createShader(bounds),
            child: Text(
              label.toUpperCase(),
              style: (labelStyle ?? const TextStyle(fontWeight: FontWeight.w900, fontSize: 10)).copyWith(color: Colors.white),
            ),
          )
        else
          Text(
            label.toUpperCase(),
            style: (labelStyle ?? TextStyle(
              fontWeight: FontWeight.w900,
              fontSize: 10,
              color: color.withOpacity(0.8),
              letterSpacing: 1.2,
            )),
          ),
      ],
    );
  }
}
