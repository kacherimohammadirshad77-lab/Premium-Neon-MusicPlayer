import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/player_provider.dart';
import '../screens/full_player_screen.dart';
import 'glass_container.dart';

/// Sticky mini player shown above the bottom navigation bar. Tapping it
/// pushes the fullscreen player with a shared Hero transition on the
/// album art.
class MiniPlayer extends StatelessWidget {
  const MiniPlayer({super.key});

  @override
  Widget build(BuildContext context) {
    final player = context.watch<PlayerProvider>();
    final song = player.currentSong;
    if (song == null) return const SizedBox.shrink();

    final accent = Theme.of(context).colorScheme.primary;

    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          PageRouteBuilder(
            transitionDuration: const Duration(milliseconds: 350),
            pageBuilder: (_, __, ___) => const FullPlayerScreen(),
            transitionsBuilder: (_, animation, __, child) => SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0, 1),
                end: Offset.zero,
              ).animate(CurvedAnimation(
                  parent: animation, curve: Curves.easeOutCubic)),
              child: child,
            ),
          ),
        );
      },
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 0, 12, 8),
        child: GlassContainer(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          borderRadius: 20,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Hero(
                    tag: 'album_art',
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        width: 44,
                        height: 44,
                        color: accent.withOpacity(0.15),
                        child: Icon(Icons.music_note, color: accent),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          song.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                        Text(
                          song.artist,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: Icon(
                      player.isPlaying
                          ? Icons.pause_circle_filled
                          : Icons.play_circle_filled,
                      color: accent,
                      size: 34,
                    ),
                    onPressed: player.playPause,
                  ),
                  IconButton(
                    icon: Icon(Icons.skip_next, color: accent),
                    onPressed: player.next,
                  ),
                ],
              ),
              const SizedBox(height: 4),
              StreamBuilder<Duration>(
                stream: player.positionStream,
                builder: (context, snapshot) {
                  final pos = snapshot.data ?? Duration.zero;
                  final total = song.duration.inMilliseconds == 0
                      ? 1
                      : song.duration.inMilliseconds;
                  final progress = (pos.inMilliseconds / total).clamp(0.0, 1.0);
                  return ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: progress,
                      minHeight: 3,
                      backgroundColor: accent.withOpacity(0.15),
                      valueColor: AlwaysStoppedAnimation(accent),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
