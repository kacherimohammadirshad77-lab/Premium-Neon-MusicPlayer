import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/playlist_provider.dart';
import 'playlist_detail_screen.dart';

/// Lists every user playlist, newest first, with create/rename/delete.
class PlaylistListScreen extends StatelessWidget {
  const PlaylistListScreen({super.key});

  Future<void> _createPlaylistDialog(BuildContext context) async {
    final controller = TextEditingController();
    final name = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('New Playlist'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(hintText: 'Playlist name'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(controller.text),
            child: const Text('Create'),
          ),
        ],
      ),
    );
    if (name != null && name.trim().isNotEmpty) {
      // ignore: use_build_context_synchronously
      await context.read<PlaylistProvider>().create(name.trim());
    }
  }

  @override
  Widget build(BuildContext context) {
    final playlistProvider = context.watch<PlaylistProvider>();
    final playlists = playlistProvider.playlists;

    return Scaffold(
      appBar: AppBar(title: const Text('Playlists')),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _createPlaylistDialog(context),
        child: const Icon(Icons.add),
      ),
      body: playlists.isEmpty
          ? const Center(child: Text('No playlists yet — tap + to create one'))
          : ListView.builder(
              itemCount: playlists.length,
              itemBuilder: (context, index) {
                final playlist = playlists[index];
                return ListTile(
                  leading: const Icon(Icons.queue_music),
                  title: Text(playlist.name),
                  subtitle: Text('${playlist.songIds.length} songs'),
                  trailing: PopupMenuButton<String>(
                    onSelected: (value) async {
                      if (value == 'rename') {
                        final controller =
                            TextEditingController(text: playlist.name);
                        final newName = await showDialog<String>(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: const Text('Rename Playlist'),
                            content: TextField(controller: controller),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.of(context).pop(),
                                child: const Text('Cancel'),
                              ),
                              FilledButton(
                                onPressed: () => Navigator.of(context)
                                    .pop(controller.text),
                                child: const Text('Save'),
                              ),
                            ],
                          ),
                        );
                        if (newName != null && newName.trim().isNotEmpty) {
                          // ignore: use_build_context_synchronously
                          await context
                              .read<PlaylistProvider>()
                              .rename(playlist.id, newName.trim());
                        }
                      } else if (value == 'delete') {
                        await context
                            .read<PlaylistProvider>()
                            .delete(playlist.id);
                      }
                    },
                    itemBuilder: (context) => const [
                      PopupMenuItem(value: 'rename', child: Text('Rename')),
                      PopupMenuItem(value: 'delete', child: Text('Delete')),
                    ],
                  ),
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => PlaylistDetailScreen(playlistId: playlist.id),
                    ),
                  ),
                );
              },
            ),
    );
  }
}
