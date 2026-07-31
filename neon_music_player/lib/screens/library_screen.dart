import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/music_library_provider.dart';
import 'song_list_screen.dart';

class LibraryScreen extends StatelessWidget {
  const LibraryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final library = context.watch<MusicLibraryProvider>();
    return SongListScreen(title: 'Library', songs: library.songs);
  }
}
