import 'dart:ui';
import 'package:flutter/material.dart';
import '../core/theme/app_theme.dart';

/// A reusable glassmorphism card: blurred translucent background, a soft
/// neon-colored border, and an optional glow shadow. This is the visual
/// building block behind dashboard cards, the mini player, and sheets.
class GlassContainer extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final double borderRadius;
  final double blurSigma;
  final NeonTheme? themeOverride;
  final bool glow;

  const GlassContainer({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.borderRadius = 22,
    this.blurSigma = 18,
    this.themeOverride,
    this.glow = true,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final accent = theme.colorScheme.primary;

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(borderRadius),
        boxShadow: glow
            ? [
                BoxShadow(
                  color: accent.withOpacity(0.25),
                  blurRadius: 24,
                  spreadRadius: -4,
                ),
              ]
            : null,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: blurSigma, sigmaY: blurSigma),
          child: Container(
            padding: padding,
            decoration: BoxDecoration(
              color: theme.colorScheme.surface.withOpacity(0.55),
              borderRadius: BorderRadius.circular(borderRadius),
              border: Border.all(color: accent.withOpacity(0.25), width: 1),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  accent.withOpacity(0.10),
                  Colors.transparent,
                ],
              ),
            ),
            child: child,
          ),
        ),
      ),
    );
  }
}
