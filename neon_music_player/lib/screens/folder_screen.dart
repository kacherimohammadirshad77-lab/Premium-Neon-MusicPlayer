import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/music_library_provider.dart';
import 'song_list_screen.dart';

/// Browse music grouped by the folder it lives in on disk.
class FolderScreen extends StatelessWidget {
  const FolderScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final library = context.watch<MusicLibraryProvider>();
    final folders = library.folders;
    final keys = folders.keys.toList()..sort();

    return Scaffold(
      appBar: AppBar(title: const Text('Folders')),
      body: ListView.builder(
        itemCount: keys.length,
        itemBuilder: (context, index) {
          final folderPath = keys[index];
          final songs = folders[folderPath]!;
          final folderName = folderPath.split('/').last;
          return ListTile(
            leading: const Icon(Icons.folder),
            title: Text(folderName),
            subtitle: Text('${songs.length} songs'),
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => SongListScreen(title: folderName, songs: songs),
              ),
            ),
          );
        },
      ),
    );
  }
}
