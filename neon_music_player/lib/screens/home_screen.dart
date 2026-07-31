import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../data/models/song_model.dart';
import '../providers/favorites_provider.dart';
import '../providers/history_provider.dart';
import '../providers/music_library_provider.dart';
import '../providers/playlist_provider.dart';
import '../widgets/dashboard_card.dart';
import 'favorites_screen.dart';
import 'folder_screen.dart';
import 'library_screen.dart';
import 'playlist_list_screen.dart';
import 'search_screen.dart';
import 'song_list_screen.dart';

/// The Home dashboard: a grid of gradient glass cards (Library, Favourite,
/// Recent Play, Recently Added, Most Played, Folder, Artists, Albums,
/// Genres, Playlist).
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<MusicLibraryProvider>().scan();
    });
  }

  @override
  Widget build(BuildContext context) {
    final library = context.watch<MusicLibraryProvider>();
    final favorites = context.watch<FavoritesProvider>();
    final history = context.watch<HistoryProvider>();
    final playlists = context.watch<PlaylistProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Neon Music',
            style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const SearchScreen()),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => library.refresh(),
          ),
        ],
      ),
      body: library.isScanning
          ? const Center(child: CircularProgressIndicator())
          : library.permissionDenied
              ? _PermissionDeniedView(onRetry: library.scan)
              : RefreshIndicator(
                  onRefresh: library.refresh,
                  child: GridView.count(
                    padding: const EdgeInsets.all(16),
                    crossAxisCount: 2,
                    mainAxisSpacing: 14,
                    crossAxisSpacing: 14,
                    childAspectRatio: 1.25,
                    children: [
                      DashboardCard(
                        icon: Icons.library_music,
                        title: 'Library',
                        count: library.songCount,
                        onTap: () => Navigator.of(context).push(
                          MaterialPageRoute(
                              builder: (_) => const LibraryScreen()),
                        ),
                      ),
                      DashboardCard(
                        icon: Icons.favorite,
                        title: 'Favourite',
                        count: favorites.favoriteIds.length,
                        onTap: () => Navigator.of(context).push(
                          MaterialPageRoute(
                              builder: (_) => const FavoritesScreen()),
                        ),
                      ),
                      DashboardCard(
                        icon: Icons.access_time,
                        title: 'Recent Play',
                        count: history.recentlyPlayedIds.length,
                        onTap: () => Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => SongListScreen(
                              title: 'Recently Played',
                              songs: history.recentlyPlayedIds
                                  .map((id) => library.byId(id))
                                  .whereType<Song>()
                                  .toList(),
                            ),
                          ),
                        ),
                      ),
                      DashboardCard(
                        icon: Icons.add_circle,
                        title: 'Recently Added',
                        count: library.recentlyAdded.length,
                        onTap: () => Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => SongListScreen(
                              title: 'Recently Added',
                              songs: library.recentlyAdded,
                            ),
                          ),
                        ),
                      ),
                      DashboardCard(
                        icon: Icons.whatshot,
                        title: 'Most Played',
                        count: history.mostPlayedIds.length,
                        onTap: () => Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => SongListScreen(
                              title: 'Most Played',
                              songs: history.mostPlayedIds
                                  .map((id) => library.byId(id))
                                  .whereType<Song>()
                                  .toList(),
                            ),
                          ),
                        ),
                      ),
                      DashboardCard(
                        icon: Icons.folder,
                        title: 'Folder',
                        count: library.folders.length,
                        onTap: () => Navigator.of(context).push(
                          MaterialPageRoute(
                              builder: (_) => const FolderScreen()),
                        ),
                      ),
                      DashboardCard(
                        icon: Icons.person,
                        title: 'Artists',
                        count: library.byArtist.length,
                        onTap: () => Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => _GroupedListRoute(
                              title: 'Artists',
                              groups: library.byArtist,
                            ),
                          ),
                        ),
                      ),
                      DashboardCard(
                        icon: Icons.album,
                        title: 'Albums',
                        count: library.byAlbum.length,
                        onTap: () => Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => _GroupedListRoute(
                              title: 'Albums',
                              groups: library.byAlbum,
                            ),
                          ),
                        ),
                      ),
                      DashboardCard(
                        icon: Icons.headphones,
                        title: 'Genres',
                        count: 0,
                        onTap: () {},
                      ),
                      DashboardCard(
                        icon: Icons.playlist_play,
                        title: 'Playlist',
                        count: playlists.playlists.length,
                        onTap: () => Navigator.of(context).push(
                          MaterialPageRoute(
                              builder: (_) => const PlaylistListScreen()),
                        ),
                      ),
                    ],
                  ),
                ),
    );
  }
}

class _GroupedListRoute extends StatelessWidget {
  final String title;
  final Map<String, dynamic> groups;

  const _GroupedListRoute({required this.title, required this.groups});

  @override
  Widget build(BuildContext context) {
    final keys = groups.keys.toList()..sort();
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: ListView.builder(
        itemCount: keys.length,
        itemBuilder: (context, index) {
          final key = keys[index];
          final songs = groups[key] as List;
          return ListTile(
            leading: const Icon(Icons.album),
            title: Text(key),
            subtitle: Text('${songs.length} songs'),
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => SongListScreen(
                  title: key,
                  songs: songs.cast<Song>(),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _PermissionDeniedView extends StatelessWidget {
  final VoidCallback onRetry;
  const _PermissionDeniedView({required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.lock_outline, size: 48),
            const SizedBox(height: 16),
            const Text(
              'Neon Music needs permission to read audio files on your '
              'device to build your library.',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            FilledButton(
              onPressed: onRetry,
              child: const Text('Grant Permission'),
            ),
          ],
        ),
      ),
    );
  }
}
