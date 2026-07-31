import 'package:on_audio_query/on_audio_query.dart';
import 'package:permission_handler/permission_handler.dart';
import '../models/song_model.dart';

/// Wraps on_audio_query to scan the device for local audio files and expose
/// them as app-level [Song] objects. Handles the storage/media permission
/// dance for Android 8 through Android 14+.
class LibraryService {
  final OnAudioQuery _query = OnAudioQuery();

  static const _supportedExtensions = [
    'mp3',
    'wav',
    'aac',
    'flac',
    'm4a',
    'ogg',
  ];

  /// Requests whichever permission is appropriate for the running Android
  /// version. On Android 13+ this is READ_MEDIA_AUDIO; on older versions it
  /// falls back to storage permission, which on_audio_query also requests
  /// internally via [OnAudioQuery.permissionsStatus].
  Future<bool> requestPermission() async {
    final granted = await _query.permissionsStatus();
    if (granted) return true;
    return _query.permissionsRequest();
  }

  Future<bool> hasPermission() => _query.permissionsStatus();

  /// Scans the whole device and returns every song with a supported
  /// extension, mapped to the app's [Song] model.
  Future<List<Song>> scanAllSongs() async {
    final ok = await requestPermission();
    if (!ok) return [];

    final models = await _query.querySongs(
      sortType: SongSortType.TITLE,
      orderType: OrderType.ASC_OR_SMALLER,
      uriType: UriType.EXTERNAL,
      ignoreCase: true,
    );

    return models
        .where((m) => _supportedExtensions.contains(
              m.fileExtension.toLowerCase(),
            ))
        .map(Song.fromAudioQuery)
        .toList();
  }

  Future<List<AlbumModel>> queryAlbums() => _query.queryAlbums();

  Future<List<ArtistModel>> queryArtists() => _query.queryArtists();

  Future<List<GenreModel>> queryGenres() => _query.queryGenres();

  /// Groups already-scanned songs by folder path, for the Folder view.
  Map<String, List<Song>> groupByFolder(List<Song> songs) {
    final map = <String, List<Song>>{};
    for (final s in songs) {
      final folder = s.folderPath ?? 'Unknown';
      map.putIfAbsent(folder, () => []).add(s);
    }
    return map;
  }

  OnAudioQuery get rawQuery => _query;
}
