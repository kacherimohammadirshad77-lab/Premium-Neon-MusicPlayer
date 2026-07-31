import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../data/models/song_model.dart';
import '../providers/favorites_provider.dart';
import '../providers/player_provider.dart';
import '../providers/playlist_provider.dart';

/// Generic reusable song list screen used by Library, Favourites, Recently
/// Played/Added, Most Played, Folder contents, Album/Artist detail, and
/// Playlist detail. Tapping a row plays the whole list starting there.
class SongListScreen extends StatelessWidget {
  final String title;
  final List<Song> songs;
  final String? playlistId; // when shown from inside a playlist

  const SongListScreen({
    super.key,
    required this.title,
    required this.songs,
    this.playlistId,
  });

  String _formatDuration(Duration d) {
    final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  @override
  Widget build(BuildContext context) {
    final favorites = context.watch<FavoritesProvider>();
    final player = context.read<PlayerProvider>();
    final playlistProvider = context.read<PlaylistProvider>();
    final accent = Theme.of(context).colorScheme.primary;

    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: songs.isEmpty
          ? const Center(child: Text('No songs here yet'))
          : ListView.builder(
              itemCount: songs.length,
              itemBuilder: (context, index) {
                final song = songs[index];
                final isFav = favorites.isFavorite(song.id);
                return ListTile(
                  leading: CircleAvatar(
                    backgroundColor: accent.withOpacity(0.15),
                    child: Icon(Icons.music_note, color: accent),
                  ),
                  title: Text(song.title,
                      maxLines: 1, overflow: TextOverflow.ellipsis),
                  subtitle: Text('${song.artist} • ${_formatDuration(song.duration)}',
                      maxLines: 1, overflow: TextOverflow.ellipsis),
                  trailing: PopupMenuButton<String>(
                    onSelected: (value) async {
                      switch (value) {
                        case 'favorite':
                          favorites.toggle(song.id);
                          break;
                        case 'remove_from_playlist':
                          if (playlistId != null) {
                            await playlistProvider.removeSong(
                                playlistId!, song.id);
                          }
                          break;
                        case 'add_to_playlist':
                          _showAddToPlaylistSheet(context, song.id);
                          break;
                      }
                    },
                    itemBuilder: (context) => [
                      PopupMenuItem(
                        value: 'favorite',
                        child: Text(isFav
                            ? 'Remove from Favourites'
                            : 'Add to Favourites'),
                      ),
                      const PopupMenuItem(
                        value: 'add_to_playlist',
                        child: Text('Add to Playlist'),
                      ),
                      if (playlistId != null)
                        const PopupMenuItem(
                          value: 'remove_from_playlist',
                          child: Text('Remove from this Playlist'),
                        ),
                    ],
                  ),
                  onTap: () => player.playQueue(songs, startIndex: index),
                );
              },
            ),
    );
  }

  void _showAddToPlaylistSheet(BuildContext context, int songId) {
    final playlistProvider = context.read<PlaylistProvider>();
    showModalBottomSheet(
      context: context,
      builder: (context) {
        final playlists = playlistProvider.playlists;
        return SafeArea(
          child: ListView(
            shrinkWrap: true,
            children: [
              for (final p in playlists)
                ListTile(
                  leading: const Icon(Icons.playlist_play),
                  title: Text(p.name),
                  onTap: () {
                    playlistProvider.addSong(p.id, songId);
                    Navigator.of(context).pop();
                  },
                ),
              ListTile(
                leading: const Icon(Icons.add),
                title: const Text('New Playlist'),
                onTap: () async {
                  Navigator.of(context).pop();
                  final controller = TextEditingController();
                  final name = await showDialog<String>(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text('New Playlist'),
                      content: TextField(
                        controller: controller,
                        decoration:
                            const InputDecoration(hintText: 'Playlist name'),
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(),
                          child: const Text('Cancel'),
                        ),
                        FilledButton(
                          onPressed: () =>
                              Navigator.of(context).pop(controller.text),
                          child: const Text('Create'),
                        ),
                      ],
                    ),
                  );
                  if (name != null && name.trim().isNotEmpty) {
                    final playlist = await playlistProvider.create(name.trim());
                    await playlistProvider.addSong(playlist.id, songId);
                  }
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
