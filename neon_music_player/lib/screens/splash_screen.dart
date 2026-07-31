import 'package:flutter/material.dart';
import 'app_root.dart';

/// Beautiful branded splash screen shown while providers load and the
/// library scan kicks off. Fades into [AppRoot] within ~1.5s.
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 900),
  )..forward();

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 1400), () {
      if (mounted) {
        Navigator.of(context).pushReplacement(
          PageRouteBuilder(
            transitionDuration: const Duration(milliseconds: 500),
            pageBuilder: (_, __, ___) => const AppRoot(),
            transitionsBuilder: (_, animation, __, child) =>
                FadeTransition(opacity: animation, child: child),
          ),
        );
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final accent = Theme.of(context).colorScheme.primary;
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Center(
        child: FadeTransition(
          opacity: _controller,
          child: ScaleTransition(
            scale: Tween<double>(begin: 0.85, end: 1.0).animate(
              CurvedAnimation(parent: _controller, curve: Curves.easeOutBack),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 96,
                  height: 96,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: accent.withOpacity(0.15),
                    boxShadow: [
                      BoxShadow(
                          color: accent.withOpacity(0.5),
                          blurRadius: 40,
                          spreadRadius: 4),
                    ],
                  ),
                  child: Icon(Icons.graphic_eq, color: accent, size: 48),
                ),
                const SizedBox(height: 20),
                Text(
                  'NEON MUSIC',
                  style: TextStyle(
                    color: accent,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 3,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
