import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/theme/app_theme.dart';
import '../providers/player_provider.dart';
import '../providers/playlist_provider.dart';
import '../providers/theme_provider.dart';
import 'equalizer_screen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();
    final player = context.watch<PlayerProvider>();
    final playlistProvider = context.read<PlaylistProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        children: [
          const _SectionHeader('Appearance'),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                for (final theme in AppThemes.all)
                  _ThemeSwatch(
                    theme: theme,
                    selected: themeProvider.theme.id == theme.id,
                    onTap: () => themeProvider.setTheme(theme),
                  ),
              ],
            ),
          ),
          SwitchListTile(
            title: const Text('AMOLED Mode'),
            subtitle: const Text('Pure black background to save battery on OLED screens'),
            value: themeProvider.amoledMode,
            onChanged: themeProvider.setAmoledMode,
          ),
          SwitchListTile(
            title: const Text('Animations'),
            subtitle: const Text('Page transitions, ripples, and glow effects'),
            value: themeProvider.animationsEnabled,
            onChanged: themeProvider.setAnimationsEnabled,
          ),
          ListTile(
            title: const Text('Album Art Quality'),
            subtitle: Text(themeProvider.albumArtQuality),
            trailing: DropdownButton<String>(
              value: themeProvider.albumArtQuality,
              items: const [
                DropdownMenuItem(value: 'low', child: Text('Low')),
                DropdownMenuItem(value: 'medium', child: Text('Medium')),
                DropdownMenuItem(value: 'high', child: Text('High')),
              ],
              onChanged: (value) {
                if (value != null) themeProvider.setAlbumArtQuality(value);
              },
            ),
          ),
          const Divider(),
          const _SectionHeader('Playback'),
          ListTile(
            title: const Text('Playback Speed'),
            subtitle: Slider(
              value: player.speed,
              min: 0.5,
              max: 2.0,
              divisions: 6,
              label: '${player.speed.toStringAsFixed(2)}x',
              onChanged: player.setSpeed,
            ),
          ),
          ListTile(
            title: const Text('Sleep Timer'),
            subtitle: const Text('Pause playback automatically'),
            trailing: PopupMenuButton<int>(
              onSelected: (minutes) =>
                  player.setSleepTimer(Duration(minutes: minutes)),
              itemBuilder: (context) => const [
                PopupMenuItem(value: 10, child: Text('10 minutes')),
                PopupMenuItem(value: 20, child: Text('20 minutes')),
                PopupMenuItem(value: 30, child: Text('30 minutes')),
                PopupMenuItem(value: 60, child: Text('60 minutes')),
              ],
              child: const Icon(Icons.timer_outlined),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.equalizer),
            title: const Text('Equalizer'),
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const EqualizerScreen()),
            ),
          ),
          const Divider(),
          const _SectionHeader('Backup'),
          ListTile(
            leading: const Icon(Icons.backup_outlined),
            title: const Text('Backup Playlists'),
            subtitle: const Text('Export all playlists as a JSON file'),
            onTap: () {
              final json = playlistProvider.exportBackup();
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Playlist Backup'),
                  content: SingleChildScrollView(child: Text(json)),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('Close'),
                    ),
                  ],
                ),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.restore),
            title: const Text('Restore Playlists'),
            subtitle: const Text('Paste a previously exported backup'),
            onTap: () async {
              final controller = TextEditingController();
              final json = await showDialog<String>(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Restore Backup'),
                  content: TextField(
                    controller: controller,
                    maxLines: 6,
                    decoration:
                        const InputDecoration(hintText: 'Paste backup JSON here'),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('Cancel'),
                    ),
                    FilledButton(
                      onPressed: () => Navigator.of(context).pop(controller.text),
                      child: const Text('Restore'),
                    ),
                  ],
                ),
              );
              if (json != null && json.trim().isNotEmpty) {
                await playlistProvider.restoreBackup(json);
              }
            },
          ),
          const Divider(),
          const _SectionHeader('About'),
          const ListTile(
            leading: Icon(Icons.info_outline),
            title: Text('About Neon Music'),
            subtitle: Text('Version 1.0.0 — an offline, ad-free music player'),
          ),
          const ListTile(
            leading: Icon(Icons.privacy_tip_outlined),
            title: Text('Privacy Policy'),
            subtitle: Text(
              'Neon Music works entirely offline. It never uploads your '
              'library, playlists, or listening history anywhere.',
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader(this.title);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
      child: Text(
        title.toUpperCase(),
        style: Theme.of(context).textTheme.labelLarge?.copyWith(
              color: Theme.of(context).colorScheme.primary,
              letterSpacing: 1.1,
            ),
      ),
    );
  }
}

class _ThemeSwatch extends StatelessWidget {
  final NeonTheme theme;
  final bool selected;
  final VoidCallback onTap;

  const _ThemeSwatch({
    required this.theme,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 78,
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: theme.background,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: selected ? theme.primary : theme.primary.withOpacity(0.2),
            width: selected ? 2 : 1,
          ),
          boxShadow: selected
              ? [BoxShadow(color: theme.primary.withOpacity(0.6), blurRadius: 12)]
              : null,
        ),
        child: Column(
          children: [
            Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(shape: BoxShape.circle, color: theme.primary),
            ),
            const SizedBox(height: 6),
            Text(
              theme.name,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 10, color: theme.onSurface),
            ),
          ],
        ),
      ),
    );
  }
}
