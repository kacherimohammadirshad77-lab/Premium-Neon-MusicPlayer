import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../data/models/song_model.dart';
import '../providers/favorites_provider.dart';
import '../providers/music_library_provider.dart';
import 'song_list_screen.dart';

class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final favorites = context.watch<FavoritesProvider>();
    final library = context.watch<MusicLibraryProvider>();
    final songs = favorites.favoriteIds
        .map((id) => library.byId(id))
        .whereType<Song>()
        .toList();
    return SongListScreen(title: 'Favourites', songs: songs);
  }
}
