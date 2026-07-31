import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../data/models/song_model.dart';
import '../providers/music_library_provider.dart';
import '../providers/playlist_provider.dart';
import 'song_list_screen.dart';

/// Shows the songs inside one playlist, with drag-to-reorder support.
class PlaylistDetailScreen extends StatelessWidget {
  final String playlistId;
  const PlaylistDetailScreen({super.key, required this.playlistId});

  @override
  Widget build(BuildContext context) {
    final playlistProvider = context.watch<PlaylistProvider>();
    final library = context.watch<MusicLibraryProvider>();
    final playlist =
        playlistProvider.playlists.firstWhere((p) => p.id == playlistId);
    final songs = playlist.songIds
        .map((id) => library.byId(id))
        .whereType<Song>()
        .toList();

    return Scaffold(
      appBar: AppBar(title: Text(playlist.name)),
      body: ReorderableListView.builder(
        itemCount: songs.length,
        onReorder: (oldIndex, newIndex) {
          playlistProvider.reorderSongs(playlistId, oldIndex, newIndex);
        },
        itemBuilder: (context, index) {
          final song = songs[index];
          return ListTile(
            key: ValueKey(song.id),
            leading: const Icon(Icons.drag_handle),
            title: Text(song.title),
            subtitle: Text(song.artist),
            trailing: IconButton(
              icon: const Icon(Icons.remove_circle_outline),
              onPressed: () =>
                  playlistProvider.removeSong(playlistId, song.id),
            ),
          );
        },
      ),
    );
  }
}
