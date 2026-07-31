import 'package:flutter/material.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'package:provider/provider.dart';
import 'providers/equalizer_provider.dart';
import 'providers/favorites_provider.dart';
import 'providers/history_provider.dart';
import 'providers/music_library_provider.dart';
import 'providers/player_provider.dart';
import 'providers/playlist_provider.dart';
import 'providers/theme_provider.dart';
import 'screens/splash_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Enables background playback + lock-screen/notification controls.
  await JustAudioBackground.init(
    androidNotificationChannelId: 'com.neonmusic.player.channel.audio',
    androidNotificationChannelName: 'Neon Music playback',
    androidNotificationOngoing: true,
    androidStopForegroundOnPause: true,
  );

  runApp(const NeonMusicApp());
}

class NeonMusicApp extends StatelessWidget {
  const NeonMusicApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()..load()),
        ChangeNotifierProvider(create: (_) => MusicLibraryProvider()),
        ChangeNotifierProvider(create: (_) => FavoritesProvider()..load()),
        ChangeNotifierProvider(create: (_) => PlaylistProvider()..load()),
        ChangeNotifierProvider(create: (_) => HistoryProvider()..load()),
        ChangeNotifierProvider(create: (_) => EqualizerProvider()..load()),
        ChangeNotifierProxyProvider<HistoryProvider, PlayerProvider>(
          create: (context) => PlayerProvider(
            historyProvider: context.read<HistoryProvider>(),
          ),
          update: (context, history, previous) => previous!,
        ),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, _) {
          return MaterialApp(
            title: 'Neon Music',
            debugShowCheckedModeBanner: false,
            theme: themeProvider.themeData,
            home: const SplashScreen(),
          );
        },
      ),
    );
  }
}
