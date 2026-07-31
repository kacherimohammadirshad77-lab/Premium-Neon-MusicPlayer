import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/music_library_provider.dart';
import '../providers/player_provider.dart';

/// Real-time search across song title, artist, album, and folder.
class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final library = context.watch<MusicLibraryProvider>();
    final player = context.read<PlayerProvider>();
    final results = library.searchResults;

    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: _controller,
          autofocus: true,
          decoration: const InputDecoration(
            hintText: 'Search songs, artists, albums, folders...',
            border: InputBorder.none,
          ),
          onChanged: library.setSearchQuery,
        ),
      ),
      body: results.isEmpty
          ? Center(
              child: Text(
                _controller.text.isEmpty ? 'Start typing to search' : 'No results',
              ),
            )
          : ListView.builder(
              itemCount: results.length,
              itemBuilder: (context, index) {
                final song = results[index];
                return ListTile(
                  leading: const Icon(Icons.music_note),
                  title: Text(song.title),
                  subtitle: Text('${song.artist} • ${song.album}'),
                  onTap: () => player.playQueue(results, startIndex: index),
                );
              },
            ),
    );
  }
}
