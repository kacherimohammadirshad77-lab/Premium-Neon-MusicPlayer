import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../data/services/player_service.dart';
import '../providers/favorites_provider.dart';
import '../providers/player_provider.dart';

/// The premium fullscreen "Now Playing" experience: large rotating album
/// art, a blurred/glowing background, animated progress, and full transport
/// controls (shuffle, previous, play/pause, next, repeat, favourite).
class FullPlayerScreen extends StatefulWidget {
  const FullPlayerScreen({super.key});

  @override
  State<FullPlayerScreen> createState() => _FullPlayerScreenState();
}

class _FullPlayerScreenState extends State<FullPlayerScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _rotationController = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 18),
  )..repeat();

  @override
  void dispose() {
    _rotationController.dispose();
    super.dispose();
  }

  String _formatDuration(Duration d) {
    String two(int n) => n.toString().padLeft(2, '0');
    final minutes = two(d.inMinutes.remainder(60));
    final seconds = two(d.inSeconds.remainder(60));
    return '$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    final player = context.watch<PlayerProvider>();
    final favorites = context.watch<FavoritesProvider>();
    final song = player.currentSong;
    final accent = Theme.of(context).colorScheme.primary;

    if (song == null) {
      return const Scaffold(body: Center(child: Text('Nothing playing')));
    }

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.keyboard_arrow_down, size: 32),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text('Now Playing'),
        actions: [
          IconButton(
            icon: const Icon(Icons.playlist_add),
            onPressed: () {}, // Hook up to a playlist picker sheet.
          ),
        ],
      ),
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Blurred album-art backdrop for the "premium" glow effect.
          Container(color: Theme.of(context).scaffoldBackgroundColor),
          Positioned.fill(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 60, sigmaY: 60),
              child: Container(
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    colors: [
                      accent.withOpacity(0.25),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 28),
              child: Column(
                children: [
                  const SizedBox(height: 90),
                  Expanded(
                    flex: 5,
                    child: Center(
                      child: RotationTransition(
                        turns: _rotationController,
                        child: Hero(
                          tag: 'album_art',
                          child: Container(
                            width: 260,
                            height: 260,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: accent.withOpacity(0.15),
                              boxShadow: [
                                BoxShadow(
                                  color: accent.withOpacity(0.5),
                                  blurRadius: 60,
                                  spreadRadius: 4,
                                ),
                              ],
                            ),
                            child: Icon(Icons.music_note,
                                size: 96, color: accent),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    song.title,
                    textAlign: TextAlign.center,
                    style: Theme.of(context)
                        .textTheme
                        .headlineSmall
                        ?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    song.artist,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: Theme.of(context)
                              .colorScheme
                              .onSurface
                              .withOpacity(0.7),
                        ),
                  ),
                  const SizedBox(height: 20),
                  StreamBuilder<Duration>(
                    stream: player.positionStream,
                    builder: (context, snapshot) {
                      final pos = snapshot.data ?? Duration.zero;
                      final total = song.duration;
                      final maxMs =
                          total.inMilliseconds == 0 ? 1 : total.inMilliseconds;
                      return Column(
                        children: [
                          SliderTheme(
                            data: SliderTheme.of(context).copyWith(
                              trackHeight: 4,
                              thumbShape: const RoundSliderThumbShape(
                                  enabledThumbRadius: 6),
                            ),
                            child: Slider(
                              value: pos.inMilliseconds
                                  .clamp(0, maxMs)
                                  .toDouble(),
                              max: maxMs.toDouble(),
                              onChanged: (value) {
                                player.seek(
                                    Duration(milliseconds: value.toInt()));
                              },
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 4),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(_formatDuration(pos),
                                    style: Theme.of(context).textTheme.bodySmall),
                                Text(_formatDuration(total - pos),
                                    style: Theme.of(context).textTheme.bodySmall),
                              ],
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        icon: Icon(Icons.shuffle,
                            color: player.shuffleEnabled
                                ? accent
                                : accent.withOpacity(0.4)),
                        onPressed: player.toggleShuffle,
                      ),
                      IconButton(
                        icon: const Icon(Icons.skip_previous, size: 34),
                        onPressed: player.previous,
                      ),
                      Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: accent,
                          boxShadow: [
                            BoxShadow(
                                color: accent.withOpacity(0.6),
                                blurRadius: 24,
                                spreadRadius: 2),
                          ],
                        ),
                        child: IconButton(
                          iconSize: 40,
                          icon: Icon(
                            player.isPlaying
                                ? Icons.pause
                                : Icons.play_arrow,
                            color: Colors.black,
                          ),
                          onPressed: player.playPause,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.skip_next, size: 34),
                        onPressed: player.next,
                      ),
                      IconButton(
                        icon: Icon(
                          switch (player.repeatMode) {
                            RepeatMode.off => Icons.repeat,
                            RepeatMode.all => Icons.repeat,
                            RepeatMode.one => Icons.repeat_one,
                          },
                          color: player.repeatMode == RepeatMode.off
                              ? accent.withOpacity(0.4)
                              : accent,
                        ),
                        onPressed: player.cycleRepeatMode,
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      IconButton(
                        icon: Icon(
                          favorites.isFavorite(song.id)
                              ? Icons.favorite
                              : Icons.favorite_border,
                          color: favorites.isFavorite(song.id)
                              ? accent
                              : null,
                        ),
                        onPressed: () => favorites.toggle(song.id),
                      ),
                      IconButton(
                        icon: const Icon(Icons.queue_music),
                        onPressed: () {}, // Opens the Now Playing queue sheet.
                      ),
                      IconButton(
                        icon: const Icon(Icons.lyrics_outlined),
                        onPressed: () {}, // Reserved for future lyrics support.
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
