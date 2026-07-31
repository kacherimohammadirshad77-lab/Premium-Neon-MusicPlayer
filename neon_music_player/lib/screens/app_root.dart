import 'package:flutter/material.dart';
import '../widgets/mini_player.dart';
import 'home_screen.dart';
import 'playlist_list_screen.dart';
import 'search_screen.dart';
import 'settings_screen.dart';

/// Hosts bottom navigation (Home / Playlists / Search / Settings) plus the
/// sticky mini player above it, per the "Bottom Mini Player" spec.
class AppRoot extends StatefulWidget {
  const AppRoot({super.key});

  @override
  State<AppRoot> createState() => _AppRootState();
}

class _AppRootState extends State<AppRoot> {
  int _index = 0;

  static const _screens = [
    HomeScreen(),
    PlaylistListScreen(),
    SearchScreen(),
    SettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _index, children: _screens),
      bottomNavigationBar: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const MiniPlayer(),
          NavigationBar(
            selectedIndex: _index,
            onDestinationSelected: (i) => setState(() => _index = i),
            destinations: const [
              NavigationDestination(icon: Icon(Icons.home), label: 'Home'),
              NavigationDestination(
                  icon: Icon(Icons.playlist_play), label: 'Playlists'),
              NavigationDestination(icon: Icon(Icons.search), label: 'Search'),
              NavigationDestination(
                  icon: Icon(Icons.settings), label: 'Settings'),
            ],
          ),
        ],
      ),
    );
  }
}
