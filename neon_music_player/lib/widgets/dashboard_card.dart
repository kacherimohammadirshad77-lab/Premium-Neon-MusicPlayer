import 'package:flutter/material.dart';
import 'glass_container.dart';

/// One of the beautiful gradient cards on the Home dashboard (Library,
/// Favourite, Recent Play, etc.). Shows an icon, a title, and a count, with
/// a scale/ripple animation on tap.
class DashboardCard extends StatefulWidget {
  final IconData icon;
  final String title;
  final int count;
  final VoidCallback onTap;

  const DashboardCard({
    super.key,
    required this.icon,
    required this.title,
    required this.count,
    required this.onTap,
  });

  @override
  State<DashboardCard> createState() => _DashboardCardState();
}

class _DashboardCardState extends State<DashboardCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 120),
    lowerBound: 0.0,
    upperBound: 0.06,
  );

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final accent = Theme.of(context).colorScheme.primary;

    return GestureDetector(
      onTapDown: (_) => _controller.forward(),
      onTapUp: (_) => _controller.reverse(),
      onTapCancel: () => _controller.reverse(),
      onTap: widget.onTap,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) => Transform.scale(
          scale: 1 - _controller.value,
          child: child,
        ),
        child: GlassContainer(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: accent.withOpacity(0.16),
                ),
                child: Icon(widget.icon, color: accent, size: 22),
              ),
              const SizedBox(height: 10),
              Text(
                widget.title,
                style: Theme.of(context)
                    .textTheme
                    .titleSmall
                    ?.copyWith(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 2),
              Text(
                '${widget.count} songs',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color:
                          Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
