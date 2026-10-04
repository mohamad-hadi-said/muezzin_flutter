import 'dart:ui';
import 'package:flutter/material.dart';

/// Ambient celestial liquid sky background with organic glowing orbs that shine through frosted glass.
class LiquidBackground extends StatelessWidget {
  final Widget child;

  const LiquidBackground({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Base multi-stop celestial sky gradient
        Positioned.fill(
          child: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0xFFE2F1FD), // Fresh crystal light sky
                  Color(0xFFC0E1FD), // Soft daytime azure
                  Color(0xFF86BFFF), // Luminous cerulean
                  Color(0xFF4B91F3), // Vibrant atmospheric blue
                  Color(0xFF2563EB), // Deep celestial royal blue
                ],
                stops: [0.0, 0.25, 0.55, 0.82, 1.0],
              ),
            ),
          ),
        ),

        // Fluid Liquid Glow 1: Warm Amber / Sunlight orb at top-left
        Positioned(
          top: -60,
          left: -40,
          child: IgnorePointer(
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    const Color(0xFFF59E0B).withValues(alpha: 0.42),
                    const Color(0xFFF59E0B).withValues(alpha: 0.0),
                  ],
                ),
              ),
            ),
          ),
        ),

        // Fluid Liquid Glow 2: Celestial Violet-Indigo orb at upper-right
        Positioned(
          top: 130,
          right: -80,
          child: IgnorePointer(
            child: Container(
              width: 340,
              height: 340,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    const Color(0xFF6366F1).withValues(alpha: 0.35),
                    const Color(0xFF6366F1).withValues(alpha: 0.0),
                  ],
                ),
              ),
            ),
          ),
        ),

        // Fluid Liquid Glow 3: Oasis Aquamarine orb at mid-left
        Positioned(
          top: 430,
          left: -80,
          child: IgnorePointer(
            child: Container(
              width: 310,
              height: 310,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    const Color(0xFF06B6D4).withValues(alpha: 0.32),
                    const Color(0xFF06B6D4).withValues(alpha: 0.0),
                  ],
                ),
              ),
            ),
          ),
        ),

        // Fluid Liquid Glow 4: Deep Starlight Indigo orb at bottom-right
        Positioned(
          bottom: -70,
          right: -40,
          child: IgnorePointer(
            child: Container(
              width: 340,
              height: 340,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    const Color(0xFF1E3A8A).withValues(alpha: 0.48),
                    const Color(0xFF1E3A8A).withValues(alpha: 0.0),
                  ],
                ),
              ),
            ),
          ),
        ),

        // The foreground content
        Positioned.fill(child: child),
      ],
    );
  }
}

/// A liquid glass container providing true backdrop blur, specular refraction borders,
/// fluid translucency, and organic ambient glow.
class LiquidGlassContainer extends StatelessWidget {
  final Widget child;
  final double blur;
  final BorderRadius? borderRadius;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final List<Color>? gradientColors;
  final Color? borderColor;
  final double borderWidth;
  final bool isGlowing;
  final Color glowColor;
  final VoidCallback? onTap;

  const LiquidGlassContainer({
    super.key,
    required this.child,
    this.blur = 18.0,
    this.borderRadius,
    this.padding,
    this.margin,
    this.gradientColors,
    this.borderColor,
    this.borderWidth = 1.1,
    this.isGlowing = false,
    this.glowColor = const Color(0xFFF59E0B),
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final radius = borderRadius ?? BorderRadius.circular(24);

    final boxDecoration = BoxDecoration(
      borderRadius: radius,
      boxShadow: [
        if (isGlowing) ...[
          BoxShadow(
            color: glowColor.withValues(alpha: 0.38),
            blurRadius: 28,
            spreadRadius: 2,
            offset: const Offset(0, 6),
          ),
          BoxShadow(
            color: Colors.white.withValues(alpha: 0.70),
            blurRadius: 10,
            spreadRadius: -1,
            offset: const Offset(0, -2),
          ),
        ] else ...[
          BoxShadow(
            color: const Color(0xFF0A2240).withValues(alpha: 0.10),
            blurRadius: 24,
            spreadRadius: -2,
            offset: const Offset(0, 8),
          ),
          BoxShadow(
            color: Colors.white.withValues(alpha: 0.60),
            blurRadius: 8,
            spreadRadius: -1,
            offset: const Offset(0, -2),
          ),
        ],
      ],
    );

    Widget glassBody = Container(
      margin: margin,
      decoration: boxDecoration,
      child: ClipRRect(
        borderRadius: radius,
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
          child: Container(
            padding: padding,
            decoration: BoxDecoration(
              borderRadius: radius,
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors:
                    gradientColors ??
                    [
                      Colors.white.withValues(alpha: 0.48),
                      Colors.white.withValues(alpha: 0.18),
                    ],
              ),
              border: Border.all(
                color: borderColor ?? Colors.white.withValues(alpha: 0.65),
                width: borderWidth,
              ),
            ),
            child: child,
          ),
        ),
      ),
    );

    if (onTap != null) {
      return Material(
        color: Colors.transparent,
        child: InkWell(onTap: onTap, borderRadius: radius, child: glassBody),
      );
    }

    return glassBody;
  }
}
